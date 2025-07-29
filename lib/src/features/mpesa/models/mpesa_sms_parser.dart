import 'package:flutter/foundation.dart';
import 'mpesa_transaction.dart';

class MpesaSmsParser {
  // Comprehensive patterns to handle different M-Pesa SMS formats
  static final List<RegExp> _patterns = [
    // Money sent to person: "ABC123 Confirmed. You have sent Ksh500.00 to JOHN DOE. New M-PESA balance is Ksh1,234.56"
    RegExp(r'([A-Z0-9]+)\s+Confirmed\.\s+You have sent\s+Ksh([\d,]+\.?\d*)\s+to\s+([^.]+)\.\s+.*New M-PESA balance is Ksh([\d,]+\.?\d*)', caseSensitive: false),

    // Standard format with transaction ID: "ABC123 Confirmed. You have received/withdrawn/deposited Ksh500.00..."
    RegExp(r'([A-Z0-9]+)\s+Confirmed\.\s+(?:You have\s+)?(received|withdrawn|deposited)\s+Ksh([\d,]+\.?\d*)\s+(?:to|from)?\s*([^.]+)\.\s+.*New M-PESA balance is Ksh([\d,]+\.?\d*)', caseSensitive: false),

    // Buy goods format: "ABC123 Confirmed. Ksh500.00 paid to SHOP NAME. New M-PESA balance is Ksh1,234.56"
    RegExp(r'([A-Z0-9]+)\s+Confirmed\.\s+Ksh([\d,]+\.?\d*)\s+paid to\s+([^.]+)\.\s+.*New M-PESA balance is Ksh([\d,]+\.?\d*)', caseSensitive: false),

    // Paybill format: "ABC123 Confirmed. Ksh500.00 sent to COMPANY for account 123456. New M-PESA balance is Ksh1,234.56"
    RegExp(r'([A-Z0-9]+)\s+Confirmed\.\s+Ksh([\d,]+\.?\d*)\s+sent to\s+([^.]+)\s+for account\s+([^.]+)\.\s+.*New M-PESA balance is Ksh([\d,]+\.?\d*)', caseSensitive: false),

    // Fallback patterns without transaction ID for older SMS formats
    // Sent money to person: "Confirmed. You have sent Ksh500.00 to JOHN DOE on 1/1/24 at 2:30 PM."
    RegExp(r'Confirmed\.\s*You have sent\s*Ksh([\d,]+\.?\d*)\s*to\s*([^o]+?)\s*on', caseSensitive: false),

    // Sent money for paybill: "Confirmed. Ksh500.00 sent to JAVA HOUSE for account 123456 on 1/1/24 at 2:30 PM."
    RegExp(r'Confirmed\.\s*Ksh([\d,]+\.?\d*)\s*sent to\s*([^f]+?)\s*for account\s*([^\s]+)', caseSensitive: false),

    // Paid bill: "Confirmed. Ksh1,200.00 paid to KPLC PREPAID for account 123456 on 1/1/24 at 2:30 PM."
    RegExp(r'Confirmed\.\s*Ksh([\d,]+\.?\d*)\s*paid to\s*([^f]+?)\s*for account\s*([^\s]+)', caseSensitive: false),

    // Buy goods: "Confirmed. Ksh250.00 paid to JAVA HOUSE. on 1/1/24 at 2:30 PM."
    RegExp(r'Confirmed\.\s*Ksh([\d,]+\.?\d*)\s*paid to\s*([^.]+?)\.\s*on', caseSensitive: false),

    // Withdraw: "Confirmed. Ksh500.00 withdrawn from agent 123456 on 1/1/24 at 2:30 PM."
    RegExp(r'Confirmed\.\s*Ksh([\d,]+\.?\d*)\s*withdrawn from\s*([^o]+?)\s*on', caseSensitive: false),

    // Generic M-Pesa pattern for any unmatched formats
    RegExp(r'Confirmed\.\s*Ksh([\d,]+\.?\d*)\s*(.+)', caseSensitive: false),
  ];

  static MpesaTransaction? parseSms(String smsBody, DateTime receivedAt) {
    if (!_isMpesaSms(smsBody)) {
      debugPrint('⚠️ SMS not recognized as M-Pesa: ${smsBody.substring(0, smsBody.length > 50 ? 50 : smsBody.length)}...');
      return null;
    }

    for (int i = 0; i < _patterns.length; i++) {
      final pattern = _patterns[i];
      final match = pattern.firstMatch(smsBody);
      if (match != null) {
        try {
          final transaction = _parseMatch(match, smsBody, receivedAt, i);
          if (transaction != null) {
            debugPrint('✅ Successfully parsed SMS with pattern $i: ${transaction.transactionId}');
            return transaction;
          }
        } catch (e) {
          debugPrint('⚠️ Failed to parse with pattern $i: $e');
          continue; // Try next pattern
        }
      }
    }

    debugPrint('❌ Could not parse M-Pesa SMS: ${smsBody.substring(0, smsBody.length > 100 ? 100 : smsBody.length)}...');
    return null;
  }

