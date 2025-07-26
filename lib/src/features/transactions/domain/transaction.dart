class Transaction {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String categoryId;
  final String userId;

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.categoryId,
    required this.userId,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      description: json['description'],
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      categoryId: json['category_id'],
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'category_id': categoryId,
      'user_id': userId,
    };
  }
}
