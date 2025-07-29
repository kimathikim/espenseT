import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:telephony/telephony.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expensetracker/src/features/categories/data/category_repository.dart';

/// SMS-based M-Pesa transaction parser - Alternative to Daraja API
class SmsTransactionParser {
  static final SmsTransactionParser _instance = SmsTransactionParser._internal();
  factory SmsTransactionParser() => _instance;
  SmsTransactionParser._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final CategoryRepository _categoryRepository = CategoryRepository();
  final Telephony _telephony = Telephony.instance;

  /// Parse M-Pesa SMS messages and sync transactions
  Future<int> syncTransactionsFromSms() async {
    try {
      debugPrint('🔄 Starting M-Pesa SMS sync...');
      
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Request SMS permissions
      final hasPermission = await _telephony.requestPhoneAndSmsPermissions;
      if (hasPermission != true) {
        throw Exception('SMS permissions required for M-Pesa sync');
      }

      debugPrint('📱 Reading M-Pesa SMS messages...');
      
      // Get SMS messages from M-Pesa (last 30 days)
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final smsMessages = await _telephony.getInboxSms(
        columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
        filter: SmsFilter.where(SmsColumn.ADDRESS).equals('MPESA'),
        sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
      );

      debugPrint('📨 Found ${smsMessages.length} M-Pesa SMS messages');

      // Parse M-Pesa transactions from SMS
      final mpesaTransactions = <Map<String, dynamic>>[];

      for (final sms in smsMessages) {
        final smsDate = DateTime.fromMillisecondsSinceEpoch(sms.date ?? 0);

        // Only process recent messages
        if (smsDate.isBefore(thirtyDaysAgo)) continue;

        final transaction = _parseMpesaSms(sms.body ?? '', smsDate, user.id);
        if (transaction != null) {
          mpesaTransactions.add(transaction);
        }
      }

      debugPrint('💰 Parsed ${mpesaTransactions.length} valid M-Pesa transactions');

      if (mpesaTransactions.isEmpty) {
        debugPrint('ℹ️ No new M-Pesa transactions found');
        return 0;
      }

      // Check for existing M-Pesa transactions to avoid duplicates
      final existingMpesaTransactions = await _supabase
          .from('mpesa_transactions')
          .select('transaction_id')
          .eq('user_id', user.id);

      final existingTransactionIds = existingMpesaTransactions
          .map((tx) => tx['transaction_id'] as String)
          .toSet();

      final newMpesaTransactions = mpesaTransactions.where((tx) {
        return !existingTransactionIds.contains(tx['transaction_id']);
      }).toList();

      if (newMpesaTransactions.isEmpty) {
        debugPrint('ℹ️ All M-Pesa transactions already exist');
        return 0;
      }

      // Insert new M-Pesa transactions (trigger will auto-convert to expenses)
      await _supabase.from('mpesa_transactions').insert(newMpesaTransactions);

      debugPrint('✅ Successfully synced ${newMpesaTransactions.length} new M-Pesa transactions');

      // Count how many will become expenses (outgoing transactions only)
      final expenseCount = newMpesaTransactions.where((tx) =>
        ['sent', 'withdraw', 'paybill', 'buygoods'].contains(tx['type'])
      ).length;

      debugPrint('💸 ${expenseCount} transactions will be converted to expenses');
      return expenseCount;

    } catch (e) {
      debugPrint('❌ SMS parsing failed: $e');
      rethrow;
    }
  }

