import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expensetracker/src/features/categories/domain/category.dart';
import 'package:expensetracker/src/features/categories/presentation/widgets/category_icon_mapper.dart';
import 'package:expensetracker/src/shared/theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategorySelectionWidget extends StatefulWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final Function(Category category) onCategorySelected;
  final bool showSearch;
  final bool showRecentCategories;

  const CategorySelectionWidget({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onCategorySelected,
    this.showSearch = true,
    this.showRecentCategories = true,
  });

  @override
  State<CategorySelectionWidget> createState() => _CategorySelectionWidgetState();
}

class _CategorySelectionWidgetState extends State<CategorySelectionWidget>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Category> _filteredCategories = [];
  List<Category> _recentCategories = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _filteredCategories = widget.categories;
    _loadRecentCategories();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentCategories() async {
    if (!widget.showRecentCategories) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final recentCategoryIds = prefs.getStringList('recent_categories') ?? [];
      
      setState(() {
        _recentCategories = recentCategoryIds
            .map((id) => widget.categories.firstWhere(
                  (cat) => cat.id == id,
                  orElse: () => Category(id: '', name: ''),
                ))
            .where((cat) => cat.id.isNotEmpty)
            .take(4)
            .toList();
      });
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _saveRecentCategory(String categoryId) async {
    if (!widget.showRecentCategories) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final recentCategoryIds = prefs.getStringList('recent_categories') ?? [];
      
      // Remove if already exists and add to front
      recentCategoryIds.remove(categoryId);
      recentCategoryIds.insert(0, categoryId);
      
      // Keep only last 10 recent categories
      if (recentCategoryIds.length > 10) {
        recentCategoryIds.removeRange(10, recentCategoryIds.length);
      }
      
      await prefs.setStringList('recent_categories', recentCategoryIds);
    } catch (e) {
      // Handle error silently
    }
  }

  void _filterCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = widget.categories;
      } else {
        _filteredCategories = widget.categories
            .where((category) =>
                category.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _selectCategory(Category category) {
    HapticFeedback.lightImpact();
    _saveRecentCategory(category.id);
    widget.onCategorySelected(category);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showSearch) _buildSearchBar(),
          if (widget.showRecentCategories && _recentCategories.isNotEmpty) ...[
            _buildRecentCategoriesSection(),
            const SizedBox(height: 16),
          ],
          _buildAllCategoriesSection(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: _filterCategories,
        decoration: InputDecoration(
          hintText: 'Search categories...',
          prefixIcon: const Icon(Icons.search, color: AppColors.greyText),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.greyText),
                  onPressed: () {
                    _searchController.clear();
                    _filterCategories('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildRecentCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Recently Used',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _recentCategories.length,
            itemBuilder: (context, index) {
              final category = _recentCategories[index];
              final isSelected = category.id == widget.selectedCategoryId;
              
              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => _selectCategory(category),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.accent.withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? AppColors.accent
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: category.color != null
                                ? Color(int.parse(category.color!.substring(1, 7), radix: 16) + 0xFF000000)
                                : AppColors.primaryStart,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: FaIcon(
                              CategoryIconMapper.getIcon(category.icon),
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category.name,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? AppColors.accent : AppColors.darkText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
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
    );
  }

  Widget _buildAllCategoriesSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _searchController.text.isNotEmpty
                  ? 'Search Results (${_filteredCategories.length})'
                  : 'All Categories',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _buildCategoryGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    if (_filteredCategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: AppColors.greyText.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No categories found',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.greyText.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search terms',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.greyText.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredCategories.length,
      itemBuilder: (context, index) {
        final category = _filteredCategories[index];
        final isSelected = category.id == widget.selectedCategoryId;

        return GestureDetector(
          onTap: () => _selectCategory(category),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accent.withOpacity(0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.accent
                    : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
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
                    child: Center(
                      child: FaIcon(
                        CategoryIconMapper.getIcon(category.icon),
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? AppColors.accent : AppColors.darkText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: AppColors.accent,
                      size: 18,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
