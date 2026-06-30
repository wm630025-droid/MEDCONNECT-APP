import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:medconnect_app/core/app_colorAccepted.dart';
import 'package:medconnect_app/models/custom_request_model.dart';
//import 'package:medconnect_app/models/custom_request_model.dart';
import 'package:medconnect_app/models/offer_request.dart';
import 'package:medconnect_app/myCustomRequests.dart';
import 'package:medconnect_app/supplierProfile.dart';
//import 'package:medconnect_app/responseScreen.dart';

class AcceptedSupplierDetailsPage extends StatelessWidget {
  final OfferRequest offer;
  final String requestBudget;
  final CustomRequest request;
  const AcceptedSupplierDetailsPage({super.key,required this.offer,required this.requestBudget, required this.request});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
             Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MyCustomRequestsPage(),
              ),
            );
          },
        ),
        title: const Text(
          "Accepted Supplier Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _supplierHeader(isDark,offer),
                const SizedBox(height: 20),
                _supplierNote(isDark,offer),
                const SizedBox(height: 20),
                _budgetSection(isDark,offer,requestBudget),
                const SizedBox(height: 20),
                _statusCard(isDark,request),
              ],
            ),
          ),
          _chatButton(offer.supplierId, offer.supplier.companyName,context),
        ],
      ),
    );
  }
}
Widget _supplierHeader(bool isDark,OfferRequest offer) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: isDark ? Colors.grey.shade800.withOpacity(.5) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark ? AppColors.borderDark : AppColors.borderLight,
      ),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 6),
      ],
    ),
    child: Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 6),
            ],
          ),
          child: CircleAvatar(
            radius: 40,
            backgroundImage: 
              offer.supplier.companyImageUrl != null 
              ? NetworkImage(offer.supplier.companyImageUrl!)
              : null,
                child: offer.supplier.companyImageUrl == null
              ? const Icon(Icons.business, size: 40)
              : null,
            ),
          
        ),
        const SizedBox(height: 12),
        Text(
           offer.supplier.companyName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
         // style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        // const SizedBox(height: 4),
        // Text(
        //   "Your trusted partner in medical technology.",
        //   style: TextStyle(
        //     color: isDark ? Colors.grey[400] : Colors.grey[600],
          
        // ),
        // )
  
      ],
    ),
  );
}
Widget _supplierNote(bool isDark ,OfferRequest offer) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDark ? Colors.grey.shade800.withOpacity(.5) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark ? AppColors.borderDark : AppColors.borderLight,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Note from Supplier",
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withOpacity(.25)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
              offer.notes ?? "No notes provided.",
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ],
    ),
  );
}
Widget _budgetSection(bool isDark, OfferRequest offer, String budget) {
  // TODO: جلب الـ original budget من الـ custom request
 // final originalBudget = "15,000"; // مؤقت
  
  return Row(
    children: [
      Expanded(
        child: _budgetCard(
          title: "Your Budget",
          value: "\$$budget",
          strike: true,
          isDark: isDark,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _budgetCard(
          title: "Accepted Budget",
          value: "\$${offer.price}",
          highlight: true,
          isDark: isDark,
        ),
      ),
    ],
  );
}

Widget _budgetCard({
  required String title,
  required String value,
  bool strike = false,
  bool highlight = false,
  required bool isDark,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDark ? Colors.grey.shade800.withOpacity(.5) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: highlight ? AppColors.primary : AppColors.borderLight,
      ),
      boxShadow: highlight
          ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(.2),
                blurRadius: 8,
              )
            ]
          : null,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: highlight ? AppColors.primary : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: highlight ? 22 : 18,
            fontWeight: FontWeight.bold,
            decoration: strike ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    ),
  );
}
Widget _statusCard(bool isDark,CustomRequest request) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDark ? Colors.grey.shade800.withOpacity(.5) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark ? AppColors.borderDark : AppColors.borderLight,
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Status",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.assignedBg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            request.status,
            style: const TextStyle(
              color: AppColors.assigned,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
Widget _chatButton(int supplierId, String supplierName,context) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: SizedBox(
      width: 300,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SupplierProfileScreen(
                supplierId: supplierId,
                supplierName: supplierName,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 6,
      ),
      icon: const Icon(Icons.chat, size: 20, color: Colors.white),
      label: const Text(
        "Show Supplier profile",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
        color: Colors.white),
      ),
    ),
    ),
  );
}
