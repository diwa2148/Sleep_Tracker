import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../../../core/utils/time_calculator.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/somna_button.dart';
import '../../../core/widgets/somna_card.dart';
import '../../../core/widgets/star_rating_bar.dart';
import '../../../shared/models/sleep_factor.dart';
import '../../../shared/models/sleep_session.dart';
import '../../../shared/providers/settings_provider.dart';
import '../../../shared/providers/sleep_tracker_provider.dart';
import '../../sleep_tracking/presentation/manual_entry_screen.dart';

/// Modal bottom sheet presenting complete session details, in-place lifestyle factor tagger,
/// inline notes editor, hypnogram stages, and actions.
class SessionDetailSheet extends StatefulWidget {
  final SleepSession session;

  const SessionDetailSheet({super.key, required this.session});

  static Future<void> show(BuildContext context, SleepSession session) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SessionDetailSheet(session: session),
    );
  }

  @override
  State<SessionDetailSheet> createState() => _SessionDetailSheetState();
}

class _SessionDetailSheetState extends State<SessionDetailSheet> {
  late SleepSession _currentSession;
  late TextEditingController _notesController;
  bool _isEditingNotes = false;

  @override
  void initState() {
    super.initState();
    _currentSession = widget.session;
    _notesController = TextEditingController(
      text: _extractCustomNotes(widget.session.notes),
    );
  }

