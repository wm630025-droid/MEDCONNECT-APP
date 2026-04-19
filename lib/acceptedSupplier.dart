import 'package:flutter/material.dart';
import 'package:medconnect_app/core/app_colorAccepted.dart';
import 'package:medconnect_app/responseScreen.dart';

class AcceptedSupplierDetailsPage extends StatelessWidget {
  const AcceptedSupplierDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => const SupplierBidsPage(),
            //   ),
            // );
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
                _supplierHeader(isDark),
                const SizedBox(height: 20),
                _supplierNote(isDark),
                const SizedBox(height: 20),
                _budgetSection(isDark),
                const SizedBox(height: 20),
                _statusCard(isDark),
              ],
            ),
          ),
          _chatButton(),
        ],
      ),
    );
  }
}
Widget _supplierHeader(bool isDark) {
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
          child: const CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(
              "https://lh3.googleusercontent.com/aida-public/AB6AXuDUC5uQ05csGzmasPLnzACIoEz6d20W7Eev_DYPRJBd1ntOlGSKhNmhXnwvHrwc7VVWd1zblzvMHG4HvvUaS5PhU6DsJsKkOJ8XUjsHJJVlJGAnhHBGB6VbdPtI0Q78b1nAZF1TDQiSeSatyj6yZ-CT50DVAjprGl0tu9VzvmzV0jxtfYOI7pxO6YdqWGIRzubqjzCDxeFTpAfyAUFu1-0PPMbsNN_k0bKkCMXGga3s81c6B_JPzXAS1QtRfBzS19jcINXuaqhgCq8",
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Global Med-Equip Inc.",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          "Your trusted partner in medical technology.",
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    ),
  );
}
Widget _supplierNote(bool isDark) {
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
          child: const Text(
            "“We are pleased to confirm our bid. All requested items are in stock and can be prepared for shipment within 2 business days. We've included a complimentary box of N95 masks with your order. Thank you for choosing us!”",
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ],
    ),
  );
}
Widget _budgetSection(bool isDark) {
  return Row(
    children: [
      Expanded(
        child: _budgetCard(
          title: "Your Budget",
          value: "\$15,000",
          strike: true,
          isDark: isDark,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _budgetCard(
          title: "Accepted Budget",
          value: "\$14,500",
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
Widget _statusCard(bool isDark) {
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
          child: const Text(
            "Assigned",
            style: TextStyle(
              color: AppColors.assigned,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
Widget _chatButton() {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: SizedBox(
      width: 300,
      child: ElevatedButton.icon(
        onPressed: () {},
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
        "Chat with Supplier",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
        color: Colors.white),
      ),
    ),
    ),
  );
}
