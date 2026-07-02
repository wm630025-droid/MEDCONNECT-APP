import 'package:flutter/material.dart';
import 'package:medconnect_app/cartScreen.dart';
import 'package:medconnect_app/checkoutPayment.dart';
import 'package:medconnect_app/models/rental_item.dart';

class CheckoutSummaryPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final double subtotal;
  final double taxes;
  final double total;
  final String selectedAddress;
  final bool isRentalMode;
  final RentalItem? rentalItem;

  const CheckoutSummaryPage({
    super.key,
    required this.selectedAddress,
    required this.cartItems,
    required this.subtotal,
    required this.taxes,
    required this.total,
    this.isRentalMode = false,
    this.rentalItem,
  });

  @override
  State<CheckoutSummaryPage> createState() => _CheckoutSummaryPageState();
}

class _CheckoutSummaryPageState extends State<CheckoutSummaryPage> {
  bool _isLoading = true;
  RentalItem? _updatedRentalItem;

  @override
  @override
void initState() {
  super.initState();
  setState(() => _isLoading = false); // ✅ مش محتاج API call
}

  

  RentalItem? get currentRentalItem => _updatedRentalItem ?? widget.rentalItem;

  DateTime? parseDate(String dateString) {
    try {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        final month = int.parse(parts[0]);
        final day = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  int getRentalDays() {
    if (currentRentalItem == null) return 0;
    final start = parseDate(currentRentalItem!.startDate);
    final end = parseDate(currentRentalItem!.endDate);
    if (start == null || end == null) return 0;
    return end.difference(start).inDays;
  }

 double getDailyRate() {
  if (currentRentalItem == null) return 0;
  return currentRentalItem!.dailyPrice; // ✅ بدل String
}

  double getTotalRentalPrice() {
  if (widget.rentalItem == null) return 0;
  final dailyRate = getDailyRate();
  final days = getRentalDays();
  final quantity = widget.rentalItem!.quantity;
  return dailyRate * days * quantity;
}
  List<CartItem> getDisplayItems() {
    if (widget.isRentalMode && currentRentalItem != null) {
      final dailyRate = getDailyRate();
    final days = getRentalDays();
    final totalRentalPrice = getTotalRentalPrice();

      return [
        CartItem(
          id: currentRentalItem!.productId,
          productId: currentRentalItem!.productId,
          name: currentRentalItem!.name,
          image: currentRentalItem!.image,
          quantity: currentRentalItem!.quantity,
          price: totalRentalPrice,
          type: 'rental',
          dailyPrice: dailyRate,
          rentalDays: days,
          startDate: currentRentalItem!.startDate,
          endDate: currentRentalItem!.endDate,
        )
      ];
    }
    return widget.cartItems;
  }

  double calculateTotalAmount() {
    if (widget.isRentalMode && currentRentalItem != null) {
      return getTotalRentalPrice();
    }
    return widget.cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.w600)),
        leading: const BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepper(),
                    const SizedBox(height: 24),
                    const Text('Delivery Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildDeliveryCard(context),
                    const SizedBox(height: 24),
                    const Text('Order Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildOrderSummary(),
                  ],
                ),
              ),
            ),
            _buildButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return Row(
      children: [
        _step(true, 'Address'),
        const SizedBox(width: 8),
        _step(true, 'Summary'),
        const SizedBox(width: 8),
        _step(false, 'Payment'),
      ],
    );
  }

  Widget _step(bool active, String title) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: active ? const Color(0xFF0D6EFD) : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 6),
          Text(title, style: TextStyle(fontSize: 12, color: active ? const Color(0xFF0D6EFD) : Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            height: 40, width: 40,
            decoration: BoxDecoration(color: const Color(0xFFEAF2FF), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.location_on, color: Color(0xFF0D6EFD)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(widget.selectedAddress.isEmpty ? "No address selected" : widget.selectedAddress,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Change')),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    final displayItems = getDisplayItems();
    double calculatedSubtotal = calculateTotalAmount();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.isRentalMode ? Icons.credit_card : Icons.shopping_cart, size: 20, color: const Color(0xFF0D6EFD)),
              const SizedBox(width: 8),
              Text(widget.isRentalMode ? 'Rental Order Summary' : 'Order Summary',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0D6EFD))),
            ],
          ),
          const SizedBox(height: 16),
          ...displayItems.map((item) {
            return Column(
              children: [
                Row(
                  children: [
                    Container(
                      height: 70, width: 70,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey.shade200),
                      child: item.image.isNotEmpty
                          ? Image.network(item.image, fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(Icons.medical_services, size: 40, color: Colors.grey))
                          : const Icon(Icons.medical_services, size: 40, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('Quantity: ${item.quantity}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          if (item.type == 'rental') ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                              child: Text('Rental • Daily: \$${item.dailyPrice}',
                                  style: const TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.w500)),
                            ),
                            if (item.rentalDays != null && item.rentalDays! > 0) ...[
                              const SizedBox(height: 2),
                              Text('Duration: ${item.rentalDays} days', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                            ],
                            if (item.startDate != null && item.endDate != null) ...[
                              const SizedBox(height: 2),
                              Text('${item.startDate} → ${item.endDate}', style: const TextStyle(color: Colors.grey, fontSize: 9)),
                            ],
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('\$${(item.price * item.quantity).toStringAsFixed(2)}',
                            style: const TextStyle(color: Color(0xFF0D6EFD), fontWeight: FontWeight.bold, fontSize: 16)),
                        if (item.type == 'rental' && item.rentalDays != null) ...[
                          const SizedBox(height: 2),
                          Text('(\$${item.dailyPrice.toStringAsFixed(2)} × ${item.rentalDays} days × ${item.quantity})',
                              style: const TextStyle(color: Colors.grey, fontSize: 9)),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
              ],
            );
          }),
          _priceRow('Subtotal', '\$${calculatedSubtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _priceRow('Total', '\$${calculatedSubtotal.toStringAsFixed(2)}', isTotal: true),
        ],
      ),
    );
  }

  Widget _priceRow(String left, String right, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(left, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 16 : 14))),
          Text(right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTotal ? 18 : 14, color: isTotal ? const Color(0xFF0D6EFD) : Colors.black)),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    final displayItems = getDisplayItems();
    double calculatedSubtotal = calculateTotalAmount();

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D6EFD),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CheckoutPaymentPage(
                cartItems: displayItems,
                subtotal: calculatedSubtotal,
                total: calculatedSubtotal,
                selectedAddress: widget.selectedAddress,
                isRentalMode: widget.isRentalMode,
                rentalItem: currentRentalItem, // ✅ بيبعت الـ updated rental item
              ),
            ),
          );
        },
        child: const Text('Continue To Payment', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE3EAF2)),
    );
  }
}