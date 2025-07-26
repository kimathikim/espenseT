import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expensetracker/src/features/categories/domain/category.dart';

class CategoryRepository {
  final _client = Supabase.instance.client;

  Future<List<Category>> fetchCategories() async {
    try {
      final data = await _client
          .from('categories')
          .select()
          .order('name', ascending: true);
      return (data as List).map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      // It's better to handle specific exceptions, but for now, we'll rethrow.
      rethrow;
    }
  }
}
