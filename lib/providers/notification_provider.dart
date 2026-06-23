import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  Map<int, bool> _notifyStatus = {};

  bool isNotified(int productId) => _notifyStatus[productId] ?? false;

  void setNotified(int productId, bool value) {
    _notifyStatus[productId] = value;
    notifyListeners(); // ✅ تحديث كل الصفحات
  }
  void clear() {
    _notifyStatus.clear();
    notifyListeners(); // ✅ تحديث كل الصفحات
  }
}