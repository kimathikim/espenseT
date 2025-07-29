import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telephony/telephony.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/mpesa_sms_parser.dart';
import '../models/mpesa_transaction.dart';

/// Mobile implementation of SMS Monitor Service
class SmsMonitorService extends ChangeNotifier {
  static final SmsMonitorService _instance = SmsMonitorService._internal();
  factory SmsMonitorService() => _instance;
  SmsMonitorService._internal();

  final Telephony _telephony = Telephony.instance;
  final SupabaseClient _supabase = Supabase.instance.client;
  StreamSubscription<SmsMessage>? _smsSubscription;
  
  bool _isMonitoring = false;
  bool _hasPermission = false;
  int _transactionsProcessed = 0;

  bool get isMonitoring => _isMonitoring;
  bool get hasPermission => _hasPermission;
  int get transactionsProcessed => _transactionsProcessed;

  Future<bool> requestPermissions() async {
    try {
      final smsPermission = await Permission.sms.request();
      _hasPermission = smsPermission.isGranted;
      notifyListeners();
      return _hasPermission;
    } catch (e) {
      debugPrint('Error requesting SMS permission: $e');
      return false;
    }
  }

  Future<void> startMonitoring() async {
    if (_isMonitoring) return;

    if (!await requestPermissions()) {
      throw Exception('SMS permission is required for M-Pesa integration');
    }

    try {
      _telephony.listenIncomingSms(
        onNewMessage: _handleNewSms,
        listenInBackground: true,
      );
      _isMonitoring = true;
      
      _isMonitoring = true;
      notifyListeners();
      debugPrint('SMS monitoring started');
    } catch (e) {
      debugPrint('Error starting SMS monitoring: $e');
      throw Exception('Failed to start SMS monitoring: $e');
    }
  }

  void _handleNewSms(SmsMessage message) async {
    try {
      if (!_isMpesaSms(message)) return;

      final transaction = MpesaSmsParser.parseSms(
        message.body ?? '',
        DateTime.fromMillisecondsSinceEpoch(message.date ?? 0),
      );

      if (transaction != null) {
        await _saveTransaction(transaction);
        _transactionsProcessed++;
        notifyListeners();
        debugPrint('New M-Pesa transaction processed: ${transaction.transactionId}');
      }
    } catch (e) {
      debugPrint('Error handling SMS: $e');
    }
  }

  bool _isMpesaSms(SmsMessage message) {
    final sender = message.address?.toLowerCase() ?? '';
    final body = message.body?.toLowerCase() ?? '';
    
    return sender.contains('mpesa') || 
           sender.contains('safaricom') ||
           body.contains('m-pesa') ||
           (body.contains('mpesa') && body.contains('confirmed'));
  }

  Future<void> _saveTransaction(MpesaTransaction transaction) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('mpesa_transactions').upsert({
        'user_id': user.id,
        'transaction_id': transaction.transactionId,
        'type': transaction.type,
        'amount': transaction.amount,
        'counterparty': transaction.counterparty,
        'balance_after': transaction.balanceAfter,
        'transaction_date': transaction.transactionDate.toIso8601String(),
        'raw_sms': transaction.rawSms,
        'processed': transaction.processed,
        'created_at': transaction.createdAt.toIso8601String(),
      });
      debugPrint('✅ M-Pesa transaction saved successfully');
    } catch (e) {
      debugPrint('❌ Error saving M-Pesa transaction: $e');
      // If table doesn't exist, provide helpful information
      if (e.toString().contains('relation') && e.toString().contains('does not exist')) {
        debugPrint('⚠️  mpesa_transactions table does not exist. Please create it in Supabase dashboard.');
        debugPrint('📋 Use this SQL to create the table:');
        debugPrint(_getCreateTableSQL());
      }
    }
  }

  String _getCreateTableSQL() {
    return '''
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
  }

  Future<int> syncHistoricalSms({int limit = 100}) async {
    if (!_hasPermission) {
      await requestPermissions();
    }

    try {
      final messages = await _telephony.getInboxSms();

      int processed = 0;
      final mpesaMessages = messages.where(_isMpesaSms).take(limit);

      for (final message in mpesaMessages) {
        final transaction = MpesaSmsParser.parseSms(
          message.body ?? '',
          DateTime.fromMillisecondsSinceEpoch(message.date ?? 0),
        );
        
        if (transaction != null) {
          await _saveTransaction(transaction);
          processed++;
        }
      }

      _transactionsProcessed += processed;
      notifyListeners();
      debugPrint('Synced $processed historical M-Pesa transactions');
      return processed;
    } catch (e) {
      debugPrint('Error syncing historical SMS: $e');
      return 0;
    }
  }

  Future<void> testConnection() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Test database connection
      await _supabase.from('mpesa_transactions')
          .select('count')
          .eq('user_id', user.id)
          .limit(1);

      debugPrint('✅ M-Pesa connection test successful');
    } catch (e) {
      debugPrint('❌ M-Pesa connection test failed: $e');
      if (e.toString().contains('relation') && e.toString().contains('does not exist')) {
        debugPrint('⚠️  mpesa_transactions table does not exist. Please create it in Supabase dashboard.');
        debugPrint('📋 Use this SQL to create the table:');
        debugPrint(_getCreateTableSQL());
      }
      throw Exception('Connection test failed: $e');
    }
  }

  void stopMonitoring() {
    _smsSubscription?.cancel();
    _smsSubscription = null;
    _isMonitoring = false;
    notifyListeners();
    debugPrint('SMS monitoring stopped');
  }

  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}
