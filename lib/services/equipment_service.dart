// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/equipment_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class EquipmentApiService {
//   static const String baseUrl = 'https://medconnect-one-pi.vercel.app';

 
//   // ✅✅✅ الميثود الوحيدة اللي انت عايزها ✅✅✅
//   static Future<List<EquipmentList>> getAllEquipmentLists() async {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('auth_token');

//     final response = await http.get(
//       Uri.parse('$baseUrl/api/api/v1/equipment-list/all-with-items'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//         if (token != null) 'Authorization': 'Bearer $token',
//       },
//     );

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);
//       final List<dynamic> listsData = data['data'];
//       print('Response Data: $data');
//       return listsData.map((json) => EquipmentList.fromJson(json)).toList();
//     } else {
//       throw Exception('Error: ${response.statusCode}');
//     }
//   }
// }
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medconnect_app/models/equipment_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


const String baseUrl = 'https://medconnect-one-pi.vercel.app/api/api/v1';

Future<Map<String, String>> _getHeaders() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  return {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
}

// 1. GET all lists (with items)
Future<List<EquipmentList>> getAllEquipmentLists() async {
  final headers = await _getHeaders();
  final response = await http.get(
    Uri.parse('$baseUrl/equipment-list/all-with-items'),
    headers: headers,
  );
  if (response.statusCode == 200) {
     print('Response Body#######################: ${response.body}'); // ✅ Debug print
    print('Response Status: ${response.statusCode}');
 final Map<String, dynamic> data = json.decode(response.body);
    
    // ✅ معالجة الحالة لو data['data'] كانت Map مش List
    if (data['data'] is List) {
      return (data['data'] as List)
          .map((json) => EquipmentList.fromJson(json))
          .toList();
    } else if (data['data'] is Map) {
      // ✅ لو data['data'] كانت Map فاضية {} أو فيها id: []
      return [];
    } else {
      return [];
    }
    
    // final Map<String, dynamic> data = json.decode(response.body);
    // final List<dynamic> listsData = data['data'];
    // print('Decoded Data: $data'); // ✅ Debug print
    // return listsData.map((json) => EquipmentList.fromJson(json)).toList();
  } else {
    throw Exception('Error fetching lists: ${response.statusCode}');
  }
}

// 2. GET simple lists (for dropdown)
Future<List<EquipmentList>> getSimpleLists() async {
  final headers = await _getHeaders();
  final response = await http.get(
    Uri.parse('$baseUrl/equipment-list'),
    headers: headers,
  );
  if (response.statusCode == 200) {
    print('----------------------------------');
    print('Response Body (Simple Lists): ${response.body}'); // ✅ Debug print
    print('Response Status (Simple Lists): ${response.statusCode}');
    final Map<String, dynamic> data = json.decode(response.body);
    
    if (data['data'] is List) {
      return (data['data'] as List)
          .map((json) => EquipmentList.fromJson(json))
          .toList();
    } else if (data['data'] is Map) {
      return [];
    } else {
      return [];
    }
    // final Map<String, dynamic> data = json.decode(response.body);
    // final List<dynamic> listsData = data['data'];
    // return listsData.map((json) => EquipmentList.fromJson(json)).toList();
  } else {
    throw Exception('Error fetching simple lists: ${response.statusCode}');
  }
}

// 3. GET single list by ID
Future<EquipmentList> getEquipmentListById(int listId) async {
  final headers = await _getHeaders();
  final response = await http.get(
    Uri.parse('$baseUrl/equipment-list/$listId'),
    headers: headers,
  );
  if (response.statusCode == 200) {
    // ✅ Debug print
    
    final Map<String, dynamic> data = json.decode(response.body);
    print('Decoded Data: $data'); // ✅ Debug print
    return EquipmentList.fromJson(data['data']);
    
  } else {
    throw Exception('Error fetching list by id: ${response.statusCode}');
  }
}

// 4. POST create new list
Future<void> createEquipmentList(String listName) async {
  final headers = await _getHeaders();
  final response = await http.post(
    Uri.parse('$baseUrl/equipment-list'),
    headers: headers,
    body: jsonEncode({"list_name": listName}),
  );
  if (response.statusCode != 201) {
    throw Exception('Failed to create list: ${response.statusCode}');
  }
}

// 5. POST add product to list
Future<void> addItemToList(int listId, int productId) async {
  final headers = await _getHeaders();
  final response = await http.post(
    Uri.parse('$baseUrl/equipment-list/$listId/add-item'),
    headers: headers,
    body: jsonEncode({"product_id": productId.toString()}),
  );
  if (response.statusCode == 422 && response.body.contains('already in the list')) {
    throw 'Product already in the list';
  } else if (response.statusCode != 201 && response.statusCode != 200) {
    throw Exception('Failed to add item: ${response.statusCode}');
  }
}

// 6. DELETE list
Future<void> deleteEquipmentList(int listId) async {
  final headers = await _getHeaders();
  final response = await http.delete(
    Uri.parse('$baseUrl/equipment-list/$listId'),
    headers: headers,
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to delete list: ${response.statusCode}');
  }
}

// 7. GET check if product is in specific list
Future<bool> isProductInList(int listId, int productId) async {
  final headers = await _getHeaders();
  final response = await http.get(
    Uri.parse('$baseUrl/equipment-list/$listId/is-in-list/$productId'),
    headers: headers,
  );
  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    return data['success'] ?? false;
  }
  return false;
}
// 8. PUT update list name
  Future<void> updateEquipmentListName(int listId, String newName, {bool isDefault = false}) async {
  final headers = await _getHeaders();
  final response = await http.post(
    Uri.parse('$baseUrl/equipment-list/$listId/update'),
    headers: headers,
    body: jsonEncode({
      "list_name": newName,
      "is_default": isDefault,
    }),
  );
  print('📦 Update List Response (${response.statusCode}): ${response.body}');
  if (response.statusCode != 200) {
    final error = json.decode(response.body);
    throw Exception(error['message'] ?? 'Failed to update list name');
  }
}
// 9. DELETE remove item from list
Future<void> removeItemFromList(int listId, int productId) async {
  final headers = await _getHeaders();
  final response = await http.delete(
    Uri.parse('$baseUrl/equipment-list/$listId/remove-item/$productId'),
    headers: headers,
    body: jsonEncode({"product_id": productId.toString()}),
  );
  print('📦 Remove Item Response (${response.statusCode}): ${response.body}');
  if (response.statusCode != 200) {
    final error = json.decode(response.body);
    throw Exception(error['message'] ?? 'Failed to remove item');
  }
}