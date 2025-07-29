import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:telephony/telephony.dart';
import 'package:expensetracker/src/features/mpesa/models/mpesa_transaction.dart';
import 'package:expensetracker/src/features/mpesa/models/mpesa_sms_parser.dart';

/// Unified M-Pesa sync service that handles both historical and real-time SMS syncing
class UnifiedMpesaSyncService extends ChangeNotifier {
  static final UnifiedMpesaSyncService _instance = UnifiedMpesaSyncService._internal();
  factory UnifiedMpesaSyncService() => _instance;
  UnifiedMpesaSyncService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final Telephony _telephony = Telephony.instance;
  
  bool _hasPermission = false;
  bool _isMonitoring = false;
  bool _isSyncing = false;
  int _transactionsProcessed = 0;
  String? _lastError;
  Timer? _periodicSyncTimer;

  // Getters
  bool get hasPermission => _hasPermission;
  bool get isMonitoring => _isMonitoring;
  bool get isSyncing => _isSyncing;
  int get transactionsProcessed => _transactionsProcessed;
  String? get lastError => _lastError;

  /// Initialize the service
  Future<void> initialize() async {
    try {
      await requestPermissions();
      if (_hasPermission) {
        await startMonitoring();
        debugPrint('✅ UnifiedMpesaSyncService initialized successfully');
      }
    } catch (e) {
      _lastError = e.toString();
      debugPrint('❌ Failed to initialize UnifiedMpesaSyncService: $e');
    }
  }

  /// Request SMS permissions
  Future<bool> requestPermissions() async {
    try {
      final hasPermission = await _telephony.requestPhoneAndSmsPermissions;
      _hasPermission = hasPermission == true;
      
      if (!_hasPermission) {
        _lastError = 'SMS permissions are required for M-Pesa sync';
      } else {
        _lastError = null;
      }
      
      notifyListeners();
      return _hasPermission;
    } catch (e) {
      _lastError = 'Failed to request permissions: $e';
      debugPrint('❌ Permission request failed: $e');
      notifyListeners();
      return false;
    }
  }

  /// Start monitoring for new M-Pesa SMS messages
  Future<void> startMonitoring() async {
    if (!_hasPermission) {
      await requestPermissions();
    }

    if (!_hasPermission) return;

    try {
      // Start real-time SMS listener
      _telephony.listenIncomingSms(
        onNewMessage: _handleNewSms,
        listenInBackground: false,
      );

      // Start periodic sync (every 30 minutes)
      _periodicSyncTimer?.cancel();
      _periodicSyncTimer = Timer.periodic(
        const Duration(minutes: 30),
        (_) => syncHistoricalSms(limit: 50), // Increased from 10 to 50 for periodic sync
      );

      _isMonitoring = true;
      _lastError = null;
      
      debugPrint('📱 Started M-Pesa SMS monitoring');
      notifyListeners();
    } catch (e) {
      _lastError = 'Failed to start monitoring: $e';
      debugPrint('❌ Failed to start monitoring: $e');
      notifyListeners();
    }
  }

  /// Stop monitoring
  void stopMonitoring() {
    _periodicSyncTimer?.cancel();
    _isMonitoring = false;
    debugPrint('📱 Stopped M-Pesa SMS monitoring');
    notifyListeners();
  }

  /// Handle new incoming SMS
  void _handleNewSms(SmsMessage message) {
    if (_isMpesaSms(message)) {
      debugPrint('📨 New M-Pesa SMS received: ${message.body?.substring(0, 50)}...');
      
      // Process after a short delay to ensure SMS is fully received
      Timer(const Duration(seconds: 2), () {
        _processSingleSms(message);
      });
    }
  }

  /// Process a single SMS message
  Future<void> _processSingleSms(SmsMessage message) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final transaction = MpesaSmsParser.parseSms(
        message.body ?? '',
        DateTime.fromMillisecondsSinceEpoch(message.date ?? 0),
      );

