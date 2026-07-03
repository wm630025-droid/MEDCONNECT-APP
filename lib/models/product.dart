import 'package:medconnect_app/models/product_image.dart';
import 'package:medconnect_app/models/review.dart';

class Product {
  final int id;
  final int supplierId;
  final String name;
  final String brand;
  final double price;
  final double? dailyPrice; // ✅ double? مش String
  final String imagePath;
   int? rentalStock;
  final int stock;
  final bool isRentable;
  final DateTime? restockDate;
  final String status;
  final List<ProductImage> images;
  final Map<String, dynamic>? supplierData;
  final String description;
  final List<dynamic> specification;
  final String warranty;
  final String? configuration;
  final int setupDuration;
  final List<Review> reviews;

  Product({
    required this.id,
    required this.supplierId,
    required this.name,
    required this.brand,
    required this.price,
    required this.imagePath,
    required this.stock,
    required this.isRentable,
    this.restockDate,
    
    required this.status,
    required this.images,
    this.configuration,
    required this.supplierData,
    required this.description,
    required this.specification,
    required this.warranty,
    required this.setupDuration,
    required this.reviews,
    this.dailyPrice, 
    this.rentalStock// ✅ optional
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String firstImage = '';
    List<ProductImage> imagesList = [];

    dynamic config = json['configuration'];
    String? configurationValue;

    if (config != null) {
      if (config is String) {
        configurationValue = config.isEmpty ? null : config;
      } else if (config is num) {
        configurationValue = config.toString();
      } else if (config is Map) {
        configurationValue = config.toString();
      } else {
        configurationValue = config.toString();
      }
    }

    if (json['image'] != null && json['image'] is List) {
      imagesList = (json['image'] as List)
          .map((img) => ProductImage.fromJson(img as Map<String, dynamic>))
          .toList();
      firstImage = imagesList.isNotEmpty ? imagesList.first.image : '';
    }

    List<Review> reviewsList = [];
    if (json['reviews'] != null && json['reviews'] is List) {
      reviewsList = (json['reviews'] as List)
          .map((r) => Review.fromJson(r))
          .toList();
    }

    // ✅ استخراج dailyPrice بأمان
    double? dailyPrice;
    if (json['rental_details'] != null &&
        json['rental_details']['price_daily'] != null) {
      dailyPrice = double.tryParse(
        json['rental_details']['price_daily'].toString(),
      );
    }

int?rentalStock;
if (json['rental_details'] != null ) {
      rentalStock = json['rental_details']['available_units']??0;
    }

    return Product(
      id: json['id'],
      supplierId: json['supplier_id'] ?? 0,
      name: json['name'],
      brand: json['name'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      imagePath: firstImage,
      stock: json['stock'] ?? 0,
      isRentable: json['is_rentable'] ?? false,
      restockDate: json['restock_date'] != null
          ? DateTime.tryParse(json['restock_date'])
          : null,
      status: json['status'] ?? 'active',
      images: imagesList,
      description: json['description'] ?? '',
      specification: json['specification'] ?? [],
      warranty: json['warranty'] ?? '0',
      setupDuration: json['setup_duration'] ?? 0,
      supplierData: json['supplier'],
      configuration: configurationValue,
      dailyPrice: dailyPrice, // ✅
      reviews: reviewsList,
      rentalStock: rentalStock,
      
    );
  }
}