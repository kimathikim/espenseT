class MpesaTransaction {
  final String id;
  final String transactionId;
  final String type;
  final double amount;
  final String counterparty;
  final DateTime transactionDate;
  final double? balanceAfter;
  final String rawSms;
  final bool processed;
  final DateTime createdAt;

  MpesaTransaction({
    required this.id,
    required this.transactionId,
    required this.type,
    required this.amount,
    required this.counterparty,
    required this.transactionDate,
    this.balanceAfter,
    required this.rawSms,
    this.processed = false,
    required this.createdAt,
  });

  factory MpesaTransaction.fromJson(Map<String, dynamic> json) {
    return MpesaTransaction(
      id: json['id'],
      transactionId: json['transaction_id'],
      type: json['type'],
      amount: (json['amount'] as num).toDouble(),
      counterparty: json['counterparty'],
      transactionDate: DateTime.parse(json['transaction_date']),
      balanceAfter: json['balance_after']?.toDouble(),
      rawSms: json['raw_sms'],
      processed: json['processed'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'transaction_id': transactionId,
    'type': type,
    'amount': amount,
    'counterparty': counterparty,
    'transaction_date': transactionDate.toIso8601String(),
    'balance_after': balanceAfter,
    'raw_sms': rawSms,
    'processed': processed,
    'created_at': createdAt.toIso8601String(),
  };

  String get displayType {
    switch (type) {
      case 'sent': return 'Sent Money';
      case 'received': return 'Received Money';
      case 'withdraw': return 'Cash Withdrawal';
      case 'deposit': return 'Cash Deposit';
      case 'paybill': return 'Pay Bill';
      case 'buygoods': return 'Buy Goods';
      default: return 'Transaction';
    }
  }

  bool get isExpense => ['sent', 'withdraw', 'paybill', 'buygoods'].contains(type);
}