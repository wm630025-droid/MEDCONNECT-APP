import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Search_model.dart';

class SearchService {
  static Future<Map<String, dynamic>> searchProducts(String? query, int? categoryId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse(
          "https://medconnect-one-pi.vercel.app/api/api/v1/product/search",
        ).replace(queryParameters: {
          if (query != null && query.isNotEmpty)'search': query ,
          if (categoryId != null) 'category_id': categoryId.toString(),
        }),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",          
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
  
}

class CategorySearch {
static Future<List<CategoryApiModel>> getCategories({
  int perPage = 10,
  int page = 1,
  }) async {
    
    final url = Uri.parse(
        "https://medconnect-one-pi.vercel.app/api/api/v1/category/doctor/show?per_page=$perPage&page=$page");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      List categoriesJson = data['data'];
      print('category body: ${response.body}');


      return categoriesJson
          .map((json) => CategoryApiModel.fromJson(json))
          .toList();
    } else {
      throw Exception("Failed to load categories");
    }
  }
}