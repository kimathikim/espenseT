import 'package:expensetracker/src/core/services/database_service.dart';
import 'package:expensetracker/src/core/services/local_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expensetracker/src/features/transactions/domain/expense.dart';

class TransactionRepository {
  final _client = Supabase.instance.client;
  final _db = DatabaseService().database;

  Future<List<Expense>> fetchTransactions({bool forceRefresh = false}) async {
    if (forceRefresh) {
      return _fetchFromSupabase();
    }

    final localExpenses = await _db.expenseDao.getAllExpenses();
    if (localExpenses.isNotEmpty) {
      return localExpenses.map((e) => e.toDomain()).toList();
    }

    return _fetchFromSupabase();
  }

  Future<List<Expense>> _fetchFromSupabase() async {
    try {
      final data = await _client
          .from('expenses')
          .select()
          .order('transaction_date', ascending: false);
      final expenses = (data as List).map((json) => Expense.fromJson(json)).toList();
      await _db.expenseDao.insertExpenses(expenses);
      return expenses;
    } catch (e) {
      // It's better to handle specific exceptions, but for now, we'll rethrow.
      rethrow;
    }
  }
}

extension on LocalExpense {
  Expense toDomain() {
    return Expense(
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
