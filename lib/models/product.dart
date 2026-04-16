class Product {
  final int id;
  final int supplierId;              // ✅ جديد (مهم للمورد)
  final String name;
  final String brand;
  final double price;
  final String imagePath;
  final int stock;
  final bool isRentable;
  final DateTime? restockDate;
  final String status;
  final List<String> images;
  final Map<String, dynamic>? supplierData; 
  // ✅ الحقول الجديدة من API
  final String description;
  final List<dynamic> specification;
  final String warranty;
  final String? configuration;
  final int setupDuration;

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
  });

  // دالة لتحويل JSON من API إلى Product
  factory Product.fromJson(Map<String, dynamic> json) {
    // استخراج أول صورة
    String firstImage = '';
    List<String> imagesList = [];
    // ✅ معالجة configuration
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
          .map((img) => img['image'] as String)
          .toList();
      firstImage = imagesList.isNotEmpty ? imagesList.first : '';
    }

    return Product(
      id: json['id'],
      supplierId: json['supplier_id'] ?? 0,
      name: json['name'],
      brand: json['name'], // مؤقتاً، لو مفيش brand منفصل
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
       configuration: configurationValue
    );
  }
}