import 'sleep_factor.dart';

/// Represents a single recorded sleep session in SOMNA.
///
/// Can be:
/// - In progress / Active (where [endTimestamp] is null)
/// - Completed (where [endTimestamp] is non-null)
class SleepSession {
  final String id;
  final DateTime startTimestamp;
  final DateTime? endTimestamp;
  final int? qualityRating; // 1 to 5 (optional)
  final String? notes; // User notes / factors
  final String source; // 'timer', 'manual', 'imported'
  final DateTime createdAt;
  final DateTime updatedAt;

  SleepSession({
    required this.id,
    required this.startTimestamp,
    this.endTimestamp,
    this.qualityRating,
    this.notes,
    this.source = 'manual',
    required this.createdAt,
    required this.updatedAt,
  }) {
    if (qualityRating != null && (qualityRating! < 1 || qualityRating! > 5)) {
      throw ArgumentError('qualityRating must be between 1 and 5');
    }
  }

  /// Whether the session is currently in progress.
  bool get isActive => endTimestamp == null;

  /// Returns the duration of the session.
  /// If active, calculates elapsed duration up to [now].
  Duration duration([DateTime? now]) {
    final end = endTimestamp ?? now ?? DateTime.now();
    return end.difference(startTimestamp);
  }

  /// Duration in minutes.
  int durationMinutes([DateTime? now]) {
    return duration(now).inMinutes;
  }

  /// Human-readable duration string: e.g. "7h 45m" or "42m".
  String formattedDuration([DateTime? now]) {
    final d = duration(now);
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Whether this session crosses midnight (local time).
  bool get isOvernight {
    if (endTimestamp == null) return false;
    final startLocal = startTimestamp.toLocal();
    final endLocal = endTimestamp!.toLocal();
    return startLocal.year != endLocal.year ||
        startLocal.month != endLocal.month ||
        startLocal.day != endLocal.day;
  }

  /// Whether the session spans multiple full days (>= 24 hours).
  bool get isMultiDay => duration().inHours >= 24;

  /// Extracts lifestyle factor tags present in [notes].
  List<String> get tags {
    if (notes == null || notes!.isEmpty) return const [];
    final lowerNotes = notes!.toLowerCase();
    return SleepFactor.all
        .where((factor) =>
            notes!.contains(factor.label) ||
            lowerNotes.contains(factor.name.toLowerCase()))
        .map((f) => f.label)
        .toList();
  }

  /// Creates a copy with optionally updated fields.
  SleepSession copyWith({
    String? id,
    DateTime? startTimestamp,
    DateTime? endTimestamp,
    int? qualityRating,
    String? notes,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearRating = false,
    bool clearNotes = false,
  }) {
    return SleepSession(
      id: id ?? this.id,
      startTimestamp: startTimestamp ?? this.startTimestamp,
      endTimestamp: endTimestamp ?? this.endTimestamp,
      qualityRating: clearRating ? null : (qualityRating ?? this.qualityRating),
      notes: clearNotes ? null : (notes ?? this.notes),
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts the session to a Map for SQLite storage.
  /// Timestamps are stored as UTC milliseconds since epoch.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start_timestamp': startTimestamp.toUtc().millisecondsSinceEpoch,
      'end_timestamp': endTimestamp?.toUtc().millisecondsSinceEpoch,
      'quality_rating': qualityRating,
      'notes': notes,
      'source': source,
      'created_at': createdAt.toUtc().millisecondsSinceEpoch,
      'updated_at': updatedAt.toUtc().millisecondsSinceEpoch,
    };
  }

  /// Constructs a [SleepSession] from a SQLite map.
  factory SleepSession.fromMap(Map<String, dynamic> map) {
    return SleepSession(
      id: map['id'] as String,
      startTimestamp: DateTime.fromMillisecondsSinceEpoch(
        map['start_timestamp'] as int,
        isUtc: true,
      ).toLocal(),
      endTimestamp: map['end_timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['end_timestamp'] as int,
              isUtc: true,
            ).toLocal()
          : null,
      qualityRating: map['quality_rating'] as int?,
      notes: map['notes'] as String?,
      source: (map['source'] as String?) ?? 'manual',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['created_at'] as int,
        isUtc: true,
      ).toLocal(),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['updated_at'] as int,
        isUtc: true,
      ).toLocal(),
    );
  }

  /// JSON serialization for export.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTimestamp': startTimestamp.toUtc().toIso8601String(),
      'endTimestamp': endTimestamp?.toUtc().toIso8601String(),
      'durationMinutes': durationMinutes(),
      'qualityRating': qualityRating,
      'notes': notes,
      'source': source,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepSession &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          startTimestamp == other.startTimestamp &&
          endTimestamp == other.endTimestamp &&
          qualityRating == other.qualityRating &&
          notes == other.notes &&
          source == other.source;

  @override
  int get hashCode =>
      id.hashCode ^
      startTimestamp.hashCode ^
      endTimestamp.hashCode ^
      qualityRating.hashCode ^
      notes.hashCode ^
      source.hashCode;
}
