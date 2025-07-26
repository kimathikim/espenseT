import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expensetracker/src/features/transactions/domain/expense.dart';

class TransactionRepository {
  final _client = Supabase.instance.client;

  Future<List<Expense>> fetchTransactions() async {
    try {
      final data = await _client
          .from('expenses')
          .select()
          .order('transaction_date', ascending: false);
      return (data as List).map((json) => Expense.fromJson(json)).toList();
    } catch (e) {
      // It's better to handle specific exceptions, but for now, we'll rethrow.
      rethrow;
    }
  }
}
