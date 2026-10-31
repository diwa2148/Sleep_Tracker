import 'package:flutter/material.dart';

/// Retro pixel / cyberdeck milestone achievement badge.
class SleepBadge {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String code; // e.g. "ACHV-01"
  final double progress; // 0.0 to 1.0
  final bool isUnlocked;
  final String progressLabel;

  const SleepBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.code,
    required this.progress,
    required this.isUnlocked,
    required this.progressLabel,
  });

  SleepBadge copyWith({
    double? progress,
    bool? isUnlocked,
    String? progressLabel,
  }) {
    return SleepBadge(
      id: id,
      title: title,
      description: description,
      icon: icon,
      code: code,
      progress: progress ?? this.progress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      progressLabel: progressLabel ?? this.progressLabel,
    );
  }
}

