import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CartService {

  static const String baseUrl =
      'https://medconnect-one-pi.vercel.app/api/api';

    Future<Map<String, dynamic>> addToCart({
    required int productId,
    int quantity = 1,
    String type = "sale",
    String? token,
  }) async {
     final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final url = Uri.parse('$baseUrl/v1/cart/add/$productId');

    final response = await http.post(
      url,
      headers: {
         'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "quantity": quantity,
        "type": type,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      return {
        'success': false,
        'message': jsonDecode(response.body)['message'] ?? 'Unauthorized. Please log in.',
      };
    } else if (response.statusCode == 422) {
      return {
        'success': false,
        'error': jsonDecode(response.body)['error'] ?? 'Invalid request data.',
      };
    } else {
      throw Exception('Failed to add to cart: ${response.body}');
    }
  }
  
   Future<List<dynamic>> getCartItems()
    
  async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      print("TOKEN => $token");
    final response = await http.get(
      Uri.parse('$baseUrl/v1/cart/show'),
      headers: {
         'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    print('Reponse Cart body: ${response.body}');
    if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    
    // تخزين الرسالة في متغير
    _lastMessage = responseData['message'] ?? 'Cart loaded';
    
    // لو الـ response فيه 'data' استخدمه، وإلا استخدم الـ response نفسه
    if (responseData is Map && responseData.containsKey('data')) {
      return responseData['data'];
    } else if (responseData is List) {
      return responseData;
    } else {
      return [];
    }
  } else {
      throw Exception('message: ${response.body}');
    }
    
  }
  

  Future<Map<String, dynamic>> updateCart({
  required int cartId,
  required int quantity,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  final url = Uri.parse('$baseUrl/v1/cart/update/$cartId');

  final response = await http.post(
    url,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      "quantity": quantity,
    }),
  );

  print('Update response status: ${response.statusCode}');
  print('Update response body: ${response.body}');

  if (response.statusCode == 200 || response.statusCode == 201) {
    final data = jsonDecode(response.body);
    
    // ✅ تأكد من إرجاع Map فيها message
    return {
      'success': true,
      'message': data['message'] ?? 'Quantity updated successfully',
      'data': data,
    };
  } else {
    throw Exception('Failed to update cart: ${response.body}');
  }
}

String _lastMessage = '';
String get lastMessage => _lastMessage;

Future<Map<String, dynamic>> deleteCartItem({
  required int cartId,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final savedToken = prefs.getString('auth_token');
  
  final response = await http.delete(
    Uri.parse('$baseUrl/v1/cart/delete/$cartId'),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (savedToken != null) 'Authorization': 'Bearer $savedToken',
    },
  );

  final data = jsonDecode(response.body);
  print('=== DELETE RESPONSE ===');
  print('Status code: ${response.statusCode}');
  print('Response body: ${response.body}');
  print('=======================');

  if (response.statusCode == 200) {
    return {
      'success': true,
      'message': data['message'] ?? 'Item deleted successfully',
    };
  } else {
    throw Exception(data['message'] ?? 'Delete failed');
  }
}
}