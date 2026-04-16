import 'package:flutter/material.dart';
import 'package:medconnect_app/cartScreen.dart';
import 'package:medconnect_app/homeScreen.dart';
import 'package:medconnect_app/mainScreen.dart';
import 'package:medconnect_app/models/product.dart';
import 'package:medconnect_app/providers/wishlist_provider.dart';
import 'package:medconnect_app/services/api_service.dart';
import 'package:provider/provider.dart';




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
  List<Product> _wishlistProducts = [];
  bool _isLoading =true;
  final ApiService _apiService = ApiService();


 @override
  void initState() {
    super.initState();
    _loadWishlistProducts();
  }

  Future<void> _loadWishlistProducts() async {
    setState(() => _isLoading = true);
    
    // ✅ جلب جميع المنتجات من API (أو من HomeScreen cache)
    try {
      final result = await _apiService.fetchProductsWithPagination(page: 1, perPage: 100);
      final allProducts = result['products'] as List<Product>;
      
      final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);
      final wishlistIds = wishlistProvider.wishlistIds;
      
      setState(() {
        _wishlistProducts = allProducts.where((p) => wishlistIds.contains(p.id)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }





  @override
  Widget build(BuildContext context) {
     final wishlistProvider = Provider.of<WishlistProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
    icon: const Icon(Icons.arrow_back_ios_new),
    onPressed: () {  //new modification 
      Navigator.pushReplacement(
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

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _wishlistProducts.isEmpty
              ? const Center(
                  child: Text(
                "No items in wishlist",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _wishlistProducts.length,
              itemBuilder: (context, index) {
                final Product = _wishlistProducts[index];
                return buildWishlistCard(Product, index);
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
  Widget buildWishlistCard(Product product , int index) {
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
            child: Image.network(
              product.imagePath,
              height: 75,
              width: 75,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 75,
                  width: 75,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, size: 40),
                );
              },
            ),
          ),

           SizedBox(width: 15),

          // TITLE + PRICE + ADD TO CART
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

         SizedBox(height: 6),

                Text(
                  "\$${product.price}",
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
      if (product.status == "rent") {
        cartItemsGlobal.add(
          CartItem(
            name: product.name,
            image: product.imagePath,
            quantity: 1,
            price: product.price,
            type: 'rent',
            dateRange: '3 Days',
            daily_rent:0,
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${product.name} added to cart (Rent)"),
          ),
        );
      } else {
        cartItemsGlobal.add(
          CartItem(
            daily_rent:0,
            name: product.name,
            image: product.imagePath,
            quantity: 1,
            price: product.price,
            type: 'buy',
            dateRange: '',
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${product.name} added to cart"),
          ),
        );
      }
    },
    child: Text(
      product.status == "rent" ? "Rent" : "Add to Cart",
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
              final provider = Provider.of<WishlistProvider>(context, listen: false);
              provider.removeFromWishlist(product.id);
              setState(() {
                _wishlistProducts.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Item removed from wishlist")),
                
              );
            },
          ),
        ],
      ),
    );
  }
}