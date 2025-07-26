import 'package:flutter/material.dart';
import 'package:expensetracker/src/shared/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _loading = false;
  IconData _selectedIcon = FontAwesomeIcons.question;
  Color _selectedColor = AppColors.chartColors[0];

  final List<IconData> _icons = [
    FontAwesomeIcons.cartShopping,
    FontAwesomeIcons.utensils,
    FontAwesomeIcons.bus,
    FontAwesomeIcons.house,
    FontAwesomeIcons.film,
    FontAwesomeIcons.heartPulse,
    FontAwesomeIcons.ellipsis,
  ];

  Future<void> _addCategory() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });
      try {
        final name = _nameController.text.trim();
        await Supabase.instance.client.from('categories').insert({
          'name': name,
          'user_id': Supabase.instance.client.auth.currentUser!.id,
          'icon_name': _selectedIcon.codePoint.toString(),
          'color': '#${_selectedColor.value.toRadixString(16).substring(2)}',
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Category added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (error) {
        print('Error adding category: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding category: $error'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _loading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Category'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: AppTheme.buildGlassmorphicCard(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Create a New Category',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.whiteText),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                        labelStyle: TextStyle(color: AppColors.whiteText),
                      ),
                      style: const TextStyle(color: AppColors.whiteText),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a category name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildIconPicker(),
                    const SizedBox(height: 24),
                    _buildColorPicker(),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loading ? null : _addCategory,
                      child: Text(_loading ? 'Adding...' : 'Add Category'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Icon',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.whiteText),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _icons.length,
            itemBuilder: (context, index) {
              final icon = _icons[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIcon = icon;
                  });
                },
                child: Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: _selectedIcon == icon ? _selectedColor : AppColors.glassBackground,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedIcon == icon ? Colors.white : AppColors.glassBorder,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: _selectedIcon == icon ? Colors.white : AppColors.whiteText,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.whiteText),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: AppColors.chartColors.length,
            itemBuilder: (context, index) {
              final color = AppColors.chartColors[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                child: Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedColor == color ? Colors.white : Colors.transparent,
                      width: 2,
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
}
