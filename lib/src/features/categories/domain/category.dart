class Category {
  final String id;
  final String name;
  final String? icon;
  final String? color;

  Category({
    required this.id,
    required this.name,
    this.icon,
    this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: json['icon_name'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_name': icon,
      'color': color,
    };
  }
}
