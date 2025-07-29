import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expensetracker/src/shared/theme.dart';

class SetupDatabaseScreen extends StatefulWidget {
  const SetupDatabaseScreen({super.key});

  @override
  State<SetupDatabaseScreen> createState() => _SetupDatabaseScreenState();
}

class _SetupDatabaseScreenState extends State<SetupDatabaseScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isCreating = false;
  String _status = '';

  final String _createTableSQL = '''
CREATE TABLE public.mpesa_transactions (
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

ALTER TABLE public.mpesa_transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow users to see their own mpesa transactions" ON public.mpesa_transactions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Allow users to insert their own mpesa transactions" ON public.mpesa_transactions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Allow users to update their own mpesa transactions" ON public.mpesa_transactions FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Allow users to delete their own mpesa transactions" ON public.mpesa_transactions FOR DELETE USING (auth.uid() = user_id);
''';

  Future<void> _testConnection() async {
    setState(() {
      _isCreating = true;
      _status = 'Testing connection...';
    });

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Test if table exists
      await _supabase.from('mpesa_transactions')
          .select('count')
          .eq('user_id', user.id)
          .limit(1);
      
      setState(() {
        _status = '✅ Table exists and connection successful!';
      });
    } catch (e) {
      setState(() {
        if (e.toString().contains('relation') && e.toString().contains('does not exist')) {
          _status = '⚠️ Table does not exist. Please create it manually in Supabase dashboard.';
        } else {
          _status = '❌ Connection failed: $e';
        }
      });
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }

  void _copySQL() {
    Clipboard.setData(ClipboardData(text: _createTableSQL));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SQL copied to clipboard!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Setup'),
        backgroundColor: AppColors.primaryStart,
        foregroundColor: AppColors.whiteText,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'M-Pesa Database Setup',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'The M-Pesa integration requires a database table to store transactions. Follow these steps:',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.greyText,
              ),
            ),
            const SizedBox(height: 24),
            
            // Step 1
            _buildStep(
              '1',
              'Test Connection',
              'Check if the mpesa_transactions table exists',
              ElevatedButton(
                onPressed: _isCreating ? null : _testConnection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryStart,
                  foregroundColor: AppColors.whiteText,
                ),
                child: _isCreating 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.whiteText),
                        ),
                      )
                    : const Text('Test Connection'),
              ),
            ),
            
            if (_status.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _status.startsWith('✅') 
                      ? AppColors.success.withOpacity(0.1)
                      : _status.startsWith('⚠️')
                          ? Colors.orange.withOpacity(0.1)
                          : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _status.startsWith('✅') 
                        ? AppColors.success
                        : _status.startsWith('⚠️')
                            ? Colors.orange
                            : AppColors.error,
                  ),
                ),
                child: Text(
                  _status,
                  style: TextStyle(
                    color: _status.startsWith('✅') 
                        ? AppColors.success
                        : _status.startsWith('⚠️')
                            ? Colors.orange
                            : AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Step 2
            _buildStep(
              '2',
              'Copy SQL Script',
              'Copy the table creation script to your clipboard',
              ElevatedButton.icon(
                onPressed: _copySQL,
                icon: const Icon(Icons.copy),
                label: const Text('Copy SQL'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.whiteText,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Step 3
            _buildStep(
              '3',
              'Execute in Supabase',
              'Go to your Supabase dashboard → SQL Editor → paste and run the script',
              TextButton.icon(
                onPressed: () {
                  // Could open Supabase dashboard URL here
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open Supabase Dashboard'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryStart,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String number, String title, String description, Widget action) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.whiteText,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryStart,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: AppColors.whiteText,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.greyText,
                  ),
                ),
                const SizedBox(height: 16),
                action,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
