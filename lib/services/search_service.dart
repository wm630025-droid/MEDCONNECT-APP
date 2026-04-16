import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class SearchService {
  static Future<Map<String, dynamic>> searchProducts(String? query, int? categoryId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse(
          "https://medconnect-one-pi.vercel.app/api/api/v1/product/search?search=$query",
        ).replace(queryParameters: {
          if (query != null && query.isNotEmpty)'search': query ,
          if (categoryId != null) 'category_id': categoryId.toString(),
        }),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          
        },
      );

      final decoded = jsonDecode(response.body);

      if (decoded['success'] == true) {
        List data = decoded['data'];

        List<ProductModel> products =
            data.map((e) => ProductModel.fromJson(e)).toList();

        return {
          'success': true,
          'data': products,
        };
      } else {
        return {
          'success': false,
          'message': decoded['message'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
  
}class ProductImage {
  final String image;

  ProductImage({required this.image});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      image: json['image'] ?? "",
    );
  }
}

