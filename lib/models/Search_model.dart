import 'package:medconnect_app/models/product_image.dart';


class ProductModel {
  final String name;
  final double price;
  final bool? is_rentable;
  final List<ProductImage> image;
  final int? id;
  final double? dailyPrice; // Add the id field

  ProductModel({
    required this.name,
    required this.price,
    required this.is_rentable,
    required this.image,
    required this.id,
     this.dailyPrice
     // Initialize the id field
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    List<ProductImage> imageList = [];

    if (json['image'] != null && json['image'] is List) {
      for (var item in json['image']) {
        imageList.add(ProductImage.fromJson(item));
      }
    }

    double parsedDailyPrice = 0.0;
    if (json['rental_details'] != null) {
      parsedDailyPrice = double.tryParse(
            json['rental_details']['price_daily']?.toString() ?? '',
          ) ??
          0.0;
    }

    return ProductModel(
      name: json["name"] ?? 'Unknown Product',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      is_rentable: json['is_rentable'] ?? false,
      image: imageList,
      id: json['id'] ?? 0,
      dailyPrice: parsedDailyPrice,
    );
  }
}
class CategoryApiModel {
  final int id;
  final String name;
  final String description;
  final bool isActive;

  CategoryApiModel({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
  });

  factory CategoryApiModel.fromJson(Map<String, dynamic> json) {
    return CategoryApiModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isActive: json['is_active'],
    );
  }
}