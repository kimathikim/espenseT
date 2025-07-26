class Expense {
  final String id;
  final String? description;
  final double amount;
  final DateTime transactionDate;
  final String categoryId;
  final String userId;
  final String? screenshotUrl;

  Expense({
    required this.id,
    this.description,
    required this.amount,
    required this.transactionDate,
    required this.categoryId,
    required this.userId,
    this.screenshotUrl,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      description: json['description'],
      amount: (json['amount'] as num).toDouble(),
      transactionDate: DateTime.parse(json['transaction_date']),
      categoryId: json['category_id'],
      userId: json['user_id'],
      screenshotUrl: json['screenshot_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'transaction_date': transactionDate.toIso8601String(),
      'category_id': categoryId,
      'user_id': userId,
      'screenshot_url': screenshotUrl,
    };
  }
}
