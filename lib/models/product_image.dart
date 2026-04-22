 class ProductImage {
  final int id;
  final int productId;
  final String image;
  final String cloudinaryImageId;
  final String createdAt;
  final String updatedAt;

  ProductImage({
    required this.id,
    required this.productId,
    required this.image,
    required this.cloudinaryImageId,
    required this.createdAt,
    required this.updatedAt,
  });
   factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json["id"],
      productId: json["product_id"],
      image: json["image"] ?? "",
      cloudinaryImageId: json["cloudinary_image_id"],
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],
    );
  }
 }