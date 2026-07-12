import 'package:flutter/material.dart';
import 'package:medconnect_app/cartScreen.dart';
import 'package:medconnect_app/chatScreen.dart';
import 'package:medconnect_app/core/app_colorSupplier.dart';
import 'package:medconnect_app/homeScreen.dart';
import 'package:medconnect_app/models/Search_model.dart';
import 'package:medconnect_app/models/equipment_model.dart';
import 'package:medconnect_app/models/product.dart';
import 'package:medconnect_app/productDetails.dart';
import 'package:medconnect_app/providers/notification_provider.dart';
//import 'package:medconnect_app/providers/wishlist_provider.dart';
import 'package:medconnect_app/services/api_service.dart';
import 'package:medconnect_app/services/cart_services.dart';
import 'package:medconnect_app/services/equipment_service.dart'
    as EquipmentApiService;
import 'package:medconnect_app/services/search_services.dart';
import 'package:medconnect_app/shimmerSkeleton.dart';
import 'package:provider/provider.dart';
//import 'package:provider/provider.dart';

class SupplierProfileScreen extends StatefulWidget {
  final int supplierId;
  final String supplierName;

  const SupplierProfileScreen({
    super.key,
    required this.supplierId,
    required this.supplierName,
  });

  @override
  State<SupplierProfileScreen> createState() => _SupplierProfileScreenState();
}

class _SupplierProfileScreenState extends State<SupplierProfileScreen> {
  bool _isLoading = true;
  String? _error;

  // بيانات المورد
  Map<String, dynamic>? _supplierData;
  List<Product> _products = [];

  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];
  bool _isSearching = false;

// ✅ متغيرات البحث والفلتر (زي الهوم)
List<ProductModel> searchResults = [];
bool isSearching = false;
int? selectedCategoryId;
bool showCategories = false;
List<CategoryApiModel> categoriesApi = [];
bool isLoadingCategoriesApi = false;
bool _isSearchingLoading = false;

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();
  int? _conversationId;
  int? _receiverId;
  // Map<int, bool> _notifyStatus = {}; // productId -> isNotified

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadSupplierData();


    _loadProducts();
    fetchCategoriesApi();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          _currentPage <= _totalPages &&
          !_isLoadingMore) {
        _loadMoreProducts();
      }
    });
    _searchController.addListener(() {
      _filterProducts();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  //################
  void _filterProducts() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _filteredProducts = [];
      } else {
        _filteredProducts = _products.where((product) {
          return product.name.toLowerCase().contains(query) ||
              product.brand.toLowerCase().contains(query) ||
              (product.supplierData?['company_name']
                      ?.toString()
                      .toLowerCase()
                      .contains(query) ??
                  false);
        }).toList();
      }
    });
  }
// ✅ جلب الأقسام من API
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

// ✅ البحث
Future<void> _searchProduct(String query) async {
  if (!mounted) return;
  setState(() {
    _isSearchingLoading = true;
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
      searchResults = result['data'];
      _isSearchingLoading = false;
      isSearching = query.isNotEmpty || selectedCategoryId != null;
    });
  }
}