      if (transaction != null) {
        await _saveTransaction(transaction, user.id);
        _transactionsProcessed++;
        notifyListeners();
        debugPrint('✅ Processed new M-Pesa transaction: ${transaction.transactionId}');
      }
    } catch (e) {
      debugPrint('❌ Failed to process SMS: $e');
    }
  }

  /// Sync historical SMS messages
  Future<int> syncHistoricalSms({int? limit}) async {
    if (!_hasPermission) {
      await requestPermissions();
    }

    if (!_hasPermission) return 0;

    _isSyncing = true;
    _lastError = null;
    notifyListeners();

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('🔄 Starting historical M-Pesa SMS sync (limit: ${limit ?? 'unlimited'})...');

      // Get SMS messages from the last 30 days
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final messages = await _telephony.getInboxSms(
        columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
        filter: SmsFilter.where(SmsColumn.ADDRESS).equals('MPESA'),
        sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
      );

      debugPrint('📱 Retrieved ${messages.length} total SMS messages from MPESA');

      int processed = 0;
      var mpesaMessages = messages
          .where((msg) => _isMpesaSms(msg) &&
                        DateTime.fromMillisecondsSinceEpoch(msg.date ?? 0).isAfter(thirtyDaysAgo));

      // Apply limit only if specified
      if (limit != null) {
        mpesaMessages = mpesaMessages.take(limit);
      }

      final mpesaMessagesList = mpesaMessages.toList();
      debugPrint('📨 Found ${mpesaMessagesList.length} M-Pesa SMS messages to process');

      // Get existing transaction IDs to avoid duplicates
      final existingTransactions = await _supabase
          .from('mpesa_transactions')
          .select('transaction_id')
          .eq('user_id', user.id);

      final existingIds = existingTransactions
          .map((tx) => tx['transaction_id'] as String)
          .toSet();

      int skippedDuplicates = 0;
      int skippedUnparseable = 0;

      for (int i = 0; i < mpesaMessagesList.length; i++) {
        final message = mpesaMessagesList[i];
        try {
          final transaction = MpesaSmsParser.parseSms(
            message.body ?? '',
            DateTime.fromMillisecondsSinceEpoch(message.date ?? 0),
          );

          if (transaction == null) {
            skippedUnparseable++;
            debugPrint('⚠️ Could not parse SMS ${i + 1}/${mpesaMessagesList.length}: ${(message.body ?? '').substring(0, (message.body ?? '').length > 50 ? 50 : (message.body ?? '').length)}...');
            continue;
          }

          if (existingIds.contains(transaction.transactionId)) {
            skippedDuplicates++;
            continue;
          }

          await _saveTransaction(transaction, user.id);
          processed++;

          if (processed % 10 == 0) {
            debugPrint('📊 Progress: ${processed}/${mpesaMessagesList.length} transactions processed');
          }
        } catch (e) {
          debugPrint('⚠️ Failed to process SMS ${i + 1}: $e');
          continue;
        }
      }

      debugPrint('📊 Sync Summary:');
      debugPrint('  - Total SMS messages: ${mpesaMessagesList.length}');
      debugPrint('  - Successfully processed: $processed');
      debugPrint('  - Skipped duplicates: $skippedDuplicates');
      debugPrint('  - Skipped unparseable: $skippedUnparseable');

      _transactionsProcessed += processed;
      _isSyncing = false;
      _lastError = null;
      
      debugPrint('✅ Historical sync completed: $processed new transactions processed');
      notifyListeners();
      return processed;
    } catch (e) {
      _isSyncing = false;
      _lastError = 'Historical sync failed: $e';
      debugPrint('❌ Historical sync failed: $e');
      notifyListeners();
      return 0;
    }
  }

  /// Save M-Pesa transaction to database
  Future<void> _saveTransaction(MpesaTransaction transaction, String userId) async {
    try {
      await _supabase.from('mpesa_transactions').insert({
        'user_id': userId,
        'transaction_id': transaction.transactionId,
        'type': transaction.type,
        'amount': transaction.amount,
        'counterparty': transaction.counterparty,
        'transaction_date': transaction.transactionDate.toIso8601String(),
        'balance_after': transaction.balanceAfter,
        'raw_sms': transaction.rawSms,
        'processed': false, // Will be processed by database trigger
      });
    } catch (e) {
      // Check if it's a duplicate key error
      if (e.toString().contains('duplicate key') || e.toString().contains('unique constraint')) {
        debugPrint('ℹ️ Transaction ${transaction.transactionId} already exists');
        return;
      }
      rethrow;
    }
  }

  /// Check if SMS is from M-Pesa
  bool _isMpesaSms(SmsMessage message) {
    final address = message.address?.toUpperCase() ?? '';
    final body = message.body?.toLowerCase() ?? '';
    
    return address == 'MPESA' || 
           body.contains('m-pesa') || 
           body.contains('mpesa') ||
           (body.contains('confirmed') && body.contains('ksh'));
  }

  /// Test connection and permissions
  Future<bool> testConnection() async {
    try {
      if (!_hasPermission) {
        await requestPermissions();
      }

      if (!_hasPermission) return false;

      // Try to read one SMS message to test permissions
      final messages = await _telephony.getInboxSms(
        columns: [SmsColumn.ADDRESS],
        filter: SmsFilter.where(SmsColumn.ADDRESS).equals('MPESA'),
        sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
      );

      debugPrint('✅ Connection test successful: Found ${messages.length} M-Pesa messages');
      return true;
    } catch (e) {
      _lastError = 'Connection test failed: $e';
      debugPrint('❌ Connection test failed: $e');
      return false;
    }
  }

  /// Force sync now
  Future<int> forceSyncNow() async {
    return await syncHistoricalSms(); // No limit - process all available transactions
  }

  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}
