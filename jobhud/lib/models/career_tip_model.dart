class CareerTip {
  final int id;
  final String title;
  final String tip;
  final String category;
  final String icon;

  CareerTip({
    required this.id,
    required this.title,
    required this.tip,
    required this.category,
    required this.icon,
  });

  factory CareerTip.fromJson(Map<String, dynamic> json) {
    return CareerTip(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      tip: json['tip'] ?? '',
      category: json['category'] ?? '',
      icon: json['icon'] ?? 'lightbulb',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'tip': tip,
      'category': category,
      'icon': icon,
    };
  }
}
