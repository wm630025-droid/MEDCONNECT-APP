import 'dart:async';

import 'package:flutter/material.dart';
import 'package:medconnect_app/cartScreen.dart';
import 'package:medconnect_app/introScreen.dart';
import 'package:medconnect_app/models/category.dart';
import 'package:medconnect_app/models/equipment_model.dart';
import 'package:medconnect_app/productDetails.dart';
import 'package:medconnect_app/models/product.dart';
import 'package:medconnect_app/doctorAccount.dart';
import 'package:medconnect_app/providers/wishlist_provider.dart';
import 'package:medconnect_app/services/api_service.dart';
import 'package:medconnect_app/services/equipment_service.dart'
    as EquipmentApiService;
import 'package:medconnect_app/services/search_services.dart';
import 'package:provider/provider.dart';
import '../models/Search_model.dart';
import 'package:medconnect_app/services/cart_services.dart';
import 'package:shimmer/shimmer.dart';


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
  //#############################
  // mohamed
  List<ProductModel> searchResults = [];
  bool isSearching = false;
  int? selectedCategoryId;
  bool showCategories = false;
  // دي جاية من API بتاعتك
  List<CategoryApiModel> categoriesApi = [];
  bool isLoadingCategoriesApi = false;

  //#################################
  //  wafaa
  final TextEditingController _searchController = TextEditingController();
  List<Product> displayedProducts = [];
  List<Product> _allProducts = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  // Categories variables
  List<Category> _categories = [];
  bool _isLoadingCategories = true;
  String? _categoriesError;

  // Products variables
  bool _isLoadingProducts = true;
  String? _productsError;
  bool _isSearchingLoading = false;   // ✅ جديد

  final ApiService _apiService = ApiService();
  final CartService cartService = CartService();

  final ScrollController _scrollController = ScrollController();

  Map<int, bool> _notifyStatus = {};

  Timer? _pollTimer;
  bool _forceRefresh = false;

  bool _forceRefreshCategories = false;
  Timer? _categoriesPollTimer;

  //#################################
  @override
  void initState() {
    super.initState();
    _loadCategories();
    fetchCategoriesApi(); //mohamed only
    _startPolling();
    _startCategoriesPolling();
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
void _startPolling() {
  _pollTimer = Timer.periodic(Duration(seconds: 30), (timer) {
    if (mounted) {
      _forceRefresh = true;
      _loadProducts(forceRefresh: true).then((_) {
        if (mounted) _forceRefresh = false;
      });
    }
  });
}
  
  

  Future<void> _loadProducts({bool loadMore = false, bool forceRefresh = false}) async {
     if (!mounted) return;
     if (ApiService.cachedProducts != null && !forceRefresh && !_forceRefresh) {
    setState(() {
      _allProducts = ApiService.cachedProducts!;
      displayedProducts = List.from(_allProducts);
      _isLoadingProducts = false;
      _isLoadingMore = false;
    });
    return;
  }
    
    
    
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
if (!mounted) return;
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

      for (var product in _allProducts) {
        if (product.stock == 0 && product.restockDate != null) {
          final isNotified = await _apiService.isNotified(product.id);
          if (!mounted) return;
          _notifyStatus[product.id] = isNotified;
        }
      }
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _productsError = e.toString();
        _isLoadingProducts = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadCategories({bool forceRefresh = false}) async {
    if (ApiService.cachedCategories != null &&
        !forceRefresh &&
        !_forceRefreshCategories) {
      setState(() {
        _categories = ApiService.cachedCategories!;
        _isLoadingCategories = false;
        _categoriesError = null;
      });
      return;
    }

 if (!mounted) return;
      if (ApiService.cachedCategories != null && !forceRefresh && !_forceRefreshCategories) {
        if (!mounted) return;
    setState(() {
      _categories = ApiService.cachedCategories!;
      _isLoadingCategories = false;
      _categoriesError = null;
    });
    return;
  }
  
    // ✅ التأكد من وجود توكن
    if (ApiService.token == null) {
      setState(() {
        _categoriesError = 'Please login first to view categories';
        _isLoadingCategories = false;
      });
      return;
    }
if (!mounted) return;
    setState(() {
      _isLoadingCategories = true;
      _categoriesError = null;
    });

    try {
      final categories = await _apiService.fetchCategories(
        page: 1,
        perPage: 10,
      );
if (!mounted) return;
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _categoriesError = e.toString();
        _isLoadingCategories = false;
      });
    }
  }

  void _startCategoriesPolling() {
    _categoriesPollTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (mounted) {
        _forceRefreshCategories = true;
        _loadCategories(forceRefresh: true).then((_) {
          _forceRefreshCategories = false;
        });
      }
    });
  }
  //######################

 
  //##################################################################
  // mohamed
  Future<void> _searchProduct(String query) async {
     if (!mounted) return;
  setState(() {
    _isSearchingLoading = true;      // ✅ بدء التحميل
    isSearching = true;       
  });
    final result = await SearchService.searchProducts(
      query,
      selectedCategoryId,
    );
 if (!mounted) return;
    if (result['success']) {
      if (!mounted) return;
      setState(() {
        searchResults = result['data'] ;
         _isSearchingLoading = false;      // ✅ انتهاء التحميل
        isSearching = query.isNotEmpty || selectedCategoryId != null;
      });
    }
  }

  Future<void> fetchCategoriesApi() async {
     if (!mounted) return;
    setState(() {
      isLoadingCategoriesApi = true;
    });

    try {
      final result = await CategorySearch.getCategories();
if (!mounted) return;
      setState(() {
        categoriesApi = result;
      });
    } catch (e) {
      print(e);
    }
if (!mounted) return;
    setState(() {
      isLoadingCategoriesApi = false;
    });
  }
  //##################################################################################
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
                MaterialPageRoute(
                  builder: (_) => doctorAccountPage(),
                ), //there is change by mohamed
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
                  print("xxxxxxxxx");
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
      if (isSearching && _isSearchingLoading)   // ✅ حالة التحميل
        _buildSearchSkeleton()
      else if (isSearching && !_isSearchingLoading)
        _searchResultsApi(searchResults[0]) // Pass the first search result
      else
        _buildHomeSections(),
    ],
        ),
      ),
    );
  }

 Widget _searchResultsApi( product) {
  if (searchResults.isEmpty) {
    return const Text("No products found");
  }

  return GridView.builder(
    itemCount: searchResults.length,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 0.75,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
    ),
    itemBuilder: (context, index) {
      final product = searchResults[index];
      final bool isRentable = product.is_rentable ?? false; 

      return GestureDetector(
        onTap: () {
          
        },
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                product.image.isNotEmpty ? product.image.first.image : "",
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "${product.price} EGP",
                  style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              if (isRentable)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Rentable",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 2),
            ],
          ),
        ),
      );
    },
  );
}
Widget _buildSearchSkeleton() {
  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 0.75,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
    ),
    itemCount: 4,  // عدد الـ skeletons أثناء التحميل
    itemBuilder: (context, index) {
      return Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ShimmerSkeleton(width: double.infinity, height: 120, borderRadius: BorderRadius.circular(8)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ShimmerSkeleton(width: double.infinity, height: 14, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ShimmerSkeleton(width: 80, height: 14, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ShimmerSkeleton(width: 70, height: 24, borderRadius: BorderRadius.circular(12)),
            ),
          ],
        ),
      );
    },
  );
}
//######################################################################################
  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              onChanged: (value) {
                _searchProduct(value);
              },
              controller: _searchController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Search For Equipment",
                icon: Icon(Icons.search),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: () {
            if (!mounted) return;
            setState(() {
              showCategories = !showCategories;
            });
            _showCategoriesTopSheet(); // استدعاء الدالة الجديدة
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }
  @override
  void dispose() {
    _scrollController.dispose();
    _pollTimer?.cancel();
    _categoriesPollTimer?.cancel();
    super.dispose();
  }
