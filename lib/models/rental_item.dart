class RentalItem {
  final int productId;
  final String name;
  final double price;
  final String image;
  final int quantity;
  final String startDate;
  final String endDate;

  RentalItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
    required this.startDate,
    required this.endDate,
  });
}