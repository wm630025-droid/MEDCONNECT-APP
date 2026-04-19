import 'package:flutter/material.dart';
import 'package:medconnect_app/cartScreen.dart';
import 'package:medconnect_app/introScreen.dart';
import 'package:medconnect_app/models/category.dart';
import 'package:medconnect_app/productDetails.dart';
import 'package:medconnect_app/models/product.dart';
import 'package:medconnect_app/doctorProfile.dart';
import 'package:medconnect_app/services/api_service.dart';
import 'package:medconnect_app/signInScreen.dart';
import 'package:provider/provider.dart';
import 'package:medconnect_app/providers/wishlist_provider.dart';

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
  List<Product> displayedProducts = [];
  List<Product> _allProducts = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  //########################

  // Categories variables
  List<Category> _categories = [];
  bool _isLoadingCategories = true;
  String? _categoriesError;

  // Products variables
  bool _isLoadingProducts = true;
  String? _productsError;

  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _loadCategories();

    _loadProducts();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _hasMore &&
          !_isLoadingMore) {
        _loadProducts(loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts({bool loadMore = false}) async {
    if (ApiService.token == null) {
      setState(() {
        _productsError = 'Please login first';
        _isLoadingProducts = false;
      });
      return;
    }

    if (!loadMore) {
      setState(() {
        _isLoadingProducts = true;
        _productsError = null;
        _currentPage = 1;
        _allProducts = [];
      });
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final result = await _apiService.fetchProductsWithPagination(
        page: _currentPage,
        perPage: 10,
      );

      setState(() {
        if (loadMore) {
          _allProducts.addAll(result['products']);
        } else {
          _allProducts = result['products'];
        }
        displayedProducts = List.from(_allProducts);
        _totalPages = result['lastPage'];
        _hasMore = _currentPage < _totalPages;
        _currentPage++;
        _isLoadingProducts = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _productsError = e.toString();
        _isLoadingProducts = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadCategories() async {
    // ✅ التأكد من وجود توكن
    if (ApiService.token == null) {
      setState(() {
        _categoriesError = 'Please login first to view categories';
        _isLoadingCategories = false;
      });
      return;
    }

    setState(() {
      _isLoadingCategories = true;
      _categoriesError = null;
    });

    try {
      final categories = await _apiService.fetchCategories(
        page: 1,
        perPage: 10,
      );

      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _categoriesError = e.toString();
        _isLoadingCategories = false;
      });
    }
  }

  //######################

  // البحث

  //  void dispose() {
  //     _searchController.dispose();
  //     super.dispose();
  //   }

  void _searchProduct(String query) {
    setState(() {
      if (query.isEmpty) {
        displayedProducts = List.from(_allProducts);
      } else {
        displayedProducts = _allProducts
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

  Widget _categoryItem({required Category category}) {
    return GestureDetector(
      onTap: () {
        // التنقل لشاشة تفاصيل القسم
        print('Category tapped: ${category.name}');
      },
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: Image.network(
                category.image,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.category,
                    size: 30,
                    color: Colors.grey,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildCategories() {
    if (_isLoadingCategories) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_categoriesError != null) {
      return Center(
        child: Column(
          children: [
            Text(
              _categoriesError!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadCategories,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_categories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No categories found.'),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((category) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _categoryItem(category: category),
          );
        }).toList(),
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
    if (_isLoadingProducts && _allProducts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_productsError != null && _allProducts.isEmpty) {
      return Center(
        child: Column(
          children: [
            Text('Error: $_productsError'),
            SizedBox(height: 10,),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blueAccent,
              ),
              onPressed: () => _loadProducts(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_allProducts.isEmpty) {
      return const Center(child: Text('No products found.'));
    }

    return Column(
      children: [
        GridView.builder(
          controller: _scrollController,
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
        ),
        if (_isLoadingMore)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  // ---------------------
  // PRODUCT CARD
  // ---------------------
  Widget _productCard(Product p) {
    final wishlistProvider = Provider.of<WishlistProvider>(
      context,
      listen: true,
    );
    final isInWishlist = wishlistProvider.isInWishlist(p.id);

    // bool isInWishlist = wishListGlobal.any((i) => i["name"] == p.name);
    bool isInequipmentList = equipmentListGlobal.any(
      (i) => i["name"] == p.name,
    );

    String supplierName = '';
    if (p.supplierData != null && p.supplierData!['company_name'] != null) {
      supplierName = p.supplierData!['company_name'];
    }

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
                      builder: (_) =>
                          ProductDetailsPage(productId: p.id, product: p),
                    ),
                  );
                },
                //#####################################################
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    p.imagePath,
                    height: MediaQuery.of(context).size.height * 0.17,
                    width: double.infinity,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.17,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.broken_image,
                          size: 40,
                          color: Colors.grey,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.17,
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
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
                  supplierName,
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

              if (p.stock == 0)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 2,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Out of Stock",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
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
                    wishlistProvider.toggleWishlist(p.id);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          wishlistProvider.isInWishlist(p.id)
                              ? "${p.name} added to wishlist"
                              : "${p.name} removed from wishlist",
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
                    Icons.bookmark_border, // أو playlist_add
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
    // ✅ حالة 1: Out of Stock (stock == 0) و restock_date == null
    if (p.stock == 0 && p.restockDate == null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade400,
            padding: const EdgeInsets.symmetric(vertical: 14),
            disabledBackgroundColor: Colors.grey.shade400,
          ),
          onPressed: null, // disabled
          child: const Text(
            "Out of Stock",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    // ✅ حالة 2: Notify Me (stock == 0 و restock_date != null)
    if (p.stock == 0 && p.restockDate != null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () {
            // TODO: استدعاء API الـ Notify Me
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

    // ✅ حالة 3: منتج متاح (stock > 0)
    // Rent + Add To Cart (يظهر Rent فقط لو isRentable == true)
    return Row(
      children: [
        // ---------- Add To Cart ----------
        Expanded(
          flex: p.isRentable ? 3 : 1,
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

        // ---------- Rent (يظهر فقط لو isRentable == true) ----------
        if (p.isRentable) ...[
          const SizedBox(width: 10),
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
              child: const Text("Rent", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
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
