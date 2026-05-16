import 'package:flutter/material.dart';
import 'package:medconnect_app/cartScreen.dart';
import 'package:medconnect_app/homeScreen.dart';
import 'package:medconnect_app/models/rental_item.dart';
import 'package:medconnect_app/services/payment_services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:medconnect_app/doctorAccount.dart';

class CheckoutPaymentPage extends StatefulWidget {
  final bool isRentalMode;
  final RentalItem? rentalItem;

  const CheckoutPaymentPage({
    super.key,
    this.isRentalMode = false,
    this.rentalItem,
import 'package:medconnect_app/services/payment_services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:medconnect_app/doctorAccount.dart';
import 'package:medconnect_app/cartScreen.dart'; // أضف هذا للاستيراد

class CheckoutPaymentPage extends StatefulWidget {
  final List<CartItem> cartItems; // ✅ أضف هذا
  final double subtotal; // ✅ أضف هذا
  final double total; // ✅ أضف هذا
  final Map<String, String> selectedAddress; // ✅ أضف هذا

  const CheckoutPaymentPage({
    super.key,
    required this.cartItems, // ✅ required
    required this.subtotal, // ✅ required
    required this.total, // ✅ required
    required this.selectedAddress, // ✅ required
  });

  @override
  State<CheckoutPaymentPage> createState() => _CheckoutPaymentPageState();
}

class _CheckoutPaymentPageState extends State<CheckoutPaymentPage> {
  String selectedPayment =
      "cod"; // cod = Cash on Delivery, online = Online Payment

  bool isLoading = false;

  // بيانات الحجز (Rental)
  String? selectedProductId;
  String? rentalStartDate;
  String? rentalEndDate;
  String orderType = "sale";
  // sale أو rental
List<CartItem> get orderItems {
  if (widget.isRentalMode && widget.rentalItem != null) {
    return [
      CartItem(
        id: widget.rentalItem!.productId,
        productId: widget.rentalItem!.productId,
        name: widget.rentalItem!.name,
        image: widget.rentalItem!.image,
        quantity: widget.rentalItem!.quantity,
        price: widget.rentalItem!.price,
        type: 'rent',
        daily_rent: widget.rentalItem!.price / 30,
      ),
    ];
  }
  return cartItemsGlobal; // ✅ الكارت العادي
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
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
                    _buildOrderSummary(), // ✅ الآن تستخدم widget.cartItems
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildPlaceOrderButton(),
          ],
        ),
      ),
    );
  }




  // ================= Stepper =================
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
  // ================= Payment Options =================

  // ================= Payment Options =================
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

  // ================= Order Summary =================
  Widget _buildOrderSummary() {

      final items = orderItems;

    
    double subtotal = items.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    double insurance = 50;
    double delivery = 25;

    double total = subtotal + insurance + delivery;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ====== عرض المنتجات ديناميكياً ======
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
                      child: Image.network(item.image, fit: BoxFit.contain),
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
                            'Qty: ${item.quantity}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF0D6EFD),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            );
          }),

          const Divider(height: 32),

          _priceRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
          _priceRow('Insurance', '\$${insurance.toStringAsFixed(2)}'),
          _priceRow('Delivery', '\$${delivery.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _priceRow('Total', '\$${total.toStringAsFixed(2)}', isTotal: true),
          
          // ✅ عرض عنوان التوصيل
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.selectedAddress['address'] ?? 'No address',
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

  // ================= Button =================
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

  /// ✅ دالة التعامل مع طلب الدفع
  Future<void> _handlePlaceOrder() async {
    // ✅ التحقق من وجود منتجات
    if (cartItemsGlobal.isEmpty && !widget.isRentalMode) {
      _showErrorDialog('Your cart is empty');
      return;
    }

    setState(() => isLoading = true);

    try {
      //#################################################################################
      // ############## new editing here #######################
      String orderType = 'sale';
      String? rentalStartDate;
      String? rentalEndDate;
      int? productId;
      int quantity = 1;
      if (widget.isRentalMode && widget.rentalItem != null) {
        orderType = 'rental';
        rentalStartDate = widget.rentalItem!.startDate;
        rentalEndDate = widget.rentalItem!.endDate;
        productId = widget.rentalItem!.productId;
        quantity = widget.rentalItem!.quantity;
      }

    // ✅ لو كان إيجار، نتعامل مع منتج واحد فقط
    if (widget.isRentalMode && widget.rentalItem != null) {
      final response = selectedPayment == 'cod'
          ? await PaymentService.placeCashOrder(
              orderType: orderType,
              productId: productId.toString(),
              quantity: quantity,
              rentalStartDate: rentalStartDate,
              rentalEndDate: rentalEndDate,
            )
          : await PaymentService.placeOnlineOrder(
              orderType: orderType,
              productId: productId.toString(),
              quantity: quantity,
              rentalStartDate: rentalStartDate,
              rentalEndDate: rentalEndDate,
            );

      if (!mounted) return;

      if (response['success'] == true) {
        // ✅ نجاح الطلب
        final link = response['redirectTo'];
        final invoice = response['invoice'];
        final message = response['status'] ?? 'Order placed successfully';

        if (selectedPayment == 'online' && link != null && link.isNotEmpty) {
          await _launchURL(link);
          _showSuccessDialog(
            message: message,
            invoice: invoice,
            paymentLink: link,
          );
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
//###########################################################################################
      }else{
      // ✅ معالجة كل منتج في السلة
      for (var item in orderItems) {
        final response = selectedPayment == 'cod'
            ? await PaymentService.placeCashOrder(
                orderType: orderType,
                productId: item.productId.toString(),
                quantity: item.quantity,
                rentalStartDate: orderType == 'rental' ? rentalStartDate : null,
                rentalEndDate: orderType == 'rental' ? rentalEndDate : null,
              )
            : await PaymentService.placeOnlineOrder(
                orderType: orderType,
                productId: item.productId.toString(),
                quantity: item.quantity,
                rentalStartDate: orderType == 'rental' ? rentalStartDate : null,
                rentalEndDate: orderType == 'rental' ? rentalEndDate : null,
              );

        if (!mounted) return;

        if (response['success'] == true) {
          // ✅ نجح الطلب
          final link =
              response['redirectTo']; // 🔗 الحصول على الرابط من الاستجابة
          final invoice = response['invoice'];
          final message = response['status'] ?? 'Order placed successfully';

          if (selectedPayment == 'online' && link != null && link.isNotEmpty) {
            print('🔗 Opening payment link: $link');
            await _launchURL(link);
            _showSuccessDialog(
              message: message,
              invoice: invoice,
              paymentLink: link,
            );
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
    }catch (e) {
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

  /// 🔗 دالة فتح الرابط
  Future<void> _launchURL(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        // بعد ما ينهي الدفع ويرجع، ندير عملية نظيفة
        print('✅ Payment link opened');
      } else {
        print('❌ Could not launch URL: $url');
        _showErrorDialog('Could not open payment page. Please try again.');
      }
    } catch (e) {
      print('❌ Error launching URL: $e');
      _showErrorDialog('Error opening payment page: $e');
    }
  }

  /// ✅ عرض نافذة النجاح
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
                MaterialPageRoute(builder: (_) => doctorAccountPage()),
                (route) => false,
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// ❌ عرض نافذة الخطأ
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