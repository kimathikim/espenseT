import 'package:expensetracker/src/features/categories/data/category_repository.dart';
import 'package:expensetracker/src/features/categories/domain/category.dart';
import 'package:flutter/material.dart';
import 'package:expensetracker/src/shared/theme.dart';

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
      _categoriesFuture = _categoryRepository.fetchCategories();
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          category.name,
                          style: const TextStyle(
                            color: AppColors.whiteText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // TODO: Add edit and delete buttons
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
        onPressed: () {
          // TODO: Navigate to add category screen
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Category',
      ),
    );
  }
}
