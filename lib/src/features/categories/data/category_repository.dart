import 'package:expensetracker/src/core/services/database_service.dart';
import 'package:expensetracker/src/core/services/local_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expensetracker/src/features/categories/domain/category.dart';

class CategoryRepository {
  final _client = Supabase.instance.client;
  final _db = DatabaseService().database;

  Future<List<Category>> fetchCategories({bool forceRefresh = false}) async {
    if (forceRefresh) {
      return _fetchFromSupabase();
    }

    final localCategories = await _db.categoryDao.getAllCategories();
    if (localCategories.isNotEmpty) {
      return localCategories.map((e) => e.toDomain()).toList();
    }

    return _fetchFromSupabase();
  }

  Future<List<Category>> _fetchFromSupabase() async {
    try {
      final data = await _client
          .from('categories')
          .select()
          .order('name', ascending: true);
      final categories = (data as List).map((json) => Category.fromJson(json)).toList();
      await _db.categoryDao.insertCategories(categories);
      return categories;
    } catch (e) {
      // It's better to handle specific exceptions, but for now, we'll rethrow.
      rethrow;
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _client
          .from('categories')
          .update(category.toJson())
          .eq('id', category.id);
      await _fetchFromSupabase(); // Refresh local cache
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _client.from('categories').delete().eq('id', categoryId);
      await _fetchFromSupabase(); // Refresh local cache
    } catch (e) {
      rethrow;
    }
  }
}

extension on LocalCategory {
  Category toDomain() {
    return Category(
      id: id,
      name: name,
      icon: icon,
      color: color,
    );
  }
}
