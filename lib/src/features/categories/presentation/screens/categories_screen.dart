import 'package:expensetracker/src/features/categories/data/category_repository.dart';
import 'package:expensetracker/src/features/categories/domain/category.dart';
import 'package:expensetracker/src/features/categories/presentation/screens/add_category_screen.dart';
import 'package:expensetracker/src/features/categories/presentation/screens/edit_category_screen.dart';
import 'package:expensetracker/src/features/categories/presentation/widgets/category_icon_mapper.dart';
import 'package:flutter/material.dart';
import 'package:expensetracker/src/shared/theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late Future<List<Category>> _categoriesFuture;
  final _categoryRepository = CategoryRepository();

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _categoryRepository.fetchCategories();
  }

  Future<void> _refreshCategories() async {
    setState(() {
      _categoriesFuture = _categoryRepository.fetchCategories(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: RefreshIndicator(
          onRefresh: _refreshCategories,
          child: FutureBuilder<List<Category>>(
            future: _categoriesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No categories found.'));
              }

              final categories = snapshot.data!;
              return ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return AppTheme.buildGlassmorphicCard(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: category.color != null
                                ? Color(int.parse(category.color!.substring(1, 7), radix: 16) + 0xFF000000)
                                : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: FaIcon(
                              CategoryIconMapper.getIcon(category.icon),
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          category.name,
                          style: const TextStyle(
                            color: AppColors.whiteText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.whiteText),
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EditCategoryScreen(category: category),
                              ),
                            );
                            _refreshCategories();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.accentRed),
                          onPressed: () async {
                            await CategoryRepository().deleteCategory(category.id);
                            _refreshCategories();
                          },
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddCategoryScreen(),
            ),
          );
          _refreshCategories();
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Category',
      ),
    );
  }
}
