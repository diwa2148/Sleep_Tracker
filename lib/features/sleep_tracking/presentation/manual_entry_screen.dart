import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../../../core/utils/time_calculator.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/somna_button.dart';
import '../../../core/widgets/somna_card.dart';
import '../../../core/widgets/star_rating_bar.dart';
import '../../../shared/models/sleep_session.dart';
import '../../../shared/providers/settings_provider.dart';
import '../../../shared/providers/sleep_tracker_provider.dart';

/// Screen for creating a new manual sleep entry or editing an existing session.
class ManualEntryScreen extends StatefulWidget {
  final SleepSession? existingSession; // Non-null when editing

  const ManualEntryScreen({super.key, this.existingSession});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;

  int? _qualityRating;
  late final TextEditingController _notesController;
  String? _errorMessage;
  bool _isSaving = false;

  bool get isEditing => widget.existingSession != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingSession;

    if (existing != null) {
      final s = existing.startTimestamp.toLocal();
      final e = (existing.endTimestamp ?? DateTime.now()).toLocal();
      _startDate = DateTime(s.year, s.month, s.day);
      _startTime = TimeOfDay(hour: s.hour, minute: s.minute);
      _endDate = DateTime(e.year, e.month, e.day);
      _endTime = TimeOfDay(hour: e.hour, minute: e.minute);
      _qualityRating = existing.qualityRating;
      _notesController = TextEditingController(text: existing.notes ?? '');
    } else {
      // Default: Last night from 23:00 to 07:00 today
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      _startDate = yesterday;
      _startTime = const TimeOfDay(hour: 23, minute: 0);
      _endDate = today;
      _endTime = const TimeOfDay(hour: 7, minute: 0);
      _qualityRating = null;
      _notesController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  DateTime get _startDateTime => DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _startTime.hour,
        _startTime.minute,
      );

  DateTime get _endDateTime => DateTime(
        _endDate.year,
        _endDate.month,
        _endDate.day,
        _endTime.hour,
        _endTime.minute,
      );

  Duration get _currentDuration => _endDateTime.difference(_startDateTime);

  static const _quickFactors = [
    '☕ Caffeine',
    '🏃 Workout',
    '📱 Late Screen',
    '📖 Reading',
    '🧘 Meditated',
    '❄️ Cool Room',
    '🍷 Alcohol',
    '⚡ Stress',
  ];

