import 'package:expensetracker/src/features/transactions/data/transaction_repository.dart';
import 'package:expensetracker/src/features/transactions/domain/transaction.dart';
import 'package:flutter/material.dart';
import 'package:expensetracker/src/shared/theme.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late Future<List<Transaction>> _transactionsFuture;
  final _transactionRepository = TransactionRepository();

  @override
  void initState() {
    super.initState();
    _transactionsFuture = _transactionRepository.fetchTransactions();
  }

  Future<void> _refreshTransactions() async {
    setState(() {
      _transactionsFuture = _transactionRepository.fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: RefreshIndicator(
          onRefresh: _refreshTransactions,
          child: FutureBuilder<List<Transaction>>(
            future: _transactionsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No transactions found.'));
              }

              final transactions = snapshot.data!;
              return ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return AppTheme.buildGlassmorphicCard(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.description,
                              style: const TextStyle(
                                color: AppColors.whiteText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              transaction.categoryId, // Placeholder for category name
                              style: TextStyle(
                                color: AppColors.whiteText.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'KSh ${transaction.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.whiteText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
