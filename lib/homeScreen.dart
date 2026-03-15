import 'package:flutter/material.dart';
import 'package:medconnect_app/cartScreen.dart';
import 'package:medconnect_app/introScreen.dart';
import 'package:medconnect_app/productDetails.dart';
import 'package:medconnect_app/models/product.dart';
import 'package:medconnect_app/doctorProfile.dart';
import 'package:medconnect_app/services/api_service.dart';
import 'package:medconnect_app/signInScreen.dart';

// ---------------------
// نموذج المنتج
// ---------------------

// ---------------------
// قائمة المنتجات
// ---------------------
final List<Product> allProducts = [
  Product(
    name: "Digital Stethoscope",
    brand: "CardioPro",
    price: 499.99,
    imagePath: "assets/images/Stetho_Scope.png",
    status: "add to cart",
    images: [
      "assets/images/imageSteth1.png",
      "assets/images/imageSteth2.png",
      "assets/images/imageSteth3.png",
    ],
  ),

  Product(
    name: "X-ray machine",
    brand: "XRayTech",
    price: 1200.0,
    imagePath: "assets/images/X-ray_machine.png",
    status: "rent",
    images: [
      "assets/images/imageXray1.png",
      "assets/images/imageXray2.png",
      "assets/images/imageXray3.png",
    ],
  ),

  Product(
    name: "UltraSound system",
    brand: "UltraSoundPro",
    price: 800.0,
    imagePath: "assets/images/UltraSound_system.png",
    status: "add to cart",
    images: [
      "assets/images/imageUltra1.png",
      "assets/images/imageUltra2.png",
      "assets/images/imageUltra3.png",
    ],
  ),

  Product(
    name: "Ventilator",
    brand: "VentPro",
    price: 2500.0,
    imagePath: "assets/images/ventilator.png",
    status: "add to cart",
    images: [
      "assets/images/imageVent1.png",
      "assets/images/imageVent2.png",
      "assets/images/imageVent3.png",
    ],
  ),

  Product(
    name: "Defibrillator",
    brand: "DefibTech",
    price: 1500.0,
    imagePath: "assets/images/Defibrillator.png",
    status: "add to cart",
    images: [
      "assets/images/imageDef1.png",
      "assets/images/imageDef2.png",
      "assets/images/imageDef3.png",
    ],
  ),

  Product(
    name: "MRI Machine",
    brand: "CardioWatch",
    price: 999.99,
    imagePath: "assets/images/MRI_Machine.png",
    status: "Notify me",
    images: [
      "assets/images/imageMRI1.png",
      "assets/images/imageMRI2.png",
      "assets/images/imageMRI3.png",
    ],
  ),

  Product(
    name: "Cardiac Monitor",
    brand: "MediScan",
    price: 750.0,
    imagePath: "assets/images/surgical_light_system.png",
    status: "add to cart",
    images: [
      "assets/images/imageSurg1.png",
      "assets/images/imageSurg2.png",
      "assets/images/imageSurg3.png",
    ],
  ),
];

// ---------------------
// GLOBAL LISTS
// ---------------------
List<CartItem> cartItemsGlobal = [];
List<Map<String, dynamic>> wishListGlobal = [];
List<Map<String, dynamic>> equipmentListGlobal = [];

// ---------------------
// HomeScreen
// ---------------------

// دالة البحث مستقلة
class HomeScreen extends StatefulWidget {
  // ⭐️ الخاصية الجديدة

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> displayedProducts = List.from(allProducts);

  // البحث

  //  void dispose() {
  //     _searchController.dispose();
  //     super.dispose();
  //   }