  static bool _isMpesaSms(String smsBody) {
    final body = smsBody.toLowerCase();
    return body.contains('m-pesa') || 
           body.contains('mpesa') ||
           body.contains('confirmed') && body.contains('ksh');
  }

  static MpesaTransaction? _parseMatch(RegExpMatch match, String smsBody, DateTime receivedAt, int patternIndex) {
    String transactionId = '';
    double amount = 0.0;
    String counterparty = '';
    double balance = 0.0;
    String type = 'unknown';

    try {
      if (patternIndex < 5) {
        // Patterns with transaction ID and balance
        transactionId = match.group(1) ?? '';
        if (patternIndex == 0) {
          // Money sent to person pattern
          type = 'sent';
          amount = _parseAmount(match.group(2) ?? '0');
          counterparty = (match.group(3) ?? '').trim();
          balance = _parseAmount(match.group(4) ?? '0');
        } else if (patternIndex == 1) {
          // Standard pattern (received, withdrawn, deposited)
          type = _normalizeType(match.group(2) ?? '');
          amount = _parseAmount(match.group(3) ?? '0');
          counterparty = (match.group(4) ?? '').trim();
          balance = _parseAmount(match.group(5) ?? '0');
        } else if (patternIndex == 2) {
          // Buy goods pattern
          type = 'buygoods';
          amount = _parseAmount(match.group(2) ?? '0');
          counterparty = (match.group(3) ?? '').trim();
          balance = _parseAmount(match.group(4) ?? '0');
        } else if (patternIndex == 3) {
          // Paybill pattern
          type = 'paybill';
          amount = _parseAmount(match.group(2) ?? '0');
          counterparty = '${(match.group(3) ?? '').trim()} (${(match.group(4) ?? '').trim()})';
          balance = _parseAmount(match.group(5) ?? '0');
        }
      } else {
        // Fallback patterns without transaction ID
        transactionId = 'SMS_${receivedAt.millisecondsSinceEpoch}';
        amount = _parseAmount(match.group(1) ?? '0');
        counterparty = (match.group(2) ?? '').trim();

        if (patternIndex == 5) {
          // Sent money to person (fallback)
          type = 'sent';
        } else if (patternIndex == 6) {
          // Sent money for paybill (fallback)
          type = 'paybill';
          if (match.groupCount >= 3) {
            counterparty = '${(match.group(2) ?? '').trim()} (${(match.group(3) ?? '').trim()})';
          }
        } else if (patternIndex == 7) {
          // Paid bill (fallback)
          type = 'paybill';
          if (match.groupCount >= 3) {
            counterparty = '${(match.group(2) ?? '').trim()} (${(match.group(3) ?? '').trim()})';
          }
        } else if (patternIndex == 8) {
          // Buy goods (fallback)
          type = 'buygoods';
        } else if (patternIndex == 9) {
          // Withdraw (fallback)
          type = 'withdraw';
        } else if (patternIndex == 10) {
          // Generic pattern - try to determine type from SMS content
          type = _determineTypeFromContent(smsBody);
        }
      }

      // Only return valid transactions with positive amounts
      if (amount <= 0 || transactionId.isEmpty) {
        debugPrint('⚠️ Invalid transaction: amount=$amount, id=$transactionId');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error parsing match: $e');
      return null;
    }

    return MpesaTransaction(
      id: '', // Will be set by database
      transactionId: transactionId,
      type: type,
      amount: amount,
      counterparty: counterparty,
      transactionDate: receivedAt,
      balanceAfter: balance,
      rawSms: smsBody,
      processed: false,
      createdAt: DateTime.now(),
    );
  }

  static String _normalizeType(String type) {
    switch (type.toLowerCase()) {
      case 'sent': return 'sent';
      case 'received': return 'received';
      case 'withdrawn': return 'withdraw';
      case 'deposited': return 'deposit';
      case 'paid': return 'paybill';
      default: return 'unknown';
    }
  }

  static double _parseAmount(String amountStr) {
    try {
      return double.parse(amountStr.replaceAll(',', ''));
    } catch (e) {
      debugPrint('⚠️ Failed to parse amount: $amountStr');
      return 0.0;
    }
  }

  static String _determineTypeFromContent(String smsBody) {
    final body = smsBody.toLowerCase();
    if (body.contains('sent to')) return 'sent';
    if (body.contains('paid to')) return 'buygoods';
    if (body.contains('withdrawn')) return 'withdraw';
    if (body.contains('received')) return 'received';
    if (body.contains('deposited')) return 'deposit';
    return 'unknown';
  }
}