// ✅ شاشة اختيار الأقسام
void _showCategoriesTopSheet() {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Dismiss",
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, anim1, anim2) {
      return Align(
        alignment: Alignment.centerRight,
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
                            Navigator.of(context).pop();
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
  Future<void> _loadSupplierData() async {
    // هنضيف API لجلب بيانات المورد بعدين
    // حالياً هنستخدم البيانات اللي جاية مع المنتج
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _apiService.fetchProductsBySupplierId(
        supplierId: widget.supplierId,
        page: 1,
        perPage: 10,

        /// perPage: 50, // يجيب أكبر عدد عشان البحث يكون دقيق
      );

      setState(() {
        _products = result['products'];
        _totalPages = result['lastPage'];
        _currentPage = 2;
        _isLoading = false;
        print('🔄 Load products - current page: $_currentPage');
        print('🔄 Products before: ${_products.length}');
        print("+++++${result['supplier']}");

        if (result['supplier'] != null) {
          _supplierData = result['supplier'];
          print("=====================");
          print('✅ Supplier data loaded: ${_supplierData?['company_name']}');
        }
        // if (_products.isNotEmpty && _products.first.supplierData != null) {
        //   _supplierData = _products.first.supplierData;
        //   print('✅ Supplier data loaded: ${_supplierData?['company_name']}');
        //   print('✅ Image URL: ${_supplierData?['company_image_url']}');
        // }
      });

      // بعد إضافة المنتجات
      for (var product in result['products']) {
        if (product.stock == 0 && product.restockDate != null) {
          final isNotified = await _apiService.isNotified(product.id);
          Provider.of<NotificationProvider>(
            context,
            listen: false,
          ).setNotified(product.id, isNotified);
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_currentPage > _totalPages) {
      print('⚠️ No more pages: $_currentPage > $_totalPages');
      return;
    }
    if (_isLoadingMore) {
      print('⚠️ Already loading more');
      return;
    }

    print('🔄 Loading more products - page $_currentPage of $_totalPages');

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final result = await _apiService.fetchProductsBySupplierId(

        supplierId: widget.supplierId,
        page: _currentPage,
        perPage: 10,
      );

      setState(() {
        // _products.addAll(result['products']);

        for (var newProduct in result['products']) {
          if (!_products.any((p) => p.id == newProduct.id)) {
            _products.add(newProduct);
          } else {
            print(
              '⚠️ Duplicate product skipped: ${newProduct.id} - ${newProduct.name}',
            );
          }
        }
        _totalPages = result['lastPage'];
        _currentPage++;
        _isLoadingMore = false;

        print('🔄 Load more - page: $_currentPage');
        print('🔄 Products before add: ${_products.length}');
        print('➕ Adding ${result['products'].length} products');

        print('🔄 Products after add: ${_products.length}');
        // ✅ استخراج بيانات المورد من الـ Response (جاية بره الـ data)
        if (result['supplier'] != null) {
          _supplierData = result['supplier'];
              _conversationId = _supplierData?['conversation_id'] ;
     _receiverId = _supplierData?['allUser_id'] ;
          print('✅ Supplier data loaded: ${_supplierData?['company_name']}');
        }
      });

      // بعد إضافة المنتجات
      for (var product in result['products']) {
        if (product.stock == 0 && product.restockDate != null) {
          final isNotified = await _apiService.isNotified(product.id);
          Provider.of<NotificationProvider>(
            context,
            listen: false,
          ).setNotified(product.id, isNotified);
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
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
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error: ${e.toString().replaceAll('Exception:', '')}",
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _topBar(context),

            // في build، بعد الـ AppBar وقبل الـ Expanded
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    const SizedBox(height: 6),
                    _supplierHeader(),
                    _aboutSection(),
                    _achievements(),
                    _certificates(),
                    _SearchBar(),
                    _productsSection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- TOP BAR ----------------
  Widget _topBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              "Supplier Profile",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          //const SizedBox(height: 4),
        ],
      ),
    );
  }

  // Widget _SearchBar() {
  //   return Padding(
  //     padding: const EdgeInsets.all(16),
  //     child: Container(
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(12),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.grey.withOpacity(0.1),
  //             blurRadius: 6,
  //             offset: const Offset(0, 2),
  //           ),
  //         ],
  //       ),
  //       child: TextField(
  //          onChanged: (value) {
  //             _searchProduct(value);
  //           },
  //         controller: _searchController,
  //         decoration: InputDecoration(
  //           hintText: "Search products...",
  //           prefixIcon: const Icon(Icons.search, color: Colors.grey),
  //           suffixIcon: _searchController.text.isNotEmpty
  //               ? IconButton(
  //                   icon: const Icon(Icons.clear, color: Colors.grey),
  //                   onPressed: () {
  //                     _searchController.clear();
  //                     _filterProducts();
  //                   },
  //                 )
  //               : null,
  //           border: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(12),
  //             borderSide: BorderSide.none,
  //           ),
  //           filled: true,
  //           fillColor: Colors.white,
  //           contentPadding: const EdgeInsets.symmetric(vertical: 14),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget _SearchBar() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Row(
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
                hintText: "Search products...",
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
            _showCategoriesTopSheet();
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
    ),
  );
}

  // ---------------- HEADER ----------------
  Widget _supplierHeader() {
    // لو فيه supplierData من API
    final imageUrl = _supplierData != null
        ? _supplierData!['company_image_url'] ?? ''
        : '';
    final companyName = widget.supplierName;
 

    print('🔍 Supplier Header - Image URL: $imageUrl');
    print('🔍 Supplier Header - Company: $companyName');

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 56,
            backgroundColor: Colors.grey.shade200,
            child: imageUrl.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      imageUrl,
                      width: 112,
                      height: 112,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('❌ Failed to load image: $imageUrl');
                        return const Icon(
                          Icons.business,
                          size: 56,
                          color: Colors.grey,
                        );
                      },
                    ),
                  )
                : const Icon(Icons.business, size: 56, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Text(
            companyName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),

          const SizedBox(height: 16),
          
          _buildChatButton(_conversationId, _receiverId),
          // SizedBox(
          //   width: double.infinity,
          //   child: ElevatedButton(
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: AppColors.primary,
          //       padding: const EdgeInsets.symmetric(vertical: 14),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(12),
          //       ),
          //     ),

          //     // onPressed: () {

          //     // },
          //     // child: const Text(
          //     //   "Chat with Vendor",
          //     //   style: TextStyle(
          //     //     fontWeight: FontWeight.bold,
          //     //     color: Colors.white,
          //     //   ),
          //     // ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildChatButton(int? convId, int? receiverId) {
    print('🔍 Supplier Data for Chat: $_supplierData');
    print('supplierconversation_id: ${_supplierData?['conversation_id']}');
    print('supplierallUser_id: ${_supplierData?['allUser_id']}');
    

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          print('🔍 Navigating to ChatScreen with:');
          print('   chatName: ${widget.supplierName}');
         // print('   conversationId: $conversationId');
          print('   receiverId: ${_supplierData?['allUser_id']}');
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                chatName: widget.supplierName,
                conversationId: convId, // ✅ لو null، ChatScreen هيتعامل
                receiverId: receiverId?? _supplierData?['allUser_id'], // ✅ لو null، ChatScreen هيتعامل
              ),
            ),
          );
          
        },
        child: const Text(
          "Chat with Vendor",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  // ---------------- ABOUT ----------------
  Widget _aboutSection() {
    return _card(
      title: "About Us",
      child: const Text(
        "MediTech Solutions Inc. is a leading provider of state-of-the-art medical equipment. Our mission is to enhance patient care by supplying reliable and innovative devices to healthcare professionals worldwide.",
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }

  // ---------------- ACHIEVEMENTS ----------------
  Widget _achievements() {
    return _card(
      title: "Key Achievements",
      child: Row(
        children: [
          _achievementItem("25+", "Years of Innovation"),
          const SizedBox(width: 12),
          _achievementItem("500+", "Partner Hospitals"),
        ],
      ),
    );
  }

  Widget _achievementItem(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- CERTIFICATES ----------------
  Widget _certificates() {
    // جلب أسماء الشهادات من supplierData
    List<String> certificates = [];

    if (_supplierData != null) {
      // لو كان certificate_name عبارة عن List
      if (_supplierData!['certificate_name'] is List) {
       // print('----------${_supplierData['certificate_name']}');
        certificates = List<String>.from(_supplierData!['certificate_name']);
      }
      // لو كان certificate_name string واحد
      else if (_supplierData!['certificate_name'] != null) {
        certificates.add(_supplierData!['certificate_name'].toString());
      }
    }

    // لو مفيش بيانات من API، نستخدم بيانات افتراضية
    if (certificates.isEmpty) {
      certificates = [" "];
    }

    return _card(
      title: "Certificates",
      child: Column(
        children: certificates.map((cert) => _certificateItem(cert)).toList(),
      ),
    );
  }

  Widget _certificateItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.verified, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
  Widget _searchResultsApi() {
  if (searchResults.isEmpty) {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Center(
        child: Text('No products found'),
      ),
    );
  }

  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Search Results (${searchResults.length})",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      ...searchResults.map((product) {
        return _productCardFromSearch(product);
      }).toList(),
    ],
  );
}

