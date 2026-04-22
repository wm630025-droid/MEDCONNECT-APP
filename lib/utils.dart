import 'package:flutter/material.dart';
import 'package:medconnect_app/equipmentListScreen.dart';
import 'homeScreen.dart';
void openEquipmentLists() async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const EquipmentListsScreen(),
    ),
  );

  if (result != null && result is String) {
    _searchController.text = result; // يحط الاسم في السيرش
    _searchProduct(result);          // يشغل البحث تلقائي
  }
}