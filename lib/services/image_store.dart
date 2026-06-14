import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

class ImageStore {
  ImageStore._privateConstructor();
  static final ImageStore _instance = ImageStore._privateConstructor();
  factory ImageStore() => _instance;

  Uint8List? profileImageBytes; // kept in-memory only
  String? profileImageUrl;

  static const String _kProfileImageUrlKey = 'profile_image_url';

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      profileImageUrl = prefs.getString(_kProfileImageUrlKey);
    } catch (_) {
      // ignore errors, leave values null
    }
  }

  Future<void> saveUrl(String? url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (url == null) {
        await prefs.remove(_kProfileImageUrlKey);
        profileImageUrl = null;
      } else {
        await prefs.setString(_kProfileImageUrlKey, url);
        profileImageUrl = url;
      }
    } catch (_) {
      // ignore persistence errors
    }
  }
}
