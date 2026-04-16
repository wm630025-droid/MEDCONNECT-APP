import 'package:flutter/material.dart';
import '../models/product.dart';

class WishlistProvider extends ChangeNotifier {
  // ✅ قائمة المنتجات في المفضلة (باستخدام productId)
  final Set<int> _wishlistIds = {};

  Set<int> get wishlistIds => _wishlistIds;
  bool get isEmpty => _wishlistIds.isEmpty;
  int get count => _wishlistIds.length;

  // ✅ التحقق إذا كان المنتج في المفضلة
  bool isInWishlist(int productId) {
    return _wishlistIds.contains(productId);
  }

  // ✅ إضافة منتج للمفضلة
  void addToWishlist(int productId) {
    if (!_wishlistIds.contains(productId)) {
      _wishlistIds.add(productId);
      notifyListeners();
    }
  }

  // ✅ إزالة منتج من المفضلة
  void removeFromWishlist(int productId) {
    if (_wishlistIds.contains(productId)) {
      _wishlistIds.remove(productId);
      notifyListeners();
    }
  }

  // ✅ تبديل حالة المفضلة (إضافة/إزالة)
  void toggleWishlist(int productId) {
    if (_wishlistIds.contains(productId)) {
      _wishlistIds.remove(productId);
    } else {
      _wishlistIds.add(productId);
    }
    notifyListeners();
  }

  // ✅ مسح كل المفضلة
  void clearWishlist() {
    _wishlistIds.clear();
    notifyListeners();
  }

  // ✅ جلب قائمة المنتجات (للـ UI)
  List<Product> getWishlistProducts(List<Product> allProducts) {
    return allProducts.where((p) => _wishlistIds.contains(p.id)).toList();
  }
}