import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../../../core/widgets/somna_button.dart';
import '../../../core/widgets/star_rating_bar.dart';
import '../../../shared/models/sleep_session.dart';

/// Modal bottom sheet presented upon completing a live sleep session.
/// Collects optional subjective sleep quality rating (1-5) and user notes.
class WakeUpSheet extends StatefulWidget {
  final SleepSession session;
  final Duration duration;
  final Function(int? rating, String? notes) onSave;

  const WakeUpSheet({
    super.key,
    required this.session,
    required this.duration,
    required this.onSave,
  });

  /// Helper to display the sheet.
  static Future<void> show({
    required BuildContext context,
    required SleepSession session,
    required Duration duration,
    required Function(int? rating, String? notes) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WakeUpSheet(
        session: session,
        duration: duration,
        onSave: onSave,
      ),
    );
  }

  @override
  State<WakeUpSheet> createState() => _WakeUpSheetState();
}

class _WakeUpSheetState extends State<WakeUpSheet> {
  int? _rating;
  final TextEditingController _notesController = TextEditingController();

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

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Container(
          padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Handle Bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Icon & Morning Greeting
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wb_sunny_rounded,
                  color: AppColors.secondary, size: 32),
            ),
            const SizedBox(height: 14),
            Text(
              'Good Morning!',
              style: AppTypography.headlineMedium(isDark),
            ),
            const SizedBox(height: 6),
            Text(
              'Recorded ${DateTimeFormatter.formatDuration(widget.duration)} of sleep',
              style: AppTypography.bodyMedium(isDark).copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),

            // Quality Rating Question
            Text(
              'How did you sleep?',
              style: AppTypography.titleSmall(isDark),
            ),
            const SizedBox(height: 12),
            StarRatingBar(
              rating: _rating,
              onRatingChanged: (newRating) =>
                  setState(() => _rating = newRating),
            ),
            const SizedBox(height: 20),

            // Quick Sleep Factor Tags
            Text(
              'Influencing Factors',
              style: AppTypography.titleSmall(isDark),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickFactors.map((factor) {
                final isSelected = _notesController.text.contains(factor);
                return FilterChip(
                  label: Text(factor),
                  selected: isSelected,
                  onSelected: (_) => _toggleFactor(factor),
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primary
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
                  ),
                  backgroundColor: isDark
                      ? AppColors.darkSurface
                      : const Color(0xFFF1F5F9),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary
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
            const SizedBox(height: 16),

            // Notes Input
            TextField(
              controller: _notesController,
              maxLines: 3,
              maxLength: 300,
              decoration: const InputDecoration(
                hintText:
                    'Any notes? (e.g. read 20 mins, woke up once, cool room)',
                counterText: '',
              ),
            ),
            const SizedBox(height: 24),

            // Action Button
            SomnaButton(
              text: 'Save Sleep Session',
              width: double.infinity,
              onPressed: () {
                widget.onSave(
                  _rating,
                  _notesController.text.trim().isEmpty
                      ? null
                      : _notesController.text.trim(),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    ),
  ),
);
  }
}
