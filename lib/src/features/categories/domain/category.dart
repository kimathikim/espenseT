class Category {
  final String id;
  final String name;
  final String? icon;
  final String? color;
  final String? userId; // null for default categories, user ID for custom categories
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    this.userId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      color: json['color'],
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
