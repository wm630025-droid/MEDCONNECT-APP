import 'package:flutter/material.dart';
import 'package:medconnect_app/core/app_colorResponse.dart';
import 'package:medconnect_app/models/supplierBid.dart';
import 'package:medconnect_app/myCustomRequests.dart';
import 'package:medconnect_app/acceptedSupplier.dart';


class SupplierBidsPage extends StatelessWidget {
  const SupplierBidsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.bgDark
          : AppColors.bgLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>  MyCustomRequestsPage(),
              ),
            );
          },
        ),
        title: const Text(
          "Responses for X-Ray Machine Request",
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SupplierBidCard(
            bid: SupplierBid(
              name: "MedEquip Solutions",
              image:
                  "https://lh3.googleusercontent.com/aida-public/AB6AXuDY0A03UFPI3HPKF2XWTUUVv8fTQL3_C8hjmtRRL2sVFU9bbKMGx-Vnu-za2X9KkQB7mUP6XjxtRFDfMrcqp8ZtgLNzHKTgn2g7zxx1l_p7s9mlq8g688wirH5TTAWfcseOu3Hs_JJjg-bE3xLbW9FVhRfzjC_6-oHY6LfI8ueJpxNvlJ3ZIX9tYp-xsiuaT1PdN6MyUMtBW9lP1UJcY1wt-dFa71z9wRp6vh-Ou_qZ-BDcw0XMXHtLovSPub16wqx6eRkx6k_sw5E",
              note:
                  "We have the RX-200 model in stock, which perfectly matches your requirements. It's brand new and comes with a 3-year warranty. We can arrange for delivery within 5 business days.",
              supplierPrice: "\$14,500",
            ),
            initiallyExpanded: true,
          ),
          SupplierBidCard(
            bid: SupplierBid(
              name: "Healthcare Logistics",
              image:
                  "https://lh3.googleusercontent.com/aida-public/AB6AXuAAhorPliCO_uyCi8mKpuWfKrxWsfUmICzlW-95EC42rjN1HpxAGwWrdxVWxTPsQXlrcV9wyXaQDBvDP2svmkuLMHy_FP-eHZXKEnAUsaVd_AqbcI3vgLVFAMOzxpWVWt14IrQdP4Vpx3pn5ZpXXbGDi9iwtftHzThWqQXTi7Vy7ex7p8sHu4SL5RTwrlrtjVeXSaBPT_zjZffRxFAx6Jy59DGZkM7TdY_vwDWi_tmJ0lZCPys-Hsse7OtU0OdDNjQNk4cBBjJKHxY",
              supplierPrice: "\$15,000",
            ),
          ),
          SupplierBidCard(
            bid: SupplierBid(
              name: "Surgical Supplies Inc.",
              image:
                  "https://lh3.googleusercontent.com/aida-public/AB6AXuARzxRsTqfQlNJyAcUniyLLJV_agzpDoUByBlbf8D92neDvU3od6BT-Ik-4zSBGcJ32Ae08iOFDc4s3PDZwXOGfbvlkpVVcMM_a0dVMyhzODl39GCO4m7EBjEpS1nHQdlfv9OV-rj3v2St9rlFfvtQBfurG7yM6GV0tFY7GXXLfBmPcn4_XL8U0DzAZNiBbzHP9prNJDcwk6NwbYjp4kFEUne_eFssbNbMceoP2FQqh29L6DV5Wsz7DnXy34Cs_a-vmEmyV3jrd7mQ",
              note:
                  "We can offer a certified refurbished model for a significant discount. It includes a 1-year warranty and has been fully tested by our technicians.",
              supplierPrice: "\$12,800",
              cancelled: true,
            ),
          ),
        ],
      ),
    );
  }
}
class SupplierBidCard extends StatelessWidget {
  final SupplierBid bid;
  final bool initiallyExpanded;

  const SupplierBidCard({
    super.key,
    required this.bid,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: const EdgeInsets.all(16),
        childrenPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(bid.image),
              radius: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                bid.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        children: [
          if (bid.note != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Note from Supplier",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(bid.note!),
                ],
              ),
            ),
          const SizedBox(height: 12),
          _budgetRow("Your Budget:", "\$15,000", strike: true),
          const SizedBox(height: 6),
          _budgetRow(
            "Supplier's Bid Budget:",
            bid.supplierPrice,
            highlight: true,
          ),
          const SizedBox(height: 16),
          bid.cancelled ? _cancelledButtons() : _activeButtons(context),
        ],
      ),
    );
  }

  Widget _budgetRow(String label, String value,
      {bool strike = false, bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: TextStyle(
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            fontSize: highlight ? 18 : 14,
            color: highlight ? AppColors.primary : null,
            decoration: strike ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }

  Widget _activeButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(onPressed: () {}, child: const Text("Cancel")),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            child: const Text("Chat"),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AcceptedSupplierDetailsPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
           
            child: const Text("Accept",
            style: TextStyle(color: Colors.white),),
          ),
        ),
      ],
    );
  }

  Widget _cancelledButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.cancelled,
            ),
            child: const Text("Cancel Offer"),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cancelled,
            ),
            child: const Text("Offer Cancelled"),
          ),
        ),
      ],
    );
  }
}
