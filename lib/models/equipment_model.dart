class EquipmentItem {
  final int id;
  final int productId;
  final String productName;
  final bool isAva;
  final String addedAt;

  EquipmentItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.isAva,
    required this.addedAt,
  });

  factory EquipmentItem.fromJson(Map<String, dynamic> json) {
    return EquipmentItem(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      isAva: json['is_ava'] ?? false,
      addedAt: json['added_at'] ?? '',
    );
  }
}

class EquipmentList {
  final int id;
   String listName;
  final bool isDefault;
  final String createdAt;
    bool isExpanded;  // ✅ أضيفي هذا السطر

  final List<EquipmentItem> items;

  EquipmentList({
    required this.id,
    required this.listName,
    required this.isDefault,
    required this.createdAt,
    required this.items,
    this.isExpanded = true,  // ✅ أضيفي هذا السطر
  });
// factory EquipmentList.fromJson(Map<String, dynamic> json) {
//   List<EquipmentItem> itemsList = [];

//   // ✅ معالجة items (سواء كانت List أو Map)
//   if (json['items'] != null) {
//     if (json['items'] is List) {
//       itemsList = (json['items'] as List)
//           .map((item) => EquipmentItem.fromJson(item))
//           .toList();
//     } else if (json['items'] is Map) {
//       // ✅ لو items كانت Map، ناخد القيم (values) ونحولها لقائمة
//       itemsList = (json['items'] as Map<String, dynamic>)
//           .values
//           .map((item) => EquipmentItem.fromJson(item))
//           .toList();
//     }
//   }

//   return EquipmentList(
//     id: json['id'] ?? 0,
//     listName: json['list_name'] ?? '',
//     isDefault: json['is_default'] ?? false,
//     createdAt: json['created_at'] ?? '',
//     items: itemsList,
//     isExpanded: json['is_expanded'] ?? true,
//   );
// }
  factory EquipmentList.fromJson(Map<String, dynamic> json) {
    return EquipmentList(
      id: json['id'] ?? 0,
      listName: json['list_name'] ?? '',
      isDefault: json['is_default'] ?? false,
      createdAt: json['created_at'] ?? '',
      items: json['items'] != null
          ? (json['items'] as List).map((item) => EquipmentItem.fromJson(item)).toList()
          : [],
      isExpanded: json['is_expanded'] ?? true,
    );
  }
}