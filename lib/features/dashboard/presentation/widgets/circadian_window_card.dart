import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/somna_card.dart';
import '../../../../shared/providers/settings_provider.dart';
import '../../../chronotype/domain/models/chronotype.dart';
import '../../../chronotype/presentation/widgets/chronotype_assessment_modal.dart';

/// Visual 24-hour Circadian Rhythm timeline & Target Sleep Window widget.
class CircadianWindowCard extends StatelessWidget {
  final int bedtimeMinutes;
  final int wakeMinutes;
  final int goalMinutes;

  const CircadianWindowCard({
    super.key,
    required this.bedtimeMinutes,
    required this.wakeMinutes,
    required this.goalMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = Provider.of<SettingsProvider?>(context);
    final chronotypeKey = settings?.preferences.chronotype ?? 'bear';
    final chronotypeProfile = ChronotypeProfile.fromString(chronotypeKey);

    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    // Normalizing bedtime/wake to 24-hour scale [0.0, 1.0]
    final currentRatio = (currentMinutes / 1440.0).clamp(0.0, 1.0);

    final bedtimeHour = bedtimeMinutes ~/ 60;
    final bedtimeMin = bedtimeMinutes % 60;
    final wakeHour = wakeMinutes ~/ 60;
    final wakeMin = wakeMinutes % 60;

    final bedtimeStr =
        '${bedtimeHour % 12 == 0 ? 12 : bedtimeHour % 12}:${bedtimeMin.toString().padLeft(2, '0')} ${bedtimeHour >= 12 ? 'PM' : 'AM'}';
    final wakeStr =
        '${wakeHour % 12 == 0 ? 12 : wakeHour % 12}:${wakeMin.toString().padLeft(2, '0')} ${wakeHour >= 12 ? 'PM' : 'AM'}';

    return SomnaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF262626)
                            : const Color(0xFFE5E5E5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.timelapse_rounded,
                        size: 16,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Circadian Window',
                        style: AppTypography.titleMedium(isDark),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF262626)
                      : const Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF404040)
                        : const Color(0xFFCCCCCC),
                  ),
                ),
                child: Text(
                  '${goalMinutes ~/ 60}h Target Window',
                  style: AppTypography.labelSmall(isDark).copyWith(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Visual 24-hour Day/Night Gradient Track (Monochrome: Night=Black, Noon=Silver)
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Background 24h Bar (Midnight Black -> Midday Silver -> Midnight Black)
              Container(
                height: 18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF111111), // Night (00:00)
                      Color(0xFF666666), // Morning (06:00)
                      Color(0xFFE0E0E0), // Noon (12:00)
                      Color(0xFF666666), // Sunset (18:00)
                      Color(0xFF111111), // Night (24:00)
                    ],
                  ),
                ),
              ),

              // Highlighted Target Sleep Window Overlay
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Row(
                  children: [
                    // Morning sleep block (00:00 to wake)
                    Expanded(
                      flex: wakeMinutes,
                      child: Container(
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : Colors.black)
                              .withValues(alpha: 0.85),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            bottomLeft: Radius.circular(6),
                          ),
                          border: Border.all(
                            color: isDark ? Colors.white : Colors.black,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    // Daytime wake block
                    Expanded(
                      flex: (bedtimeMinutes - wakeMinutes).clamp(0, 1440),
                      child: const SizedBox(),
                    ),
                    // Evening sleep block (bedtime to 24:00)
                    Expanded(
                      flex: (1440 - bedtimeMinutes).clamp(0, 1440),
                      child: Container(
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : Colors.black)
                              .withValues(alpha: 0.85),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(6),
                            bottomRight: Radius.circular(6),
                          ),
                          border: Border.all(
                            color: isDark ? Colors.white : Colors.black,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Live Current Time Indicator Needle
              Positioned(
                left: (MediaQuery.of(context).size.width * 0.45 * currentRatio)
                    .clamp(4.0, 320.0),
                top: -3,
                bottom: -3,
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : Colors.black,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 3,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 24h Time Labels (00h, 06h, 12h, 18h, 24h)
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('00:00',
                        style: AppTypography.bodySmall(isDark)
                            .copyWith(fontSize: 10)),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('06:00',
                        style: AppTypography.bodySmall(isDark)
                            .copyWith(fontSize: 10)),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('12:00',
                        style: AppTypography.bodySmall(isDark)
                            .copyWith(fontSize: 10)),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('18:00',
                        style: AppTypography.bodySmall(isDark)
                            .copyWith(fontSize: 10)),
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('24:00',
                        style: AppTypography.bodySmall(isDark)
                            .copyWith(fontSize: 10)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Chronotype Archetype & Personalized Sleep Gate
          InkWell(
            onTap: () => ChronotypeAssessmentModal.show(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141414) : const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 500;
                  final archetypePill = FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(chronotypeProfile.emoji,
                            style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          '${chronotypeProfile.name.toUpperCase()} ARCHETYPE',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.edit_outlined,
                          size: 11,
                          color: isDark
                              ? const Color(0xFFA3A3A3)
                              : const Color(0xFF525252),
                        ),
                      ],
                    ),
                  );

                  final sleepGatePill = FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SLEEP GATE: ',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.primary
                                : AppColors.primaryDark,
                          ),
                        ),
                        Text(
                          chronotypeProfile.sleepGateFormatted,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  );

                  if (isCompact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        archetypePill,
                        const SizedBox(height: 4),
                        sleepGatePill,
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: archetypePill),
                      const SizedBox(width: 8),
                      sleepGatePill,
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Schedule Target Values Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.nightlight_round,
                          size: 16,
                          color: isDark
                              ? AppColors.primary
                              : AppColors.primaryDark),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bedtime Target',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelSmall(isDark),
                            ),
                            Text(
                              bedtimeStr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.titleMedium(isDark).copyWith(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.wb_sunny_rounded,
                          size: 16,
                          color: isDark
                              ? const Color(0xFFA3A3A3)
                              : const Color(0xFF525252)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Wake Target',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelSmall(isDark),
                            ),
                            Text(
                              wakeStr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.titleMedium(isDark).copyWith(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
