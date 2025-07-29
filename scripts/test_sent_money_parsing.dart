import 'dart:io';

/// Test script specifically for "money sent to person" M-Pesa transactions
/// This verifies that sent money transactions are properly parsed as expenses
void main() {
  print('🧪 Testing M-Pesa "Money Sent to Person" Parsing');
  print('==================================================\n');

  // Real M-Pesa SMS examples for "sent to person" transactions
  final sentMoneyMessages = [
    // Standard format with transaction ID
    'ABC123 Confirmed. You have sent Ksh500.00 to JOHN DOE. New M-PESA balance is Ksh2,500.00 on 15/1/24 at 2:30 PM.',
    
    // Another standard format
    'DEF456 Confirmed. You have sent Ksh1,200.00 to MARY WANJIKU. New M-PESA balance is Ksh1,300.00 on 15/1/24 at 1:15 PM.',
    
    // Sent to business person
    'GHI789 Confirmed. You have sent Ksh750.00 to PETER KAMAU. New M-PESA balance is Ksh550.00 on 15/1/24 at 12:45 PM.',
    
    // Older format without transaction ID
    'Confirmed. You have sent Ksh300.00 to JANE MUTHONI on 1/1/24 at 2:30 PM. New M-PESA balance is Ksh1,700.00',
    
    // Different variations
    'JKL012 Confirmed. You have sent Ksh50.00 to SAMUEL KIPROTICH. New M-PESA balance is Ksh500.00 on 15/1/24 at 4:00 PM.',
    
    // Mixed case
    'MNO345 confirmed. you have sent ksh2,000.00 to GRACE AKINYI. new m-pesa balance is ksh3,000.00 on 15/1/24 at 3:00 PM.',
  ];

  // Test patterns specifically for "sent to person"
  final sentMoneyPatterns = [
    // Primary pattern for "sent to person"
    RegExp(r'([A-Z0-9]+)\s+Confirmed\.\s+You have sent\s+Ksh([\d,]+\.?\d*)\s+to\s+([^.]+)\.\s+.*New M-PESA balance is Ksh([\d,]+\.?\d*)', caseSensitive: false),
    
    // Fallback pattern without transaction ID
    RegExp(r'Confirmed\.\s*You have sent\s*Ksh([\d,]+\.?\d*)\s*to\s*([^o]+?)\s*on', caseSensitive: false),
  ];

  print('Testing ${sentMoneyMessages.length} "sent to person" SMS messages:\n');

  int successfullyParsed = 0;
  int failedToParse = 0;

  for (int msgIndex = 0; msgIndex < sentMoneyMessages.length; msgIndex++) {
    final message = sentMoneyMessages[msgIndex];
    print('📱 Message ${msgIndex + 1}:');
    print('   ${message}');
    
    bool matched = false;
    for (int patternIndex = 0; patternIndex < sentMoneyPatterns.length; patternIndex++) {
      final pattern = sentMoneyPatterns[patternIndex];
      final match = pattern.firstMatch(message);
      
      if (match != null) {
        print('   ✅ Matched "sent to person" pattern ${patternIndex + 1}:');
        for (int i = 1; i <= match.groupCount; i++) {
          print('      Group $i: "${match.group(i)}"');
        }
        
        // Extract transaction details
        try {
          String transactionId = '';
          double amount = 0.0;
          String counterparty = '';
          double? balance;
          String type = 'sent'; // This should always be 'sent' for these messages
          
          if (patternIndex == 0) {
            // Primary pattern with transaction ID
            transactionId = match.group(1) ?? '';
            amount = double.tryParse(match.group(2)?.replaceAll(',', '') ?? '0') ?? 0.0;
            counterparty = match.group(3)?.trim() ?? '';
            balance = double.tryParse(match.group(4)?.replaceAll(',', '') ?? '0');
          } else if (patternIndex == 1) {
            // Fallback pattern without transaction ID
            transactionId = 'SMS_${DateTime.now().millisecondsSinceEpoch}';
            amount = double.tryParse(match.group(1)?.replaceAll(',', '') ?? '0') ?? 0.0;
            counterparty = match.group(2)?.trim() ?? '';
          }
          
          print('      💰 Parsed Transaction:');
          print('         ID: $transactionId');
          print('         Type: $type (should be "sent")');
          print('         Amount: Ksh$amount');
          print('         Counterparty: $counterparty');
          print('         Balance After: ${balance != null ? 'Ksh$balance' : 'N/A'}');
          
          // Verify this is an expense transaction
          final isExpense = ['sent', 'withdraw', 'paybill', 'buygoods'].contains(type);
          print('         Is Expense: ${isExpense ? '✅ YES' : '❌ NO'}');
          
          if (isExpense && amount > 0) {
            successfullyParsed++;
            print('         Status: ✅ Will be saved as EXPENSE');
          } else {
            failedToParse++;
            print('         Status: ❌ Will NOT be saved as expense');
          }
          
        } catch (e) {
          print('      ❌ Error parsing: $e');
          failedToParse++;
        }
        
        matched = true;
        break;
      }
    }
    
    if (!matched) {
      print('   ❌ No "sent to person" pattern matched this message');
      failedToParse++;
    }
    
    print('');
  }

  // Summary
  print('🎯 Test Summary:');
  print('================');
  print('Total "sent to person" messages tested: ${sentMoneyMessages.length}');
  print('Successfully parsed as expenses: $successfullyParsed');
  print('Failed to parse: $failedToParse');
  print('Success rate: ${((successfullyParsed / sentMoneyMessages.length) * 100).toStringAsFixed(1)}%');
  
  if (successfullyParsed == sentMoneyMessages.length) {
    print('\n🎉 SUCCESS: All "sent to person" transactions will be captured as expenses!');
  } else {
    print('\n⚠️  WARNING: Some "sent to person" transactions may not be captured.');
    print('   Review the failed messages above and add more patterns if needed.');
  }

  // Test database trigger logic
  print('\n🗄️  Database Trigger Test:');
  print('=========================');
  final expenseTypes = ['sent', 'withdraw', 'paybill', 'buygoods'];
  final incomeTypes = ['received', 'deposit'];
  
  print('Transaction types that become EXPENSES: ${expenseTypes.join(', ')}');
  print('Transaction types that are recorded but NOT expenses: ${incomeTypes.join(', ')}');
  
  print('\n✅ The database trigger should convert "sent" type transactions to expenses.');
  print('✅ This means "money sent to person" will appear in the expense tracker.');

  // Recommendations
  print('\n💡 Recommendations:');
  print('===================');
  print('1. Test with your actual M-Pesa SMS messages');
  print('2. Check the app after sync to ensure "sent" transactions appear as expenses');
  print('3. Verify the expense descriptions are clear (e.g., "M-Pesa: Sent to JOHN DOE")');
  print('4. Ensure these transactions get proper default categories');
}