  /// Parse individual M-Pesa SMS message
  Map<String, dynamic>? _parseMpesaSms(String smsBody, DateTime smsDate, String userId) {
    try {
      // Enhanced M-Pesa SMS patterns for different transaction types
      final patterns = [
        // Standard format with transaction ID: "ABC123 Confirmed. You have sent Ksh500.00 to JOHN DOE. New M-PESA balance is Ksh1,234.56"
        RegExp(r'([A-Z0-9]+)\s+Confirmed\.\s+(?:You have\s+)?(sent|received|withdrawn|deposited|paid)\s+Ksh([\d,]+\.?\d*)\s+(?:to|from)?\s*([^.]+)\.\s+.*New M-PESA balance is Ksh([\d,]+\.?\d*)', caseSensitive: false),

        // Buy goods format: "ABC123 Confirmed. Ksh500.00 paid to SHOP NAME. New M-PESA balance is Ksh1,234.56"
        RegExp(r'([A-Z0-9]+)\s+Confirmed\.\s+Ksh([\d,]+\.?\d*)\s+paid to\s+([^.]+)\.\s+.*New M-PESA balance is Ksh([\d,]+\.?\d*)', caseSensitive: false),

        // Paybill format: "ABC123 Confirmed. Ksh500.00 sent to COMPANY for account 123456. New M-PESA balance is Ksh1,234.56"
        RegExp(r'([A-Z0-9]+)\s+Confirmed\.\s+Ksh([\d,]+\.?\d*)\s+sent to\s+([^.]+)\s+for account\s+([^.]+)\.\s+.*New M-PESA balance is Ksh([\d,]+\.?\d*)', caseSensitive: false),

        // Fallback patterns without transaction ID
        // Sent money: "Confirmed. Ksh500.00 sent to JAVA HOUSE for account 123456 on 1/1/24 at 2:30 PM."
        RegExp(r'Confirmed\.\s*Ksh([\d,]+\.?\d*)\s*sent to\s*([^f]+?)\s*for account\s*([^\s]+)', caseSensitive: false),

        // Paid bill: "Confirmed. Ksh1,200.00 paid to KPLC PREPAID for account 123456 on 1/1/24 at 2:30 PM."
        RegExp(r'Confirmed\.\s*Ksh([\d,]+\.?\d*)\s*paid to\s*([^f]+?)\s*for account\s*([^\s]+)', caseSensitive: false),

        // Buy goods: "Confirmed. Ksh250.00 paid to JAVA HOUSE. on 1/1/24 at 2:30 PM."
        RegExp(r'Confirmed\.\s*Ksh([\d,]+\.?\d*)\s*paid to\s*([^.]+?)\.\s*on', caseSensitive: false),

        // Withdraw: "Confirmed. Ksh500.00 withdrawn from agent 123456 on 1/1/24 at 2:30 PM."
        RegExp(r'Confirmed\.\s*Ksh([\d,]+\.?\d*)\s*withdrawn from\s*([^o]+?)\s*on', caseSensitive: false),
      ];

      for (int i = 0; i < patterns.length; i++) {
        final pattern = patterns[i];
        final match = pattern.firstMatch(smsBody);
        if (match != null) {
          String transactionId = '';
          double amount = 0.0;
          String counterparty = '';
          double? balance;
          String type = 'unknown';

          if (i < 3) {
            // Patterns with transaction ID and balance
            transactionId = match.group(1) ?? '';
            if (i == 0) {
              // Standard pattern
              type = _normalizeTransactionType(match.group(2) ?? '');
              amount = double.tryParse(match.group(3)?.replaceAll(',', '') ?? '0') ?? 0.0;
              counterparty = match.group(4)?.trim() ?? '';
              balance = double.tryParse(match.group(5)?.replaceAll(',', '') ?? '0');
            } else if (i == 1) {
              // Buy goods pattern
              type = 'buygoods';
              amount = double.tryParse(match.group(2)?.replaceAll(',', '') ?? '0') ?? 0.0;
              counterparty = match.group(3)?.trim() ?? '';
              balance = double.tryParse(match.group(4)?.replaceAll(',', '') ?? '0');
            } else if (i == 2) {
              // Paybill pattern
              type = 'paybill';
              amount = double.tryParse(match.group(2)?.replaceAll(',', '') ?? '0') ?? 0.0;
              counterparty = '${match.group(3)?.trim() ?? ''} (${match.group(4)?.trim() ?? ''})';
              balance = double.tryParse(match.group(5)?.replaceAll(',', '') ?? '0');
            }
          } else {
            // Fallback patterns without transaction ID
            transactionId = 'SMS_${DateTime.now().millisecondsSinceEpoch}';
            amount = double.tryParse(match.group(1)?.replaceAll(',', '') ?? '0') ?? 0.0;
            counterparty = match.group(2)?.trim() ?? '';

            if (i == 3 || i == 4) {
              type = i == 3 ? 'sent' : 'paybill';
              counterparty = '${match.group(2)?.trim() ?? ''} (${match.group(3)?.trim() ?? ''})';
            } else if (i == 5) {
              type = 'buygoods';
            } else if (i == 6) {
              type = 'withdraw';
            }
          }

          // Only process expense transactions (outgoing money)
          if (amount > 0 && ['sent', 'withdraw', 'paybill', 'buygoods'].contains(type)) {
            return {
              'user_id': userId,
              'transaction_id': transactionId,
              'type': type,
              'amount': amount,
              'counterparty': counterparty,
              'transaction_date': smsDate.toIso8601String(),
              'balance_after': balance,
              'raw_sms': smsBody,
              'processed': false,
            };
          }
        }
      }

      debugPrint('⚠️ Could not parse SMS: ${smsBody.substring(0, smsBody.length > 50 ? 50 : smsBody.length)}...');
      return null;
    } catch (e) {
      debugPrint('❌ Error parsing SMS: $e');
      return null;
    }
  }