  void _toggleFactor(String factor) {
    final currentText = _notesController.text;
    if (currentText.contains(factor)) {
      var updated = currentText.replaceAll(factor, '').trim();
      updated = updated.replaceAll(RegExp(r',\s*,'), ',');
      updated = updated.replaceAll(RegExp(r'^,\s*|,\s*$'), '');
      _notesController.text = updated;
    } else {
      if (currentText.trim().isEmpty) {
        _notesController.text = factor;
      } else {
        _notesController.text = '${currentText.trim()}, $factor';
      }
    }
    setState(() {});
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(picked)) {
          _endDate = picked;
        }
        _validate();
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
        _validate();
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _validate();
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
        _validate();
      });
    }
  }

  void _validate() {
    final error =
        TimeCalculator.validateSessionTimes(_startDateTime, _endDateTime);
    setState(() => _errorMessage = error);
  }

  Future<void> _save() async {
    _validate();
    if (_errorMessage != null) return;

    setState(() => _isSaving = true);
    final tracker = context.read<SleepTrackerProvider>();
    final settings = context.read<SettingsProvider>();

    String? error;
    if (isEditing) {
      error = await tracker.updateSession(
        id: widget.existingSession!.id,
        start: _startDateTime,
        end: _endDateTime,
        qualityRating: _qualityRating,
        notes: _notesController.text,
        preferences: settings.preferences,
      );
    } else {
      error = await tracker.addManualSession(
        start: _startDateTime,
        end: _endDateTime,
        qualityRating: _qualityRating,
        notes: _notesController.text,
        preferences: settings.preferences,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              isEditing ? 'Sleep session updated' : 'Sleep session recorded'),
          backgroundColor: AppColors.positiveDark,
        ),
      );
    }
  }

  Future<void> _delete() async {
    if (!isEditing) return;
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Sleep Record?',
      message:
          'Are you sure you want to permanently delete this sleep session? This cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      final tracker = context.read<SleepTrackerProvider>();
      final settings = context.read<SettingsProvider>();
      await tracker.deleteSession(
          widget.existingSession!.id, settings.preferences);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final duration = _currentDuration;
    final isValidDuration = duration.inMinutes > 0 && duration.inHours <= 24;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Sleep Session' : 'Record Sleep'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error),
              tooltip: 'Delete session',
              onPressed: _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Duration Preview Card
              SomnaCard(
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF171717), const Color(0xFF0F0F0F)]
                      : [const Color(0xFFF5F5F5), const Color(0xFFFFFFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Total Sleep Duration',
                        style: AppTypography.labelMedium(isDark),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isValidDuration
                            ? DateTimeFormatter.formatDuration(duration)
                            : '--',
                        style: AppTypography.displayMedium(isDark).copyWith(
                          color: isValidDuration
                              ? (isDark
                                  ? AppColors.primary
                                  : AppColors.primaryDark)
                              : AppColors.error,
                        ),
                      ),
                      if (_startDate.day != _endDate.day) ...[
                        const SizedBox(height: 6),
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
                            'Overnight Session',
                            style: AppTypography.labelSmall(isDark).copyWith(
                              color: isDark
                                  ? const Color(0xFFD4D4D4)
                                  : const Color(0xFF262626),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Bedtime Section
              Text('BEDTIME (SLEEP START)',
                  style: AppTypography.labelSmall(isDark)
                      .copyWith(letterSpacing: 1.1)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildPickerButton(
                      label: DateTimeFormatter.formatShortDate(_startDate),
                      icon: Icons.calendar_today_rounded,
                      isDark: isDark,
                      onTap: _pickStartDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _buildPickerButton(
                      label: _startTime.format(context),
                      icon: Icons.nightlight_round,
                      isDark: isDark,
                      onTap: _pickStartTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Wake Time Section
              Text('WAKE-UP TIME (SLEEP END)',
                  style: AppTypography.labelSmall(isDark)
                      .copyWith(letterSpacing: 1.1)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildPickerButton(
                      label: DateTimeFormatter.formatShortDate(_endDate),
                      icon: Icons.calendar_today_rounded,
                      isDark: isDark,
                      onTap: _pickEndDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _buildPickerButton(
                      label: _endTime.format(context),
                      icon: Icons.wb_sunny_rounded,
                      isDark: isDark,
                      onTap: _pickEndTime,
                    ),
                  ),
                ],
              ),

              // Error Message
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AppColors.error, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppTypography.bodySmall(isDark)
                              .copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 28),

              // Sleep Quality Rating
              Text('SLEEP QUALITY (OPTIONAL)',
                  style: AppTypography.labelSmall(isDark)
                      .copyWith(letterSpacing: 1.1)),
              const SizedBox(height: 12),
              SomnaCard(
                padding: const EdgeInsets.all(16),
                child: StarRatingBar(
                  rating: _qualityRating,
                  onRatingChanged: (val) =>
                      setState(() => _qualityRating = val),
                ),
              ),
              const SizedBox(height: 24),

              // Quick Factor Tags
              Text('QUICK SLEEP FACTORS',
                  style: AppTypography.labelSmall(isDark)
                      .copyWith(letterSpacing: 1.1)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickFactors.map((factor) {
                  final isSelected =
                      _notesController.text.contains(factor);
                  return FilterChip(
                    label: Text(factor),
                    selected: isSelected,
                    onSelected: (_) => _toggleFactor(factor),
                    selectedColor: isDark
                        ? const Color(0xFF262626)
                        : const Color(0xFFE5E5E5),
                    checkmarkColor: isDark ? Colors.white : Colors.black,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? (isDark ? Colors.white : Colors.black)
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                    ),
                    backgroundColor: isDark
                        ? AppColors.darkSurface
                        : const Color(0xFFF5F5F5),
                    side: BorderSide(
                      color: isSelected
                          ? (isDark ? Colors.white : Colors.black)
                          : (isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // Notes Field
              Text('NOTES & OBSERVATIONS',
                  style: AppTypography.labelSmall(isDark)
                      .copyWith(letterSpacing: 1.1)),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 3,
                maxLength: 300,
                decoration: const InputDecoration(
                  hintText:
                      'e.g. Exercised earlier, read before bed, quiet room...',
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SomnaButton(
                text: isEditing ? 'Update Session' : 'Save Session',
                width: double.infinity,
                isLoading: _isSaving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerButton({
    required String label,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return SomnaCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              size: 18,
              color: isDark ? AppColors.primary : AppColors.primaryDark),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: AppTypography.titleSmall(isDark),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
