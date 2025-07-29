import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:expensetracker/src/features/categories/data/category_repository.dart';
import 'package:expensetracker/src/features/categories/domain/category.dart';
import 'package:expensetracker/src/features/categories/presentation/widgets/category_icon_mapper.dart';
import 'package:expensetracker/src/features/categories/presentation/widgets/category_form_modal.dart';
import 'package:expensetracker/src/features/categories/presentation/widgets/category_list_item.dart';
import 'package:expensetracker/src/shared/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with TickerProviderStateMixin {
  final CategoryRepository _categoryRepository = CategoryRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Category> _allCategories = [];
  List<Category> _filteredCategories = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String _searchQuery = '';
  String? _error;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadCategories();
    _searchController.addListener(_onSearchChanged);
  }

  void _initAnimations() {
    _animationController = AnimationController(
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
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  Future<void> _loadCategories() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final categories = await _categoryRepository.fetchCategories(forceRefresh: true);
      if (mounted) {
        setState(() {
          _allCategories = categories;
          _filteredCategories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredCategories = _allCategories;
      } else {
        _filteredCategories = _allCategories
            .where((category) => category.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header (similar to dashboard)
              _buildHeader(),

              // Content area with card background
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: RefreshIndicator(
                        onRefresh: _loadCategories,
                        color: AppColors.accent,
                        backgroundColor: AppColors.cardBackground,
                        child: _buildBody(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Title and actions row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(
                      color: AppColors.whiteText,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your expense categories',
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
                    icon: Icon(
                      _isSearching ? Icons.close : Icons.search,
                      color: AppColors.whiteText,
                      size: 28,
                    ),
                    onPressed: _toggleSearch,
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: AppColors.whiteText, size: 28),
                    color: AppColors.cardBackground,
                    onSelected: _handleMenuAction,
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'refresh',
                        child: Row(
                          children: [
                            Icon(Icons.refresh, color: AppColors.darkText),
                            SizedBox(width: 8),
                            Text('Refresh', style: TextStyle(color: AppColors.darkText)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'help',
                        child: Row(
                          children: [
                            Icon(Icons.help_outline, color: AppColors.darkText),
                            SizedBox(width: 8),
                            Text('Help', style: TextStyle(color: AppColors.darkText)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Search bar (when active)
          if (_isSearching) ...[
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: AppColors.whiteText),
                decoration: InputDecoration(
                  hintText: 'Search categories...',
                  hintStyle: TextStyle(color: AppColors.whiteText.withOpacity(0.7)),
                  prefixIcon: const Icon(Icons.search, color: AppColors.whiteText),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) => _onSearchChanged(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_filteredCategories.isEmpty) {
      return _buildEmptyState();
    }

    return _buildCategoriesList();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
          ),
          SizedBox(height: 16),
          Text(
            'Loading categories...',
            style: TextStyle(
              color: AppColors.darkText,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.accentRed,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading categories',
            style: const TextStyle(
              color: AppColors.darkText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: const TextStyle(
              color: AppColors.greyText,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadCategories,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasSearchQuery = _searchQuery.isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasSearchQuery ? Icons.search_off : Icons.category_outlined,
            size: 64,
            color: AppColors.whiteText70,
          ),
          const SizedBox(height: 16),
          Text(
            hasSearchQuery ? 'No categories found' : 'No categories yet',
            style: const TextStyle(
              color: AppColors.whiteText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasSearchQuery
                ? 'Try adjusting your search terms'
                : 'Create your first custom category to get started',
            style: const TextStyle(
              color: AppColors.whiteText70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          if (!hasSearchQuery) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddCategoryModal,
              icon: const Icon(Icons.add),
              label: const Text('Add Category'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoriesList() {
    final defaultCategories = _filteredCategories.where((c) => c.userId == null).toList();
    final customCategories = _filteredCategories.where((c) => c.userId != null).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (defaultCategories.isNotEmpty) ...[
          _buildSectionHeader('Default Categories', defaultCategories.length),
          const SizedBox(height: 12),
          ...defaultCategories.map((category) => CategoryListItem(
            category: category,
            isDefault: true,
            onEdit: null, // Default categories can't be edited
            onDelete: null, // Default categories can't be deleted
            onTap: () => _showCategoryDetails(category),
          )),
          const SizedBox(height: 24),
        ],
        if (customCategories.isNotEmpty) ...[
          _buildSectionHeader('My Categories', customCategories.length),
          const SizedBox(height: 12),
          ...customCategories.map((category) => CategoryListItem(
            category: category,
            isDefault: false,
            onEdit: () => _showEditCategoryModal(category),
            onDelete: () => _showDeleteConfirmation(category),
            onTap: () => _showCategoryDetails(category),
          )),
        ] else if (defaultCategories.isNotEmpty) ...[
          _buildSectionHeader('My Categories', 0),
          const SizedBox(height: 12),
          AppTheme.buildGlassmorphicCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    size: 48,
                    color: AppColors.greyText,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Create Your First Category',
                    style: TextStyle(
                      color: AppColors.darkText,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add custom categories to better organize your expenses',
                    style: TextStyle(
                      color: AppColors.greyText,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showAddCategoryModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add Category'),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.darkText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _showAddCategoryModal,
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text('Add Category'),
      tooltip: 'Add new category',
    );
  }

  // Action methods
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
        _filteredCategories = _allCategories;
      }
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'refresh':
        HapticFeedback.lightImpact();
        _loadCategories();
        break;
      case 'help':
        _showHelpDialog();
        break;
    }
  }

  Future<void> _showAddCategoryModal() async {
    HapticFeedback.lightImpact();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CategoryFormModal(),
    );

    if (result == true) {
      await _loadCategories();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _showEditCategoryModal(Category category) async {
    HapticFeedback.lightImpact();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoryFormModal(category: category),
    );

    if (result == true) {
      await _loadCategories();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmation(Category category) async {
    HapticFeedback.lightImpact();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Delete Category',
          style: TextStyle(color: AppColors.whiteText),
        ),
        content: Text(
          'Are you sure you want to delete "${category.name}"?\n\nAny expenses using this category will be moved to "Uncategorized".',
          style: const TextStyle(color: AppColors.whiteText70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.accentRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteCategory(category);
    }
  }

  Future<void> _deleteCategory(Category category) async {
    try {
      await _categoryRepository.deleteCategory(category.id);
      await _loadCategories();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${category.name} deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete category: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    }
  }

  void _showCategoryDetails(Category category) {
    // TODO: Implement category details/usage statistics
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Category: ${category.name}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Category Management',
          style: TextStyle(color: AppColors.darkText),
        ),
        content: const Text(
          'Default categories are provided by the app and cannot be edited or deleted.\n\n'
          'You can create custom categories with your own names, icons, and colors.\n\n'
          'Custom categories can be edited or deleted at any time.',
          style: TextStyle(color: AppColors.greyText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
