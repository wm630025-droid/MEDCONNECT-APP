import 'package:flutter/material.dart';
import 'package:medconnect_app/core/app_colorResponse.dart';
import 'package:medconnect_app/models/offer_request.dart';
import 'package:medconnect_app/models/supplierBid.dart';
import 'package:medconnect_app/myCustomRequests.dart';
import 'package:medconnect_app/acceptedSupplier.dart';
import 'package:medconnect_app/services/api_service.dart';

class SupplierBidsPage extends StatefulWidget {
  final int customRequestId;
  const SupplierBidsPage({super.key, required this.customRequestId});

  @override
  State<SupplierBidsPage> createState() => _SupplierBidsPageState();
}

class _SupplierBidsPageState extends State<SupplierBidsPage> {
  List<OfferRequest> _offers = [];
  bool _isLoading = true;
  String? _error;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final offers = await _apiService.getOfferRequests(widget.customRequestId);
      setState(() {
        _offers = offers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

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
              MaterialPageRoute(builder: (context) => MyCustomRequestsPage()),
            );
          },
        ),
        title: const Text("Supplier Bids", overflow: TextOverflow.ellipsis),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadOffers,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _offers.isEmpty
          ? const Center(child: Text('No offers yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _offers.length,
              itemBuilder: (context, index) {
                return SupplierBidCard(
                  offer: _offers[index],
                  initiallyExpanded: index == 0,
                );
              },
            ),
    );
  }
}

class SupplierBidCard extends StatelessWidget {
  final OfferRequest offer;
  final bool initiallyExpanded;

  const SupplierBidCard({
    super.key,
    required this.offer,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = offer.status.toLowerCase() == 'pending';
    final isCancelled = offer.status.toLowerCase() == 'cancelled';
    final isAccepted = offer.status.toLowerCase() == 'accepted';
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
              backgroundImage: offer.supplier.companyImageUrl != null
                  ? NetworkImage(offer.supplier.companyImageUrl!)
                  : null,
              child: offer.supplier.companyImageUrl == null
                  ? const Icon(Icons.business)
                  : null,
              radius: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                offer.supplier.companyName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        children: [
          if (offer.notes != null)
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
                  Text(offer.notes!),
                ],
              ),
            ),
          const SizedBox(height: 12),
          _budgetRow("Delivery Days:", "${offer.deliveryDays} days"),
          const SizedBox(height: 6),
          _budgetRow(
            "Supplier's Bid :",
            "\$${offer.price}",
            highlight: true,
          ),
          const SizedBox(height: 16),
          if (isPending) _pendingButtons(context),
          if (isAccepted) _acceptedButtons(),
          if (isCancelled) _cancelledButtons(),
        ],
      ),
    );
  }

  // Widget _budgetRow(
  //   String label,
  //   String value, {
  //   bool strike = false,
  //   bool highlight = false,
  // }) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Text(label),
  //       Text(
  //         value,
  //         style: TextStyle(
  //           fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
  //           fontSize: highlight ? 18 : 14,
  //           color: highlight ? AppColors.primary : null,
  //           decoration: strike ? TextDecoration.lineThrough : null,
  //         ),
  //       ),
  //     ],
  //   );
  // }
  Widget _budgetRow(String label, String value, {bool highlight = false}) {
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
          ),
        ),
      ],
    );
  }
Widget _pendingButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              // TODO: رفض العرض
            },
            child: const Text("Decline"),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              // TODO: فتح شات مع المورد
            },
            child: const Text("Chat"),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(onPressed: () {
              // TODO: قبول العرض
              _showAcceptDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text(
              "Accept",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _showAcceptDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Accept Offer'),
        content: const Text('Are you sure you want to accept this offer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: استدعاء API قبول العرض
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Offer accepted!')),
              );
            },
            child: const Text('Accept', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  Widget _acceptedButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text("Accepted", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _cancelledButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
            ),
            child: const Text("Offer Cancelled", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
  // Widget _activeButtons(BuildContext context) {
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: OutlinedButton(onPressed: () {}, child: const Text("Cancel")),
  //       ),
  //       const SizedBox(width: 8),
  //       Expanded(
  //         child: OutlinedButton(onPressed: () {}, child: const Text("Chat")),
  //       ),
  //       const SizedBox(width: 8),
  //       Expanded(
  //         child: ElevatedButton(
  //           onPressed: () {
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (context) => const AcceptedSupplierDetailsPage(),
  //               ),
  //             );
  //           },
  //           style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),

  //           child: const Text("Accept", style: TextStyle(color: Colors.white)),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _cancelledButtons() {
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: OutlinedButton(
  //           onPressed: () {},
  //           style: OutlinedButton.styleFrom(
  //             foregroundColor: AppColors.cancelled,
  //           ),
  //           child: const Text("Cancel Offer"),
  //         ),
  //       ),
  //       const SizedBox(width: 8),
  //       Expanded(
  //         child: ElevatedButton(
  //           onPressed: null,
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: AppColors.cancelled,
  //           ),
  //           child: const Text("Offer Cancelled"),
  //         ),
  //       ),
  //     ],
  //   );
  // }

