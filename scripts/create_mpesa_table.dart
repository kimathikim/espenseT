import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final supabase = Supabase.instance.client;

  try {
    // Create the mpesa_transactions table
    await supabase.rpc('create_mpesa_transactions_table');
    print('✅ mpesa_transactions table created successfully');
  } catch (e) {
    print('❌ Error creating table: $e');
    
    // Try alternative approach - create table using raw SQL
    try {
      final createTableSql = '''
        CREATE TABLE IF NOT EXISTS public.mpesa_transactions (
          id uuid NOT NULL DEFAULT gen_random_uuid(),
          created_at timestamp with time zone NOT NULL DEFAULT now(),
          user_id uuid NOT NULL,
          transaction_id text NOT NULL,
          type text NOT NULL,
          amount numeric NOT NULL,
          counterparty text NOT NULL,
          transaction_date timestamp with time zone NOT NULL,
          balance_after numeric NULL,
          raw_sms text NOT NULL,
          processed boolean NOT NULL DEFAULT false,
          CONSTRAINT mpesa_transactions_pkey PRIMARY KEY (id),
          CONSTRAINT mpesa_transactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE,
          CONSTRAINT mpesa_transactions_unique_per_user UNIQUE (user_id, transaction_id)
        );
      ''';
      
      await supabase.rpc('exec_sql', params: {'sql': createTableSql});
      print('✅ Table created using alternative method');
    } catch (e2) {
      print('❌ Alternative method also failed: $e2');
      print('Please create the table manually in Supabase dashboard');
    }
  }

  // Enable RLS
  try {
    await supabase.rpc('exec_sql', params: {
      'sql': 'ALTER TABLE public.mpesa_transactions ENABLE ROW LEVEL SECURITY;'
    });
    print('✅ RLS enabled');
  } catch (e) {
    print('⚠️  Could not enable RLS: $e');
  }

  // Create RLS policies
  final policies = [
    "CREATE POLICY \"Allow users to see their own mpesa transactions\" ON public.mpesa_transactions FOR SELECT USING (auth.uid() = user_id);",
    "CREATE POLICY \"Allow users to insert their own mpesa transactions\" ON public.mpesa_transactions FOR INSERT WITH CHECK (auth.uid() = user_id);",
    "CREATE POLICY \"Allow users to update their own mpesa transactions\" ON public.mpesa_transactions FOR UPDATE USING (auth.uid() = user_id);",
    "CREATE POLICY \"Allow users to delete their own mpesa transactions\" ON public.mpesa_transactions FOR DELETE USING (auth.uid() = user_id);",
  ];

  for (final policy in policies) {
    try {
      await supabase.rpc('exec_sql', params: {'sql': policy});
      print('✅ Policy created');
    } catch (e) {
      print('⚠️  Could not create policy: $e');
    }
  }

  print('🎉 Setup complete!');
}
