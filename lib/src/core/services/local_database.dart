import 'package:flutter/foundation.dart';
import 'package:expensetracker/src/features/categories/domain/category.dart' as domain;
import 'package:expensetracker/src/features/transactions/domain/expense.dart' as domain;

// Simplified database service that works on all platforms
// For web, it acts as a stub and relies on Supabase for all operations

class LocalCategory {
  final String id;
  final String name;
  final String? icon;
  final String? color;
  final String? userId;

  LocalCategory({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    this.userId,
  });

  domain.Category toDomain() {
    return domain.Category(
      id: id,
      name: name,
      icon: icon,
      color: color,
    );
  }
}

class LocalExpense {
  final String id;
  final String? description;
  final double amount;
  final DateTime transactionDate;
  final String categoryId;
  final String userId;
  final String? screenshotUrl;

  LocalExpense({
    required this.id,
    this.description,
    required this.amount,
    required this.transactionDate,
    required this.categoryId,
    required this.userId,
    this.screenshotUrl,
  });

  domain.Expense toDomain() {
    return domain.Expense(
      id: id,
      description: description,
      amount: amount,
      transactionDate: transactionDate,
      categoryId: categoryId,
      userId: userId,
      screenshotUrl: screenshotUrl,
    );
  }
}

class CategoryDao {
  CategoryDao(AppDatabase db);

  Future<List<LocalCategory>> getAllCategories() async {
    if (kIsWeb) {
      debugPrint('Web: getAllCategories called - returning empty list');
      return [];
    }
    // For mobile, implement actual local storage later
    return [];
  }

  Future<void> insertCategories(List<domain.Category> categories) async {
    if (kIsWeb) {
      debugPrint('Web: insertCategories called with ${categories.length} categories');
      return;
    }
    // For mobile, implement actual local storage later
  }
}

class ExpenseDao {
  ExpenseDao(AppDatabase db);

  Future<List<LocalExpense>> getAllExpenses() async {
    if (kIsWeb) {
      debugPrint('Web: getAllExpenses called - returning empty list');
      return [];
    }
    // For mobile, implement actual local storage later
    return [];
  }

  Future<void> insertExpenses(List<domain.Expense> expenses) async {
    if (kIsWeb) {
      debugPrint('Web: insertExpenses called with ${expenses.length} expenses');
      return;
    }
    // For mobile, implement actual local storage later
  }
}

class AppDatabase {
  late final CategoryDao categoryDao;
  late final ExpenseDao expenseDao;

  AppDatabase() {
    categoryDao = CategoryDao(this);
    expenseDao = ExpenseDao(this);
    debugPrint('AppDatabase initialized (simplified version)');
  }
}