//############################################################################################
// mohamed
void _showCategoriesTopSheet() {
  showGeneralDialog(
    context: context,
    barrierDismissible: true, // النقر خارج النافذة يغلقها
    barrierLabel: "Dismiss",
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, anim1, anim2) {
      return Align(
        alignment: Alignment.topCenter, // تظهر في أعلى المنتصف
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.only(top: 80, left: 60, right: 60),
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Text(
                    'Select Category',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Text(
                      'Select Category',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  if (isLoadingCategoriesApi)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (categoriesApi.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text("No categories found")),
                    )
                  else
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: categoriesApi.map((cat) {
                          return CheckboxListTile(
                            title: Text(cat.name),
                            value: selectedCategoryId == cat.id,
                            onChanged: (checked) {
                              setState(() {
                                selectedCategoryId =
                                    (selectedCategoryId == cat.id)
                                    ? null
                                    : cat.id;
                                showCategories = false;
                              });
                              Navigator.of(context).pop(); // إغلاق النافذة
                              _searchProduct(_searchController.text);
                            },
                            activeColor: const Color(0xFF0066FF),
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim, _, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        );
      },
    );
  }

  //##########################################################################################################
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
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // الخلفية
            Image.asset(
              'assets/images/intro_BackGround.png',
              fit: BoxFit.cover,
              color: const Color.fromRGBO(0, 0, 0, 0.7),
              colorBlendMode: BlendMode.darken,
            ),

            // المحتوى
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // اللوجو
                Image.asset(
                  "assets/images/logoPNG.png",
                  width: 220,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ],
        ),
      ),
    );

    // return AspectRatio(
    //   aspectRatio: 16 / 9,
    //   child: Container(
    //     decoration: BoxDecoration(
    //       borderRadius: BorderRadius.circular(12),
    //       image: const DecorationImage(
    //         image: AssetImage("assets/images/intro_backGround.png"),
    //         fit: BoxFit.cover,
    //       ),
    //     ),
    //   ),
    // );
  }

  Widget _categoryItem({required Category category}) {
    return GestureDetector(
      onTap: () {
        ////there is change by mohamed
        setState(() {
          selectedCategoryId = category.id;
        });

        _searchProduct(_searchController.text);
      },
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                category.image,
                width: 65,
                height: 65,
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
      return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          2, // ✅ عدد الـ skeleton categories
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                ShimmerSkeleton(width: 70, height: 70, borderRadius: BorderRadius.circular(12)),
                const SizedBox(height: 8),
                ShimmerSkeleton(width: 60, height: 12, borderRadius: BorderRadius.circular(4)),
              ],
            ),
          ),
        ),
      );
      // return const Center(
      //   child: Padding(
      //     padding: EdgeInsets.all(16.0),
      //     child: CircularProgressIndicator(),
      //   ),
      // );
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
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.50,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 4, // ✅ عدد الـ skeleton cards
        itemBuilder: (context, index) {
          return _skeletonProductCard();
        },
      );
    }

    // if (_isLoadingProducts && _allProducts.isEmpty) {
    //   return const Center(child: CircularProgressIndicator());
    // }

    if (_productsError != null && _allProducts.isEmpty) {
      return Center(
        child: Column(
          children: [
            Text('Error: $_productsError'),
            SizedBox(height: 10),
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
            childAspectRatio: 0.50,
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
Widget _skeletonProductCard() {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // صورة
        ShimmerSkeleton(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.22,
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 8),
        // اسم المنتج
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ShimmerSkeleton(width: double.infinity, height: 14, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(height: 8),
        // اسم المورد
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ShimmerSkeleton(width: 100, height: 12, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(height: 8),
        // السعر
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ShimmerSkeleton(width: 80, height: 14, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(height: 8),
        // زر
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ShimmerSkeleton(width: double.infinity, height: 36, borderRadius: BorderRadius.circular(8)),
        ),
        const SizedBox(height: 8),
      ],
    ),
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
    // final isInWishlist = wishListGlobal.any((i) => i["name"] == p.name);
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
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProductDetailsPage(productId: p.id, product: p),
                    ),
                  );

                  if (result == true && mounted) {
                    final isNotified = await _apiService.isNotified(p.id);
                    setState(() {
                      _notifyStatus[p.id] = isNotified;
                    });
                  }
                },
                //#####################################################
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    p.imagePath,
                    height: MediaQuery.of(context).size.height * 0.22,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.22,
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
                        height: MediaQuery.of(context).size.height * 0.22,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                  padding: const EdgeInsets.all(7.0),
                  child: const Text(
                    " ",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (p.isRentable && p.stock > 0)
                Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: const Text(
                    "Available for Rent",
                    style: TextStyle(
                      color: Color.fromARGB(255, 89, 129, 248),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
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
                //   GestureDetector(
                //   onTap: () {
                //     wishlistProvider.toggleWishlist(p.id);

                //     ScaffoldMessenger.of(context).showSnackBar(
                //       SnackBar(
                //         content: Text(
                //           wishlistProvider.isInWishlist(p.id)
                //               ? "${p.name} added to wishlist"
                //               : "${p.name} removed from wishlist",
                //         ),
                //       ),
                //     );
                //   },
                //   child: Icon(
                //     isInWishlist ? Icons.favorite : Icons.favorite_border,
                //     color: isInWishlist ? Colors.red : Colors.black,
                //     size: 26,
                //   ),
                // ),
                // const SizedBox(width: 8),

                // 📋 Equipment List
                IconButton(
                  icon: const Icon(Icons.playlist_add, color: Colors.grey),
                  onPressed: () => _showAddToListDialog(p),
                ),

                // onTap: () {
                //   setState(() {
                //     if (isInequipmentList) {
                //       equipmentListGlobal.removeWhere(
                //         (i) => i["name"] == p.name,
                //       );
                //     } else {
                //       equipmentListGlobal.add({
                //         "name": p.name,
                //         "price": p.price,
                //         "image": p.imagePath,
                //       });
                //     }

                //     // toggle اللون
                //     isInequipmentList = !isInequipmentList;
                //   });

                //   ScaffoldMessenger.of(context).showSnackBar(
                //     SnackBar(
                //       content: Text(
                //         isInequipmentList
                //             ? "${p.name} added to equipment list"
                //             : "${p.name} removed from equipment list",
                //       ),
                //     ),
                //   );
                // },
                // child: Icon(
                //   Icons.playlist_add, // أو playlist_add
                //   color: isInequipmentList ? Colors.blue : Colors.black,
                //   size: 26,
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddToListDialog(Product product) async {
    try {
      final lists = await EquipmentApiService.getSimpleLists();
      if (lists.isEmpty) {
        _showCreateListFirstDialog(product);
        return;
      }

      final selectedList = await showDialog<EquipmentList>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Add to Equipment List"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...lists.map(
                (list) => ListTile(
                  title: Text(list.listName),
                  onTap: () => Navigator.pop(ctx, list),
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text("+ Create New List"),
                onTap: () => Navigator.pop(ctx, null),
              ),
            ],
          ),
        ),
      );

      if (selectedList != null) {
        await EquipmentApiService.addItemToList(selectedList.id, product.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Added to list")));
      } else {
        _showCreateNewListDialog(product);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }
  }

  void _showCreateNewListDialog(Product product) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("New List Name"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Create"),
          ),
        ],
      ),
    );
    if (confirmed == true && controller.text.isNotEmpty) {
      try {
        await EquipmentApiService.createEquipmentList(controller.text);
        final newLists = await EquipmentApiService.getSimpleLists();
        final newList = newLists.firstWhere(
          (l) => l.listName == controller.text,
        );
        await EquipmentApiService.addItemToList(newList.id, product.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("List created and item added")),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("$e")));
      }
    }
  }

  void _showCreateListFirstDialog(Product product) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("No Lists Found"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("You don't have any equipment lists yet."),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Enter list name",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Create"),
          ),
        ],
      ),
    );

    if (confirmed == true && controller.text.isNotEmpty) {
      try {
        await EquipmentApiService.createEquipmentList(controller.text);
        final newLists = await EquipmentApiService.getSimpleLists();
        final newList = newLists.firstWhere(
          (l) => l.listName == controller.text,
        );
        await EquipmentApiService.addItemToList(newList.id, product.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("List created and item added")),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("$e")));
      }
    }
  }
  // ---------------------
  // BUTTONS: Add / Rent / Notify Me
  // ---------------------

  // ... كل المتغيرات

  Widget _buildNotifyButton(Product p) {
    return FutureBuilder<bool>(
      future: _apiService.isNotified(p.id),
      builder: (context, snapshot) {
        final isNotified = snapshot.data ?? false;
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isNotified
                  ? const Color.fromARGB(255, 238, 235, 235)
                  : Colors.amber,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () async {
              if (isNotified) {
                await _apiService.undoRestockNotification(p.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notification cancelled')),
                );
              } else {
                await _apiService.requestRestockNotification(p.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notification requested!')),
                );
              }
              setState(() {});
            },
            child: Text(
              isNotified ? "Un Notify" : "Notify Me",
              style: TextStyle(
                color: isNotified ? Colors.red : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildActionButton(Product p) {
    // ✅ حالة 1: Out of Stock (stock == 0) و restock_date == null
    if (p.stock == 0 && p.restockDate == null) {
      return SizedBox(
        width: double.infinity,
        child: Expanded(
          flex: 1,
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
        ),
      );
    }

    // ✅ حالة 2: Notify Me (stock == 0 و restock_date != null)
    if (p.stock == 0 && p.restockDate != null) {
      return _buildNotifyButton(p);
      // return SizedBox(
      //   width: double.infinity,
      //   child: ElevatedButton(
      //     style: ElevatedButton.styleFrom(
      //       backgroundColor: Colors.amber,
      //       padding: const EdgeInsets.symmetric(vertical: 14),
      //     ),
      //     onPressed:  () async {
      //   try {
      //     final result = await _apiService.requestRestockNotification(p.id);
      //     if (result['success'] == true) {
      //       ScaffoldMessenger.of(context).showSnackBar(
      //         const SnackBar(content: Text("Notification requested! We'll notify you when back in stock")),
      //       );
      //     } else {
      //       throw Exception(result['error']);
      //     }
      //   } catch (e) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(content: Text(e.toString().replaceAll('Exception:', ''))),
      //     );
      //   }
      // },
      //     child: const Text(
      //       "Notify Me",
      //       style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      //     ),
      //   ),
      // );
    }

    // ✅ حالة 3: منتج متاح (stock > 0)
    // Rent + Add To Cart (يظهر Rent فقط لو isRentable == true)
    final CartService _cartService = CartService();
    return Row(
      children: [
        // ---------- Add To Cart ----------
        Expanded(
          flex: 1,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () async {
              //there is change by mohamed
              final result = await _cartService.addToCart(
                productId: p.id,
                quantity: 1,
                type: "sale",
              );
if (!mounted) return;
              if (result['success'] != false) {
                // ✅ ضيفه local برضو لو عايز
                cartItemsGlobal.add(
                  CartItem(
                    daily_rent: 0,
                    name: p.name,
                    image: p.imagePath,
                    quantity: 1,
                    price: p.price,
                    type: 'sale',
                    dateRange: '',
                    id: p.id,
                    productId: p.id,
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${p.name} added to cart ✅")),
                );
              } else {
                //there is change by mohamed
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['message'] ?? "Error")),
                );
              }
            },
            //     onPressed: () async {
            //        //there is change by mohamed
            //        try{
            //       final result = await _cartService.addToCart(
            //         productId: p.id,
            //         quantity: 1,
            //         type: "sale",
            //       );

            //       if (result['success'] == true) {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         SnackBar(content: Text("${p.name} added to cart (Buy)")),
            //       );
            //     } else {
            //       throw Exception(result['error']);
            //     }
            //   } catch (e) {
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       SnackBar(content: Text(e.toString().replaceAll('Exception:', ''))),
            //     );
            //   }
            // },
            child: const Text(
              "Add To Cart",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),

        // ---------- Rent (يظهر فقط لو isRentable == true) ----------
        // if (p.isRentable)
        //  const SizedBox(width: 10),
        //     Expanded(
        //       flex: 2,
        //         child: const Text(
        //           "Available for Rent",
        //           style: TextStyle(
        //             color: Color.fromARGB(255, 89, 129, 248),
        //             fontWeight: FontWeight.bold,
        //             fontSize: 12,
        //           ),
        //         ),

        //     ),
      ],
    );
  }
  //#########################   comment by mohamed
  // ---------------------
  // Search Results
  // ---------------------
  // Widget _searchResults() {
  //   if (displayedProducts.isEmpty) {
  //     return const Padding(
  //       padding: EdgeInsets.all(20),
  //       child: Text("No products found."),
  //     );
  //   }

  //   return GridView.builder(
  //     itemCount: displayedProducts.length,
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //       crossAxisCount: 2,
  //       childAspectRatio: 0.60,
  //       crossAxisSpacing: 12,
  //       mainAxisSpacing: 12,
  //     ),
  //     itemBuilder: (context, index) {
  //       return _productCard(displayedProducts[index]);
  //     },
  //   );
  // }
}

class ShimmerSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const ShimmerSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      period: const Duration(milliseconds: 1200),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white, // اللون سيتم تجاوزه بواسطة الـ Shimmer
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

