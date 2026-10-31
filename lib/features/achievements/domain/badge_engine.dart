import 'package:flutter/material.dart';
import '../../../shared/models/sleep_session.dart';
import '../../../shared/models/sleep_stats.dart';
import 'models/sleep_badge.dart';

/// Evaluates player achievements and unlocks from sleep logs and statistics.
class BadgeEngine {
  BadgeEngine._();

  static List<SleepBadge> evaluateBadges({
    required List<SleepSession> sessions,
    required SleepStats stats,
  }) {
    final completed = sessions.where((s) => s.endTimestamp != null).toList();

    // 1. Night Pioneer: Log 5 completed sleep sessions
    final pioneerProgress = (completed.length / 5).clamp(0.0, 1.0);
    final pioneerBadge = SleepBadge(
      id: 'night_pioneer',
      title: 'Night Pioneer',
      description: 'Record your first 5 completed sleep sessions.',
      icon: Icons.explore_rounded,
      code: 'ACHV-01',
      progress: pioneerProgress,
      isUnlocked: completed.length >= 5,
      progressLabel: '${completed.length}/5 Sessions',
    );

    // 2. Circadian Lock: Bedtime consistency >= 85% with at least 3 logs
    final consistencyScore = stats.bedtimeConsistencyScore;
    final isConsistencyUnlocked =
        completed.length >= 3 && consistencyScore >= 85;
    final lockProgress = completed.length < 3
        ? (completed.length / 3) * 0.5
        : (consistencyScore / 100).clamp(0.0, 1.0);
    final lockBadge = SleepBadge(
      id: 'circadian_lock',
      title: 'Circadian Lock',
      description: 'Achieve 85%+ bedtime rhythm regularity.',
      icon: Icons.lock_clock_rounded,
      code: 'ACHV-02',
      progress: lockProgress,
      isUnlocked: isConsistencyUnlocked,
      progressLabel: '$consistencyScore% / 85%',
    );

    // 3. Battery Overcharge: Record any session of 8h 30m+ with 5-star rating
    final hasOvercharge = completed.any(
      (s) => s.durationMinutes() >= 510 && (s.qualityRating ?? 0) >= 5,
    );
    final maxLongSession = completed.fold<int>(
      0,
      (max, s) => s.durationMinutes() > max ? s.durationMinutes() : max,
    );
    final overchargeProgress = (maxLongSession / 510).clamp(0.0, 1.0);
    final overchargeBadge = SleepBadge(
      id: 'battery_overcharge',
      title: 'Battery Overcharge',
      description: 'Log 8h 30m+ rest with a 5-star quality rating.',
      icon: Icons.battery_charging_full_rounded,
      code: 'ACHV-03',
      progress: hasOvercharge ? 1.0 : overchargeProgress,
      isUnlocked: hasOvercharge,
      progressLabel: hasOvercharge ? 'Completed' : '${maxLongSession ~/ 60}h/8.5h',
    );

    // 4. Zen Protocol: Log meditation before bed in 2+ sessions
    final meditatedCount = completed.where((s) {
      final n = s.notes?.toLowerCase() ?? '';
      return n.contains('meditated') || n.contains('🧘');
    }).length;
    final zenProgress = (meditatedCount / 2).clamp(0.0, 1.0);
    final zenBadge = SleepBadge(
      id: 'zen_protocol',
      title: 'Zen Protocol',
      description: 'Log meditation before sleep for 2+ nights.',
      icon: Icons.self_improvement_rounded,
      code: 'ACHV-04',
      progress: zenProgress,
      isUnlocked: meditatedCount >= 2,
      progressLabel: '$meditatedCount/2 Nights',
    );

    // 5. Cryo Chamber: Log cool room sleep environment
    final coolRoomCount = completed.where((s) {
      final n = s.notes?.toLowerCase() ?? '';
      return n.contains('cool room') || n.contains('❄️');
    }).length;
    final cryoProgress = (coolRoomCount / 2).clamp(0.0, 1.0);
    final cryoBadge = SleepBadge(
      id: 'cryo_chamber',
      title: 'Cryo Chamber',
      description: 'Optimize sleep with a cool bedroom environment.',
      icon: Icons.ac_unit_rounded,
      code: 'ACHV-05',
      progress: cryoProgress,
      isUnlocked: coolRoomCount >= 2,
      progressLabel: '$coolRoomCount/2 Nights',
    );

    // 6. Caffeine Free: Log caffeine-free restful sleep
    final caffeineCount = completed.where((s) {
      final n = s.notes?.toLowerCase() ?? '';
      return n.contains('caffeine') || n.contains('☕');
    }).length;
    final noCaffeineCount = completed.length - caffeineCount;
    final caffeineFreeProgress = (noCaffeineCount / 3).clamp(0.0, 1.0);
    final caffeineFreeBadge = SleepBadge(
      id: 'caffeine_detox',
      title: 'Caffeine Detox',
      description: 'Log 3+ sessions without late afternoon caffeine.',
      icon: Icons.emoji_food_beverage_rounded,
      code: 'ACHV-06',
      progress: caffeineFreeProgress,
      isUnlocked: noCaffeineCount >= 3,
      progressLabel: '$noCaffeineCount/3 Nights',
    );

    return [
      pioneerBadge,
      lockBadge,
      overchargeBadge,
      zenBadge,
      cryoBadge,
      caffeineFreeBadge,
    ];
  }
}

