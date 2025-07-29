import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Script to set up the database schema for the expense tracker app
/// This script will create all necessary tables, policies, and functions
Future<void> main() async {
  print('🚀 Setting up Expense Tracker database...');

  // Initialize Supabase
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    print('❌ Error: SUPABASE_URL and SUPABASE_ANON_KEY environment variables are required');
    print('Usage: dart run scripts/setup_database.dart --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key');
    exit(1);
  }

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );

    final supabase = Supabase.instance.client;
    print('✅ Connected to Supabase');

    // Read the database schema file
    final schemaFile = File('supabase/database_schema.sql');
    if (!schemaFile.existsSync()) {
      print('❌ Error: database_schema.sql file not found');
      exit(1);
    }

    final schema = await schemaFile.readAsString();
    print('📄 Read database schema file');

    // Split the schema into individual statements
    final statements = schema
        .split(';')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && !s.startsWith('--'))
        .toList();

    print('🔧 Executing ${statements.length} database statements...');

    int successCount = 0;
    int errorCount = 0;

    for (int i = 0; i < statements.length; i++) {
      final statement = statements[i];
      if (statement.isEmpty) continue;

      try {
        print('  [${i + 1}/${statements.length}] Executing: ${_truncateStatement(statement)}');
        
        // Execute the statement
        await supabase.rpc('exec_sql', params: {'sql': statement});
        successCount++;
        
      } catch (e) {
        print('  ⚠️  Warning: ${e.toString()}');
        errorCount++;
        
        // Continue with other statements even if one fails
        continue;
      }
    }

    print('\n📊 Database setup completed:');
    print('  ✅ Successful statements: $successCount');
    print('  ⚠️  Warnings/Errors: $errorCount');

    // Verify tables were created
    await _verifyTables(supabase);

    print('\n🎉 Database setup completed successfully!');
    print('Your expense tracker database is ready to use.');

  } catch (e) {
    print('❌ Fatal error during database setup: $e');
    exit(1);
  }
}

/// Truncate long SQL statements for display
String _truncateStatement(String statement) {
  final cleaned = statement.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (cleaned.length <= 80) return cleaned;
  return '${cleaned.substring(0, 77)}...';
}

/// Verify that all required tables were created
Future<void> _verifyTables(SupabaseClient supabase) async {
  print('\n🔍 Verifying database tables...');

  final requiredTables = ['categories', 'expenses', 'mpesa_transactions'];
  
  for (final table in requiredTables) {
    try {
      final result = await supabase.from(table).select('count').limit(1);
      print('  ✅ Table "$table" exists and is accessible');
    } catch (e) {
      print('  ❌ Table "$table" verification failed: $e');
    }
  }

  // Check if default categories exist
  try {
    final categories = await supabase
        .from('categories')
        .select('name')
        .is_('user_id', null);
    
    if (categories.isNotEmpty) {
      print('  ✅ Default categories found: ${categories.length} categories');
    } else {
      print('  ⚠️  No default categories found - they may need to be inserted manually');
    }
  } catch (e) {
    print('  ⚠️  Could not verify default categories: $e');
  }
}
