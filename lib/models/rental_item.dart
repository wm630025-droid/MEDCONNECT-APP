class RentalItem {
  final int productId;
  final String name;
  final double dailyPrice; // ✅ double
  final String image;
  final int quantity;
  final String startDate;
  final String endDate;
  final double? price;
  final int? orderId;
  final String? invoiceNumber;
  final String? status;
  final double? subtotal;
  final double? total;
  final int? minRentalDays;
  final int? maxRentalDays;
  final int? availableUnits;

  RentalItem({
    required this.productId,
    required this.name,
    required this.dailyPrice,
    required this.image,
    required this.quantity,
    required this.startDate,
    required this.endDate,

    this.price,
    this.orderId,
    this.invoiceNumber,
    this.status,
    this.subtotal,
    this.total,
    this.minRentalDays,
    this.maxRentalDays,
    this.availableUnits,
  });

  factory RentalItem.fromJson(Map<String, dynamic> json) {
    final orderData = json['data']['data'];
    final item = orderData['items'][0];
    final product = item['product'];
    final rentalDetails = product['rental_details'];

    return RentalItem(
      orderId: orderData['id'] ?? 0,
      invoiceNumber: orderData['invoice_number'] ?? '',
      status: orderData['status'] ?? '',
      subtotal: double.tryParse(orderData['subtotal'].toString()) ?? 0.0,
      total: double.tryParse(orderData['total'].toString()) ?? 0.0,
      productId: product['id'] ?? 0,
      name: product['name'] ?? '',
      price: double.tryParse(item['unit_price'].toString()) ?? 0.0,
      dailyPrice: double.tryParse(rentalDetails['price_daily'].toString()) ?? 0.0, // ✅
      image: '',
      quantity: item['quantity'] ?? 0,
      startDate: item['rental_start'] ?? '',
      endDate: item['rental_end'] ?? '',
      minRentalDays: rentalDetails['minimum_rental_days'] ?? 0,
      maxRentalDays: rentalDetails['maximum_rental_days'] ?? 0,
      availableUnits: rentalDetails['available_units'] ?? 0,
    );
  }
}