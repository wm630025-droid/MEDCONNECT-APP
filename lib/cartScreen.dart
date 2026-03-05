import 'package:flutter/material.dart';
import 'package:medconnect_app/homeScreen.dart';
import 'package:medconnect_app/checkoutAddress.dart';
import 'package:medconnect_app/mainScreen.dart';

class CartItem {
  final String name;
  final String image;
  int quantity;
  final double price;

  String? dateRange;
  final double daily_rent;
  DateTime? rStartDate;
  DateTime? rEndDate;

  String type;
  CartItem({
    required this.name,
    required this.image,
    required this.quantity,
    required this.price,
    required this.dateRange,
    required this.type,
    required this.daily_rent,
  });
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int selectedCartTab = 0; // 0 = Purchase | 1 = Rental

  //int _selectedIndex = 1;

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //     if (index == 0) {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (_) => const HomeScreen()),
  //       );
  //     } else if (index == 2) {
  //       Navigator.pushReplacementNamed(context, '/wishlist');
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final filteredItems = cartItemsGlobal.where((item) {
      if (selectedCartTab == 0) {
        return item.type.toLowerCase() == 'buy';
      } else {
        return item.type.toLowerCase() == 'rent';
      }
    }).toList();

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

      body: cartItemsGlobal.isEmpty
          ? const Center(
              child: Text("Your cart is empty", style: TextStyle(fontSize: 16)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCartToggle(),
                  const SizedBox(height: 16),

                  for (int i = 0; i < filteredItems.length; i++) ...[
                    buildCartItem(
                      item: filteredItems[i],
                      index: cartItemsGlobal.indexOf(filteredItems[i]),
                    ),
                    const SizedBox(height: 12),
                  ],
                  buildOrderSummary(),
                  const SizedBox(height: 90),
                ],
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CheckoutAddressPage(cartItems: cartItemsGlobal)),
              );
            },
            child: const Text(
              'Continue To Address',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    );
  }

  Widget _buildCartToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [_toggleItem("Purchase", 0), _toggleItem("Rental", 1)],
      ),
    );
  }

  Widget _toggleItem(String title, int index) {
    final bool isSelected = selectedCartTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => selectedCartTab = index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color.fromARGB(255, 255, 255, 255)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= CART ITEM =================
  DateTime? rentStartDate;
  DateTime? rentEndDate;

  Widget buildCartItem({required CartItem item, required int index}) {
    final isRent = item.type == 'rent';
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

                if (!isRent)
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                const SizedBox(height: 4),

                if (isRent)
                  Text(
                    "\$${item.daily_rent.toString()} / day",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),

                const SizedBox(height: 4),
                if (isRent)
                  Column(
                    children: [
                      _dateBox("Start Date", true),

                      const SizedBox(height: 10),
                      _dateBox("End Date", false),
                    ],
                  ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isRent
                        ? Colors.blue.shade100
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isRent ? "rental" : "Purchase",
                    style: TextStyle(
                      fontSize: 12,
                      color: isRent
                          ? Colors.blue.shade700
                          : Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isRent) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _qtyButton(Icons.add, () {
                        setState(() => item.quantity++);
                      }),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('${item.quantity}'),
                      ),

                      _qtyButton(Icons.remove, () {
                        if (item.quantity > 1) {
                          setState(() => item.quantity--);
                        }
                      }),
                    ],
                  ),
                ],
                if (!isRent)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _qtyButton(Icons.add, () {
                        setState(() => item.quantity++);
                      }),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('${item.quantity}'),
                      ),
                      _qtyButton(Icons.remove, () {
                        if (item.quantity > 1) {
                          setState(() => item.quantity--);
                        }
                      }),
                    ],
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    setState(() {
                      cartItemsGlobal.removeAt(index);
                    });
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
        child: Image.asset(path, fit: BoxFit.contain),
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
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
    double subtotal = cartItemsGlobal
        .where((item) {
          if (selectedCartTab == 0) {
            return item.type.toLowerCase() == 'buy';
          } else {
            return item.type.toLowerCase() == 'rent';
          }
        })
        .fold(0, (sum, item) => sum + (item.price * item.quantity));

    double taxes = subtotal * 0.05;
    double total = subtotal + taxes;

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
          _row("Estimated Taxes & Fees", taxes),
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

  Widget _dateBox(String title, bool isStart) => GestureDetector(
    onTap: () async {
      final picked = await showDatePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime(2030),
        initialDate: DateTime.now(),
      );
      if (picked != null) {
        setState(() {
          if (isStart) {
            rentStartDate = picked;
          } else {
            rentEndDate = picked;
          }
        });
      }
    },
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month, size: 15),
          const SizedBox(width: 8),
          Text(
            isStart
                ? (rentStartDate == null
                      ? title
                      : rentStartDate!.toString().split(" ")[0])
                : (rentEndDate == null
                      ? title
                      : rentEndDate!.toString().split(" ")[0]),
          ),
        ],
      ),
    ),
  );
}
