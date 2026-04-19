

enum ProductAction { addToCart, notify, rentBuy }

class SupplierProduct {
  final String name;
  final String category;
  final String image;
  final String price;
  final String? subtitle;
  final ProductAction action;

  SupplierProduct({
    required this.name,
    required this.category,
    required this.image,
    required this.price,
    this.subtitle,
    required this.action,
  });
}
