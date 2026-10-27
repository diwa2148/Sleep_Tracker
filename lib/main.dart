import 'package:flutter/material.dart';
import 'app/app.dart';
import 'shared/services/database_service.dart';
import 'shared/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite database
  try {
    await DatabaseService.instance.database;
  } catch (e, stack) {
    debugPrint('Database initialization error: $e\n$stack');
  }

  // Initialize local notifications
  try {
    await NotificationService.instance.initialize();
  } catch (e, stack) {
    debugPrint('Notification initialization error: $e\n$stack');
  }

  runApp(const SomnaApp());
}
