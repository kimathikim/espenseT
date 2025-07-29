import 'dart:io';
import 'package:flutter/foundation.dart';

/// Debug script to test M-Pesa SMS parsing patterns
/// This helps identify why some transactions might not be parsed
void main() {
  print('🧪 M-Pesa SMS Parsing Debug Tool');
  print('================================\n');

  // Sample M-Pesa SMS messages for testing
  final testMessages = [
    // Standard format
    'ABC123 Confirmed. You have sent Ksh500.00 to JAVA HOUSE. New M-PESA balance is Ksh2,500.00 on 15/1/24 at 2:30 PM.',
    
    // Buy goods format
    'DEF456 Confirmed. Ksh1,200.00 paid to KPLC PREPAID. New M-PESA balance is Ksh1,300.00 on 15/1/24 at 1:15 PM.',
    
    // Paybill format
    'GHI789 Confirmed. Ksh250.00 sent to UBER KENYA for account 123456. New M-PESA balance is Ksh1,050.00 on 15/1/24 at 12:45 PM.',
    
    // Withdrawal format
    'JKL012 Confirmed. You have withdrawn Ksh1,000.00 from AGENT 123456. New M-PESA balance is Ksh50.00 on 15/1/24 at 11:30 AM.',
    
    // Older format without transaction ID
    'Confirmed. Ksh300.00 sent to JAVA HOUSE for account 123456 on 1/1/24 at 2:30 PM.',
    
    // Generic format
    'Confirmed. Ksh150.00 paid to SHOP NAME. on 1/1/24 at 2:30 PM.',
    
    // Received money
    'MNO345 Confirmed. You have received Ksh2,000.00 from JOHN DOE. New M-PESA balance is Ksh3,000.00 on 15/1/24 at 3:00 PM.',
    
    // Different variations
    'PQR678 Confirmed. Ksh75.00 withdrawn from agent 987654 on 15/1/24 at 4:00 PM. New M-PESA balance is Ksh925.00',
  ];

  // Test patterns
  final patterns = [
    // Standard format with transaction ID
    RegExp(r'([A-Z0-9]+)\s+Confirmed\.\s+(?:You have\s+)?(sent|received|withdrawn|deposited|paid)\s+Ksh([\d,]+\.?\d*)\s+(?:to|from)?\s*([^.]+)\.\s+.*New M-PESA balance is Ksh([\d,]+\.?\d*)', caseSensitive: false),
    
    // Buy goods format
    RegExp(r'([A-Z0-9]+)\s+Confirmed\.\s+Ksh([\d,]+\.?\d*)\s+paid to\s+([^.]+)\.\s+.*New M-PESA balance is Ksh([\d,]+\.?\d*)', caseSensitive: false),
    
    // Paybill format
    RegExp(r'([A-Z0-9]+)\s+Confirmed\.\s+Ksh([\d,]+\.?\d*)\s+sent to\s+([^.]+)\s+for account\s+([^.]+)\.\s+.*New M-PESA balance is Ksh([\d,]+\.?\d*)', caseSensitive: false),
    
    // Fallback patterns without transaction ID
    RegExp(r'Confirmed\.\s*Ksh([\d,]+\.?\d*)\s*sent to\s*([^f]+?)\s*for account\s*([^\s]+)', caseSensitive: false),
    RegExp(r'Confirmed\.\s*Ksh([\d,]+\.?\d*)\s*paid to\s*([^f]+?)\s*for account\s*([^\s]+)', caseSensitive: false),
    RegExp(r'Confirmed\.\s*Ksh([\d,]+\.?\d*)\s*paid to\s*([^.]+?)\.\s*on', caseSensitive: false),
    RegExp(r'Confirmed\.\s*Ksh([\d,]+\.?\d*)\s*withdrawn from\s*([^o]+?)\s*on', caseSensitive: false),
    
    // Generic pattern
    RegExp(r'Confirmed\.\s*Ksh([\d,]+\.?\d*)\s*(.+)', caseSensitive: false),
  ];

  print('Testing ${testMessages.length} sample SMS messages against ${patterns.length} patterns:\n');

  for (int msgIndex = 0; msgIndex < testMessages.length; msgIndex++) {
    final message = testMessages[msgIndex];
    print('📱 Message ${msgIndex + 1}:');
    print('   ${message.substring(0, message.length > 80 ? 80 : message.length)}${message.length > 80 ? '...' : ''}');
    
    bool matched = false;
    for (int patternIndex = 0; patternIndex < patterns.length; patternIndex++) {
      final pattern = patterns[patternIndex];
      final match = pattern.firstMatch(message);
      
      if (match != null) {
        print('   ✅ Matched pattern ${patternIndex + 1}:');
        for (int i = 1; i <= match.groupCount; i++) {
          print('      Group $i: "${match.group(i)}"');
        }
        
        // Extract key information
        try {
          String transactionId = '';
          double amount = 0.0;
          String counterparty = '';
          String type = 'unknown';
          
          if (patternIndex < 3) {
            // Patterns with transaction ID
            transactionId = match.group(1) ?? '';
            if (patternIndex == 0) {
              type = match.group(2) ?? '';
              amount = double.tryParse(match.group(3)?.replaceAll(',', '') ?? '0') ?? 0.0;
              counterparty = match.group(4)?.trim() ?? '';
            } else if (patternIndex == 1) {
              type = 'buygoods';
              amount = double.tryParse(match.group(2)?.replaceAll(',', '') ?? '0') ?? 0.0;
              counterparty = match.group(3)?.trim() ?? '';
            } else if (patternIndex == 2) {
              type = 'paybill';
              amount = double.tryParse(match.group(2)?.replaceAll(',', '') ?? '0') ?? 0.0;
              counterparty = '${match.group(3)?.trim() ?? ''} (${match.group(4)?.trim() ?? ''})';
            }
          } else {
            // Fallback patterns
            transactionId = 'SMS_${DateTime.now().millisecondsSinceEpoch}';
            amount = double.tryParse(match.group(1)?.replaceAll(',', '') ?? '0') ?? 0.0;
            counterparty = match.group(2)?.trim() ?? '';
            
            if (patternIndex == 3 || patternIndex == 4) {
              type = patternIndex == 3 ? 'sent' : 'paybill';
            } else if (patternIndex == 5) {
              type = 'buygoods';
            } else if (patternIndex == 6) {
              type = 'withdraw';
            } else {
              type = _determineTypeFromContent(message);
            }
          }
          
          print('      💰 Parsed: ID=$transactionId, Type=$type, Amount=Ksh$amount, Counterparty=$counterparty');
          
        } catch (e) {
          print('      ❌ Error parsing: $e');
        }
        
        matched = true;
        break;
      }
    }
    
    if (!matched) {
      print('   ❌ No pattern matched this message');
    }
    
    print('');
  }

  print('🎯 Summary:');
  print('- Test completed for ${testMessages.length} messages');
  print('- Check the results above to see which patterns work');
  print('- Messages that show "❌ No pattern matched" need new patterns');
  print('\n💡 Tips:');
  print('- Add more test messages from your actual SMS history');
  print('- Create new regex patterns for unmatched messages');
  print('- Test with real SMS data for better accuracy');
}

String _determineTypeFromContent(String smsBody) {
  final body = smsBody.toLowerCase();
  if (body.contains('sent to')) return 'sent';
  if (body.contains('paid to')) return 'buygoods';
  if (body.contains('withdrawn')) return 'withdraw';
  if (body.contains('received')) return 'received';
  if (body.contains('deposited')) return 'deposit';
  return 'unknown';
}