  /// Normalize transaction type from SMS text
  String _normalizeTransactionType(String type) {
    switch (type.toLowerCase()) {
      case 'sent': return 'sent';
      case 'received': return 'received';
      case 'withdrawn': return 'withdraw';
      case 'deposited': return 'deposit';
      case 'paid': return 'paybill';
      default: return 'unknown';
    }
  }

  /// Smart category suggestion based on merchant name
  String _suggestCategory(String merchant, List<dynamic> categories) {
    final merchantLower = merchant.toLowerCase();
    
    // Food & Dining
    if (merchantLower.contains('java') || 
        merchantLower.contains('kfc') || 
        merchantLower.contains('pizza') ||
        merchantLower.contains('restaurant') ||
        merchantLower.contains('cafe')) {
      return categories.firstWhere((c) => c['name'].toLowerCase().contains('food'), 
                                 orElse: () => categories.first)['id'];
    }
    
    // Transport
    if (merchantLower.contains('uber') || 
        merchantLower.contains('bolt') || 
        merchantLower.contains('matatu') ||
        merchantLower.contains('taxi')) {
      return categories.firstWhere((c) => c['name'].toLowerCase().contains('transport'), 
                                 orElse: () => categories.first)['id'];
    }
    
    // Shopping
    if (merchantLower.contains('carrefour') || 
        merchantLower.contains('nakumatt') || 
        merchantLower.contains('tuskys') ||
        merchantLower.contains('shop')) {
      return categories.firstWhere((c) => c['name'].toLowerCase().contains('shopping'), 
                                 orElse: () => categories.first)['id'];
    }
    
    // Bills & Utilities
    if (merchantLower.contains('kplc') || 
        merchantLower.contains('nairobi water') || 
        merchantLower.contains('safaricom') ||
        merchantLower.contains('airtel')) {
      return categories.firstWhere((c) => c['name'].toLowerCase().contains('bills'), 
                                 orElse: () => categories.first)['id'];
    }
    
    // Default category
    return categories.first['id'];
  }

  /// Listen for new M-Pesa SMS messages in real-time
  void startSmsListener() {
    _telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        if (message.address == 'MPESA') {
          debugPrint('📨 New M-Pesa SMS received, triggering sync...');
          // Trigger sync after a short delay to ensure SMS is saved
          Timer(const Duration(seconds: 2), () {
            syncTransactionsFromSms();
          });
        }
      },
      listenInBackground: false,
    );
  }

  /// Stop SMS listener
  void stopSmsListener() {
    // The telephony package doesn't have an explicit stop method
    // The listener will stop when the app is closed
    debugPrint('📱 SMS listener stopped');
  }
}
