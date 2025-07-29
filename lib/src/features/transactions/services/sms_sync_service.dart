import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expensetracker/src/features/transactions/services/sms_transaction_parser.dart';
import 'package:expensetracker/src/features/transactions/data/expense_service.dart';

enum SyncStatus {
  idle,
  syncing,
  success,
  error,
  offline
}

class SyncResult {
  final bool success;
  final String? error;
  final int newTransactions;
  final int updatedTransactions;
  final DateTime timestamp;

  SyncResult({
    required this.success,
    this.error,
    this.newTransactions = 0,
    this.updatedTransactions = 0,
    required this.timestamp,
  });
}

/// SMS-based M-Pesa transaction sync service (Alternative to Daraja API)
class SmsSyncService extends ChangeNotifier {
  static final SmsSyncService _instance = SmsSyncService._internal();
  factory SmsSyncService() => _instance;
  SmsSyncService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final SmsTransactionParser _smsParser = SmsTransactionParser();
  final ExpenseService _expenseService = ExpenseService();
  
  SyncStatus _status = SyncStatus.idle;
  SyncResult? _lastSyncResult;
  Timer? _periodicSyncTimer;
  StreamSubscription? _realtimeSubscription;
  
  // Sync configuration
  static const Duration _syncInterval = Duration(minutes: 15); // Less frequent for SMS
  static const int _maxRetries = 2; // Fewer retries for SMS
  static const Duration _retryDelay = Duration(seconds: 30);
  
  int _retryCount = 0;
  Timer? _retryTimer;

  // Getters
  SyncStatus get status => _status;
  SyncResult? get lastSyncResult => _lastSyncResult;
  bool get isSyncing => _status == SyncStatus.syncing;
  bool get hasError => _status == SyncStatus.error;
  String? get lastError => _lastSyncResult?.error;

  /// Initialize the SMS sync service
  Future<void> initialize() async {
    try {
      await _setupRealtimeSubscription();
      await _startPeriodicSync();
      _startSmsListener();
      debugPrint('✅ SMS-based TransactionSyncService initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize SMS TransactionSyncService: $e');
    }
  }

  /// Setup real-time subscription for live transaction updates
  Future<void> _setupRealtimeSubscription() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      _realtimeSubscription = _supabase
          .from('expenses')
          .stream(primaryKey: ['id'])
          .eq('user_id', user.id)
          .listen((data) {
            debugPrint('📡 Real-time transaction update received: ${data.length} records');
            notifyListeners();
          });
    } catch (e) {
      debugPrint('⚠️ Failed to setup realtime subscription: $e');
    }
  }

  /// Start periodic background sync
  Future<void> _startPeriodicSync() async {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = Timer.periodic(_syncInterval, (_) => syncTransactions());
  }

  /// Start SMS listener for real-time M-Pesa notifications
  void _startSmsListener() {
    _smsParser.startSmsListener();
  }

  /// Manual sync trigger with comprehensive error handling
  Future<SyncResult> syncTransactions({bool showProgress = true}) async {
    if (_status == SyncStatus.syncing) {
      return _lastSyncResult ?? SyncResult(success: false, error: 'Sync already in progress', timestamp: DateTime.now());
    }

    if (showProgress) {
      _updateStatus(SyncStatus.syncing);
    }

    try {
      debugPrint('🔄 Starting SMS-based M-Pesa sync...');
      
      // Sync via SMS parsing
      final newTransactions = await _smsParser.syncTransactionsFromSms();

      final result = SyncResult(
        success: true,
        newTransactions: newTransactions,
        timestamp: DateTime.now(),
      );

      _lastSyncResult = result;
      _updateStatus(SyncStatus.success);
      _retryCount = 0; // Reset retry count on success
      
      debugPrint('✅ SMS sync completed: $newTransactions new transactions');
      return result;

    } catch (e) {
      debugPrint('❌ SMS sync failed: $e');
      
      final result = SyncResult(
        success: false,
        error: _getErrorMessage(e),
        timestamp: DateTime.now(),
      );

      _lastSyncResult = result;
      _updateStatus(SyncStatus.error);
      
      // Implement retry logic
      await _scheduleRetry();
      
      return result;
    }
  }

  /// Schedule retry with exponential backoff
  Future<void> _scheduleRetry() async {
    if (_retryCount >= _maxRetries) {
      debugPrint('❌ Max retries reached, giving up');
      return;
    }

    _retryCount++;
    final delay = _retryDelay * _retryCount; // Exponential backoff
    
    debugPrint('⏳ Scheduling SMS sync retry #$_retryCount in ${delay.inSeconds}s');
    
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, () => syncTransactions(showProgress: false));
  }

  /// Update sync status and notify listeners
  void _updateStatus(SyncStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      notifyListeners();
    }
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('SMS permissions')) {
      return 'SMS permissions required. Please grant SMS access to sync M-Pesa transactions.';
    } else if (error.toString().contains('No categories found')) {
      return 'Please create expense categories first before syncing transactions.';
    } else if (error.toString().contains('User not authenticated')) {
      return 'Please log in to sync transactions.';
    } else {
      return 'SMS sync failed: ${error.toString()}';
    }
  }

  /// Force sync now (for pull-to-refresh)
  Future<SyncResult> forceSyncNow() async {
    _retryCount = 0; // Reset retry count for manual sync
    return syncTransactions(showProgress: true);
  }

  /// Stop all sync operations
  void stopSync() {
    _periodicSyncTimer?.cancel();
    _retryTimer?.cancel();
    _realtimeSubscription?.cancel();
    _smsParser.stopSmsListener();
    _updateStatus(SyncStatus.idle);
  }

  @override
  void dispose() {
    stopSync();
    super.dispose();
  }
}
