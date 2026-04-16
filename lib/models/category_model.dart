class CategoryModel {
  final int id;
  final String name;
  final String description;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isActive: json['is_active'],
    );
  }
}