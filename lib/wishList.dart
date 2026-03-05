import 'package:flutter/material.dart';
import 'package:medconnect_app/cartScreen.dart';
import 'package:medconnect_app/homeScreen.dart';
import 'package:medconnect_app/mainScreen.dart';




// -----------------------------
// GLOBAL LISTS (نفس اللي في HomeScreen)
// -----------------------------
// -----------------------------
// WISHLIST PAGE
// -----------------------------
class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
    icon: const Icon(Icons.arrow_back_ios_new),
    onPressed: () {  //new modification 
      Navigator.push(
        context,
        MaterialPageRoute(
         builder: (context) => const MainScreen(),
        ),
      );
    },
  ),
        title: const Text(
          "Wishlist",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: wishListGlobal.isEmpty
          ? const Center(
              child: Text(
                "No items in wishlist",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: wishListGlobal.length,
              itemBuilder: (context, index) {
                final item = wishListGlobal[index];
                return buildWishlistCard(item , index);
              },
            ),

      // bottomNavigationBar: NavigationBar(
      //   indicatorColor: Colors.transparent,
      //   selectedIndex: 2,
      //   onDestinationSelected: (index) {
      //     if (index == 0) {
      //       Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(builder: (_) => const HomeScreen()),
      //       );
      //     } else if (index == 1) {
      //       Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(builder: (_) => const CartPage()),
      //       );
      //     }else if (index == 3) {
      //       Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(builder: (_) => const EquipmentListsScreen()),
      //       );

      //     }
      //   },
      //   destinations: const [
      //     NavigationDestination(icon: Icon(Icons.home_outlined), label: "Home"),
      //     NavigationDestination(
      //       icon: Icon(Icons.shopping_cart_outlined),
      //       label: "Cart",
      //     ),
      //     NavigationDestination(
      //       icon: Icon(Icons.favorite_border),
      //       selectedIcon: Icon(Icons.favorite, color: Color(0xFF0A69C3)),
      //       label: "Wishlist",
      //     ),
      //     NavigationDestination(
      //       icon: Icon(Icons.notifications_outlined),
      //       label: "equipment list",
      //     ),
      //   ],
      // ),
    );
  }

  // -----------------------------
  // CARD UI
  // -----------------------------
  Widget buildWishlistCard(Map<String, dynamic> item , int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // PRODUCT IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              item["image"],
              height: 75,
              width: 75,
              fit: BoxFit.contain,
            ),
          ),

           SizedBox(width: 15),

          // TITLE + PRICE + ADD TO CART
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["name"],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

         SizedBox(height: 6),

                Text(
                  "\$${item["price"]}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),

     SizedBox(height: 10),

               SizedBox(
  width: 120,
  height: 36,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    onPressed: () {
      if (item["status"] == "rent") {
        cartItemsGlobal.add(
          CartItem(
            name: item["name"],
            image: item["image"],
            quantity: 1,
            price: item["price"],
            type: 'rent',
            dateRange: '3 Days',
            daily_rent:50,
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${item["name"]} added to cart (Rent)"),
          ),
        );
      } else {
        cartItemsGlobal.add(
          CartItem(
            daily_rent:0,
            name: item["name"],
            image: item["image"],
            quantity: 1,
            price: item["price"],
            type: 'buy',
            dateRange: '',
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${item["name"]} added to cart"),
          ),
        );
      }
    },
    child: Text(
      item["status"] == "rent" ? "Rent" : "Add to Cart",
      style: const TextStyle(
        fontSize: 14,
        color: Colors.white,
    ),
  ),
),
               ),
              ],
            ),
          ),

          // REMOVE BUTTON
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              setState(() {
                wishListGlobal.removeAt(index);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Item removed from wishlist"),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}