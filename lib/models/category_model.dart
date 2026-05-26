class CategoryModel {
  final String id;
  final String name;
  final String iconName;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconName,
    required this.isActive,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, String docId) {
    return CategoryModel(
      id: docId,
      name: map['name'] ?? '',
      iconName: map['iconName'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'iconName': iconName,
      'isActive': isActive,
    };
  }
}
