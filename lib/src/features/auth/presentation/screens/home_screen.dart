import 'package:flutter/material.dart';
import 'package:expensetracker/src/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:expensetracker/src/features/categories/presentation/screens/categories_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expensetracker/src/shared/theme.dart';
import 'package:expensetracker/src/features/transactions/data/expense_service.dart';
import 'package:expensetracker/src/features/categories/data/category_repository.dart';
import 'package:expensetracker/src/features/transactions/domain/expense.dart';
import 'package:expensetracker/src/features/categories/domain/category.dart';
import 'package:expensetracker/src/features/mpesa/presentation/screens/mpesa_linking_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardTab(),
    const TransactionsScreen(),
    const CategoriesTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
        ],
      ),
    );
  }
}

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final ExpenseService _expenseService = ExpenseService();
  final CategoryRepository _categoryRepository = CategoryRepository();

  List<Expense> _expenses = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final expenses = await _expenseService.fetchExpenses();
      final categories = await _categoryRepository.fetchCategories();

      setState(() {
        _expenses = expenses;
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  double get _monthlyTotal {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);

    return _expenses
        .where((expense) =>
            expense.transactionDate.isAfter(currentMonth) &&
            expense.transactionDate.isBefore(nextMonth))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Map<String, double> get _categorySpending {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);

    final monthlyExpenses = _expenses
        .where((expense) =>
            expense.transactionDate.isAfter(currentMonth) &&
            expense.transactionDate.isBefore(nextMonth))
        .toList();

    final Map<String, double> spending = {};

    for (final expense in monthlyExpenses) {
      final category = _categories.firstWhere(
        (cat) => cat.id == expense.categoryId,
        orElse: () => Category(id: 'uncategorized', name: 'Uncategorized'),
      );

      spending[category.name] = (spending[category.name] ?? 0) + expense.amount;
    }

    return spending;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dashboard',
                          style: TextStyle(
                            color: AppColors.whiteText,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMMM yyyy').format(DateTime.now()),
                          style: TextStyle(
                            color: AppColors.whiteText.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MpesaLinkingScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.phone_android,
                            color: AppColors.whiteText,
                            size: 28,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await Supabase.instance.client.auth.signOut();
                          },
                          icon: const Icon(
                            Icons.logout,
                            color: AppColors.whiteText,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error.isNotEmpty
                          ? _buildErrorState()
                          : _buildDashboardContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.greyText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryStart,
                foregroundColor: AppColors.whiteText,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Monthly Summary Card
            _buildMonthlySummaryCard(),
            const SizedBox(height: 24),

            // Quick Actions
            _buildQuickActions(),
            const SizedBox(height: 24),

            // Spending Breakdown
            if (_categorySpending.isNotEmpty) ...[
              _buildSpendingBreakdown(),
              const SizedBox(height: 24),
            ],

            // Recent Transactions
            _buildRecentTransactions(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlySummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: AppColors.secondaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryStart.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This Month\'s Spending',
            style: TextStyle(
              color: AppColors.whiteText,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'KSh ${NumberFormat('#,##0.00').format(_monthlyTotal)}',
            style: const TextStyle(
              color: AppColors.whiteText,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.trending_up,
                color: AppColors.whiteText,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${_expenses.length} transactions',
                style: TextStyle(
                  color: AppColors.whiteText.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.phone_android,
                title: 'Link M-Pesa',
                subtitle: 'Connect account',
                color: AppColors.primaryStart,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MpesaLinkingScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                icon: Icons.sync,
                title: 'Sync Data',
                subtitle: 'Refresh transactions',
                color: AppColors.accent,
                onTap: _loadData,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.whiteText,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingBreakdown() {
    final spending = _categorySpending;
    if (spending.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Spending Breakdown',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.whiteText,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: PieChart(
            PieChartData(
              sections: _buildPieChartSections(spending),
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildSpendingLegend(spending),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, double> spending) {
    final total = spending.values.fold(0.0, (sum, amount) => sum + amount);
    final colors = [
      AppColors.primaryStart,
      AppColors.accent,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
      AppColors.secondaryStart,
    ];

    int colorIndex = 0;
    return spending.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      final color = colors[colorIndex % colors.length];
      colorIndex++;

      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        color: color,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.whiteText,
        ),
      );
    }).toList();
  }

  Widget _buildSpendingLegend(Map<String, double> spending) {
    final colors = [
      AppColors.primaryStart,
      AppColors.accent,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
      AppColors.secondaryStart,
    ];

    int colorIndex = 0;
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: spending.entries.map((entry) {
        final color = colors[colorIndex % colors.length];
        colorIndex++;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${entry.key}: KSh ${NumberFormat('#,##0').format(entry.value)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.greyText,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildRecentTransactions() {
    final recentTransactions = _expenses.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_expenses.length > 5)
              TextButton(
                onPressed: () {
                  // Navigate to transactions screen
                  DefaultTabController.of(context)?.animateTo(1);
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: AppColors.primaryStart,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (recentTransactions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.whiteText,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  size: 48,
                  color: AppColors.greyText,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No transactions yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Link your M-Pesa account to start tracking expenses',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.greyText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppColors.whiteText,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentTransactions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final expense = recentTransactions[index];
                final category = _categories.firstWhere(
                  (cat) => cat.id == expense.categoryId,
                  orElse: () => Category(id: 'uncategorized', name: 'Uncategorized'),
                );

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryStart.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(category.icon),
                      color: AppColors.primaryStart,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    expense.description ?? 'Transaction',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  subtitle: Text(
                    '${category.name} • ${DateFormat('MMM dd').format(expense.transactionDate)}',
                    style: const TextStyle(
                      color: AppColors.greyText,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  trailing: SizedBox(
                    width: 100,
                    child: Text(
                      'KSh ${NumberFormat('#,##0.00').format(expense.amount)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  IconData _getCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'food': return Icons.restaurant;
      case 'transport': return Icons.directions_car;
      case 'shopping': return Icons.shopping_bag;
      case 'entertainment': return Icons.movie;
      case 'bills': return Icons.receipt;
      case 'health': return Icons.local_hospital;
      default: return Icons.category;
    }
  }
}

class CategoriesTab extends StatelessWidget {
  const CategoriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoriesScreen();
  }
}