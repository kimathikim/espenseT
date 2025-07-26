import 'package:expensetracker/src/core/services/local_database.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  late AppDatabase _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  AppDatabase get database => _database;

  Future<void> init() async {
    _database = AppDatabase();
  }
}
