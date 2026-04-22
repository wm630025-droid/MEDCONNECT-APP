import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';

class CategoryService {
  static Future<List<CategoryModel>> getCategories({
  int perPage = 10,
  int page = 1,
  }) async {
    
    final url = Uri.parse(
        "https://medconnect-one-pi.vercel.app/api/api/v1/category/doctor/show?per_page=$perPage&page=$page");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      List categoriesJson = data['data'];

      return categoriesJson
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } else {
      throw Exception("Failed to load categories");
    }
  }
}