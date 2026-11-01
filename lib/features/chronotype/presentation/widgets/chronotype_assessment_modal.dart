import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/somna_button.dart';
import '../../../../core/widgets/somna_card.dart';
import '../../../../shared/providers/settings_provider.dart';
import '../../domain/models/chronotype.dart';

class ChronotypeAssessmentModal extends StatefulWidget {
  const ChronotypeAssessmentModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ChronotypeAssessmentModal(),
    );
  }

  @override
  State<ChronotypeAssessmentModal> createState() =>
      _ChronotypeAssessmentModalState();
}

class _ChronotypeAssessmentModalState extends State<ChronotypeAssessmentModal> {
  int _currentStep = 0; // 0, 1, 2 questions; 3 = result
  ChronotypeType? _answer1;
  ChronotypeType? _answer2;
  ChronotypeType? _answer3;

  ChronotypeProfile _calculateResult() {
    final votes = <ChronotypeType, int>{
      ChronotypeType.lion: 0,
      ChronotypeType.bear: 0,
      ChronotypeType.wolf: 0,
      ChronotypeType.dolphin: 0,
    };

    if (_answer1 != null) votes[_answer1!] = (votes[_answer1!] ?? 0) + 1;
    if (_answer2 != null) votes[_answer2!] = (votes[_answer2!] ?? 0) + 1;
    if (_answer3 != null) votes[_answer3!] = (votes[_answer3!] ?? 0) + 1;

    // Pick maximum votes, defaulting to bear (most common ~55%)
    ChronotypeType best = ChronotypeType.bear;
    int maxVotes = -1;
    votes.forEach((type, count) {
      if (count > maxVotes) {
        maxVotes = count;
        best = type;
      }
    });

    return ChronotypeProfile.fromType(best);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final maxHeight = MediaQuery.of(context).size.height * 0.90;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 620, maxHeight: maxHeight),
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

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.explore_rounded,
                    size: 16,
                    color: isDark ? AppColors.primary : AppColors.primaryDark,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'CIRCADIAN CHRONOTYPE',
                    style: AppTypography.labelLarge(isDark).copyWith(
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.primary : AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color:
                      isDark ? const Color(0xFF262626) : const Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _currentStep < 3 ? 'STEP ${_currentStep + 1} OF 3' : 'DIAGNOSTIC COMPLETE',
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
          const SizedBox(height: 16),

          Flexible(
            child: SingleChildScrollView(
              child: _currentStep < 3
                  ? _buildQuestionStep(isDark)
                  : _buildResultStep(isDark, settings),
            ),
          ),
        ],
      ),
    ),
  ),
);
  }

  Widget _buildQuestionStep(bool isDark) {
    String qNumber;
    String qTitle;
    String qText;
    ChronotypeType? selectedAnswer;
    void Function(ChronotypeType) onSelect;

    switch (_currentStep) {
      case 0:
        qNumber = 'QUESTION 1';
        qTitle = 'Natural Weekend Wake Time';
        qText =
            'Without an alarm clock, what time do you naturally open your eyes and feel ready to get up?';
        selectedAnswer = _answer1;
        onSelect = (t) => setState(() => _answer1 = t);
        break;
      case 1:
        qNumber = 'QUESTION 2';
        qTitle = 'Peak Mental Focus & Clarity';
        qText =
            'When during the day is your brain functioning at its highest clarity, focus, and analytical speed?';
        selectedAnswer = _answer2;
        onSelect = (t) => setState(() => _answer2 = t);
        break;
      default:
        qNumber = 'QUESTION 3';
        qTitle = 'Late Evening Sleepiness & Melatonin Surge';
        qText =
            'When 10:00 PM approaches, what is your body\'s natural physiological state?';
        selectedAnswer = _answer3;
        onSelect = (t) => setState(() => _answer3 = t);
        break;
    }

    final options = _getOptionsForStep(_currentStep);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          qNumber,
          style: AppTypography.labelSmall(isDark).copyWith(
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFF888888) : const Color(0xFF777777),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          qTitle,
          style: AppTypography.titleLarge(isDark).copyWith(fontSize: 18),
        ),
        const SizedBox(height: 6),
        Text(
          qText,
          style: AppTypography.bodyMedium(isDark),
        ),
        const SizedBox(height: 16),

        // Radio-style Options
        ...options.map((opt) {
          final isSelected = selectedAnswer == opt.type;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => onSelect(opt.type),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? const Color(0xFF262626) : const Color(0xFFE5E5E5))
                      : (isDark ? const Color(0xFF141414) : const Color(0xFFF7F7F7)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? (isDark ? Colors.white : Colors.black)
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? (isDark ? Colors.white : Colors.black)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? Colors.white : Colors.black)
                              : (isDark ? const Color(0xFF555555) : const Color(0xFFBBBBBB)),
                          width: 1.5,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              size: 13,
                              color: isDark ? Colors.black : Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(opt.emoji, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                opt.title,
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            opt.description,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentStep > 0)
              TextButton.icon(
                onPressed: () => setState(() => _currentStep--),
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Back'),
              )
            else
              const SizedBox.shrink(),
            ElevatedButton.icon(
              onPressed: selectedAnswer == null
                  ? null
                  : () {
                      setState(() {
                        _currentStep++;
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : Colors.black,
                foregroundColor: isDark ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
              icon: Icon(
                _currentStep == 2 ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
                size: 16,
              ),
              label: Text(
                _currentStep == 2 ? 'View Chronotype' : 'Next',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultStep(bool isDark, SettingsProvider settings) {
    final profile = _calculateResult();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Trophy / Reveal Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF181818) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            children: [
              Text(
                profile.emoji,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 8),
              Text(
                '${profile.name.toUpperCase()} ARCHETYPE',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                profile.tagline,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.primary : AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                profile.description,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall(isDark),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Personalized Schedule Benchmarks
        SomnaCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PERSONALIZED CIRCADIAN PROFILE',
                style: AppTypography.labelSmall(isDark).copyWith(
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.primary : AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 12),
              _buildMetricRow('Optimal Sleep Gate:', profile.sleepGateFormatted, isDark),
              const Divider(height: 14),
              _buildMetricRow('Ideal Bedtime:', TimeOfDay(hour: profile.idealBedtimeMinutes ~/ 60, minute: profile.idealBedtimeMinutes % 60).format(context), isDark),
              const Divider(height: 14),
              _buildMetricRow('Ideal Wake Time:', TimeOfDay(hour: profile.idealWakeMinutes ~/ 60, minute: profile.idealWakeMinutes % 60).format(context), isDark),
              const Divider(height: 14),
              _buildMetricRow('Peak Focus Window:', profile.energyPeak, isDark),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Action Buttons
        SomnaButton(
          text: 'Apply ${profile.name} Schedule & Save',
          icon: Icons.auto_awesome_rounded,
          type: SomnaButtonType.primary,
          onPressed: () async {
            await settings.updateChronotype(profile.name.toLowerCase());
            await settings.updateSchedule(
              bedtimeMinutes: profile.idealBedtimeMinutes,
              wakeMinutes: profile.idealWakeMinutes,
            );
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${profile.emoji} ${profile.name} schedule applied! Bedtime: ${profile.sleepGateFormatted}',
                  ),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
        ),
        const SizedBox(height: 10),
        SomnaButton(
          text: 'Save Archetype Only (Keep Current Times)',
          type: SomnaButtonType.secondary,
          onPressed: () async {
            await settings.updateChronotype(profile.name.toLowerCase());
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${profile.emoji} Circadian Archetype set to ${profile.name}!',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  List<_OptionItem> _getOptionsForStep(int step) {
    if (step == 0) {
      return const [
        _OptionItem(
          type: ChronotypeType.lion,
          emoji: '🦁',
          title: 'Before 06:30 AM',
          description: 'Wide awake and energetic right away; early riser',
        ),
        _OptionItem(
          type: ChronotypeType.bear,
          emoji: '🐻',
          title: '07:00 – 08:30 AM',
          description: 'Naturally wake up as morning sunlight fills the room',
        ),
        _OptionItem(
          type: ChronotypeType.wolf,
          emoji: '🐺',
          title: 'After 09:00 AM',
          description: 'Hate early mornings; sleep in deeply whenever possible',
        ),
        _OptionItem(
          type: ChronotypeType.dolphin,
          emoji: '🐬',
          title: 'Variable / Fragmented',
          description: 'Wake up light, restless, or groggy regardless of time',
        ),
      ];
    } else if (step == 1) {
      return const [
        _OptionItem(
          type: ChronotypeType.lion,
          emoji: '🦁',
          title: 'Early Morning (08:00 AM – 12:00 PM)',
          description: 'Tackle hardest cognitive tasks right at daybreak',
        ),
        _OptionItem(
          type: ChronotypeType.bear,
          emoji: '🐻',
          title: 'Mid-Morning to Early Afternoon (10:00 AM – 02:00 PM)',
          description: 'Steady, reliable productivity aligned with normal work day',
        ),
        _OptionItem(
          type: ChronotypeType.wolf,
          emoji: '🐺',
          title: 'Late Evening & Night (05:00 PM – 10:00 PM)',
          description: 'Creative inspiration and deep focus peak after sundown',
        ),
        _OptionItem(
          type: ChronotypeType.dolphin,
          emoji: '🐬',
          title: 'Afternoon Bursts (03:00 PM – 06:00 PM)',
          description: 'Sporadic spikes of clarity amid nervous energy',
        ),
      ];
    } else {
      return const [
        _OptionItem(
          type: ChronotypeType.lion,
          emoji: '🦁',
          title: 'Heavy sleepiness by 09:30 – 10:00 PM',
          description: 'Can barely keep eyes open; early natural melatonin surge',
        ),
        _OptionItem(
          type: ChronotypeType.bear,
          emoji: '🐻',
          title: 'Wind down smoothly by 10:30 – 11:30 PM',
          description: 'Comfortably fall asleep around 11:00 PM without friction',
        ),
        _OptionItem(
          type: ChronotypeType.wolf,
          emoji: '🐺',
          title: 'Second wind strikes! Alert past midnight',
          description: 'Mind races with ideas, gaming, or reading late into night',
        ),
        _OptionItem(
          type: ChronotypeType.dolphin,
          emoji: '🐬',
          title: 'Tired but wired; difficulty settling',
          description: 'Overthinking or sensitive to room noise and light',
        ),
      ];
    }
  }
}

class _OptionItem {
  final ChronotypeType type;
  final String emoji;
  final String title;
  final String description;

  const _OptionItem({
    required this.type,
    required this.emoji,
    required this.title,
    required this.description,
  });
}
