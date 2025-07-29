import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expensetracker/src/features/transactions/domain/expense.dart';
import 'package:expensetracker/src/features/categories/domain/category.dart';
import 'package:expensetracker/src/features/categories/presentation/widgets/category_icon_mapper.dart';
import 'package:expensetracker/src/features/categories/presentation/widgets/category_selection_widget.dart';
import 'package:expensetracker/src/shared/theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class TransactionDetailModal extends StatefulWidget {
  final Expense transaction;
  final List<Category> categories;
  final Function(String categoryId) onCategoryChanged;
  final VoidCallback? onDelete;

  const TransactionDetailModal({
    super.key,
    required this.transaction,
    required this.categories,
    required this.onCategoryChanged,
    this.onDelete,
  });

  @override
  State<TransactionDetailModal> createState() => _TransactionDetailModalState();
}

class _TransactionDetailModalState extends State<TransactionDetailModal>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _backdropAnimation;

  String? _selectedCategoryId;
  bool _isLoading = false;
  bool _showCategorySelection = false;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.transaction.categoryId;

    // Initialize animations
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _backdropAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }



  Future<void> _selectCategory(String categoryId) async {
    if (_isLoading) return;

    HapticFeedback.lightImpact();
    setState(() {
      _selectedCategoryId = categoryId;
      _isLoading = true;
    });

    try {
      await widget.onCategoryChanged(categoryId);
      await _closeModal();
    } catch (e) {
      setState(() {
        _selectedCategoryId = widget.transaction.categoryId;
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to update category: $e');
    }
  }

  Future<void> _closeModal() async {
    await _fadeController.reverse();
    await _slideController.reverse();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Category _getCurrentCategory() {
    return widget.categories.firstWhere(
      (cat) => cat.id == _selectedCategoryId,
      orElse: () => Category(id: 'unknown', name: 'Uncategorized'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Stack(
          children: [
            // Backdrop
            GestureDetector(
              onTap: _closeModal,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withOpacity(_backdropAnimation.value),
              ),
            ),
            // Modal content
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildModalContent(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModalContent() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModalHandle(),
          _buildModalHeader(),
          Flexible(
            child: _showCategorySelection
                ? _buildCategorySelection()
                : _buildTransactionDetails(),
          ),
        ],
      ),
    );
  }

  Widget _buildModalHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.greyText.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildModalHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          if (_showCategorySelection)
            IconButton(
              onPressed: () {
                setState(() {
                  _showCategorySelection = false;
                });
              },
              icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
            ),
          Expanded(
            child: Text(
              _showCategorySelection ? 'Select Category' : 'Transaction Details',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
              textAlign: _showCategorySelection ? TextAlign.left : TextAlign.center,
            ),
          ),
          if (!_showCategorySelection)
            IconButton(
              onPressed: _closeModal,
              icon: const Icon(Icons.close, color: AppColors.darkText),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails() {
    final currentCategory = _getCurrentCategory();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTransactionInfoCard(),
          const SizedBox(height: 20),
          _buildCategorySection(currentCategory),
          const SizedBox(height: 20),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildTransactionInfoCard() {
    return AppTheme.buildGlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryStart.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: AppColors.primaryStart,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KSh ${NumberFormat('#,##0.00').format(widget.transaction.amount)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                    Text(
                      DateFormat('EEEE, MMMM dd, yyyy • hh:mm a').format(widget.transaction.transactionDate),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.transaction.description != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.transaction.description!,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.darkText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategorySection(Category currentCategory) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            setState(() {
              _showCategorySelection = true;
            });
          },
          child: AppTheme.buildGlassmorphicCard(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: currentCategory.color != null
                        ? Color(int.parse(currentCategory.color!.substring(1, 7), radix: 16) + 0xFF000000)
                        : AppColors.primaryStart,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: FaIcon(
                      CategoryIconMapper.getIcon(currentCategory.icon),
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    currentCategory.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.greyText,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _closeModal,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        if (widget.onDelete != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _isLoading ? null : widget.onDelete,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Delete Transaction',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCategorySelection() {
    return CategorySelectionWidget(
      categories: widget.categories,
      selectedCategoryId: _selectedCategoryId,
      onCategorySelected: (category) => _selectCategory(category.id),
      showSearch: true,
      showRecentCategories: true,
    );
  }
}
