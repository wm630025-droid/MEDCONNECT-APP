import 'package:flutter/material.dart';
import 'package:medconnect_app/cartScreen.dart';
import 'package:medconnect_app/introScreen.dart';
import 'package:medconnect_app/productDetails.dart';
import 'package:medconnect_app/models/product.dart';
import 'package:medconnect_app/doctorAccount.dart';
import 'package:medconnect_app/services/api_service.dart';
import 'package:medconnect_app/signInScreen.dart';
import 'package:medconnect_app/models/product_model.dart';
import 'package:medconnect_app/services/search_service.dart';
import 'package:medconnect_app/services/categoriesServices.dart';
import 'package:medconnect_app/models/category_model.dart';


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
List<ProductModel> searchResults = [];
bool isSearching = false;
// ---------------------
// GLOBAL LISTS
// ---------------------
List<CartItem> cartItemsGlobal = [];
List<Map<String, dynamic>> wishListGlobal = [];
List<Map<String, dynamic>> equipmentListGlobal = [];
    List<String> images = [];


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
int? selectedCategoryId;
 List<Product> displayedProducts = List.from(allProducts);
String selectedFilter = "sort"; 
String name = '';
double price = 0.0;
List<String> images = [];
bool is_rentable = false;
List<CategoryModel> categories = [];
bool isLoadingCategories = false;
bool showCategories = false;
  // البحث

  //  void dispose() {
  //     _searchController.dispose();
  //     super.dispose();
  //   }

 Future<void> searchProduct(String query) async {
  final result = await SearchService.searchProducts(query, selectedCategoryId);

  if (result['success']) {
    setState(() {
      searchResults = result['data'] ?? [];
      isSearching = query.isNotEmpty || selectedCategoryId != null;
    });
  } else {
    setState(() {
      isSearching = true;
    });
  }
}
  Future<void> fetchCategories() async {
  setState(() {
    isLoadingCategories = true;
  });

  try {
    final result = await CategoryService.getCategories();

    setState(() {
      categories = result;
    });
  } catch (e) {
    print("Error: $e");
  }

  setState(() {
    isLoadingCategories = false;
  });
}
@override
void initState() {
  super.initState();
  fetchCategories();
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
                MaterialPageRoute(builder: (_) =>  doctorAccountPage()),
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
                    MaterialPageRoute(builder: (_) => const IntroScreen()),
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
            const SizedBox(height: 10),

Row(
  children: [
    _filterButton(text: "Sort: Relevance", value: "sort"),
    const SizedBox(width: 10),
    _filterButton(text: "Category", value: "category"),
    const SizedBox(width: 10),
    _filterButton(text: "Price", value: "price"),
    const SizedBox(height: 10),
if (showCategories) _buildCategoryList(),
if (showCategories) _buildCategoriesSection(),
  ],
),
const SizedBox(height: 10),

if (showCategories)
  SizedBox(
    height: 100,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedCategoryId = cat.id;
              showCategories = false;
               showCategories = !showCategories;
            });

            searchProduct(_searchController.text);
          },
          child: Container(
            width: 100,
            margin: const EdgeInsets.only(right: 10),
            child: Column(
              children: [
                Text(cat.name),
              ],
            ),
          ),
        );
      },
    ),
  ),

const SizedBox(height: 10),
           isSearching
    ? _searchResults()
    : _buildHomeSections(),
          ],
        ),
      ),
    );
  }
  
 Widget _filterButton({
  required String text,
  required String value,
}) {
  bool isSelected = selectedFilter == value;

  return GestureDetector(
   onTap: () {
  if (value == "category") {
    setState(() {
      showCategories = !showCategories;
    });
  } else {
    setState(() {
      selectedFilter = value;
      showCategories = false; // يقفلها لو ضغط حاجة تانية
    });
  }
},
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade100 : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
     children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.blue : Colors.black,
            ),
          ),
          const SizedBox(width: 5),
          Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: isSelected ? Colors.blue : Colors.black,
          ),
        ],
    ),
    ),
  );
} 
Widget _buildCategoryList() {
  if (isLoadingCategories) {
    return const Center(child: CircularProgressIndicator());
  }

  if (categories.isEmpty) {
    return const Text("No Categories Found");
  }

  return Container(
    margin: const EdgeInsets.only(top: 10),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Filter By Category",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];

           Row(
  children: [
    Checkbox(
      value: selectedCategoryId == cat.id,
      onChanged: (value) {
        setState(() {
          selectedCategoryId =
              (selectedCategoryId == cat.id) ? null : cat.id;
        });

        searchProduct(_searchController.text);
      },
    ),
    Text(cat.name),
  ],
);
          },
        ),
      ],
    ),
  );
}

  Widget _productCardApi(ProductModel m) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       Image.network(
  m.images.isNotEmpty
    ? (m.images[0].image )
    : "https://via.placeholder.com/150",
  height: MediaQuery.of(context).size.height * 0.17,
  width: double.infinity,
  fit: BoxFit.cover,
),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            m.name ?? "Unknown Product",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text("${m.price} EGP"),
        ),
        if (m.is_rentable ?? false)
  Container(
    padding: EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Colors.green,
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      "Rentable",
      style: TextStyle(color: Colors.white),
    ),
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
        onChanged: searchProduct,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "Search For Equipment",
          icon: Icon(Icons.search),
        ),
      ),
    );
  }
  Widget _buildCategoriesSection() {
  if (isLoadingCategories) {
    return const Center(child: CircularProgressIndicator());
  }

  if (categories.isEmpty) {
    return const Text("No Categories Found");
  }

  return SizedBox(
    height: 100,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final isSelected = selectedCategoryId == cat.id;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedCategoryId = cat.id;
              showCategories = false; // يخفيها بعد الاختيار
            });

            searchProduct(_searchController.text);
          },
          child: Container(
            width: 100,
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.shade100 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.shade300,
              ),
            ),
            child: Column(
              children: [
                
                const SizedBox(height: 5),
                Text(
                  cat.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.blue : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
  
  if (searchResults.isEmpty) {
    return const Padding(
      padding: EdgeInsets.all(20),
    );
  }

  return GridView.builder(
    itemCount: searchResults.length,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 0.60,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
    ),
    itemBuilder: (context, index) {
      return _productCardApi(searchResults[index]);
    },
  );
}
}

