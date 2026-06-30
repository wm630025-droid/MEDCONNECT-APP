import 'package:flutter/material.dart';
import 'package:medconnect_app/cartScreen.dart';
import 'package:medconnect_app/checkoutPayment.dart';
import 'package:medconnect_app/models/rental_item.dart';

// ========== صفحة الـ Summary ==========
class CheckoutSummaryPage extends StatelessWidget {
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

  // تحويل صيغة التاريخ من mm/dd/yyyy إلى DateTime
  DateTime? parseDate(String dateString) {
    try {
      // الصيغة المستخدمة في ProductDetailsPage: "MM/DD/YYYY"
      final parts = dateString.split('/');
      if (parts.length == 3) {
        final month = int.parse(parts[0]);
        final day = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
      return null;
    } catch (e) {
      print('Error parsing date: $e');
      return null;
    }
  }

  // حساب عدد أيام الإيجار من التواريخ
  int getRentalDays() {
    if (rentalItem == null) return 0;
    if (rentalItem!.startDate.isEmpty || rentalItem!.endDate.isEmpty) {
      print('⚠️ Start date or end date is empty');
      return 0;
    }
    
    try {
      print('📅 Start date from rentalItem: ${rentalItem!.startDate}');
      print('📅 End date from rentalItem: ${rentalItem!.endDate}');
      
      final start = parseDate(rentalItem!.startDate);
      final end = parseDate(rentalItem!.endDate);
      
      if (start == null || end == null) {
        print('❌ Failed to parse dates');
        return 0;
      }
      
      final days = end.difference(start).inDays + 1;
      print('✅ Rental days calculated: $days');
      return days;
    } catch (e) {
      print('❌ Error calculating rental days: $e');
      return 0;
    }
  }

  // حساب السعر اليومي (من سعر المنتج / 30)
  double getDailyRate() {
    if (rentalItem == null) return 0;
    // السعر اليومي = سعر المنتج الكامل / 30
    final dailyRate = rentalItem!.price / 30;
    print('💰 Daily rate: $dailyRate (product price: ${rentalItem!.price})');
    return dailyRate;
  }

  // حساب إجمالي سعر الإيجار (السعر اليومي × عدد الأيام × الكمية)
  double getTotalRentalPrice() {
    if (rentalItem == null) return 0;
    final dailyRate = getDailyRate();
    final days = getRentalDays();
    final quantity = rentalItem!.quantity;
    final total = dailyRate * days * quantity;
    print('💰 Total rental price: $dailyRate × $days days × $quantity = $total');
    return total;
  }

  // دالة لجلب العناصر حسب الوضع
  List<CartItem> getDisplayItems() {
    if (isRentalMode && rentalItem != null) {
      final dailyRate = getDailyRate();
      final days = getRentalDays();
      final totalRentalPrice = getTotalRentalPrice();
      
      print('📊 Display Items - Daily Rate: $dailyRate, Days: $days, Total: $totalRentalPrice');
      
      return [
        CartItem(
          id: rentalItem!.productId,
          productId: rentalItem!.productId,
          name: rentalItem!.name,
          image: rentalItem!.image,
          quantity: rentalItem!.quantity,
          price: totalRentalPrice,
          type: 'rent',
          daily_rent: dailyRate,
          rentalDays: days,
          startDate: rentalItem!.startDate,
          endDate: rentalItem!.endDate,
        )
      ];
    } else {
      return cartItems;
    }
  }

  // دالة لحساب المجموع حسب الوضع
  double calculateTotalAmount() {
    if (isRentalMode && rentalItem != null) {
      return getTotalRentalPrice();
    } else {
      double sum = 0;
      for (var item in cartItems) {
        sum += item.price * item.quantity;
      }
      return sum;
    }
  }

  @override
  Widget build(BuildContext context) {
    // طباعة بيانات الـ rentalItem للتأكد
    if (isRentalMode && rentalItem != null) {
      print('🔍 RentalItem Data:');
      print('   - productId: ${rentalItem!.productId}');
      print('   - name: ${rentalItem!.name}');
      print('   - price: ${rentalItem!.price}');
      print('   - quantity: ${rentalItem!.quantity}');
      print('   - startDate: ${rentalItem!.startDate}');
      print('   - endDate: ${rentalItem!.endDate}');
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
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
                    const Text(
                      'Delivery Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDeliveryCard(context),
                    const SizedBox(height: 24),
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: active ? const Color(0xFF0D6EFD) : Colors.grey,
            ),
          ),
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
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.location_on, color: Color(0xFF0D6EFD)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Delivery Address',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  selectedAddress.isEmpty ? "No address selected" : selectedAddress,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    final displayItems = getDisplayItems();
    double calculatedSubtotal = calculateTotalAmount();
    double calculatedTotal = calculatedSubtotal;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isRentalMode ? Icons.credit_card : Icons.shopping_cart,
                size: 20,
                color: const Color(0xFF0D6EFD),
              ),
              const SizedBox(width: 8),
              Text(
                isRentalMode ? 'Rental Order Summary' : 'Order Summary',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D6EFD),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (displayItems.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('No items to display'),
              ),
            )
          else
            ...displayItems.map((item) {
              return Column(
                children: [
                  Row(
                    children: [
                      Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade200,
                        ),
                        child: item.image.isNotEmpty
                            ? Image.network(
                                item.image,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.medical_services,
                                      size: 40, color: Colors.grey);
                                },
                              )
                            : const Icon(Icons.medical_services,
                                size: 40, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Quantity: ${item.quantity}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            if (item.type == 'rent') ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Rental • Daily: \$${item.daily_rent.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (item.rentalDays != null && item.rentalDays! > 0) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Duration: ${item.rentalDays} days',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                              if (item.startDate != null && item.endDate != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  '${item.startDate} → ${item.endDate}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFF0D6EFD),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (item.type == 'rent' && item.rentalDays != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              '(\$${item.daily_rent.toStringAsFixed(2)} × ${item.rentalDays} days × ${item.quantity})',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 9,
                              ),
                            ),
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
          
          const SizedBox(height: 8),
          _priceRow('Subtotal', '\$${calculatedSubtotal.toStringAsFixed(2)}'),
         
          const SizedBox(height: 8),
          _priceRow('Total', '\$${calculatedTotal.toStringAsFixed(2)}', isTotal: true),
        ],
      ),
    );
  }

  Widget _priceRow(String left, String right, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              left,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 16 : 14,
              ),
            ),
          ),
          Text(
            right,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? 18 : 14,
              color: isTotal ? const Color(0xFF0D6EFD) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    final displayItems = getDisplayItems();
    double calculatedSubtotal = calculateTotalAmount();
    double calculatedTotal = calculatedSubtotal + 50 + 25;

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
                total: calculatedTotal,
                selectedAddress: selectedAddress,
                isRentalMode: isRentalMode,
                rentalItem: rentalItem,
              ),
            ),
          );
        },
        
        child: const Text(
          'Continue To Payment',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
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