class OfferRequest {
  final int id;
  final int requestId;
  final int supplierId;
  final String price;
  final int deliveryDays;
  final String? notes;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Supplier supplier;

  OfferRequest({
    required this.id,
    required this.requestId,
    required this.supplierId,
    required this.price,
    required this.deliveryDays,
    this.notes,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.supplier,
  });

  factory OfferRequest.fromJson(Map<String, dynamic> json) {
    return OfferRequest(
      id: json['id'],
      requestId: json['request_id'],
      supplierId: json['supplier_id'],
      price: json['price'],
      deliveryDays: json['delivery_days'],
      notes: json['notes'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      supplier: Supplier.fromJson(json['supplier']),
    );
  }
}

class Supplier {
  final int id;
  final String companyName;
  final String? companyImageUrl;

  Supplier({
    required this.id,
    required this.companyName,
    this.companyImageUrl,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'],
      companyName: json['company_name'],
      companyImageUrl: json['company_image_url'],
    );
  }
}