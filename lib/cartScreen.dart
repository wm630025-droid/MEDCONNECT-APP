import 'package:flutter/material.dart';
import 'package:medconnect_app/checkoutAddress.dart';
import 'package:medconnect_app/mainScreen.dart';
import 'package:medconnect_app/services/cart_services.dart';
import 'dart:convert';
import 'package:medconnect_app/models/Search_model.dart';
import 'package:dio/dio.dart';
import 'package:medconnect_app/shimmerSkeleton.dart';
import 'package:medconnect_app/homeScreen.dart';


class CartItem {
  final int id; // 🔥 مهم
  final String name;
  final String image;
  int quantity;
  final double price;
  final String type;
  final int productId;
  final double daily_rent;
  String? dateRange;
  DateTime? rStartDate;
  DateTime? rEndDate;
  final int? rentalDays; // ✅ أضف هذا
  final String? startDate; // ✅ أضف هذا
  final String? endDate; // ✅ أضف هذا

  CartItem({
    required this.id,
    required this.name,
    required this.image,
    required this.quantity,
    required this.price,
    required this.type,
    required this.daily_rent,
    this.dateRange,
    required this.productId,
    this.rStartDate,
    this.rentalDays, // ✅ أضف هذا
    this.startDate, // ✅ أضف هذا
    this.endDate,
  });
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Widget _buildCartSkeleton() {
    return ListView.builder(
      itemCount: 4, // عدد العناصر الظاهرة أثناء التحميل
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              ShimmerSkeleton(
                width: 80,
                height: 80,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerSkeleton(
                      width: double.infinity,
                      height: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    ShimmerSkeleton(
                      width: 100,
                      height: 14,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    ShimmerSkeleton(
                      width: 80,
                      height: 14,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
              ShimmerSkeleton(
                width: 40,
                height: 40,
                borderRadius: BorderRadius.circular(20),
              ),
            ],
          ),
        );
      },
    );
  }
 String _extractErrorMessage(dynamic error) {
  if (error is DioException) {
    final response = error.response;
    if (response != null && response.data != null) {
      try {
        final data = response.data as Map<String, dynamic>;
        // 1️⃣ رسالة مباشرة
        if (data.containsKey('message')) {
          return data['message'].toString();
        }
        // 2️⃣ أخطاء تفصيلية (مثل validation errors)
        if (data.containsKey('errors')) {
          final errors = data['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          } else {
            return firstError.toString();
          }
        }
        // 3️⃣ أي بيانات أخرى
        return data.toString();
      } catch (_) {
        return response.data.toString();
      }
    }
    // إذا لم تكن استجابة أو لا تحتوي على بيانات
    return error.message ?? 'Network error occurred';
  }
  // لأي خطأ آخر (مثل http.ClientException)
  return error.toString().replaceAll('Exception:', '');
}

  final CartService cartService = CartService();
  bool isLoading = true;
  bool isUpdating = false; // أضف هذا المتغير

  @override
  void initState() {
    super.initState();
    loadCart();
    print('🛒 Cart items count: ${cartItemsGlobal.length}');
    for (var item in cartItemsGlobal) {
      print('   - ${item.name} | Qty: ${item.quantity} | Price: ${item.price}');
    }
  }