  void _searchProduct(String query) {
    setState(() {
      if (query.isEmpty) {
        displayedProducts = List.from(allProducts);
      } else {
        displayedProducts = allProducts
            .where(
              (p) =>
                  p.name.toLowerCase().contains(query.toLowerCase()) ||
                  p.brand.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  //int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: SizedBox(
          height: 30,
          child: Image.asset("assets/images/logoPNG.png", fit: BoxFit.contain),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const doctorProfilePage()),
              );

              // افتح صفحة البروفايل
              // Navigator.push(...)
            },
          ),
          /////////////////////////////////new editing for api////////////////////////
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              // 1️⃣ رسالة تأكيد
              bool? confirmLogout = await showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Log out'),
                  content: Text('Are you sure you want to log out ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text('Log out'),
                    ),
                  ],
                ),
              );

              if (confirmLogout == true) {
                // 2️⃣ استدعاء logout من ApiService
                final result = await ApiService().logout();

                if (result['success']) {
                  // 3️⃣ التوجيه لشاشة Intro
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                    (route) => false,
                  );

                  // 4️⃣ رسالة نجاح
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message'] ?? 'Logged Out'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  // 5️⃣ لو فشل
                  print("xxxxxxxxxxxxxxxxxxxxxxx");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['error'] ?? 'Something went wrong'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
          ///////////////////////////////////////////////////////////////////////
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 20),
            _searchController.text.isEmpty
                ? _buildHomeSections()
                : _searchResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _searchProduct,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "Search For Equipment",
          icon: Icon(Icons.search),
        ),
      ),
    );
  }

  // ---------------------
  // أقسام الصفحة الرئيسية
  // ---------------------
  Widget _buildHomeSections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBanner(),
        const SizedBox(height: 20),
        _sectionTitle("Categories"),
        const SizedBox(height: 10),
        buildCategories(), // 👈 هنا
        const SizedBox(height: 20),

        _sectionTitle("Featured Products"),
        const SizedBox(height: 10),
        _featuredGrid(),
      ],
    );
  }

  Widget _buildBanner() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: const DecorationImage(
            image: AssetImage("assets/images/Ventilator_banner.png"),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }

  Widget _categoryItem({required String imagepath, required String label}) {
    return Column(
      children: [
        SizedBox.square(
          child: Container(
            decoration: BoxDecoration(color: Colors.white),
            child: Image.asset(imagepath, width: 40, height: 40),
          ),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }

  Widget buildCategories() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _categoryItem(
          imagepath: "assets/images/surgical.png",
          label: "Surgical",
        ),
        _categoryItem(imagepath: "assets/images/fly.png", label: "Imaging"),
        _categoryItem(
          imagepath: "assets/images/laboratory.png",
          label: "Laboratory",
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  // ---------------------
  // Grid Products
  // ---------------------
  Widget _featuredGrid() {
    return GridView.builder(
      itemCount: allProducts.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.60,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        return _productCard(allProducts[index]);
      },
    );
  }

  // ---------------------
  // PRODUCT CARD
  // ---------------------
  Widget _productCard(Product p) {
    bool isInWishlist = wishListGlobal.any((i) => i["name"] == p.name);
    bool isInequipmentList = equipmentListGlobal.any(
      (i) => i["name"] == p.name,
    );
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsPage(product: p),
                    ),
                  );
                },
                //#####################################################
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    p.imagePath,
                    height: MediaQuery.of(context).size.height * 0.17,
                    width: double.infinity,
                    fit: BoxFit.fill,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4,
                ),
                child: Text(
                  p.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4,
                ),
                child: Text(
                  p.brand,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4,
                ),
                child: Text(
                  "\$${p.price}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4,
                ),

                child: _buildActionButton(p),
              ),
            ],
          ),

          Positioned(
            right: 8,
            top: 8,
            child: Row(
              children: [
                // ❤️ Wishlist
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isInWishlist) {
                        wishListGlobal.removeWhere((i) => i["name"] == p.name);
                      } else {
                        wishListGlobal.add({
                          "name": p.name,
                          "price": p.price,
                          "image": p.imagePath,
                        });
                      }
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isInWishlist
                              ? "${p.name} removed from wishlist"
                              : "${p.name} added to wishlist",
                        ),
                      ),
                    );
                  },
                  child: Icon(
                    isInWishlist ? Icons.favorite : Icons.favorite_border,
                    color: isInWishlist ? Colors.red : Colors.black,
                    size: 26,
                  ),
                ),

                const SizedBox(width: 8),

                // 📋 Equipment List
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isInequipmentList) {
                        equipmentListGlobal.removeWhere(
                          (i) => i["name"] == p.name,
                        );
                      } else {
                        equipmentListGlobal.add({
                          "name": p.name,
                          "price": p.price,
                          "image": p.imagePath,
                        });
                      }

                      // toggle اللون
                      isInequipmentList = !isInequipmentList;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isInequipmentList
                              ? "${p.name} added to equipment list"
                              : "${p.name} removed from equipment list",
                        ),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.notifications, // أو playlist_add
                    color: isInequipmentList ? Colors.blue : Colors.black,
                    size: 26,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------
  // BUTTONS: Add / Rent / Notify Me
  // ---------------------
  Widget _buildActionButton(Product p) {
    // ⭐ Notify Me فقط
    if (p.status == "Notify me") {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("We will notify you when available"),
              ),
            );
          },
          child: const Text(
            "Notify Me",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    // ⭐ Rent + Add To Cart مع بعض
    return Row(
      children: [
        // ---------- Add To Cart ----------
        Expanded(
          flex: 3,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              cartItemsGlobal.add(
                CartItem(
                  daily_rent: 0,
                  name: p.name,
                  image: p.imagePath,
                  quantity: 1,
                  price: p.price,
                  type: 'buy',
                  dateRange: '',
                ),
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${p.name} added to cart (Buy)")),
              );
            },
            child: const Text(
              "Add To Cart",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // ---------- Rent ----------
        Expanded(
          flex: 2,

          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              cartItemsGlobal.add(
                CartItem(
                  name: p.name,
                  image: p.imagePath,
                  quantity: 1,
                  price: 0,
                  type: 'rent',
                  dateRange: '',
                  daily_rent: 50,
                ),
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${p.name} added to cart (Rent)")),
              );
            },
            child: const Text("rent", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  // ---------------------
  // Search Results
  // ---------------------
  Widget _searchResults() {
    if (displayedProducts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text("No products found."),
      );
    }

    return GridView.builder(
      itemCount: displayedProducts.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.60,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        return _productCard(displayedProducts[index]);
      },
    );
  }
}
