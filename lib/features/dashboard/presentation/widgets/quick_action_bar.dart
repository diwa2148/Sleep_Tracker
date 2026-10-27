import 'package:flutter/material.dart';
import '../../../../core/widgets/somna_button.dart';

/// Quick action buttons at the bottom of the dashboard.
class QuickActionBar extends StatelessWidget {
  final bool isTracking;
  final VoidCallback onStartSleep;
  final VoidCallback onManualLog;

  const QuickActionBar({
    super.key,
    required this.isTracking,
    required this.onStartSleep,
    required this.onManualLog,
  });

  @override
  Widget build(BuildContext context) {
    if (isTracking) {
      return SomnaButton(
        text: 'Add Past Sleep Manually',
        icon: Icons.edit_calendar_rounded,
        type: SomnaButtonType.secondary,
        width: double.infinity,
        onPressed: onManualLog,
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SomnaButton(
            text: 'Start Sleep',
            icon: Icons.nightlight_round,
            type: SomnaButtonType.primary,
            onPressed: onStartSleep,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: SomnaButton(
            text: 'Log Past',
            icon: Icons.add_rounded,
            type: SomnaButtonType.secondary,
            onPressed: onManualLog,
          ),
        ),
      ],
    );
  }
}