Widget _productCardFromSearch(ProductModel product) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailsPage(
            productId: product.id ?? 0,
          ),
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              product.image.isNotEmpty ? product.image.first.image : '',
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, size: 40),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "${product.price} EGP",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildSearchSkeleton() {
  return Column(
    children: List.generate(
      3,
      (index) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ShimmerSkeleton(width: 90, height: 90, borderRadius: BorderRadius.circular(12)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerSkeleton(width: double.infinity, height: 16, borderRadius: BorderRadius.circular(4)),
                  const SizedBox(height: 8),
                  ShimmerSkeleton(width: 80, height: 14, borderRadius: BorderRadius.circular(4)),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  // ---------------- PRODUCTS ----------------
  Widget _productsSection() {

    // ✅ حالة تحميل البحث
  if (isSearching && _isSearchingLoading) {
    return _buildSearchSkeleton();
  }

  // ✅ عرض نتائج البحث
  if (isSearching && !_isSearchingLoading) {
    return _searchResultsApi();
  }
    if (_isLoading && _products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          children: [
            Text(_error!),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blueAccent,
              ),
              onPressed: _loadProducts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    final displayList = _isSearching ? _filteredProducts : _products;
    if (displayList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No products available from this supplier'),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isSearching
                    ? "Search Results (${displayList.length})"
                    : "All Products by this Supplier",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ...displayList.map((product) => _productCard(product)).toList(),
        if (_isLoadingMore && !_isSearching)
          const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  final CartService _cartService = CartService();

  Widget _productCard(Product product) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final isNotified = notificationProvider.isNotified(product.id);

    print('🃏 Product card: ${product.id} - ${product.name}');

    bool isOutOfStock = product.stock == 0;
    //final wishlistProvider = context.watch<WishlistProvider>();

    // final isInWishlist = wishlistProvider.isInWishlist(product.id);

    return GestureDetector(
      onTap: () {
        // ✅ التنقل لصفحة تفاصيل المنتج
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsPage(
              productId: product.id,
              product: product, // ✅ تمرير المنتج للـ cache
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.imagePath,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, size: 40),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "EGP${product.price}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isOutOfStock ? Colors.red : AppColors.primary,
                    ),
                  ),
                  if (isOutOfStock)
                    const Text(
                      "Out of Stock",
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  if (product.isRentable && product.rentalStock! > 0)
                    const Text(
                      "available for rent",
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                ],
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
            if (product.stock == 0 && product.restockDate != null)
                      IconButton(
                        icon: const Icon(Icons.notifications_active, color: Colors.black),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("We'll notify you when available"),
            ),
                          );
                        },
                      ),
                
             const SizedBox(width: 6),
                    if (product.stock > 0)
                    
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
                        onPressed: () async {  //there is change by mohamed
                          final result = await _cartService.addToCart(
            productId: product.id,
            quantity: 1,
            type: "sale",
                          );
            
                          if (result['success'] != false) {
            // ✅ ضيفه local برضو لو عايز
            cartItemsGlobal.add(
              CartItem(
                dailyPrice: product.dailyPrice ?? 0,
                name: product.name,
                image: product.imagePath,
                quantity: 1,
                price: product.price,
                type: 'sale',
                dateRange: '',
                id: product.id,
                productId: product.id,
              ),
            );
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("${product.name} added to cart ✅"),
                duration: const Duration(seconds: 2),
              backgroundColor: Colors.blue,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              action: SnackBarAction(
                label: "View Cart",
                textColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CartPage()),
                  );
                },
              ),
              
              
              ),
            );
                          } else { //there is change by mohamed
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result['message'] ?? "Error")),
            );
                          }
                        },
                      
                      ),    // IconButton(
                //   icon: Icon(
                //     isInWishlist ? Icons.favorite : Icons.favorite_border,
                //     color: isInWishlist ? Colors.red : Colors.grey,
                //   ),
                //   onPressed: () {
                //     wishlistProvider.toggleWishlist(product.id);
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       SnackBar(
                //         content: Text(
                //           wishlistProvider.isInWishlist(product.id)
                //               ? "${product.name} removed from wishlist"
                //               : "${product.name} added to wishlist",
                //         ),
                //         duration: const Duration(seconds: 1),
                //       ),
                //     );
                //   },
                // ),
                //// equipment list botton
                IconButton(
                  icon: Icon(Icons.playlist_add, color: Colors.grey[700]),
                  onPressed: () {
                    _showAddToListDialog(product);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildProductButton(Product product) {
  //   // if (product.stock == 0 && product.restockDate == null) {
  //   //   return ElevatedButton(
  //   //     onPressed: null,

  //   //     style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
  //   //     child: const Text(
  //   //       "Out of Stock",
  //   //       style: TextStyle(color: Colors.white),
  //   //     ),
  //   //   );
  //   //  }

  //   // if (product.stock == 0 && product.restockDate != null) {
  //   //   return ElevatedButton(
  //   //     onPressed: () {
  //   //       ScaffoldMessenger.of(context).showSnackBar(
  //   //         const SnackBar(content: Text("We'll notify you when available")),
  //   //       );
  //   //     },
  //   //     style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
  //   //     child: const Text("Notify Me", style: TextStyle(color: Colors.black)),
  //   //   );
  //   // }

  //   return Column(
  //     children: [
  //       // if (product.stock == 0 && product.restockDate == null)
  //       //   ElevatedButton(
  //       //     onPressed: null,

  //       //     style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
  //       //     child: const Text(
  //       //       "Out of Stock",
  //       //       style: TextStyle(color: Colors.white),
  //       //     ),
  //       //   ),
  //       if (product.stock == 0 && product.restockDate != null)
  //         IconButton(
  //           icon: const Icon(Icons.notifications, color: Colors.amber),
  //           onPressed: () {
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               const SnackBar(
  //                 content: Text("We'll notify you when available"),
  //               ),
  //             );
  //           },
  //          // style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
  //           // child: const Text(
  //           //   "Notify Me",
  //           //   style: TextStyle(color: Colors.black),
  //           // ),
  //         ),

  //      // if (product.isRentable && product.stock > 0)

  //         // ElevatedButton(
  //         //   style: ElevatedButton.styleFrom(backgroundColor: Colors.white70),
  //         //   onPressed: () {},
  //         //   child: const Text("Rent", style: TextStyle(color: Colors.blue)),
  //         // ),
  //       const SizedBox(height: 6),
  //       if (product.stock > 0)

  //         IconButton(
  //           icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
  //           onPressed: () async {  //there is change by mohamed
  //             final result = await _cartService.addToCart(
  //               productId: product.id,
  //               quantity: 1,
  //               type: "sale",
  //             );

  //             if (result['success'] != false) {
  //               // ✅ ضيفه local برضو لو عايز
  //               cartItemsGlobal.add(
  //                 CartItem(
  //                   daily_rent: 0,
  //                   name: product.name,
  //                   image: product.imagePath,
  //                   quantity: 1,
  //                   price: product.price,
  //                   type: 'sale',
  //                   dateRange: '',
  //                   id: product.id,
  //                   productId: product.id,
  //                 ),
  //               );

  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 SnackBar(
  //                   content: Text("${product.name} added to cart ✅"),
  //                   duration: const Duration(seconds: 2),
  //                 backgroundColor: Colors.blue,
  //                 behavior: SnackBarBehavior.floating,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //                 action: SnackBarAction(
  //                   label: "View Cart",
  //                   textColor: Colors.white,
  //                   onPressed: () {
  //                     Navigator.push(
  //                       context,
  //                       MaterialPageRoute(builder: (_) => CartPage()),
  //                     );
  //                   },
  //                 ),

  //                 ),
  //               );
  //             } else { //there is change by mohamed
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 SnackBar(content: Text(result['message'] ?? "Error")),
  //               );
  //             }
  //           },
  //         // style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
  //          //  child: Icon( Icons.shopping_cart, color: Colors.black),
  //           //const Text(
  //           //   "Add to Cart",
  //           //   style: TextStyle(color: Colors.white),
  //           // ),
  //         ),
  //     ],
  //   );

  //   // return ElevatedButton(
  //   //   onPressed: () {},
  //   //   style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
  //   //   child: const Text("buy", style: TextStyle(color: Colors.white)),
  //   // );
  // }

  // ---------------- COMMON CARD ----------------
  Widget _card({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

// ---------------- CERTIFICATE ITEM ----------------
// class _CertificateItem extends StatelessWidget {
//   final String text;
//   const _CertificateItem(this.text);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         children: [
//           const Icon(Icons.verified, color: AppColors.primary, size: 20),
//           const SizedBox(width: 8),
//           Expanded(child: Text(text)),
//         ],
//       ),
//     );
//   }
// }
