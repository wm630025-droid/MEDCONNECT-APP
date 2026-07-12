import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medconnect_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medconnect_app/models/order_model.dart';

class OrderServices {
  static const String baseUrl = 'https://med-connect-backend-ten.vercel.app/api/api';
//https://med-connect-backend-ten.vercel.app
  static Future<Map<String, dynamic>> fetchDoctorOrders({
    int page = 1,
    int perPage = 15,
    String status = '',
    bool forceRefresh = false,
    String orderType = '',
  }) async {
    
  if (!forceRefresh && 
      page == 1 && 
      orderType.isEmpty &&
      ApiService.cachedRecentOrders != null && 
      ApiService.cachedRecentOrdersTime != null &&
      DateTime.now().difference(ApiService.cachedRecentOrdersTime!).inMinutes < 5) {
    return {
      'success': true,
      'orders': ApiService.cachedRecentOrders!,
      'lastPage': 5,
      'perPage': perPage,
      'total': ApiService.cachedRecentOrders!.length,
    };
  }
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('Please login first.');
    }

    final uri = Uri.parse('$baseUrl/v1/order/doctor/show').replace(
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (status.isNotEmpty) 'status': status,
            if (orderType.isNotEmpty) 'type': orderType,  // ✅ كـ query param
                      
      },
    );

   
     
      
    final request = http.Request('GET', uri)
  ..headers.addAll({
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  })
  ..body = jsonEncode({
    'type': orderType,
  });

final streamedResponse = await request.send();
final response = await http.Response.fromStream(streamedResponse);

    final data = jsonDecode(response.body);
    print('order details: ${response.body} and status code ${response.statusCode} ');

    if (response.statusCode == 200 && data['success'] == true) {
      final dataPayload = data['data'];
      List<dynamic> ordersJson = [];
      int lastPage = data['last_page'] ?? 1;
      int perPageResponse = data['per_page'] ?? perPage;
      int subtotal = data['subtotal'] ?? 0;

      if (dataPayload is List) {
        ordersJson = dataPayload;
      } else if (dataPayload is Map<String, dynamic>) {
        if (dataPayload['data'] is List) {
          ordersJson = dataPayload['data'] as List<dynamic>;
        } else if (dataPayload['orders'] is List) {
          ordersJson = dataPayload['orders'] as List<dynamic>;
        }

        lastPage = dataPayload['last_page'] ?? lastPage;
        perPageResponse = dataPayload['per_page'] ?? perPageResponse;
        subtotal = dataPayload['subtotal'] ?? subtotal;
      }

      final orders = ordersJson
          .map((json) => Order.fromJson(json as Map<String, dynamic>))
          .toList();

          if (page == 1) {
      ApiService.cachedRecentOrders = orders;
      ApiService.cachedRecentOrdersTime = DateTime.now();
    }

      return {
        'success': true,
        'orders': orders,
        'lastPage': lastPage,
        'perPage': perPageResponse,
        'total': subtotal == 0 ? orders.length : subtotal,
      };
    }

    throw Exception(data['message'] ?? 'Failed to load orders.');
  }

  static Future<Order> fetchDoctorOrder(int orderId) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('Please login first.');
    }

    final uri = Uri.parse('$baseUrl/v1/order/doctor/show/$orderId');

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    try {
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);

      if (data['success'] == true && data['data'] != null) {
        return Order.fromJson(data['data'] as Map<String, dynamic>);
      }

      throw Exception(data['message'] ?? 'Failed to load order');
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);

      throw Exception('Failed to load order details: $e');
    }
  }

  static Future<Map<String, dynamic>> cancelDoctorOrder(int orderId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('Please login first.');
    }

    final uri = Uri.parse('$baseUrl/v1/order/doctor/cancel/$orderId');

    final response = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);
    print("STATUS CODE: ${response.statusCode}");
    print("RESPONSE BODY: ${response.body}");

    if (response.statusCode == 200 && data['success'] == true) {
      return data;
    } else {
      throw Exception(
        data['error'] ?? data['message'] ?? 'Failed to cancel order',
      );
    }
  }

  static Future<Map<String, dynamic>> assignOrderIssue({
    required int orderId,
    required String orderIssue,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('Please login first.');
    }

    final uri = Uri.parse('$baseUrl/v1/order/doctor/issue/$orderId');

    final response = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"order_issue": orderIssue}),
    );

    final data = jsonDecode(response.body);
    print('RESPONSE : $data');

    // نجاح
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        data['success'] != false) {
      return data;
    }

    // validation errors
    if (data['errors'] != null && data['errors']['order_issue'] != null) {
      throw Exception(data['errors']['order_issue'][0]);
    }

    // api error
    throw Exception(
      data['error'] ?? data['message'] ?? 'Failed to assign issue',
    );
  }

  static Future<Map<String, dynamic>> extendRent({
    required int orderId,
    required int extensionDays,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('Please login first.');
    }

    final uri = Uri.parse('$baseUrl/v1/payment/extend-rent');

    final response = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'order_id': orderId,
        'extension_days': extensionDays,
      }),
      
    );

    final data = jsonDecode(response.body);
     print('📦 RAW DATA: $data');
    print('🔍 DATA KEYS: ${data.keys}');
    print('📊 DATA STRUCTURE: ${data.toString()}');
    print('EXTEND RENT RESPONSE: ${response.statusCode} - ${response.body}');

    // نجاح: رجع فاتورة الدفع
    if (response.statusCode == 200 && data['status'] == 'success') {
      return {
        'success': true,
        'redirectUrl': data['data']['payment_data']['redirectTo'],
        'invoiceId': data['data']['invoice_id'],
      };
    }

    // أخطاء الفاليديشن
    if (data['errors'] != null) {
      final firstError = (data['errors'] as Map<String, dynamic>)
          .values
          .first[0];
      throw Exception(firstError);
    }

    // باقي حالات success: false
    throw Exception(data['error'] ?? data['message'] ?? 'Failed to extend rent');
  }

  /// بتستنى وتتأكد إن الـ extend اتأكد فعلاً من السيرفر
  /// بتحاول كذا مرة (polling) لحد ما تلاقي إن الحالة اتغيرت من pending
  static Future<Order?> waitForExtendConfirmation({
    required int orderId,
    required int itemId,
    int maxAttempts = 6,
    Duration interval = const Duration(seconds: 3),
  }) async {
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      await Future.delayed(interval);

      try {
        final order = await fetchDoctorOrder(orderId);
        final item = order.items.firstWhere(
          (it) => it.id == itemId,
          orElse: () => order.items.first,
        );

        // ✅ لو الـ extend_rent موجود وحالته مش pending، يبقى اتأكد
        if (item.extendRent != null &&
            item.extendRent!.status.toLowerCase() != 'pending') {
          print('✅ Extend confirmed after ${attempt + 1} attempt(s)');
          return order;
        }

        // ✅ أو لو rentalEnd نفسه اتغير عن القيمة القديمة (احتياطي)
        print('⏳ Attempt ${attempt + 1}: still pending, retrying...');
      } catch (e) {
        print('⚠️ Polling attempt ${attempt + 1} failed: $e');
        // نكمل نحاول تاني حتى لو فشل الطلب مرة
      }
    }

    print('⌛ Polling timed out after $maxAttempts attempts');
    return null; // خلص المحاولات ولسه pending - السيرفر لسه بيعالج
  }
}
