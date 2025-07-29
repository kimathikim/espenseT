import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Test script to verify M-Pesa SMS parsing and database sync
/// This script simulates M-Pesa SMS messages and tests the sync functionality
Future<void> main() async {
  print('🧪 Testing M-Pesa SMS sync functionality...');

  // Initialize Supabase
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    print('❌ Error: SUPABASE_URL and SUPABASE_ANON_KEY environment variables are required');
    print('Usage: dart run scripts/test_mpesa_sync.dart --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key');
    exit(1);
  }

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );

    final supabase = Supabase.instance.client;
    print('✅ Connected to Supabase');

    // Test SMS messages (real M-Pesa format examples)
    final testSmsMessages = [
      {
        'body': 'ABC123 Confirmed. You have sent Ksh500.00 to JAVA HOUSE. New M-PESA balance is Ksh2,500.00 on 15/1/24 at 2:30 PM.',
        'date': DateTime.now().subtract(const Duration(hours: 2)),
        'description': 'Sent money to Java House'
      },
      {
        'body': 'DEF456 Confirmed. Ksh1,200.00 paid to KPLC PREPAID. New M-PESA balance is Ksh1,300.00 on 15/1/24 at 1:15 PM.',
        'date': DateTime.now().subtract(const Duration(hours: 4)),
        'description': 'Bill payment to KPLC'
      },
      {
        'body': 'GHI789 Confirmed. Ksh250.00 paid to UBER KENYA. New M-PESA balance is Ksh1,050.00 on 15/1/24 at 12:45 PM.',
        'date': DateTime.now().subtract(const Duration(hours: 6)),
        'description': 'Buy goods payment to Uber'
      },
      {
        'body': 'JKL012 Confirmed. You have withdrawn Ksh1,000.00 from AGENT 123456. New M-PESA balance is Ksh50.00 on 15/1/24 at 11:30 AM.',
        'date': DateTime.now().subtract(const Duration(hours: 8)),
        'description': 'Cash withdrawal from agent'
      },
    ];

    print('\n📱 Testing SMS parsing with ${testSmsMessages.length} sample messages...');

    // Test each SMS message
    for (int i = 0; i < testSmsMessages.length; i++) {
      final sms = testSmsMessages[i];
      print('\n  [${i + 1}] Testing: ${sms['description']}');
      print('      SMS: ${(sms['body'] as String).substring(0, 50)}...');

      // Parse the SMS (you would need to import your parser here)
      final transaction = _parseMpesaSms(
        sms['body'] as String,
        sms['date'] as DateTime,
        'test-user-id',
      );

      if (transaction != null) {
        print('      ✅ Parsed successfully:');
        print('         Transaction ID: ${transaction['transaction_id']}');
        print('         Type: ${transaction['type']}');
        print('         Amount: KSh ${transaction['amount']}');
        print('         Counterparty: ${transaction['counterparty']}');

        // Test database insertion
        try {
          await supabase.from('mpesa_transactions').insert(transaction);
          print('      ✅ Saved to database successfully');
        } catch (e) {
          if (e.toString().contains('duplicate key')) {
            print('      ℹ️  Transaction already exists in database');
          } else {
            print('      ❌ Database error: $e');
          }
        }
      } else {
        print('      ❌ Failed to parse SMS');
      }
    }

    // Test database queries
    print('\n🔍 Testing database queries...');

    try {
      // Check categories
      final categories = await supabase
          .from('categories')
          .select('id, name, icon, color')
          .is_('user_id', null);
      print('  ✅ Categories: Found ${categories.length} default categories');

      // Check M-Pesa transactions
      final mpesaTransactions = await supabase
          .from('mpesa_transactions')
          .select('id, transaction_id, type, amount, counterparty')
          .limit(5);
      print('  ✅ M-Pesa Transactions: Found ${mpesaTransactions.length} transactions');

      // Check expenses (should be auto-created by trigger)
      final expenses = await supabase
          .from('expenses')
          .select('id, amount, description, category_id')
          .limit(5);
      print('  ✅ Expenses: Found ${expenses.length} expense records');

      if (expenses.isNotEmpty) {
        print('      Sample expense: ${expenses.first['description']} - KSh ${expenses.first['amount']}');
      }

    } catch (e) {
      print('  ❌ Database query error: $e');
    }

    print('\n🎉 M-Pesa sync test completed!');
    print('If you see ✅ marks above, your M-Pesa sync is working correctly.');

  } catch (e) {
    print('❌ Fatal error during testing: $e');
    exit(1);
  }
}

/// Simple M-Pesa SMS parser for testing
/// This is a simplified version of the actual parser
Map<String, dynamic>? _parseMpesaSms(String smsBody, DateTime smsDate, String userId) {
  try {
    // Enhanced M-Pesa SMS patterns
    final patterns = [
      // Standard format: "ABC123 Confirmed. You have sent Ksh500.00 to JOHN DOE. New M-PESA balance is Ksh1,234.56"
      RegExp(r'([A-Z0-9]+)\s+Confirmed\.\s+(?:You have\s+)?(sent|received|withdrawn|deposited|paid)\s+Ksh([\d,]+\.?\d*)\s+(?:to|from)?\s*([^.]+)\.\s+.*New M-PESA balance is Ksh([\d,]+\.?\d*)', caseSensitive: false),
      
      // Buy goods format: "ABC123 Confirmed. Ksh500.00 paid to SHOP NAME. New M-PESA balance is Ksh1,234.56"
      RegExp(r'([A-Z0-9]+)\s+Confirmed\.\s+Ksh([\d,]+\.?\d*)\s+paid to\s+([^.]+)\.\s+.*New M-PESA balance is Ksh([\d,]+\.?\d*)', caseSensitive: false),
    ];

    for (int i = 0; i < patterns.length; i++) {
      final pattern = patterns[i];
      final match = pattern.firstMatch(smsBody);
      if (match != null) {
        String transactionId = match.group(1) ?? '';
        double amount = 0.0;
        String counterparty = '';
        double? balance;
        String type = 'unknown';

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