  Future<void> loadCart() async {
  try {
    final data = await cartService.getCartItems();
    print(JsonEncoder.withIndent('  ').convert(data));

    final items = <CartItem>[];

    for (var item in data) {
      try {
        final product = ProductModel.fromJson(item['product']);

        String imageUrl = product.image.isNotEmpty
            ? product.image[0].image
            : "";

        items.add(
          CartItem(
            id: item['id'] ?? 0,
            name: product.name,
            image: imageUrl,
            quantity: item['quantity'] ?? 1,
            price: product.price,
            type: item['type'] ?? 'sale',
            daily_rent: 0,
            productId: product.id ?? 0,
          ),
        );
      } catch (e) {
        print("Error parsing item: $e");
        continue;
      }
    }

    if (!mounted) return;

    setState(() {
      cartItemsGlobal = items;
      isLoading = false;
    });
    final message = cartService.lastMessage;
if (message.isNotEmpty && mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: Colors.green),
  );
}

  } catch (e) {
    print('Load cart error: $e');
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            //new modification
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          },
        ),

        title: const Text(
          'My Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    

      // داخل CartScreen
      body: isLoading
          ? _buildCartSkeleton() // ✅ استبدال الـ CircularProgressIndicator
          : cartItemsGlobal.isEmpty
          ? const Center(
              child: Text("Your cart is empty", style: TextStyle(fontSize: 16)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  for (int i = 0; i < cartItemsGlobal.length; i++) ...[
                    buildCartItem(
                      item: cartItemsGlobal[i],
                      index: cartItemsGlobal.indexOf(cartItemsGlobal[i]),
                    ),
                    const SizedBox(height: 12),
                  ],
                  buildOrderSummary(),
                  const SizedBox(height: 90),
                ],
              ),
            ),
      bottomSheet: cartItemsGlobal.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A69C3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CheckoutAddressPage(cartItems: cartItemsGlobal),
                      ),
                    );
                  },
                  child: const Text(
                    "Continue",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  // ================= CART ITEM =================

  Widget buildCartItem({required CartItem item, required int index}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _productImage(item.image),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 4),
                Column(),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _qtyButton(Icons.add, () async {
  if (isUpdating) return;

  int newQuantity = item.quantity + 1;
  int oldQuantity = item.quantity;

  setState(() => isUpdating = true);

  try {
    final response = await cartService.updateCart(
      cartId: item.id,
      quantity: newQuantity,
    );

    if (!mounted) return;

    if (response['success'] == true) {
      // ✅ بيغير الكمية بس لو الـ API نجح
      setState(() {
        item.quantity = newQuantity;
        isUpdating = false;
      });
    } else {
      // ❌ الـ API رجع success: false
      setState(() => isUpdating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Failed to update'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  } catch (e) {
    if (!mounted) return;
    setState(() {
      item.quantity = oldQuantity;
      isUpdating = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString().replaceAll('Exception:', '').trim()),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('${item.quantity}'),
                      ),

                     _qtyButton(Icons.remove, () async {
  if (isUpdating) return;
  
  if (item.quantity > 1) {
    int newQuantity = item.quantity - 1;
    int oldQuantity = item.quantity;
    
    setState(() => isUpdating = true);
    
    try {
      final response = await cartService.updateCart(
        cartId: item.id,
        quantity: newQuantity,
      );
      
      if (!mounted) return;
      
      setState(() {
        item.quantity = newQuantity;
        isUpdating = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Quantity updated'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      setState(() {
        item.quantity = oldQuantity;
        isUpdating = false;
      });
      
      String errorMessage = _extractErrorMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Minimum quantity is 1"),
        backgroundColor: Colors.orange,
      ),
    );
  }
}),
                    ],
                  ),
                ],
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Delete Item"),
                        content: Text(
                          "Are you sure you want to remove this item?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text("Delete"),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      try {
                        // ✅ محاولة الحذف من الـ API
                        await cartService.deleteCartItem(cartId: item.id);
                        final message = cartService.lastMessage;

                        // ✅ عرض رسالة النجاح من الـ API
                        if (message.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }

                        // ✅ إعادة تحميل الكارت بعد الحذف
                        await loadCart();
                      } catch (e) {
                        // ✅ عرض رسالة الخطأ إذا فشل الحذف
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Failed to delete: ${e.toString()}"),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _productImage(String path) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          path,

          fit: BoxFit.cover,
          errorBuilder: (_, error, __) {
            print("IMAGE ERROR: $error");
            return Icon(Icons.broken_image);
          },
        ),
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap, // خلاص كده - من غير أي شرط
      child: Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
  // ================= ORDER SUMMARY =================

  Widget buildOrderSummary() {
    double subtotal = cartItemsGlobal.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    double total = subtotal; // + أي رسوم إضافية إذا كانت موجودة
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),
          _row("Subtotal", subtotal),
          const Divider(height: 24),
          _row("Total", total, isBold: true),
        ],
      ),
    );
  }

  Widget _row(String title, double value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: isBold ? FontWeight.bold : null),
        ),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: TextStyle(fontWeight: isBold ? FontWeight.bold : null),
        ),
      ],
    );
  }
}

