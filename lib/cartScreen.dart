import 'package:flutter/material.dart';
import 'package:medconnect_app/checkoutAddress.dart';
import 'package:medconnect_app/mainScreen.dart';
import 'package:medconnect_app/services/cart_services.dart';

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
  final int? rentalDays;      // ✅ أضف هذا
  final String? startDate;    // ✅ أضف هذا
  final String? endDate;      // ✅ أضف هذا


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
     this.rentalDays,          // ✅ أضف هذا
    this.startDate,           // ✅ أضف هذا
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
            Skeleton(width: 80, height: 80, borderRadius: BorderRadius.circular(8)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(width: double.infinity, height: 16, borderRadius: BorderRadius.circular(4)),
                  const SizedBox(height: 8),
                  Skeleton(width: 100, height: 14, borderRadius: BorderRadius.circular(4)),
                  const SizedBox(height: 8),
                  Skeleton(width: 80, height: 14, borderRadius: BorderRadius.circular(4)),
                ],
              ),
            ),
            Skeleton(width: 40, height: 40, borderRadius: BorderRadius.circular(20)),
          ],
        ),
      );
    },
  );
}
  final CartService cartService = CartService();
List<CartItem> cartItemsGlobal = [];
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
    final message = cartService.lastMessage;

    final items = <CartItem>[]; // قائمة فارغة
    
    for (var item in data) {
      try {
        final product = item['product'];
        
        // استخراج الصورة بطريقة بسيطة وآمنة
        String imageUrl = "";
        try {
          var imageField = product['image'];
          if (imageField != null) {
            // لو كانت Map
            if (imageField is Map) {
              var innerImage = imageField['image'];
              if (innerImage is List && innerImage.isNotEmpty) {
                var firstImage = innerImage[0];
                if (firstImage is Map) {
                  imageUrl = firstImage['image']?.toString() ?? "";
                }
              }
            }
            // لو كانت List
            else if (imageField is List && imageField.isNotEmpty) {
              var firstImage = imageField[0];
              if (firstImage is Map) {
                imageUrl = firstImage['image']?.toString() ?? "";
              }
            }
            else if (imageField is String) {
              imageUrl = imageField;
            }
          }
        } catch (e) {
          print("Image error: $e");
          imageUrl = "";
        }
        
        // إضافة المنتج للقائمة
        items.add(CartItem(
          id: item['id'] ?? 0,
          name: product['name'] ?? 'Unknown',
          image: imageUrl,
          quantity: item['quantity'] ?? 1,
          price: double.tryParse(product['price']?.toString() ?? '0') ?? 0.0,
          type: item['type'] ?? 'sale',
          daily_rent: 0,
          productId: product['id'] ?? 0,
        ));
        
      } catch (e) {
        print("Error parsing item: $e");
        continue; // تخطي العنصر الخاطئ ومتابعة الباقي
      }
    }

    if (!mounted) return;

    setState(() {
      cartItemsGlobal = items;
      isLoading = false;
    });

    if (message.isNotEmpty) {
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
      backgroundColor: const Color(0xFFF4F4F4),

     // داخل CartScreen
body: isLoading
    ? _buildCartSkeleton()   // ✅ استبدال الـ CircularProgressIndicator
    : cartItemsGlobal.isEmpty
        ? const Center(child: Text("Your cart is empty", style: TextStyle(fontSize: 16)))
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
  "Pay to buy",
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
                  Column(

                  ),
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
  if (isUpdating) return; // لمنع الضغط المتكرر
  
  int newQuantity = item.quantity + 1;
  int oldQuantity = item.quantity;
  
  setState(() {
    isUpdating = true;
  });
  
  try {
    final response = await cartService.updateCart(
      cartId: item.id,
      quantity: newQuantity,
    );
    
    setState(() {
      item.quantity = newQuantity;
      isUpdating = false;
    });
    
    print('✅ API Response: ${response['message']}');
     ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Quantity updated successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
  } catch (e) {
    setState(() {
      item.quantity = oldQuantity;
      isUpdating = false;
    });
    print('❌ Update failed: $e');
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
    
    setState(() {
      isUpdating = true;
    });
    
    setState(() {
      item.quantity = newQuantity;
    });
    
    try {
      final response = await cartService.updateCart(
        cartId: item.id,
        quantity: newQuantity,
      );
      
      setState(() {
        isUpdating = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Quantity updated successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
      
    } catch (e) {
      setState(() {
        item.quantity = oldQuantity;
        isUpdating = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update quantity"),
          backgroundColor: Colors.red,
        ),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
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
        SnackBar(content: Text(message), backgroundColor: Colors.green),
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
)
      ),
    );
  }

Widget _qtyButton(IconData icon, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,  // خلاص كده - من غير أي شرط
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

class Skeleton extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const Skeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: borderRadius,
      ),
    );
  }
}