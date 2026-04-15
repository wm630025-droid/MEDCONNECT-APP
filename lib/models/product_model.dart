import 'package:medconnect_app/models/product_image.dart';


class ProductModel {
  final String? name;
  final double? price;
  final bool? is_rentable;
  final List<ProductImage> images;

  ProductModel({
    this.name,
    this.price,
    this.is_rentable,
    required this.images,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    List<ProductImage> imageList = [];

    if (json['image'] != null && json['image'] is List) {
      for (var item in json['image']) {
        imageList.add(ProductImage.fromJson(item));
      }
    }

    return ProductModel(
      name: json["name"] ?? 'Unknown Product',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      is_rentable: json['is_rentable'] ?? false,
      images: imageList,
    );
  }
}