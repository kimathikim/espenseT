import 'package:expensetracker/src/features/transactions/data/expense_service.dart';
import 'package:expensetracker/src/features/transactions/domain/expense.dart';

class TransactionRepository {
  final _expenseService = ExpenseService();

  Future<List<Expense>> fetchTransactions({bool forceRefresh = false}) async {
    return _expenseService.fetchExpenses(forceRefresh: forceRefresh);
  }

  Future<void> syncTransactions() async {
    return _expenseService.syncExpenses();
  }

  Future<Expense> updateTransactionCategory(String transactionId, String categoryId) async {
    return _expenseService.updateExpenseCategory(transactionId, categoryId);
  }
}
