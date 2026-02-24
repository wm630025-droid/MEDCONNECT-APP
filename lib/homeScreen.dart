import 'package:flutter/material.dart';
import 'package:medconnect_app/cartScreen.dart';
import 'package:medconnect_app/wishList.dart';
import 'package:medconnect_app/productDetails.dart';
import 'package:medconnect_app/models/product.dart';
import 'package:medconnect_app/doctorProfile.dart';
import 'package:medconnect_app/introScreen.dart';
 
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
List<Map<String, dynamic >> wishListGlobal = [];

// ---------------------
// HomeScreen
// ---------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> displayedProducts = List.from(allProducts);

  // البحث
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

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CartPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WishlistPage()),
      );
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      

     appBar: AppBar(
  backgroundColor: Colors.white,
  elevation: 0,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back_ios_new),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const IntroScreen(),
        ),
      );
    },
  ),
  title: SizedBox(
    height: 40,
    child: Image.asset("assets/images/logoPNG.png", fit: BoxFit.contain),
  ),
  actions: [
    IconButton(
      icon: const Icon(
        Icons.person_outline,
        color: Colors.black,
      ),
      onPressed: () {
        Navigator.push(context,
          MaterialPageRoute(builder: (_) => const doctorProfilePage()),
        );

        // افتح صفحة البروفايل
        // Navigator.push(...)
      },
    ),
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

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF0A69C3),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: "Wishlist",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Alerts",
          ),
        ],
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
      buildCategories(),   // 👈 هنا
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
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Image.asset(
              imagepath,
              width: 40,
              height: 40,
            ),
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
      _categoryItem(
        imagepath: "assets/images/fly.png",
        label: "Imaging",
      ),
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
                    builder: (_) => ProductDetailsPage(product: p ),
                  ),
                );
              },
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
                vertical: 2,
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
                vertical: 2,
              ),
              child: Text(
                p.brand,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 2,
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
          right: 10,
          top: 10,
          child: GestureDetector(
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
              size: 28,
            ),
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
      flex : 3,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: () {
          cartItemsGlobal.add(
            CartItem(
              name: p.name,
              image: p.imagePath,
              quantity: 1,
              price: p.price,
              type: 'buy',
              dateRange: '',
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${p.name} added to cart (Buy)"),
            ),
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
            flex : 2,

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
              price: p.price,
              type: 'rent',
              dateRange: '3 Days Rent',
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${p.name} added to cart (Rent)"),
            ),
          );
        },
        child: const Text(
          "rent",
          style: TextStyle(color: Colors.white),
        ),
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




