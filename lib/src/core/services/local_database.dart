import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:expensetracker/src/features/categories/domain/category.dart' as domain;
import 'package:expensetracker/src/features/transactions/domain/expense.dart' as domain;

part 'local_database.g.dart';

@DataClassName('LocalCategory')
class LocalCategories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get userId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LocalExpense')
class LocalExpenses extends Table {
  TextColumn get id => text()();
  TextColumn get description => text().nullable()();
  RealColumn get amount => real()();
  DateTimeColumn get transactionDate => dateTime()();
  TextColumn get categoryId => text()();
  TextColumn get userId => text()();
  TextColumn get screenshotUrl => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [LocalCategories, LocalExpenses], daos: [CategoryDao, ExpenseDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

@DriftAccessor(tables: [LocalCategories])
class CategoryDao extends DatabaseAccessor<AppDatabase> with _$CategoryDaoMixin {
  CategoryDao(AppDatabase db) : super(db);

  Future<List<LocalCategory>> getAllCategories() => select(localCategories).get();

  Future<void> insertCategories(List<domain.Category> categories) async {
    await batch((batch) {
      batch.insertAll(
        localCategories,
        categories.map(
          (category) => LocalCategoriesCompanion.insert(
            id: category.id,
            name: category.name,
            icon: Value(category.icon),
            color: Value(category.color),
            userId: Value(null), // Assuming default categories for now
          ),
        ),
        mode: InsertMode.insertOrReplace,
      );
    });
  }
}

@DriftAccessor(tables: [LocalExpenses])
class ExpenseDao extends DatabaseAccessor<AppDatabase> with _$ExpenseDaoMixin {
  ExpenseDao(AppDatabase db) : super(db);

  Future<List<LocalExpense>> getAllExpenses() => select(localExpenses).get();

  Future<void> insertExpenses(List<domain.Expense> expenses) async {
    await batch((batch) {
      batch.insertAll(
        localExpenses,
        expenses.map(
          (expense) => LocalExpensesCompanion.insert(
            id: expense.id,
            description: Value(expense.description),
            amount: expense.amount,
            transactionDate: expense.transactionDate,
            categoryId: expense.categoryId,
            userId: expense.userId,
            screenshotUrl: Value(expense.screenshotUrl),
          ),
        ),
        mode: InsertMode.insertOrReplace,
      );
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    final cache = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cache;

    return NativeDatabase.createInBackground(file);
  });
}
