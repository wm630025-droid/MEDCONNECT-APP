import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

String _stringifyDynamicValue(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is Map || value is List) return jsonEncode(value);
  return value.toString();
}

class PaymentService {
  static const String baseUrl =
      'https://medconnect-one-pi.vercel.app/api/api';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, dynamic>> placeCashOrder({
    required String orderType,
    required List<Map<String, dynamic>> cartItems,
    required double cartTotal,
    String? rentalStartDate,
    String? rentalEndDate,
  }) async {
    try {
      final token = await _getToken();

      final Map<String, dynamic> body = {
        'payment_type': 'cash',
        'order_type': orderType,
        'cart_total': cartTotal,
      };

      if (cartItems.length == 1) {
        final item = cartItems[0];
        body['product_id'] = item['product_id'].toString();
        body['quantity'] = item['quantity'];
      } else {
        body['items'] = cartItems;
      }

      if (rentalStartDate != null) body['rental_start_date'] = rentalStartDate;
      if (rentalEndDate != null) body['rental_end_date'] = rentalEndDate;

      print('Sending payment request...');
      print('📦 Payment Type: cash');
      print('📦 Order Type: $orderType');
      print('📦 Cart Items: $cartItems');
      print('📦 Cart Total: $cartTotal');

      final response = await http.post(
        Uri.parse('$baseUrl/v1/payment'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('📤 Request Body: ${jsonEncode(body)}');
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      final bool isSuccessfulResponse = response.statusCode == 200 || response.statusCode == 201;
      final bool hasSuccessFlag = data['success'] == true;
      final String responseMessage = (data['message'] ?? '').toString().toLowerCase();
      final bool isSuccessMessage = responseMessage.contains('success') ||
          responseMessage.contains('created') ||
          responseMessage.contains('placed') ||
          responseMessage.contains('approved');

      if (isSuccessfulResponse && (hasSuccessFlag || isSuccessMessage)) {
        final orderData = data['data']?['data'];
        return {
          'success': true,
          'message': data['message'] ?? 'Order placed successfully',
          'invoiceNumber': orderData?['invoice_number'] ?? '',
          'status': orderData?['status'] ?? '',
          'redirectTo': null,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? jsonEncode(data),
        };
      }
    } catch (e) {
      print('❌ PaymentService Error: $e');
      return {
        'success': false,
        'message': 'Payment failed: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> placeRentalOrder({
    required int productId,
    required int quantity,
    required String startDate,
    required String endDate,
    required String paymentType,
  }) async {
    try {
      final token = await _getToken();
      final normalizedPaymentType = paymentType.trim().toLowerCase();
      final finalPaymentType = normalizedPaymentType == 'cod' || normalizedPaymentType == 'cash'
          ? 'cash'
          : normalizedPaymentType == 'online' || normalizedPaymentType == 'card' || normalizedPaymentType == 'card_payment'
              ? 'online'
              : normalizedPaymentType;

      final response = await http.post(
        Uri.parse('$baseUrl/v1/payment'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'payment_type': finalPaymentType,
          'order_type': 'rental',
          'product_id': productId.toString(),
          'rental_start_date': startDate,
          'rental_end_date': endDate,
          'quantity': quantity,
        }),
      );

      final data = jsonDecode(response.body);

      final bool isSuccessfulResponse = response.statusCode == 200 || response.statusCode == 201;
      final bool hasSuccessFlag = data['success'] == true;
      final String responseMessage = (data['message'] ?? '').toString().toLowerCase();
      final bool isSuccessMessage = responseMessage.contains('success') ||
          responseMessage.contains('created') ||
          responseMessage.contains('placed') ||
          responseMessage.contains('approved');

      if (isSuccessfulResponse && (hasSuccessFlag || isSuccessMessage)) {
        final orderData = data['data']?['data'];
        final items = orderData?['items'] is List && (orderData?['items'] as List).isNotEmpty
            ? (orderData!['items'] as List).first
            : null;
        final rentalDetails = items?['product']?['rental_details'];

        String? paymentLink;
        final paymentData = data['payment_data'];
        if (paymentData is Map) {
          paymentLink = _stringifyDynamicValue(paymentData['redirectTo']);
        }

        return {
          'success': true,
          'message': data['message'] ?? 'Order placed successfully',
          'invoiceNumber': orderData?['invoice_number'] ?? '',
          'status': orderData?['status'] ?? '',
          'paymentLink': paymentLink ?? '',
          'dailyPrice': rentalDetails != null
              ? double.tryParse(rentalDetails['price_daily'].toString()) ?? 0.0
              : 0.0,
          'subtotal': orderData != null
              ? double.tryParse(orderData['subtotal'].toString()) ?? 0.0
              : 0.0,
          'total': orderData != null
              ? double.tryParse(orderData['total'].toString()) ?? 0.0
              : 0.0,
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to place rental order',
      };
    } catch (e) {
      print('❌ PaymentService Rental Error: $e');
      return {
        'success': false,
        'message': 'Failed to place rental order: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> placeOnlineOrder({
    required String orderType,
    required List<Map<String, dynamic>> cartItems,
    required double cartTotal,
    String? rentalStartDate,
    String? rentalEndDate,
  }) async {
    try {
      final token = await _getToken();

      final Map<String, dynamic> body = {
        'payment_type': 'online',
        'order_type': orderType,
        'cart_total': cartTotal,
      };

      if (cartItems.length == 1) {
        final item = cartItems[0];
        body['product_id'] = item['product_id'].toString();
        body['quantity'] = item['quantity'];
      } else {
        body['items'] = cartItems;
      }

      if (rentalStartDate != null) body['rental_start_date'] = rentalStartDate;
      if (rentalEndDate != null) body['rental_end_date'] = rentalEndDate;

      print('Sending payment request...');
      print('📦 Payment Type: online');
      print('📦 Order Type: $orderType');
      print('📦 Cart Items: $cartItems');
      print('📦 Cart Total: $cartTotal');

      final response = await http.post(
        Uri.parse('$baseUrl/v1/payment'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('📤 Request Body: ${jsonEncode(body)}');
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      final bool isSuccessfulResponse = response.statusCode == 200 || response.statusCode == 201;
      final bool hasSuccessFlag = data['success'] == true;
      final String responseMessage = (data['message'] ?? '').toString().toLowerCase();
      final bool isSuccessMessage = responseMessage.contains('success') ||
          responseMessage.contains('created') ||
          responseMessage.contains('placed') ||
          responseMessage.contains('approved');

      if (isSuccessfulResponse && (hasSuccessFlag || isSuccessMessage)) {
        final orderData = data['data']?['data'];

        // ✅ استخراج paymentLink بأمان
        String? redirectTo;
        final paymentData = data['payment_data'];
        if (paymentData is Map) {
          redirectTo = _stringifyDynamicValue(paymentData['redirectTo']);
        }

        return {
          'success': true,
          'message': data['message'] ?? 'Order placed successfully',
          'invoiceNumber': orderData?['invoice_id'] ?? '',
          'status': orderData?['status'] ?? '',
          'redirectTo': redirectTo ?? '',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? jsonEncode(data),
        };
      }
    } catch (e) {
      print('❌ PaymentService Error: $e');
      return {
        'success': false,
        'message': 'Payment failed: $e',
      };
    }
  }
}