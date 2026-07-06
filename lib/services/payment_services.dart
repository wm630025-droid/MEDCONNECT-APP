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

  /// يفهم الـ response بشكليه (Cash confirmation / Online redirect link)
  /// ويرجّع Map موحّد دايمًا بنفس الـ keys، سواء sale أو rental
  static Map<String, dynamic> _parsePaymentResponse(
    int statusCode,
    Map<String, dynamic> data,
  ) {
    final bool isSuccessfulResponse = statusCode == 200 || statusCode == 201;

    if (!isSuccessfulResponse) {
      return {
        'success': false,
        'message': data['message']?.toString() ?? 'Request failed',
      };
    }

    final nestedData = data['data'];

    // ================== Shape B: رابط دفع أونلاين (Fawaterk) ==================
    // { "status": "success", "data": { "invoice_id", "payment_data": { "redirectTo" } } }
    if (data['status'] == 'success' &&
        nestedData is Map &&
        nestedData['payment_data'] is Map) {
      final paymentData = nestedData['payment_data'] as Map;
      final redirectTo = _stringifyDynamicValue(paymentData['redirectTo']);

      return {
        'success': true,
        'message': 'Order placed successfully',
        'invoiceNumber': nestedData['invoice_id']?.toString() ?? '',
        'redirectTo': redirectTo,
        'subtotal': 0.0,
        'total': 0.0,
        'dailyPrice': 0.0,
      };
    }

    // ================== Shape A: طلب مؤكد مباشرة (Cash) ==================
    // { "success": true, "message": "...", "data": { "data": { order fields } } }
    final bool hasSuccessFlag = data['success'] == true;
    final String responseMessage = (data['message'] ?? '').toString().toLowerCase();
    final bool isSuccessMessage = responseMessage.contains('success') ||
        responseMessage.contains('created') ||
        responseMessage.contains('placed') ||
        responseMessage.contains('approved');

    if (hasSuccessFlag || isSuccessMessage) {
      final orderData = nestedData is Map ? nestedData['data'] : null;

      final items = orderData is Map &&
              orderData['items'] is List &&
              (orderData['items'] as List).isNotEmpty
          ? (orderData['items'] as List).first
          : null;
Map? rentalDetails;
if (items is Map) {
  final product = items['product'];
  if (product is Map) {
    rentalDetails = product['rental_details'];
  }
}
      return {
        'success': true,
        'message': data['message']?.toString() ?? 'Order placed successfully',
        'invoiceNumber': orderData?['invoice_number']?.toString() ?? '',
        'redirectTo': '', // مفيش لينك دفع في الشكل ده
        'subtotal': orderData != null
            ? double.tryParse(orderData['subtotal'].toString()) ?? 0.0
            : 0.0,
        'total': orderData != null
            ? double.tryParse(orderData['total'].toString()) ?? 0.0
            : 0.0,
        'dailyPrice': rentalDetails != null
            ? double.tryParse(rentalDetails['price_daily'].toString()) ?? 0.0
            : 0.0,
      };
    }

    // ================== أي شكل تاني = فشل ==================
    return {
      'success': false,
      'message': data['message']?.toString() ?? 'Failed to place order',
    };
  }

  static String _normalizePaymentType(String paymentType) {
    final t = paymentType.trim().toLowerCase();
    if (t == 'cod' || t == 'cash') return 'cash';
    if (t == 'online' || t == 'card' || t == 'card_payment') return 'online';
    return t;
  }

  /// نقطة الدخول المشتركة لأي طلب دفع (sale أو rental)، كاش أو أونلاين
  static Future<Map<String, dynamic>> _sendPaymentRequest({
    required String paymentType, // 'cash' or 'online'
    required String orderType,   // 'sale' or 'rental'
    double? cartTotal,
    List<Map<String, dynamic>>? cartItems,
    int? productId,
    int? quantity,
    String? rentalStartDate,
    String? rentalEndDate,
  }) async {
    try {
      final token = await _getToken();
      final finalPaymentType = _normalizePaymentType(paymentType);

      final Map<String, dynamic> body = {
        'payment_type': finalPaymentType,
        'order_type': orderType,
      };

      if (orderType == 'rental') {
        // ================== Rental Payload ==================
        body['product_id'] = productId?.toString() ?? '';
        body['quantity'] = quantity ?? 1;
        if (rentalStartDate != null) body['rental_start_date'] = rentalStartDate;
        if (rentalEndDate != null) body['rental_end_date'] = rentalEndDate;
      } else {
        // ================== Sale Payload ==================
        body['cart_total'] = cartTotal ?? 0.0;
        if (cartItems != null && cartItems.length == 1) {
          final item = cartItems[0];
          body['product_id'] = item['product_id'].toString();
          body['quantity'] = item['quantity'];
        } else if (cartItems != null) {
          body['items'] = cartItems;
        }
      }

      print('📦 Payment Type: $finalPaymentType | Order Type: $orderType');
      print('📦 Body: $body');

      final response = await http.post(
        Uri.parse('$baseUrl/v1/payment'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      final data = jsonDecode(response.body);
      return _parsePaymentResponse(response.statusCode, data);
    } catch (e) {
      print('❌ PaymentService Error: $e');
      return {
        'success': false,
        'message': 'Payment failed: $e',
      };
    }
  }

  /// كاش - يدعم sale و rental
  static Future<Map<String, dynamic>> placeCashOrder({
    required String orderType, // 'sale' or 'rental'
    List<Map<String, dynamic>>? cartItems,
    double? cartTotal,
    int? productId,
    int? quantity,
    String? rentalStartDate,
    String? rentalEndDate,
  }) async {
    return _sendPaymentRequest(
      paymentType: 'cash',
      orderType: orderType,
      cartTotal: cartTotal,
      cartItems: cartItems,
      productId: productId,
      quantity: quantity,
      rentalStartDate: rentalStartDate,
      rentalEndDate: rentalEndDate,
    );
  }

  /// أونلاين - يدعم sale و rental
  static Future<Map<String, dynamic>> placeOnlineOrder({
    required String orderType, // 'sale' or 'rental'
    List<Map<String, dynamic>>? cartItems,
    double? cartTotal,
    int? productId,
    int? quantity,
    String? rentalStartDate,
    String? rentalEndDate,
  }) async {
    return _sendPaymentRequest(
      paymentType: 'online',
      orderType: orderType,
      cartTotal: cartTotal,
      cartItems: cartItems,
      productId: productId,
      quantity: quantity,
      rentalStartDate: rentalStartDate,
      rentalEndDate: rentalEndDate,
    );
  }
}