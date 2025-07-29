import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:expensetracker/src/features/categories/data/category_repository.dart';
import 'package:expensetracker/src/features/categories/domain/category.dart';
import 'package:expensetracker/src/features/categories/presentation/widgets/category_icon_mapper.dart';
import 'package:expensetracker/src/shared/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryFormModal extends StatefulWidget {
  final Category? category; // null for add, non-null for edit

  const CategoryFormModal({
    super.key,
    this.category,
  });

  @override
  State<CategoryFormModal> createState() => _CategoryFormModalState();
}

class _CategoryFormModalState extends State<CategoryFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final CategoryRepository _categoryRepository = CategoryRepository();
  
  String _selectedIcon = 'faFolder';
  String _selectedColor = '#667eea';
  bool _isLoading = false;
  List<Category> _existingCategories = [];

  // Predefined color palette
  final List<String> _colorPalette = [
    '#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7',
    '#DDA0DD', '#74B9FF', '#00B894', '#6C5CE7', '#FD79A8',
    '#FDCB6E', '#B2BEC3', '#667eea', '#f093fb', '#f5576c',
    '#4facfe', '#43e97b', '#fa709a', '#fee140', '#a8edea',
  ];

  // Popular icons for categories
  final List<String> _iconOptions = [
    'faUtensils', 'faCar', 'faShoppingBag', 'faFileInvoiceDollar',
    'faGamepad', 'faHeartbeat', 'faGraduationCap', 'faPlane',
    'faBriefcase', 'faSpa', 'faGift', 'faFolder',
    'faHome', 'faShoppingCart', 'faGasPump', 'faTshirt',
    'faFilm', 'faBook', 'faCoffee', 'faPizzaSlice',
    'faPhone', 'faLaptop', 'faMusic', 'faPaw',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingCategories();
    
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedIcon = widget.category!.icon ?? 'faFolder';
      _selectedColor = widget.category!.color ?? '#667eea';
    }
  }

  Future<void> _loadExistingCategories() async {
    try {
      final categories = await _categoryRepository.fetchCategories();
      setState(() {
        _existingCategories = categories;
      });
    } catch (e) {
      // Handle error silently for now
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildForm(),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.greyText.withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _parseColor(_selectedColor),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: FaIcon(
                CategoryIconMapper.getIcon(_selectedIcon),
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.category == null ? 'Add Category' : 'Edit Category',
                  style: const TextStyle(
                    color: AppColors.darkText,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.category == null 
                      ? 'Create a new custom category'
                      : 'Modify category details',
                  style: const TextStyle(
                    color: AppColors.greyText,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(false),
            icon: const Icon(
              Icons.close,
              color: AppColors.greyText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNameField(),
            const SizedBox(height: 24),
            _buildIconSelector(),
            const SizedBox(height: 24),
            _buildColorSelector(),
            const SizedBox(height: 24),
            _buildPreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category Name',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          style: const TextStyle(color: AppColors.darkText),
          decoration: InputDecoration(
            hintText: 'Enter category name',
            hintStyle: const TextStyle(color: AppColors.greyText),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: _validateName,
          textCapitalization: TextCapitalization.words,
          onChanged: (value) => setState(() {}), // Refresh preview
        ),
      ],
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Icon',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _iconOptions.length,
            itemBuilder: (context, index) {
              final iconName = _iconOptions[index];
              final isSelected = iconName == _selectedIcon;
              
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedIcon = iconName;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? _parseColor(_selectedColor).withOpacity(0.3)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected 
                          ? _parseColor(_selectedColor)
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: FaIcon(
                      CategoryIconMapper.getIcon(iconName),
                      color: isSelected 
                          ? _parseColor(_selectedColor)
                          : AppColors.greyText,
                      size: 20,
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

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 10,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _colorPalette.length,
            itemBuilder: (context, index) {
              final colorString = _colorPalette[index];
              final color = _parseColor(colorString);
              final isSelected = colorString == _selectedColor;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedColor = colorString;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: AppColors.darkText, width: 3)
                        : Border.all(color: AppColors.greyText.withOpacity(0.3), width: 1),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: isSelected
                      ? const Center(
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preview',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _parseColor(_selectedColor),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _parseColor(_selectedColor).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: FaIcon(
                    CategoryIconMapper.getIcon(_selectedIcon),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameController.text.isEmpty
                          ? 'Category Name'
                          : _nameController.text,
                      style: TextStyle(
                        color: _nameController.text.isEmpty
                            ? AppColors.greyText
                            : AppColors.darkText,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Custom category',
                      style: TextStyle(
                        color: AppColors.greyText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.greyText.withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.greyText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveCategory,
              style: ElevatedButton.styleFrom(
                backgroundColor: _parseColor(_selectedColor),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
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
                  : Text(
                      widget.category == null ? 'Create' : 'Update',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Category name is required';
    }

    if (value.trim().length > 50) {
      return 'Category name must be 50 characters or less';
    }

    // Check for duplicate names (excluding current category if editing)
    final existingNames = _existingCategories
        .where((c) => widget.category == null || c.id != widget.category!.id)
        .map((c) => c.name.toLowerCase())
        .toList();

    if (existingNames.contains(value.trim().toLowerCase())) {
      return 'A category with this name already exists';
    }

    return null;
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final categoryData = Category(
        id: widget.category?.id ?? '',
        name: _nameController.text.trim(),
        icon: _selectedIcon,
        color: _selectedColor,
        userId: user.id,
        createdAt: widget.category?.createdAt,
      );

      if (widget.category == null) {
        // Create new category
        await _categoryRepository.createCategory(categoryData);
      } else {
        // Update existing category
        await _categoryRepository.updateCategory(categoryData);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save category: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Color _parseColor(String colorString) {
    try {
      final cleanColor = colorString.startsWith('#')
          ? colorString.substring(1)
          : colorString;
      return Color(int.parse(cleanColor, radix: 16) + 0xFF000000);
    } catch (e) {
      return AppColors.accent;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
