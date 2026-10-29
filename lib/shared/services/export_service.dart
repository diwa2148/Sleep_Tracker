import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../app/app_config.dart';
import '../models/sleep_session.dart';

/// Service for exporting sleep data to RFC-4180 compliant CSV and structured JSON.
class ExportService {
  /// Converts sessions into an RFC-4180 compliant CSV string.
  /// Handles commas, double quotes, and multi-line text safely.
  static String generateCsv(List<SleepSession> sessions) {
    final buffer = StringBuffer();

    // CSV Header
    buffer.writeln(
        'ID,Start Time (UTC),End Time (UTC),Duration (Minutes),Duration Formatted,Quality Rating,Source,Notes');

    for (final s in sessions) {
      final id = _escapeCsvCell(s.id);
      final startUtc = s.startTimestamp.toUtc().toIso8601String();
      final endUtc = s.endTimestamp?.toUtc().toIso8601String() ?? 'ACTIVE';
      final durationMins = s.durationMinutes().toString();
      final durationFmt = _escapeCsvCell(s.formattedDuration());
      final rating = s.qualityRating?.toString() ?? '';
      final source = _escapeCsvCell(s.source);
      final notes = _escapeCsvCell(s.notes ?? '');

      buffer.writeln(
          '$id,$startUtc,$endUtc,$durationMins,$durationFmt,$rating,$source,$notes');
    }

    return buffer.toString();
  }

  /// Escapes a cell according to RFC 4180:
  /// If the field contains comma, quote, or newline, wrap it in double quotes
  /// and replace any inner double quotes with two double quotes ("").
  static String _escapeCsvCell(String text) {
    if (text.isEmpty) return '';
    if (text.contains(',') ||
        text.contains('"') ||
        text.contains('\n') ||
        text.contains('\r')) {
      final escaped = text.replaceAll('"', '""');
      return '"$escaped"';
    }
    return text;
  }

  /// Converts sessions into pretty JSON format.
  static String generateJson(List<SleepSession> sessions) {
    final list = sessions.map((s) => s.toJson()).toList();
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert({
      'application': AppConfig.appName,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'totalSessions': sessions.length,
      'sessions': list,
    });
  }

  /// Exports sessions as a CSV or JSON file and prompts the platform share sheet.
  static Future<bool> exportAndShare({
    required List<SleepSession> sessions,
    required bool isCsv,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ext = isCsv ? 'csv' : 'json';
      final fileName = 'somna_sleep_export_$timestamp.$ext';
      final content = isCsv ? generateCsv(sessions) : generateJson(sessions);
      final mimeType = isCsv ? 'text/csv' : 'application/json';

      final XFile xFile;
      if (kIsWeb) {
        xFile = XFile.fromData(
          utf8.encode(content),
          name: fileName,
          mimeType: mimeType,
        );
      } else {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsString(content);
        xFile = XFile(file.path, mimeType: mimeType, name: fileName);
      }

      final result = await Share.shareXFiles(
        [xFile],
        text: 'Exported Sleep History from ${AppConfig.appName}',
        subject: '${AppConfig.appName} Sleep Data Export',
      );

      return result.status == ShareResultStatus.success ||
          result.status == ShareResultStatus.dismissed ||
          result.status == ShareResultStatus.unavailable;
    } catch (e) {
      return false;
    }
  }
}
