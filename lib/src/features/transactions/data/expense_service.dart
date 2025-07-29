import 'package:flutter/foundation.dart';
import 'package:expensetracker/src/core/services/database_service.dart';
import 'package:expensetracker/src/features/transactions/domain/expense.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpenseService {
  final _client = Supabase.instance.client;
  final _db = DatabaseService().database;

  Future<List<Expense>> fetchExpenses({bool forceRefresh = false}) async {
    if (forceRefresh || _db == null) {
      return _fetchFromSupabase();
    }

    try {
      // Try local first
      final localExpenses = await _db!.expenseDao.getAllExpenses();
      if (localExpenses.isNotEmpty) {
        return localExpenses.map((e) => e.toDomain()).toList();
      }
    } catch (e) {
      // If local database fails, fall back to Supabase
      debugPrint('Local database error, falling back to Supabase: $e');
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
      
      // Try to cache locally if database is available
      if (_db != null) {
        try {
          await _db!.expenseDao.insertExpenses(expenses);
        } catch (e) {
          debugPrint('Failed to cache expenses locally: $e');
        }
      }
      
      return expenses;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> syncExpenses() async {
    try {
      // Call the edge function to sync M-Pesa transactions
      await _client.functions.invoke('sync-mpesa-transactions');
      
      // Fetch updated data
      await _fetchFromSupabase();
    } catch (e) {
      rethrow;
    }
  }

  Future<Expense> updateExpenseCategory(String expenseId, String categoryId) async {
    try {
      final data = await _client
          .from('expenses')
          .update({'category_id': categoryId})
          .eq('id', expenseId)
          .select()
          .single();

      final updatedExpense = Expense.fromJson(data);
      
      // Update local cache
      await _db?.expenseDao.insertExpenses([updatedExpense]);
      
      return updatedExpense;
    } catch (e) {
      rethrow;
    }
  }
}

