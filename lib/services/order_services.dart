import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medconnect_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medconnect_app/models/order_model.dart';

class OrderServices {
  static const String baseUrl = 'https://medconnect-one-pi.vercel.app/api/api';

  static Future<Map<String, dynamic>> fetchDoctorOrders({
    int page = 1,
    int perPage = 15,
    String status = '',
    bool forceRefresh = false,
  }) async {
    
  if (!forceRefresh && 
      page == 1 && 
      ApiService.cachedRecentOrders != null && 
      ApiService.cachedRecentOrdersTime != null &&
      DateTime.now().difference(ApiService.cachedRecentOrdersTime!).inMinutes < 5) {
    return {
      'success': true,
      'orders': ApiService.cachedRecentOrders!,
      'lastPage': 1,
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
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);
    print('order details: ${response.body} and status code ${response.statusCode} ');

    if (response.statusCode == 200 && data['success'] == true) {
      final dataPayload = data['data'];
      List<dynamic> ordersJson = [];
      int lastPage = data['last_page'] ?? 1;
      int perPageResponse = data['per_page'] ?? perPage;
      int total = data['total'] ?? 0;

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
        total = dataPayload['total'] ?? total;
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
        'total': total == 0 ? orders.length : total,
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
}
