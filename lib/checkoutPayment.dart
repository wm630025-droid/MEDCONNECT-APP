import 'package:flutter/material.dart';
import 'package:medconnect_app/cartScreen.dart';
import 'package:medconnect_app/models/rental_item.dart';
import 'package:medconnect_app/services/payment_services.dart';
import 'package:medconnect_app/doctorAccount.dart';
import 'package:medconnect_app/wep_app.dart';


class CheckoutPaymentPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final double subtotal;
  final double total;
  final String selectedAddress;
  final bool isRentalMode;
  final RentalItem? rentalItem;

  const CheckoutPaymentPage({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.total,
    required this.selectedAddress,
    this.isRentalMode = false,
    this.rentalItem,
  });

  @override
  State<CheckoutPaymentPage> createState() => _CheckoutPaymentPageState();
}

class _CheckoutPaymentPageState extends State<CheckoutPaymentPage> {
  String selectedPayment = "cod";
  bool isLoading = false;

  // تحويل صيغة التاريخ من mm/dd/yyyy إلى DateTime
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
      print('Error parsing date: $e');
      return null;
    }
  }

  // حساب عدد أيام الإيجار من التواريخ
  int getRentalDays() {
    if (widget.rentalItem == null) return 0;
    if (widget.rentalItem!.startDate.isEmpty || widget.rentalItem!.endDate.isEmpty) {
      return 0;
    }
    
    try {
      final start = parseDate(widget.rentalItem!.startDate);
      final end = parseDate(widget.rentalItem!.endDate);
      
      if (start == null || end == null) return 0;
      
      return end.difference(start).inDays + 1;
    } catch (e) {
      print('❌ Error calculating rental days: $e');
      return 0;
    }
  }

  // حساب السعر اليومي
  double getDailyRate() {
    if (widget.rentalItem == null) return 0;
    return widget.rentalItem!.price / 30;
  }

  // حساب إجمالي سعر الإيجار
  double getTotalRentalPrice() {
    if (widget.rentalItem == null) return 0;
    
    // إذا كان الـ cartItems يحتوي على السعر المحسوب بالفعل
    if (widget.cartItems.isNotEmpty && widget.cartItems.first.type == 'rent') {
      return widget.cartItems.first.price * widget.cartItems.first.quantity;
    }
    
    // حساب جديد
    final dailyRate = getDailyRate();
    final days = getRentalDays();
    final quantity = widget.rentalItem!.quantity;
    return dailyRate * days * quantity;
  }

  // دالة لجلب العناصر حسب الوضع
  List<CartItem> getDisplayItems() {
    if (widget.isRentalMode && widget.rentalItem != null) {
      final dailyRate = getDailyRate();
      final days = getRentalDays();
      final totalRentalPrice = getTotalRentalPrice();
      
      return [
        CartItem(
          id: widget.rentalItem!.productId,
          productId: widget.rentalItem!.productId,
          name: widget.rentalItem!.name,
          image: widget.rentalItem!.image,
          quantity: widget.rentalItem!.quantity,
          price: totalRentalPrice,
          type: 'rent',
          daily_rent: dailyRate,
          rentalDays: days,
          startDate: widget.rentalItem!.startDate,
          endDate: widget.rentalItem!.endDate,
        )
      ];
    } else {
      return widget.cartItems;
    }
  }

  // دالة لحساب المجموع
  double calculateTotalAmount() {
    if (widget.isRentalMode && widget.rentalItem != null) {
      return getTotalRentalPrice();
    } else {
      double sum = 0;
      for (var item in widget.cartItems) {
        sum += item.price * item.quantity;
      }
      return sum;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  children: [
                    _buildStepper(),
                    const SizedBox(height: 24),
                    _buildPaymentOptions(),
                    const SizedBox(height: 24),
                    _buildOrderSummary(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildPlaceOrderButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return Row(
      children: [
        _step(true, 'Address'),
        _step(true, 'Summary'),
        _step(true, 'Payment'),
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

  Widget _buildPaymentOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Options',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            setState(() {
              selectedPayment = "cod";
            });
          },
          child: _paymentTile(
            title: 'Pay On Delivery',
            subtitle: 'Pay With Cash Or Card Upon Arrival',
            selected: selectedPayment == "cod",
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            setState(() {
              selectedPayment = "online";
            });
          },
          child: _paymentTile(
            title: 'Online Payment',
            subtitle: 'Credit/Debit Card, Net Banking',
            selected: selectedPayment == "online",
          ),
        ),
      ],
    );
  }

  Widget _paymentTile({
    required String title,
    required String subtitle,
    required bool selected,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? const Color(0xFF0D6EFD) : Colors.grey.shade300,
          width: 1.5,
        ),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: const Color(0xFF0D6EFD),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    final items = getDisplayItems();
    double subtotal = calculateTotalAmount();
    double total = subtotal;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.isRentalMode ? Icons.credit_card : Icons.shopping_cart,
                size: 20,
                color: const Color(0xFF0D6EFD),
              ),
              const SizedBox(width: 8),
              Text(
                widget.isRentalMode ? 'Rental Order Summary' : 'Order Summary',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D6EFD),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('No items to display'),
              ),
            )
          else
            ...items.map((item) {
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
                              '(\$${item.daily_rent.toStringAsFixed(2) } × ${item.rentalDays} days × ${item.quantity})',
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
                ],
              );
            }),

          const Divider(height: 32),
          _priceRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
         
          const SizedBox(height: 8),
          _priceRow('Total', '\$${total.toStringAsFixed(2)}', isTotal: true),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.selectedAddress,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
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

  Widget _buildPlaceOrderButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D6EFD),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: isLoading ? null : () => _handlePlaceOrder(),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Place Order',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _handlePlaceOrder() async {
    final items = getDisplayItems();
    
    if (items.isEmpty) {
      _showErrorDialog('No items to order');
      return;
    }

    setState(() => isLoading = true);

    try {
      if (widget.isRentalMode && widget.rentalItem != null) {
        String orderType = 'rental';
        String? rentalStartDate = widget.rentalItem!.startDate;
        String? rentalEndDate = widget.rentalItem!.endDate;
        
        final response = selectedPayment == 'cod'
            ? await PaymentService.placeCashOrder(
                orderType: orderType,
                cartItems: items.map((item) => {
                  'product_id': item.productId,
                  'quantity': item.quantity,
                  'price': item.price,
                  'type': item.type,
                  'daily_rent': item.daily_rent,
                  'rental_days': item.rentalDays,
                  'start_date': item.startDate,
                  'end_date': item.endDate,
                }).toList(),
                cartTotal: items.fold(0.0, (sum, item) => sum + (item.price * item.quantity)),
                rentalStartDate: rentalStartDate,
                rentalEndDate: rentalEndDate,
              )
            : await PaymentService.placeOnlineOrder(
                orderType: orderType,
                cartItems: items.map((item) => {
                  'product_id': item.productId.toString(),
                  'quantity': item.quantity,
                  'price': item.price,
                  'type': item.type,
                  'daily_rent': item.daily_rent,
                  'rental_days': item.rentalDays,
                  'start_date': item.startDate,
                  'end_date': item.endDate,
                }).toList(),
                cartTotal: items.fold(0.0, (sum, item) => sum + (item.price * item.quantity)),
                rentalStartDate: rentalStartDate,
                rentalEndDate: rentalEndDate,
              );

        if (!mounted) return;

        if (response['success'] == true) {
          final link = response['redirectTo'];
          final invoice = response['invoice'].toString();
          final message = response['status'] ?? 'Order placed successfully';

          if (selectedPayment == 'online' && link != null && link.isNotEmpty) {
            await _launchURL(link);
           
          } else {
            _showSuccessDialog(
              message: message,
              invoice: invoice,
              paymentLink: selectedPayment == 'online' ? link : null,
            );
          }
        } else {
          _showErrorDialog(
            response['status'] ?? response['error'] ?? 'Failed to place order',
          );
        }
      } else {
        for (var item in items) {
          final response = selectedPayment == 'cod'
              ? await PaymentService.placeCashOrder(
                  orderType: 'sale',
                  cartItems: [
                    {
                      'product_id': item.productId.toString(),
                      'quantity': item.quantity,
                      'price': item.price,
                      'type': item.type,
                      'daily_rent': item.daily_rent,
                      'rental_days': item.rentalDays,
                      'start_date': item.startDate,
                      'end_date': item.endDate,
                    }
                  ],
                  cartTotal: item.price * item.quantity,
                  rentalStartDate: null,
                  rentalEndDate: null,
                )
              : await PaymentService.placeOnlineOrder(
                  orderType: 'sale',
                  cartItems: [
                    {
                      'product_id': item.productId,
                      'quantity': item.quantity,
                      'price': item.price,
                      'type': item.type,
                      'daily_rent': item.daily_rent,
                      'rental_days': item.rentalDays,
                      'start_date': item.startDate,
                      'end_date': item.endDate,
                    }
                  ],
                  cartTotal: item.price * item.quantity,
                  rentalStartDate: null,
                  rentalEndDate: null,
                );

          if (!mounted) return;

          if (response['success'] == true) {
            final link = response['redirectTo'];
            final invoice = response['invoice'].toString();
            final message = response['status'] ?? 'Order placed successfully';

            if (selectedPayment == 'online' && link != null && link.isNotEmpty) {
              await _launchURL(link);
            
            } else {
              _showSuccessDialog(
                message: message,
                invoice: invoice,
                paymentLink: selectedPayment == 'online' ? link : null,
              );
            }
          } else {
            _showErrorDialog(
              response['status'] ?? response['error'] ?? 'Failed to place order',
            );
            return;
          }
        }
      }
    } catch (e) {
      print('❌ Exception: $e');
      if (mounted) {
        _showErrorDialog('An unexpected error occurred: $e');
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _launchURL(String url) async {
  print('Opening WebView with URL: $url');
  if (url.isEmpty) {
    _showErrorDialog('Invalid payment link');
    return;
  }
 Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => InAppWebViewScreen(
        url: url,
        onSuccess: () {
          // ✅ روح لصفحة الـ Orders وامسح كل الصفحات السابقة
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => AllOrdersScreen()), // غير لاسم صفحة الـ orders عندك
            (route) => false,
          );
        },
      ),
    ),
  );
}

  void _showSuccessDialog({
    required String message,
    String? invoice,
    String? paymentLink,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Order Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (invoice != null) ...[
              const SizedBox(height: 12),
              Text(
                'Invoice: $invoice',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D6EFD),
                ),
              ),
            ],
            if (paymentLink != null && paymentLink.isNotEmpty) ...[
              const SizedBox(height: 12),
              SelectableText(
                paymentLink,
                style: const TextStyle(fontSize: 12, color: Color(0xFF0D6EFD)),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _launchURL(paymentLink);
                },
                child: const Text('Open Payment Page'),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) =>  AllOrdersScreen()),
                (route) => false,
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
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

