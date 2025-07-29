import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:expensetracker/src/features/categories/domain/category.dart';
import 'package:expensetracker/src/features/categories/presentation/widgets/category_icon_mapper.dart';
import 'package:expensetracker/src/shared/theme.dart';

class CategoryListItem extends StatefulWidget {
  final Category category;
  final bool isDefault;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final int? transactionCount;
  final double? totalAmount;

  const CategoryListItem({
    super.key,
    required this.category,
    required this.isDefault,
    this.onEdit,
    this.onDelete,
    this.onTap,
    this.transactionCount,
    this.totalAmount,
  });

  @override
  State<CategoryListItem> createState() => _CategoryListItemState();
}

class _CategoryListItemState extends State<CategoryListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTapDown: (_) => _onTapDown(),
          onTapUp: (_) => _onTapUp(),
          onTapCancel: _onTapCancel,
          onTap: widget.onTap,
          child: AppTheme.buildGlassmorphicCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildCategoryIcon(),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCategoryInfo()),
                  if (widget.transactionCount != null) ...[
                    const SizedBox(width: 12),
                    _buildUsageStats(),
                  ],
                  const SizedBox(width: 12),
                  _buildActions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon() {
    final color = _parseColor(widget.category.color);
    
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: FaIcon(
          CategoryIconMapper.getIcon(widget.category.icon),
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildCategoryInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.category.name,
                style: const TextStyle(
                  color: AppColors.whiteText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.isDefault) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'DEFAULT',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          widget.isDefault 
              ? 'Built-in category'
              : 'Custom category',
          style: const TextStyle(
            color: AppColors.whiteText70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildUsageStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${widget.transactionCount ?? 0}',
          style: const TextStyle(
            color: AppColors.whiteText,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          'transactions',
          style: TextStyle(
            color: AppColors.whiteText70,
            fontSize: 10,
          ),
        ),
        if (widget.totalAmount != null) ...[
          const SizedBox(height: 2),
          Text(
            'KSh ${widget.totalAmount!.toStringAsFixed(0)}',
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActions() {
    if (widget.isDefault) {
      return const Icon(
        Icons.lock_outline,
        color: AppColors.whiteText70,
        size: 20,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.onEdit != null)
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: AppColors.whiteText70,
              size: 20,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              widget.onEdit!();
            },
            tooltip: 'Edit category',
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        if (widget.onDelete != null)
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.accentRed,
              size: 20,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              widget.onDelete!();
            },
            tooltip: 'Delete category',
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
      ],
    );
  }

  Color _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return AppColors.accent;
    }
    
    try {
      // Remove # if present
      final cleanColor = colorString.startsWith('#') 
          ? colorString.substring(1) 
          : colorString;
      
      // Parse hex color
      return Color(int.parse(cleanColor, radix: 16) + 0xFF000000);
    } catch (e) {
      return AppColors.accent;
    }
  }

  void _onTapDown() {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