  @override
  void didUpdateWidget(SessionDetailSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session.id != widget.session.id ||
        oldWidget.session.updatedAt != widget.session.updatedAt) {
      _currentSession = widget.session;
      if (!_isEditingNotes) {
        _notesController.text = _extractCustomNotes(widget.session.notes);
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  /// Separates freeform notes from factor labels and names.
  String _extractCustomNotes(String? rawNotes) {
    if (rawNotes == null || rawNotes.isEmpty) return '';
    String text = rawNotes;
    for (final factor in SleepFactor.all) {
      text = text.replaceAll(factor.label, '');
      text = text.replaceAll(
        RegExp('\\b${RegExp.escape(factor.name)}\\b', caseSensitive: false),
        '',
      );
    }
    // Clean up commas, spaces, and repeated punctuation
    text = text.replaceAll(RegExp(r',\s*,'), ',');
    text = text.replaceAll(RegExp(r'^\s*,\s*|\s*,\s*$'), '');
    return text.trim();
  }

  /// Merges active factor tags with freeform observations into a canonical notes string.
  String _composeNotes({
    required Iterable<String> activeLabels,
    required String customNotes,
  }) {
    final parts = <String>[];
    if (activeLabels.isNotEmpty) {
      parts.addAll(activeLabels);
    }
    final cleanCustom = customNotes.trim();
    if (cleanCustom.isNotEmpty) {
      parts.add(cleanCustom);
    }
    return parts.join(', ');
  }

  void _triggerHaptic(SettingsProvider settings) {
    if (settings.preferences.hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  String _ratingLabel(int? rating) {
    switch (rating) {
      case 1:
        return 'Poor (1/5)';
      case 2:
        return 'Fair (2/5)';
      case 3:
        return 'Good (3/5)';
      case 4:
        return 'Great (4/5)';
      case 5:
        return 'Excellent (5/5)';
      default:
        return 'Tap stars to rate';
    }
  }

  Widget _buildRatingBadge(int? rating, bool isDark) {
    final label = _ratingLabel(rating);
    final isRated = rating != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isRated
            ? (isDark ? const Color(0xFF262626) : const Color(0xFFE5E5E5))
            : (isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF2F2F2)),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isRated
              ? (isDark ? const Color(0xFF444444) : const Color(0xFFCCCCCC))
              : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0)),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 11,
          fontWeight: isRated ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: 0.2,
          color: isRated
              ? (isDark ? Colors.white : Colors.black)
              : (isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight),
        ),
      ),
    );
  }

  Future<void> _pickTime({
    required bool isBedtime,
    required SleepTrackerProvider tracker,
    required SettingsProvider settings,
  }) async {
    _triggerHaptic(settings);
    final initialDt = isBedtime
        ? _currentSession.startTimestamp
        : (_currentSession.endTimestamp ?? DateTime.now());

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDt),
    );
    if (picked == null) return;

    DateTime newStart = _currentSession.startTimestamp;
    DateTime newEnd = _currentSession.endTimestamp ?? DateTime.now();

    if (isBedtime) {
      newStart = DateTime(
        initialDt.year,
        initialDt.month,
        initialDt.day,
        picked.hour,
        picked.minute,
      );
      if (newStart.isAfter(newEnd)) {
        newStart = newStart.subtract(const Duration(days: 1));
      }
    } else {
      newEnd = DateTime(
        initialDt.year,
        initialDt.month,
        initialDt.day,
        picked.hour,
        picked.minute,
      );
      if (newEnd.isBefore(newStart)) {
        newEnd = newEnd.add(const Duration(days: 1));
      }
    }

    final validation = TimeCalculator.validateSessionTimes(newStart, newEnd);
    if (validation != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validation),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final previousSession = _currentSession;
    _triggerHaptic(settings);
    final updated = _currentSession.copyWith(
      startTimestamp: newStart,
      endTimestamp: newEnd,
      updatedAt: DateTime.now(),
    );

    setState(() {
      _currentSession = updated;
    });

    final error = await tracker.updateSession(
      id: updated.id,
      start: newStart,
      end: newEnd,
      qualityRating: updated.qualityRating,
      notes: updated.notes,
      preferences: settings.preferences,
    );

    if (error != null && mounted) {
      setState(() {
        _currentSession = previousSession;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _toggleFactor(
    SleepFactor factor,
    SleepTrackerProvider tracker,
    SettingsProvider settings,
  ) async {
    final previousSession = _currentSession;
    _triggerHaptic(settings);

    // Determine current active tags
    final active = Set<String>.from(_currentSession.tags);
    if (active.contains(factor.label)) {
      active.remove(factor.label);
    } else {
      active.add(factor.label);
    }

    final customNotes = _extractCustomNotes(_currentSession.notes);
    final combinedNotes = _composeNotes(
      activeLabels: active,
      customNotes: customNotes,
    );

    final updated = _currentSession.copyWith(
      notes: combinedNotes.isEmpty ? null : combinedNotes,
      clearNotes: combinedNotes.isEmpty,
      updatedAt: DateTime.now(),
    );

    setState(() {
      _currentSession = updated;
    });

    final error = await tracker.updateSession(
      id: updated.id,
      start: updated.startTimestamp,
      end: updated.endTimestamp ?? DateTime.now(),
      qualityRating: updated.qualityRating,
      notes: updated.notes,
      preferences: settings.preferences,
    );

    if (error != null && mounted) {
      setState(() {
        _currentSession = previousSession;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _updateRating(
    int? newRating,
    SleepTrackerProvider tracker,
    SettingsProvider settings,
  ) async {
    final previousSession = _currentSession;
    _triggerHaptic(settings);

    final updated = _currentSession.copyWith(
      qualityRating: newRating,
      clearRating: newRating == null,
      updatedAt: DateTime.now(),
    );

    setState(() {
      _currentSession = updated;
    });

    final error = await tracker.updateSession(
      id: updated.id,
      start: updated.startTimestamp,
      end: updated.endTimestamp ?? DateTime.now(),
      qualityRating: updated.qualityRating,
      notes: updated.notes,
      preferences: settings.preferences,
    );

    if (error != null && mounted) {
      setState(() {
        _currentSession = previousSession;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveCustomNotes(
    SleepTrackerProvider tracker,
    SettingsProvider settings,
  ) async {
    final previousSession = _currentSession;
    _triggerHaptic(settings);
    final customNotes = _notesController.text.trim();
    final combinedNotes = _composeNotes(
      activeLabels: _currentSession.tags,
      customNotes: customNotes,
    );

    final updated = _currentSession.copyWith(
      notes: combinedNotes.isEmpty ? null : combinedNotes,
      clearNotes: combinedNotes.isEmpty,
      updatedAt: DateTime.now(),
    );

    setState(() {
      _currentSession = updated;
      _isEditingNotes = false;
    });

    final error = await tracker.updateSession(
      id: updated.id,
      start: updated.startTimestamp,
      end: updated.endTimestamp ?? DateTime.now(),
      qualityRating: updated.qualityRating,
      notes: updated.notes,
      preferences: settings.preferences,
    );

    if (error != null && mounted) {
      setState(() {
        _currentSession = previousSession;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tracker = context.read<SleepTrackerProvider>();
    final settings = context.read<SettingsProvider>();
    final maxHeight = MediaQuery.of(context).size.height * 0.90;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 680, maxHeight: maxHeight),
        child: Container(
          padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Relative Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateTimeFormatter.formatFullDate(
                                  _currentSession.startTimestamp),
                              style: AppTypography.titleLarge(isDark),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Recorded via ${_currentSession.source}',
                              style: AppTypography.bodySmall(isDark),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF262626)
                              : const Color(0xFFE5E5E5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _currentSession.formattedDuration(),
                          style: AppTypography.labelLarge(isDark).copyWith(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Bedtime and Wake-up Times Card (Interactive in-place)
                  SomnaCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: _buildTimeColumn(
                                'BEDTIME',
                                _currentSession.startTimestamp,
                                Icons.nightlight_round,
                                isDark,
                                onTap: () => _pickTime(
                                  isBedtime: true,
                                  tracker: tracker,
                                  settings: settings,
                                ),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 42,
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                            Expanded(
                              child: _buildTimeColumn(
                                'WAKE UP',
                                _currentSession.endTimestamp ?? DateTime.now(),
                                Icons.wb_sunny_rounded,
                                isDark,
                                onTap: () => _pickTime(
                                  isBedtime: false,
                                  tracker: tracker,
                                  settings: settings,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap times to adjust in-place',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 10,
                            color: isDark
                                ? const Color(0xFF666666)
                                : const Color(0xFFAAAAAA),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sleep Quality Rating (Interactive in-place with immediate descriptive badge)
                  SomnaCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sleep Quality',
                                style: AppTypography.titleSmall(isDark),
                              ),
                              const SizedBox(height: 6),
                              _buildRatingBadge(
                                  _currentSession.qualityRating, isDark),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        StarRatingBar(
                          rating: _currentSession.qualityRating,
                          readOnly: false,
                          starSize: 22,
                          onRatingChanged: (newRating) =>
                              _updateRating(newRating, tracker, settings),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sleep Architecture & Hypnogram Stages (Dynamically recalculates on rating change)
                  _buildSleepArchitecture(_currentSession, isDark),
                  const SizedBox(height: 16),

                  // Interactive In-Place Lifestyle Factors & Habits
                  _buildFactorChips(
                    isDark: isDark,
                    tracker: tracker,
                    settings: settings,
                  ),

                  // Inline Notes & Observations Editor
                  _buildNotesSection(
                    isDark: isDark,
                    tracker: tracker,
                    settings: settings,
                  ),

                  // Action Buttons: Edit Session and Delete
                  Row(
                    children: [
                      Expanded(
                        child: SomnaButton(
                          text: 'Edit Session',
                          icon: Icons.edit_rounded,
                          type: SomnaButtonType.secondary,
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ManualEntryScreen(
                                  existingSession: _currentSession,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SomnaButton(
                          text: 'Delete',
                          icon: Icons.delete_outline_rounded,
                          type: SomnaButtonType.destructive,
                          onPressed: () async {
                            final confirmed = await ConfirmDialog.show(
                              context: context,
                              title: 'Delete Session?',
                              message:
                                  'Are you sure you want to permanently delete this sleep session? This action cannot be undone.',
                              confirmText: 'Delete',
                              isDestructive: true,
                            );
                            if (confirmed && context.mounted) {
                              await tracker.deleteSession(
                                _currentSession.id,
                                settings.preferences,
                              );
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);
  }

  Widget _buildFactorChips({
    required bool isDark,
    required SleepTrackerProvider tracker,
    required SettingsProvider settings,
  }) {
    final activeTags = _currentSession.tags;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'LIFESTYLE FACTORS & HABITS',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: AppTypography.labelSmall(isDark).copyWith(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.primary : AppColors.primaryDark,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (activeTags.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF262626)
                      : const Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${activeTags.length} active',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Tap chips to tag or untag habits affecting this session',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 11,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SleepFactor.all.map((factor) {
            final isSelected = activeTags.contains(factor.label);
            return _buildFactorChip(
              factor: factor,
              isSelected: isSelected,
              isDark: isDark,
              onTap: () => _toggleFactor(factor, tracker, settings),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFactorChip({
    required SleepFactor factor,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final selectedBg = isDark ? Colors.white : Colors.black;
    final selectedFg = isDark ? Colors.black : Colors.white;
    final unselectedBg =
        isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F3F3);
    final unselectedBorder =
        isDark ? const Color(0xFF333333) : const Color(0xFFCCCCCC);
    final unselectedFg =
        isDark ? const Color(0xFFD4D4D4) : const Color(0xFF333333);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : unselectedBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? selectedBg : unselectedBorder,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                factor.emoji,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(width: 5),
              Text(
                factor.name,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? selectedFg : unselectedFg,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.check_rounded,
                  size: 13,
                  color: selectedFg,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesSection({
    required bool isDark,
    required SleepTrackerProvider tracker,
    required SettingsProvider settings,
  }) {
    final customNotes = _extractCustomNotes(_currentSession.notes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'NOTES & OBSERVATIONS',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: AppTypography.labelSmall(isDark).copyWith(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.primary : AppColors.primaryDark,
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                setState(() {
                  _isEditingNotes = !_isEditingNotes;
                  if (_isEditingNotes) {
                    _notesController.text = customNotes;
                  }
                });
              },
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isEditingNotes
                          ? Icons.close_rounded
                          : Icons.edit_note_rounded,
                      size: 16,
                      color: isDark ? AppColors.primary : AppColors.primaryDark,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isEditingNotes
                          ? 'Cancel'
                          : (customNotes.isEmpty ? 'Add Note' : 'Edit'),
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color:
                            isDark ? AppColors.primary : AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isEditingNotes)
          SomnaCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  autofocus: true,
                  style: AppTypography.bodyMedium(isDark),
                  decoration: InputDecoration(
                    hintText: 'Enter observations, dreams, awakenings...',
                    hintStyle: AppTypography.bodySmall(isDark),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isEditingNotes = false;
                        });
                      },
                      child: Text(
                        'Cancel',
                        style: AppTypography.labelMedium(isDark),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _saveCustomNotes(tracker, settings),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.white : Colors.black,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                      ),
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text(
                        'Save Note',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        else if (customNotes.isNotEmpty)
          InkWell(
            onTap: () {
              setState(() {
                _isEditingNotes = true;
                _notesController.text = customNotes;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: SomnaCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      customNotes,
                      style: AppTypography.bodyMedium(isDark),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: isDark
                        ? const Color(0xFF666666)
                        : const Color(0xFFAAAAAA),
                  ),
                ],
              ),
            ),
          )
        else
          InkWell(
            onTap: () {
              setState(() {
                _isEditingNotes = true;
                _notesController.text = '';
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF181818) : const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2E2E2E)
                      : const Color(0xFFE5E5E5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.add_comment_outlined,
                    size: 16,
                    color: isDark
                        ? const Color(0xFF888888)
                        : const Color(0xFF777777),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Add personal observation notes...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFF888888)
                            : const Color(0xFF777777),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTimeColumn(
    String label,
    DateTime dt,
    IconData icon,
    bool isDark, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 13, color: AppColors.primary),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSmall(isDark),
                  ),
                ),
                const SizedBox(width: 3),
                Icon(
                  Icons.edit_outlined,
                  size: 11,
                  color: isDark
                      ? const Color(0xFF666666)
                      : const Color(0xFFAAAAAA),
                ),
              ],
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                DateTimeFormatter.formatTime(dt),
                style: AppTypography.titleMedium(isDark).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepArchitecture(SleepSession session, bool isDark) {
    final totalMinutes = session.durationMinutes();
    if (totalMinutes <= 0) return const SizedBox.shrink();

    // Dynamically recalculate sleep architecture based on quality rating
    double deepPct;
    double remPct;
    double awakePct;
    double lightPct;

    switch (session.qualityRating) {
      case 1:
        deepPct = 0.12;
        remPct = 0.14;
        awakePct = 0.16;
        lightPct = 0.58;
        break;
      case 2:
        deepPct = 0.15;
        remPct = 0.17;
        awakePct = 0.12;
        lightPct = 0.56;
        break;
      case 3:
        deepPct = 0.18;
        remPct = 0.20;
        awakePct = 0.09;
        lightPct = 0.53;
        break;
      case 4:
        deepPct = 0.21;
        remPct = 0.23;
        awakePct = 0.07;
        lightPct = 0.49;
        break;
      case 5:
        deepPct = 0.25;
        remPct = 0.25;
        awakePct = 0.05;
        lightPct = 0.45;
        break;
      default:
        deepPct = 0.19;
        remPct = 0.21;
        awakePct = 0.08;
        lightPct = 0.52;
        break;
    }

    final deepMinutes = math.max(0, (totalMinutes * deepPct).round());
    final remMinutes = math.max(0, (totalMinutes * remPct).round());
    final awakeMinutes = math.max(0, (totalMinutes * awakePct).round());
    final lightMinutes = math.max(
      0,
      totalMinutes - deepMinutes - remMinutes - awakeMinutes,
    );

    String fmt(int mins) {
      if (mins <= 0) return '0m';
      final h = mins ~/ 60;
      final m = mins % 60;
      return h > 0 ? '${h}h ${m}m' : '${m}m';
    }

    final restorativePct = ((deepPct + remPct) * 100).round().clamp(0, 100);

    // Build architecture bar segments safely (only positive flex, avoids assertion crashes)
    final deepFlex = math.max(0, (deepPct * 1000).round());
    final remFlex = math.max(0, (remPct * 1000).round());
    final lightFlex = math.max(0, (lightPct * 1000).round());
    final awakeFlex = math.max(0, (awakePct * 1000).round());

    final rawSegments = [
      (
        flex: deepFlex,
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
        ),
        label: 'Deep Sleep',
        percent: '${(deepPct * 100).round()}%',
      ),
      (
        flex: remFlex,
        gradient: const LinearGradient(
          colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
        ),
        label: 'REM Sleep',
        percent: '${(remPct * 100).round()}%',
      ),
      (
        flex: lightFlex,
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
        ),
        label: 'Light Sleep',
        percent: '${(lightPct * 100).round()}%',
      ),
      (
        flex: awakeFlex,
        gradient: const LinearGradient(
          colors: [Color(0xFFE11D48), Color(0xFFFB7185)],
        ),
        label: 'Awake',
        percent: '${(awakePct * 100).round()}%',
      ),
    ];

    final activeSegments = rawSegments.where((s) => s.flex > 0).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'SLEEP ARCHITECTURE',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: AppTypography.labelSmall(isDark).copyWith(
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.primary : AppColors.primaryDark,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF262626)
                    : const Color(0xFFE5E5E5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF404040)
                      : const Color(0xFFCCCCCC),
                  width: 1,
                ),
              ),
              child: Text(
                '$restorativePct% Restorative',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 16,
            child: activeSegments.isEmpty
                ? Container(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFE2E8F0),
                  )
                : Row(
                    children: [
                      for (int i = 0; i < activeSegments.length; i++) ...[
                        if (i > 0) const SizedBox(width: 2),
                        Expanded(
                          flex: activeSegments[i].flex,
                          child: Tooltip(
                            message:
                                '${activeSegments[i].label}: ${activeSegments[i].percent}',
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: activeSegments[i].gradient,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 280;
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStagePill(
                        label: 'Deep Sleep',
                        duration: fmt(deepMinutes),
                        percent: '${(deepPct * 100).round()}%',
                        color: AppColors.deepSleep,
                        isDark: isDark,
                        isCompact: isNarrow,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStagePill(
                        label: 'REM Sleep',
                        duration: fmt(remMinutes),
                        percent: '${(remPct * 100).round()}%',
                        color: AppColors.remSleep,
                        isDark: isDark,
                        isCompact: isNarrow,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildStagePill(
                        label: 'Light Sleep',
                        duration: fmt(lightMinutes),
                        percent: '${(lightPct * 100).round()}%',
                        color: AppColors.lightSleep,
                        isDark: isDark,
                        isCompact: isNarrow,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStagePill(
                        label: 'Awake / Arousals',
                        duration: fmt(awakeMinutes),
                        percent: '${(awakePct * 100).round()}%',
                        color: AppColors.awake,
                        isDark: isDark,
                        isCompact: isNarrow,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStagePill({
    required String label,
    required String duration,
    required String percent,
    required Color color,
    required bool isDark,
    bool isCompact = false,
  }) {
    return Semantics(
      label: '$label: $duration, $percent',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 6 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: isCompact ? 4 : 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: isCompact ? 9 : 10,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '$duration ($percent)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: isCompact ? 10 : 11,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
