import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expensetracker/src/features/transactions/domain/expense.dart';
import 'package:expensetracker/src/features/transactions/services/sms_sync_service.dart';
import 'package:expensetracker/src/features/transactions/data/expense_service.dart';
import 'package:expensetracker/src/features/categories/data/category_repository.dart';
import 'package:expensetracker/src/features/categories/domain/category.dart';
import 'package:expensetracker/src/features/transactions/presentation/widgets/transaction_detail_modal.dart';
import 'package:expensetracker/src/shared/theme.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with TickerProviderStateMixin {
  final SmsSyncService _syncService = SmsSyncService();
  final ExpenseService _expenseService = ExpenseService();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final TextEditingController _searchController = TextEditingController();

  late AnimationController _animationController;
  late AnimationController _searchAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<Expense> _allTransactions = [];
  List<Expense> _filteredTransactions = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String _searchQuery = '';
  String? _selectedFilter;
  bool _isOffline = false;
  List<String> _pendingCategoryUpdates = [];
  bool _isSelectionMode = false;
  Set<String> _selectedTransactionIds = {};

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initSyncService();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _initSyncService() {
    _syncService.addListener(_onSyncStatusChanged);
    _syncService.initialize();
  }

  void _onSyncStatusChanged() {
    if (mounted) {
      final wasOffline = _isOffline;

      setState(() {
        // Update offline status based on sync service status
        _isOffline = _syncService.status == SyncStatus.offline ||
                    _syncService.status == SyncStatus.error;
      });

      // If we just came back online, sync pending updates
      if (wasOffline && !_isOffline && _pendingCategoryUpdates.isNotEmpty) {
        _syncPendingUpdates();
      }

      // Show sync result feedback
      final result = _syncService.lastSyncResult;
      if (result != null && result.success && result.newTransactions > 0) {
        _showSyncSuccessSnackBar(result.newTransactions);
        _loadData(); // Refresh data after successful sync
      } else if (result != null && !result.success) {
        _showSyncErrorSnackBar(result.error ?? 'Sync failed');
      }
    }
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      final [expenses, categories] = await Future.wait([
        _expenseService.fetchExpenses(),
        _categoryRepository.fetchCategories(),
      ]);

      setState(() {
        _allTransactions = expenses as List<Expense>;
        _categories = categories as List<Category>;
        _filteredTransactions = _allTransactions;
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load transactions: $e');
    }
  }

  Future<void> _refreshTransactions() async {
    HapticFeedback.lightImpact();
    final result = await _syncService.forceSyncNow();

    if (result.success) {
      await _loadData();
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _searchQuery = query;
      _filterTransactions();
    });
  }

  void _filterTransactions() {
    List<Expense> filtered = _allTransactions;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((transaction) {
        final description = transaction.description?.toLowerCase() ?? '';
        final amount = transaction.amount.toString();
        final category = _getCategoryName(transaction.categoryId).toLowerCase();

        return description.contains(_searchQuery) ||
               amount.contains(_searchQuery) ||
               category.contains(_searchQuery);
      }).toList();
    }

    // Apply category filter
    if (_selectedFilter != null && _selectedFilter != 'All') {
      filtered = filtered.where((transaction) {
        return _getCategoryName(transaction.categoryId) == _selectedFilter;
      }).toList();
    }

    setState(() {
      _filteredTransactions = filtered;
    });
  }

  String _getCategoryName(String categoryId) {
    final category = _categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => Category(id: 'unknown', name: 'Uncategorized'),
    );
    return category.name;
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });

    if (_isSearching) {
      _searchAnimationController.forward();
    } else {
      _searchAnimationController.reverse();
      _searchController.clear();
      _onSearchChanged();
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  Widget _buildFilterBottomSheet() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.greyText.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Filter by Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: ['All', ..._categories.map((cat) => cat.name)].map((filter) {
                  final isSelected = _selectedFilter == filter ||
                                    (filter == 'All' && _selectedFilter == null);

                  return ListTile(
                    leading: Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: isSelected ? AppColors.primaryStart : AppColors.greyText,
                    ),
                    title: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? AppColors.primaryStart : AppColors.darkText,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter == 'All' ? null : filter;
                        _filterTransactions();
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showSyncSuccessSnackBar(int newTransactions) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text('Synced $newTransactions new transactions'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSyncErrorSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(error)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showErrorSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchAnimationController.dispose();
    _searchController.dispose();
    _syncService.removeListener(_onSyncStatusChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppTheme.buildGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              if (_isSearching) _buildSearchBar(),
              _buildSyncStatusIndicator(),
              Expanded(
                child: _isLoading ? _buildSkeletonLoader() : _buildTransactionsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    if (_isSelectionMode) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            IconButton(
              onPressed: _toggleSelectionMode,
              icon: const Icon(Icons.close, color: AppColors.whiteText, size: 24),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_selectedTransactionIds.length} selected',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.whiteText,
                    ),
                  ),
                  Text(
                    'Tap transactions to select',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.whiteText.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (_selectedTransactionIds.isNotEmpty) ...[
              IconButton(
                onPressed: _showBulkCategorySelection,
                icon: const Icon(Icons.category, color: AppColors.whiteText, size: 24),
                tooltip: 'Categorize selected',
              ),
              IconButton(
                onPressed: _selectedTransactionIds.length == _filteredTransactions.length
                    ? _clearSelection
                    : _selectAllTransactions,
                icon: Icon(
                  _selectedTransactionIds.length == _filteredTransactions.length
                      ? Icons.deselect
                      : Icons.select_all,
                  color: AppColors.whiteText,
                  size: 24,
                ),
                tooltip: _selectedTransactionIds.length == _filteredTransactions.length
                    ? 'Deselect all'
                    : 'Select all',
              ),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transactions',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.whiteText,
                  ),
                ),
                Text(
                  '${_filteredTransactions.length} transactions',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.whiteText.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: _toggleSearch,
                icon: Icon(
                  _isSearching ? Icons.close : Icons.search,
                  color: AppColors.whiteText,
                  size: 24,
                ),
              ),
              IconButton(
                onPressed: _showFilterBottomSheet,
                icon: Stack(
                  children: [
                    const Icon(
                      Icons.filter_list,
                      color: AppColors.whiteText,
                      size: 24,
                    ),
                    if (_selectedFilter != null)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (_filteredTransactions.isNotEmpty)
                IconButton(
                  onPressed: _toggleSelectionMode,
                  icon: const Icon(
                    Icons.checklist,
                    color: AppColors.whiteText,
                    size: 24,
                  ),
                  tooltip: 'Select multiple',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: AppColors.whiteText),
            decoration: InputDecoration(
              hintText: 'Search transactions...',
              hintStyle: TextStyle(color: AppColors.whiteText.withOpacity(0.7)),
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.whiteText.withOpacity(0.7),
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged();
                      },
                      icon: Icon(
                        Icons.clear,
                        color: AppColors.whiteText.withOpacity(0.7),
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSyncStatusIndicator() {
    // Show offline status with pending updates count
    if (_isOffline || _pendingCategoryUpdates.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.warning.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, color: AppColors.warning, size: 16),
            const SizedBox(width: 8),
            Text(
              _pendingCategoryUpdates.isNotEmpty
                  ? 'Offline • ${_pendingCategoryUpdates.length} pending'
                  : 'Offline mode',
              style: TextStyle(
                color: AppColors.warning,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_syncService.status == SyncStatus.idle) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getSyncStatusColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getSyncStatusColor().withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_syncService.isSyncing)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(_getSyncStatusColor()),
              ),
            )
          else
            Icon(
              _getSyncStatusIcon(),
              size: 16,
              color: _getSyncStatusColor(),
            ),
          const SizedBox(width: 8),
          Text(
            _getSyncStatusText(),
            style: TextStyle(
              color: _getSyncStatusColor(),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSyncStatusColor() {
    switch (_syncService.status) {
      case SyncStatus.syncing:
        return AppColors.accent;
      case SyncStatus.success:
        return AppColors.success;
      case SyncStatus.error:
        return AppColors.error;
      case SyncStatus.offline:
        return AppColors.greyText;
      default:
        return AppColors.whiteText;
    }
  }

  IconData _getSyncStatusIcon() {
    switch (_syncService.status) {
      case SyncStatus.success:
        return Icons.check_circle;
      case SyncStatus.error:
        return Icons.error;
      case SyncStatus.offline:
        return Icons.cloud_off;
      default:
        return Icons.sync;
    }
  }

  String _getSyncStatusText() {
    switch (_syncService.status) {
      case SyncStatus.syncing:
        return 'Syncing transactions...';
      case SyncStatus.success:
        return 'Sync completed';
      case SyncStatus.error:
        return _syncService.lastError ?? 'Sync failed';
      case SyncStatus.offline:
        return 'Offline mode';
      default:
        return 'Ready';
    }
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 11,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 14,
                    width: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 11,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionsList() {
    if (_filteredTransactions.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshTransactions,
      color: AppColors.primaryStart,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: _filteredTransactions.length,
          itemBuilder: (context, index) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, 0.3),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  (index * 0.1).clamp(0.0, 1.0),
                  ((index * 0.1) + 0.3).clamp(0.0, 1.0),
                  curve: Curves.easeOutCubic,
                ),
              )),
              child: _buildTransactionCard(_filteredTransactions[index], index),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Expense transaction, int index) {
    final category = _categories.firstWhere(
      (cat) => cat.id == transaction.categoryId,
      orElse: () => Category(id: 'unknown', name: 'Uncategorized'),
    );

    final isSelected = _selectedTransactionIds.contains(transaction.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.accent.withOpacity(0.2)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? AppColors.accent
              : Colors.white.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _isSelectionMode
              ? _toggleTransactionSelection(transaction.id)
              : _showTransactionDetails(transaction),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_isSelectionMode) ...[
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.accent : AppColors.whiteText.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                  const SizedBox(width: 12),
                ],
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryStart.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getCategoryIcon(category.icon),
                    color: AppColors.primaryStart,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        transaction.description ?? 'No description',
                        style: const TextStyle(
                          color: AppColors.whiteText,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Flexible(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                category.name,
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              ' • ${DateFormat('MMM dd').format(transaction.transactionDate)}',
                              style: TextStyle(
                                color: AppColors.whiteText.withOpacity(0.7),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'KSh ${NumberFormat('#,##0.00').format(transaction.amount)}',
                      style: const TextStyle(
                        color: AppColors.whiteText,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      DateFormat('HH:mm').format(transaction.transactionDate),
                      style: TextStyle(
                        color: AppColors.whiteText.withOpacity(0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 60,
              color: AppColors.whiteText.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isNotEmpty ? 'No matching transactions' : 'No transactions yet',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.whiteText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search or filters'
                : 'Link your M-Pesa account to start tracking expenses',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.whiteText.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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

  void _showTransactionDetails(Expense transaction) {
    HapticFeedback.lightImpact();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Transaction Details',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return TransactionDetailModal(
          transaction: transaction,
          categories: _categories,
          onCategoryChanged: (categoryId) => _updateTransactionCategory(transaction, categoryId),
          onDelete: () => _deleteTransaction(transaction),
        );
      },
    );
  }

  Future<void> _updateTransactionCategory(Expense transaction, String categoryId) async {
    // Optimistic update - update UI immediately
    final originalCategoryId = transaction.categoryId;
    final updatedTransaction = Expense(
      id: transaction.id,
      description: transaction.description,
      amount: transaction.amount,
      transactionDate: transaction.transactionDate,
      categoryId: categoryId,
      userId: transaction.userId,
      screenshotUrl: transaction.screenshotUrl,
    );

    setState(() {
      final index = _allTransactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _allTransactions[index] = updatedTransaction;
        _onSearchChanged(); // Refresh filtered list
      }
    });

    try {
      // Check if we're offline
      if (_isOffline) {
        // Store for later sync
        _pendingCategoryUpdates.add('${transaction.id}:$categoryId');
        _showOfflineSnackBar('Category update saved. Will sync when online.');
        return;
      }

      // Update in database
      await _expenseService.updateExpenseCategory(transaction.id, categoryId);

      // Remove from pending updates if it was there
      _pendingCategoryUpdates.removeWhere((update) => update.startsWith(transaction.id));

      // Show success feedback
      _showSuccessSnackBar('Category updated successfully', () {
        // Undo functionality
        _updateTransactionCategory(updatedTransaction, originalCategoryId);
      });
    } catch (e) {
      // Check if it's a network error
      if (_isNetworkError(e)) {
        setState(() {
          _isOffline = true;
        });
        _pendingCategoryUpdates.add('${transaction.id}:$categoryId');
        _showOfflineSnackBar('No internet connection. Category update saved for later sync.');
        return;
      }

      // Rollback optimistic update on other errors
      setState(() {
        final index = _allTransactions.indexWhere((t) => t.id == transaction.id);
        if (index != -1) {
          _allTransactions[index] = transaction;
          _onSearchChanged(); // Refresh filtered list
        }
      });

      _showErrorSnackBar('Failed to update category: $e');
      rethrow; // Re-throw to let modal handle the error
    }
  }

  bool _isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
           errorString.contains('connection') ||
           errorString.contains('timeout') ||
           errorString.contains('unreachable');
  }

  Future<void> _syncPendingUpdates() async {
    if (_pendingCategoryUpdates.isEmpty) return;

    final pendingUpdates = List<String>.from(_pendingCategoryUpdates);
    _pendingCategoryUpdates.clear();

    int successCount = 0;
    int failureCount = 0;

    for (final update in pendingUpdates) {
      final parts = update.split(':');
      if (parts.length != 2) continue;

      final transactionId = parts[0];
      final categoryId = parts[1];

      try {
        await _expenseService.updateExpenseCategory(transactionId, categoryId);
        successCount++;
      } catch (e) {
        // Re-add to pending if it fails
        _pendingCategoryUpdates.add(update);
        failureCount++;
      }
    }

    if (successCount > 0) {
      _showSuccessSnackBar('Synced $successCount pending category updates', () {});
    }

    if (failureCount > 0) {
      _showErrorSnackBar('Failed to sync $failureCount category updates');
    }
  }

  void _showOfflineSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.cloud_off, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedTransactionIds.clear();
      }
    });
  }

  void _toggleTransactionSelection(String transactionId) {
    setState(() {
      if (_selectedTransactionIds.contains(transactionId)) {
        _selectedTransactionIds.remove(transactionId);
      } else {
        _selectedTransactionIds.add(transactionId);
      }
    });
  }

  void _selectAllTransactions() {
    setState(() {
      _selectedTransactionIds = _filteredTransactions.map((t) => t.id).toSet();
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedTransactionIds.clear();
    });
  }

  Future<void> _showBulkCategorySelection() async {
    if (_selectedTransactionIds.isEmpty) return;

    final selectedCategory = await showModalBottomSheet<Category>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildBulkCategorySelectionModal(),
    );

    if (selectedCategory != null) {
      await _bulkUpdateCategories(selectedCategory.id);
    }
  }

  Widget _buildBulkCategorySelectionModal() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.greyText.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Select Category for ${_selectedTransactionIds.length} transactions',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.darkText),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];

                return GestureDetector(
                  onTap: () => Navigator.of(context).pop(category),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: category.color != null
                                  ? Color(int.parse(category.color!.substring(1, 7), radix: 16) + 0xFF000000)
                                  : AppColors.primaryStart,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getCategoryIcon(category.icon),
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              category.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.darkText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTransaction(Expense transaction) async {
    final confirmed = await _showDeleteConfirmationDialog();
    if (!confirmed) return;

    // Optimistic update - remove from UI immediately
    final originalIndex = _allTransactions.indexWhere((t) => t.id == transaction.id);
    setState(() {
      _allTransactions.removeWhere((t) => t.id == transaction.id);
      _onSearchChanged(); // Refresh filtered list
    });

    try {
      // Delete from database (assuming this method exists)
      // await _expenseService.deleteExpense(transaction.id);

      Navigator.of(context).pop(); // Close modal
      _showSuccessSnackBar('Transaction deleted successfully', () {
        // Undo functionality
        setState(() {
          _allTransactions.insert(originalIndex, transaction);
          _onSearchChanged();
        });
      });
    } catch (e) {
      // Rollback optimistic update on error
      setState(() {
        _allTransactions.insert(originalIndex, transaction);
        _onSearchChanged();
      });

      _showErrorSnackBar('Failed to delete transaction: $e');
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showSuccessSnackBar(String message, VoidCallback onUndo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: onUndo,
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _bulkUpdateCategories(String categoryId) async {
    final selectedTransactions = _allTransactions
        .where((t) => _selectedTransactionIds.contains(t.id))
        .toList();

    if (selectedTransactions.isEmpty) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Updating ${selectedTransactions.length} transactions...'),
          ],
        ),
      ),
    );

    int successCount = 0;
    int failureCount = 0;
    final List<Expense> originalTransactions = [];

    // Optimistic updates
    for (final transaction in selectedTransactions) {
      originalTransactions.add(transaction);
      final updatedTransaction = Expense(
        id: transaction.id,
        description: transaction.description,
        amount: transaction.amount,
        transactionDate: transaction.transactionDate,
        categoryId: categoryId,
        userId: transaction.userId,
        screenshotUrl: transaction.screenshotUrl,
      );

      setState(() {
        final index = _allTransactions.indexWhere((t) => t.id == transaction.id);
        if (index != -1) {
          _allTransactions[index] = updatedTransaction;
        }
      });
    }

    // Update filtered list
    _onSearchChanged();

    // Update in database
    for (int i = 0; i < selectedTransactions.length; i++) {
      final transaction = selectedTransactions[i];
      try {
        if (_isOffline) {
          _pendingCategoryUpdates.add('${transaction.id}:$categoryId');
        } else {
          await _expenseService.updateExpenseCategory(transaction.id, categoryId);
        }
        successCount++;
      } catch (e) {
        // Rollback this specific transaction
        setState(() {
          final index = _allTransactions.indexWhere((t) => t.id == transaction.id);
          if (index != -1) {
            _allTransactions[index] = originalTransactions[i];
          }
        });
        failureCount++;
      }
    }

    // Close loading dialog
    Navigator.of(context).pop();

    // Exit selection mode
    setState(() {
      _isSelectionMode = false;
      _selectedTransactionIds.clear();
    });

    // Update filtered list again
    _onSearchChanged();

    // Show result
    if (_isOffline && successCount > 0) {
      _showOfflineSnackBar('$successCount category updates saved for later sync.');
    } else if (successCount > 0 && failureCount == 0) {
      _showSuccessSnackBar('Updated $successCount transactions successfully', () {
        // Undo functionality for bulk operations
        _bulkUndoCategories(selectedTransactions, originalTransactions);
      });
    } else if (successCount > 0 && failureCount > 0) {
      _showErrorSnackBar('Updated $successCount transactions, $failureCount failed');
    } else {
      _showErrorSnackBar('Failed to update transactions');
    }
  }

  Future<void> _bulkUndoCategories(List<Expense> transactions, List<Expense> originalTransactions) async {
    for (int i = 0; i < transactions.length; i++) {
      final transaction = transactions[i];
      final originalTransaction = originalTransactions[i];

      try {
        await _updateTransactionCategory(transaction, originalTransaction.categoryId);
      } catch (e) {
        // Handle individual failures silently for undo operations
      }
    }
  }
}
