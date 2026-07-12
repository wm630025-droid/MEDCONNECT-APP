import 'package:medconnect_app/models/product.dart';

class Order {
  final int id;
  final int doctorId;
  final String orderType;
  final String orderIssue;
  final double subtotal;
  final double total;
  final String? invoiceKey;
  final String invoiceNumber;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.doctorId,
    required this.orderType,
    required this.orderIssue,
    required this.subtotal,
    required this.total,
    this.invoiceKey,
    required this.invoiceNumber,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return Order(
      id: json['id'] ?? 0,
      doctorId: json['doctor_id'] ?? 0,
      orderType: json['order_type'] ?? '',
      orderIssue: json['order_issue'] ?? '',
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '') ?? 0.0,
      total: double.tryParse(json['total']?.toString() ?? '') ?? 0.0,
      invoiceKey: json['invoice_key'],
      invoiceNumber: json['invoice_number'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      items: itemsJson.isNotEmpty
          ? itemsJson
                .map(
                  (itemJson) =>
                      OrderItem.fromJson(itemJson as Map<String, dynamic>),
                )
                .toList()
          : [],
    );
  }
}

class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final double unitPrice;
  final double finalPrice;
  final String description;
  final String name;
  final double total; // ✅ تأكد من وجوده
  final DateTime? rentalStart;
  final DateTime? rentalEnd;
  final Product? product;
  final double? dailyPrice; // ✅ أضف هذا
  final int? rentalDays; // ✅ أضف هذا
  final String? startDate; // ✅ أضف هذا (اختياري)
  final String? endDate;
    final ExtendRentInfo? extendRent; // ✅ جديد
 // ✅ أضف هذا (اختياري)

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.finalPrice,
    required this.description,
    required this.name,
    required this.total,

    this.rentalStart,
    this.rentalEnd,
    this.product,
    this.dailyPrice,
    this.rentalDays,
    this.startDate,
    this.endDate,
    this.extendRent,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      orderId: json['order_id'] ?? 0,

      productId: json['product_id'] ?? 0,
      total: double.tryParse(json['total']?.toString() ?? '') ?? 0.0,


      quantity: int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
      unitPrice: double.tryParse(json['unit_price']?.toString() ?? '') ?? 0.0,
      dailyPrice: json['daily_price'] != null
          ? double.tryParse(json['daily_price'].toString()) ?? 0.0
          : null,

      finalPrice: double.tryParse(json['final_price']?.toString() ?? '') ?? 0.0,

      description: json['product']?['description'] ?? json['description'] ?? '',

      name: json['product']?['name'] ?? json['name'] ?? '',

      rentalStart: json['rental_start'] != null
          ? DateTime.tryParse(json['rental_start'])
          : null,

      rentalEnd: json['rental_end'] != null
          ? DateTime.tryParse(json['rental_end'])
          : null,

      product: json['product'] != null
          ? Product.fromJson(json['product'] as Map<String, dynamic>)
          : null,
           extendRent: json['extend_rent'] != null // ✅ السطر الناقص - ضيفه
          ? ExtendRentInfo.fromJson(json['extend_rent'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ExtendRentInfo {
  final int id;
  final int itemId;
  final int? extendDay;
  final String? invoiceKey;
  final String status;
  final String? amount;
  final String? paymentMethod;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? prevDay;

  ExtendRentInfo({
    required this.id,
    required this.itemId,
    this.extendDay,
    this.invoiceKey,
    required this.status,
    this.amount,
    this.paymentMethod,
    this.createdAt,
    this.updatedAt,
    this.prevDay,
  });

  factory ExtendRentInfo.fromJson(Map<String, dynamic> json) {
    return ExtendRentInfo(
      id: json['id'] ?? 0,
      itemId: json['item_id'] ?? 0,
      extendDay: json['extend_day'] != null
          ? int.tryParse(json['extend_day'].toString())
          : null,
      invoiceKey: json['invoice_key'],
      status: json['status'] ?? 'pending',
      amount: json['amount']?.toString(),
      paymentMethod: json['payment_method'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      prevDay: json['prev_day'] != null
          ? int.tryParse(json['prev_day'].toString())
          : null,
    );
  }
}
