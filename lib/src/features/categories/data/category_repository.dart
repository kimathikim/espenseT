import 'package:flutter/foundation.dart';
import 'package:expensetracker/src/core/services/database_service.dart';
import 'package:expensetracker/src/core/services/local_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expensetracker/src/features/categories/domain/category.dart' as domain;

class CategoryRepository {
  final _client = Supabase.instance.client;
  final _db = DatabaseService().database;

  Future<List<domain.Category>> fetchCategories({bool forceRefresh = false}) async {
    if (forceRefresh || _db == null) {
      return _fetchFromSupabase();
    }

    try {
      final localCategories = await _db!.categoryDao.getAllCategories();
      if (localCategories.isNotEmpty) {
        return localCategories.map((e) => e.toDomain()).toList();
      }
    } catch (e) {
      // If local database fails, fall back to Supabase
      debugPrint('Local database error, falling back to Supabase: $e');
    }

    return _fetchFromSupabase();
  }

  Future<List<domain.Category>> _fetchFromSupabase() async {
    try {
      final data = await _client
          .from('categories')
          .select()
          .order('name', ascending: true);
      final categories = (data as List).map((json) => domain.Category.fromJson(json)).toList();

      // Try to cache locally if database is available
      if (_db != null) {
        try {
          await _db!.categoryDao.insertCategories(categories.cast<domain.Category>());
        } catch (e) {
          debugPrint('Failed to cache categories locally: $e');
        }
      }

      return categories;
    } catch (e) {
      // It's better to handle specific exceptions, but for now, we'll rethrow.
      rethrow;
    }
  }

  Future<void> updateCategory(domain.Category category) async {
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
  domain.Category toDomain() {
    return domain.Category(
      id: id,
      name: name,
      icon: icon,
      color: color,
    );
  }
}
