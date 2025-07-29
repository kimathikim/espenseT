import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Web implementation of SMS Monitor Service
/// Since web doesn't have access to SMS, this provides a stub implementation
class SmsMonitorService extends ChangeNotifier {
  static final SmsMonitorService _instance = SmsMonitorService._internal();
  factory SmsMonitorService() => _instance;
  SmsMonitorService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  
  bool _isMonitoring = false;
  bool _hasPermission = false;
  final int _transactionsProcessed = 0;

  bool get isMonitoring => _isMonitoring;
  bool get hasPermission => _hasPermission;
  int get transactionsProcessed => _transactionsProcessed;

  Future<bool> requestPermissions() async {
    // Web doesn't need SMS permissions
    _hasPermission = true;
    notifyListeners();
    return true;
  }

  Future<void> startMonitoring() async {
    if (_isMonitoring) return;

    // Web implementation - no actual SMS monitoring
    _isMonitoring = true;
    notifyListeners();
    debugPrint('SMS monitoring started (Web stub)');
  }

  Future<int> syncHistoricalSms({int limit = 100}) async {
    // Web implementation - no SMS access
    debugPrint('Historical SMS sync not available on web');
    return 0;
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
      
      debugPrint('M-Pesa connection test successful (Web)');
    } catch (e) {
      debugPrint('M-Pesa connection test failed: $e');
      throw Exception('Connection test failed: $e');
    }
  }

  void stopMonitoring() {
    _isMonitoring = false;
    notifyListeners();
    debugPrint('SMS monitoring stopped (Web stub)');
  }

  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}
