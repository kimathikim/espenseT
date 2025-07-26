import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expensetracker/src/features/transactions/domain/transaction.dart';

class TransactionRepository {
  final _client = Supabase.instance.client;

  Future<List<Transaction>> fetchTransactions() async {
    try {
      final data = await _client
          .from('transactions')
          .select()
          .order('date', ascending: false);
      return (data as List).map((json) => Transaction.fromJson(json)).toList();
    } catch (e) {
      // It's better to handle specific exceptions, but for now, we'll rethrow.
      rethrow;
    }
  }
}
