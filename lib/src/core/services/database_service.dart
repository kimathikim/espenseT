import 'package:flutter/foundation.dart';
import 'local_database.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  AppDatabase? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  AppDatabase? get database => _database;

  Future<void> init() async {
    try {
      _database = AppDatabase();
      debugPrint('Database service initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize database: $e');
      // Continue without local database - app will work with Supabase only
    }
  }
}
