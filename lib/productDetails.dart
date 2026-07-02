import 'package:flutter/material.dart';
import 'package:medconnect_app/cartScreen.dart';
import 'package:medconnect_app/checkoutAddress.dart';
import 'package:medconnect_app/models/equipment_model.dart';
import 'package:medconnect_app/models/product.dart';
import 'package:medconnect_app/homeScreen.dart';
import 'package:medconnect_app/models/rental_item.dart';
import 'package:medconnect_app/models/review.dart';
import 'package:medconnect_app/providers/notification_provider.dart';
import 'package:medconnect_app/services/api_service.dart';
import 'package:medconnect_app/services/cart_services.dart';
import 'package:medconnect_app/services/equipment_service.dart'
    as EquipmentApiService;
import 'package:medconnect_app/supplierProfile.dart';
import 'package:provider/provider.dart';
import '../providers/wishlist_provider.dart';
import 'package:medconnect_app/shimmerSkeleton.dart';

// ---------------- PAGE ----------------
class ProductDetailsPage extends StatefulWidget {
  final int productId;
  final Product? product;
  final bool openRentTab;
  const ProductDetailsPage({
    super.key,
    required this.productId,
    this.product,
    this.openRentTab = false,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int currentImage = 0;
  int selectedPurchase = 1; // 0 Rent - 1 Buy
  int selectedTab = 0;
  Product? _product;
  bool isLoading = true;
  String? _error;
  //bool _isNotified = false;

  bool get isOutOfStock =>
      _product!.stock == 0 && _product!.restockDate == null;
  bool get isRentable =>
      _product!.isRentable && (_product!.rentalStock ?? 0) > 0;
  bool get canBuy => _product!.stock > 0;
  bool get showNotifyMe =>
      _product!.stock == 0 && _product!.restockDate != null;

  List<Review> get reviews => _product?.reviews ?? [];
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadProduct();
    if (widget.openRentTab) {
      selectedPurchase = 0; // يفتح على تبويب Rent
    }
  }

  Future<void> _fetchReviews() async {
    if (_product == null) return;
    try {
      final reviews = await _apiService.getProductReviews(_product!.id);
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final updatedReviews = reviews.map((r) {
        return Review(
          id: r.id,
          doctorId: r.doctorId,
          rating: r.rating,
          comment: r.comment,
          createdAt: r.createdAt,
          productId: r.productId,
          doctorName: r.doctorName,
          canDelete: r.doctorId == ApiService.doctorId,
          profileImageUrl: r.profileImageUrl,
          
        );
      }).toList();

      if (mounted) {
        setState(() {
          _product = Product(
            id: _product!.id,
            supplierId: _product!.supplierId,
            name: _product!.name,
            brand: _product!.brand,
            price: _product!.price,
            imagePath: _product!.imagePath,
            stock: _product!.stock,
            isRentable: _product!.isRentable,
            restockDate: _product!.restockDate,
            status: _product!.status,
            images: _product!.images,
            description: _product!.description,
            specification: _product!.specification,
            warranty: _product!.warranty,
            configuration: _product!.configuration,
            dailyRent: _product!.dailyRent,
            rentalStock: _product!.rentalStock,
            setupDuration: _product!.setupDuration,
            supplierData: _product!.supplierData,
            reviews: updatedReviews,
          );
        });
      }
    } catch (e) {
      print('❌ Error fetching reviews: $e');
    }
  }

  Future<void> _loadProduct() async {
    // لو المنتج جاي من HomeScreen (مش محتاج API)
    if (widget.product != null) {
      if (mounted) {
        setState(() {
          _product = widget.product;
          isLoading = false;
        });
      }
      await _fetchReviews(); // ✅ جلب التعليقات بعد تحميل المنتج
      //await _checkNotificationStatus();
      return; // ✅ رجوع عشان ما ينفذش الكود اللي بعده
    }
    // // لو محتاجين نجيب من API
    // setState(() {
    //   _isLoading = true;
    //   _error = null;
    // });
    //print(" product config : ${_product!.configuration}");
    try {
      final freshproduct = await _apiService.fetchProductById(widget.productId);
      final reviews = await _apiService.getProductReviews(widget.productId);

      reviews.sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      ); // الأحدث أولاً
      final updatedReviews = reviews.map((r) {
        print('-------------------------------------');
        print('@@Review Url: ${r.profileImageUrl}');
        return Review(
          id: r.id,
          doctorId: r.doctorId,
          rating: r.rating,
          comment: r.comment,
          createdAt: r.createdAt,
          productId: r.productId,
          doctorName: r.doctorName,
          canDelete: r.doctorId == ApiService.doctorId,
          profileImageUrl: r.profileImageUrl,
        );
      }).toList();
      if (mounted) {
        setState(() {
          //   _product = freshproduct;

          _product = Product(
            id: freshproduct.id,
            supplierId: freshproduct.supplierId,
            name: freshproduct.name,
            brand: freshproduct.brand,
            price: freshproduct.price,
            imagePath: freshproduct.imagePath,
            stock: freshproduct.stock,
            isRentable: freshproduct.isRentable,
            restockDate: freshproduct.restockDate,
            status: freshproduct.status,
            images: freshproduct.images,
            description: freshproduct.description,
            specification: freshproduct.specification,
            configuration: freshproduct.configuration,
            warranty: freshproduct.warranty,
            setupDuration: freshproduct.setupDuration,
            supplierData: freshproduct.supplierData,
            dailyRent: freshproduct.dailyRent,
            reviews: updatedReviews, // ✅ من API منفصل
          );
          isLoading = false;
        });
      }

      // await _checkNotificationStatus();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          isLoading = false;
        });
      }
    }
  }

  // ✅ دالة منفصلة عشان نجيب isNotified
  // Future<void> _checkNotificationStatus() async {
  //   if (_product == null) return;
  //   final isNotified = await _apiService.isNotified(_product!.id);
  //   if (mounted) {
  //     setState(() {
  //       _isNotified = isNotified;
  //     });
  //   }
  // }
  // -------- Rent --------
  DateTime? rentStartDate;
  DateTime? rentEndDate;
  int rentQuantity = 1;

  // -------- Buy --------
  // String selectedConfig = "Standard Unit";
  // double get price {
  //   return selectedConfig == "Total price"
  //       ? _product!.price
  //       : _product!.price; // Example price difference
  // }

  // String selectedWarranty = "";

  // -------- Reviews --------
  double get averageRating {
    if (reviews.isEmpty) return 0;
    return reviews.fold<int>(0, (sum, r) => sum + r.rating) / reviews.length;
  }

  int userRating = 0;
  final TextEditingController reviewController = TextEditingController();

  int get rentDays {
    if (rentStartDate == null || rentEndDate == null) return 0;
    return rentEndDate!.difference(rentStartDate!).inDays + 1;
  }

  bool isInWishlist = false;
  bool isInEquipmentList = false;

  Future<void> _rentNow() async {
    if (rentStartDate == null || rentEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both start and end dates'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // ✅ التحقق من أن End Date بعد Start Date
    if (rentEndDate!.isBefore(rentStartDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date must be after start date'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    String formatDate(DateTime date) {
      return "${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}";

      //return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    }

    print('sending rent validation');
    print(' productId : ${_product!.id}');
    print('quantity: $rentQuantity');
    print("start date : ${formatDate(rentStartDate!)}");
    print("end date : ${formatDate(rentEndDate!)}");

    try {
      final isValid = await _apiService.validateRent(
        productId: _product!.id,
        quantity: rentQuantity,
        startDate: formatDate(rentStartDate!),
        endDate: formatDate(rentEndDate!),
      );

      if (isValid) {
        final rentalItem = RentalItem(
          productId: _product!.id,
          name: _product!.name,
          price: _product!.dailyRent ?? 0.0,
          image: _product!.imagePath,
          quantity: rentQuantity,
          startDate: formatDate(rentStartDate!),
          endDate: formatDate(rentEndDate!),
        );
        print('Rent validated, navigating to checkout,$rentalItem');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                CheckoutAddressPage(isRentalMode: true, rentalItem: rentalItem),
          ),
        );
      }
    } catch (e) {
      // ✅ عرض رسالة الخطأ من الـ API
      String errorMessage = e.toString().replaceAll('Exception:', '').trim();

      // لو الخطأ من الـ API نفسه (زي "not rentable" أو "Insufficient stock for rent")
      if (errorMessage.contains('not rentable')) {
        errorMessage = 'This product is not available for rent';
      } else if (errorMessage.contains('Insufficient stock')) {
        errorMessage = 'Not enough stock available for rent';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
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
  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "Product Details",
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة المنتج
              ShimmerSkeleton(
                width: double.infinity,
                height: 260,
                borderRadius: BorderRadius.circular(0),
              ),
              const SizedBox(height: 16),

              // اسم المنتج
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ShimmerSkeleton(
                  width: double.infinity,
                  height: 24,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 10),

              // الوصف
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ShimmerSkeleton(
                  width: double.infinity,
                  height: 14,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ShimmerSkeleton(
                  width: 200,
                  height: 14,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),

              // زرار Wishlist و Equipment
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ShimmerSkeleton(
                        width: double.infinity,
                        height: 40,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ShimmerSkeleton(
                        width: double.infinity,
                        height: 40,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Supplier card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ShimmerSkeleton(
                  width: double.infinity,
                  height: 70,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(height: 16),

              // Rent/Buy switch
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ShimmerSkeleton(
                  width: double.infinity,
                  height: 44,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              const SizedBox(height: 16),

              // Config card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ShimmerSkeleton(
                  width: double.infinity,
                  height: 150,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Product Details")),
        body: const Center(child: Text('Product not found')),
      );
    }
    // final wishlistProvider = Provider.of<WishlistProvider>(
    //   context,
    //   listen: true,
    // );
    // final isInWishlist = wishlistProvider.isInWishlist(_product!.id);
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Product Details",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _imageSlider(),
            _imageDots(),

            //###########
            const SizedBox(height: 15),
            Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _product!.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (_product!.description.isNotEmpty) ...[
                          Expanded(child: Text(_product!.description)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            //##########3333
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Expanded(
                  //   child: SizedBox(
                  //     height: 40,
                  //     child: ElevatedButton.icon(
                  //       onPressed: () {
                  //         wishlistProvider.toggleWishlist(_product!.id);
                  //         ScaffoldMessenger.of(context).showSnackBar(
                  //           SnackBar(
                  //             content: Text(
                  //               wishlistProvider.isInWishlist(_product!.id)
                  //                   ? "Added to wishlist"
                  //                   : "Removed from wishlist",
                  //             ),
                  //             duration: const Duration(seconds: 1),
                  //           ),
                  //         );
                  //       },
                  //       icon: Icon(
                  //         isInWishlist ? Icons.favorite : Icons.favorite_border,
                  //         color: isInWishlist ? Colors.red : Colors.black,
                  //       ),
                  //       label: Text(
                  //         "Wishlist",
                  //         style: TextStyle(
                  //           color: isInWishlist ? Colors.red : Colors.black,
                  //         ),
                  //       ),
                  //       style: ElevatedButton.styleFrom(
                  //         backgroundColor: Colors.white,
                  //         side: BorderSide(color: Colors.grey.shade300),
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(8),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 35,
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddToListDialog(_product!),

                        icon: Icon(
                          Icons.playlist_add,
                          color: isInEquipmentList ? Colors.blue : Colors.black,
                        ),
                        label: Text(
                          "Equipment List",
                          style: TextStyle(
                            color: isInEquipmentList
                                ? Colors.blue
                                : Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),
            _supplierCard(context),
            _rentBuySwitch(),
            //   if (_product!.stock != 0) ...[
            if (selectedPurchase == 0) _rentConfig(),
            if (selectedPurchase == 1) _buyConfig(),

            _tabs(),
            selectedTab == 0 ? _specifications() : _reviewsSection(),

            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomNavigationBar: _actionButton(),
    );
  }

  Widget locationAndSetupTime() {
    return Container(
      // padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location Card
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                const Text(
                  "Location",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 15,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Cairo", // Replace with actual location if available
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Setup Time Card
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                const Text(
                  "Setup time",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 15,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          // _product!.setupDuration == 0
                          //     ? "Same day"
                          //     :
                          "${_product!.setupDuration}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- IMAGE SLIDER ----------------
  Widget _imageSlider() => SizedBox(
    height: 260,
    child: PageView.builder(
      itemCount: _product!.images.length,
      onPageChanged: (i) => setState(() => currentImage = i),
      itemBuilder: (_, i) => Image.network(
        _product!.images[i].image, //there is change by mohamed
        fit: BoxFit.contain,
        errorBuilder: (context, error, StackTrace) {
          return const Icon(Icons.broken_image, size: 50);
        },
      ),
    ),
  );

  Widget _imageDots() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(
      _product!.images.length,
      (i) => Container(
        margin: const EdgeInsets.all(4),
        width: currentImage == i ? 10 : 6,
        height: 6,
        decoration: BoxDecoration(
          color: currentImage == i ? Colors.blue : Colors.grey,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );

  // ---------------- SUPPLIER ----------------
  Widget _supplierCard(BuildContext context) {
    // ✅ جلب اسم المورد من supplierData
    String supplierName = ' '; // اسم افتراضي

    if (_product!.supplierData != null) {
      supplierName = _product!.supplierData!['company_name'] ?? ' ';
      print('🏢 Supplier from API: $supplierName');
    } else {
      print('⚠️ No supplier data available, using brand: $supplierName');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SupplierProfileScreen(
                supplierId: _product!.supplierId,
                supplierName: supplierName,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              // ✅ صورة المورد من supplierData
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey.shade200,
                child:
                    _product!.supplierData != null &&
                        _product!.supplierData!['company_image_url'] != null &&
                        _product!.supplierData!['company_image_url']
                            .toString()
                            .isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          _product!.supplierData!['company_image_url'],
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.business,
                              size: 30,
                              color: Colors.grey,
                            );
                          },
                        ),
                      )
                    : const Icon(Icons.business, size: 30, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplierName, // ✅ اسم المورد الحقيقي
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "$averageRating (${reviews.length} Reviews)",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- RENT / BUY SWITCH ----------------
  Widget _rentBuySwitch() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(children: [_switchItem("Rent", 0), _switchItem("Buy", 1)]),
      ),
    );
  }

  Widget _switchItem(String title, int index) => Expanded(
    child: GestureDetector(
      onTap: () => setState(() => selectedPurchase = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selectedPurchase == index ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: selectedPurchase == index ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  );

  // ---------------- RENT ----------------
  Widget _rentConfig() => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductInfo(),
        const SizedBox(height: 16),
        const Text(
          "Rental Period",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _dateBox("Start Date", true)),
            const SizedBox(width: 12),
            Expanded(child: _dateBox("End Date", false)),
          ],
        ),
        const SizedBox(height: 12),
        _buildQuantitySelector(),
        const SizedBox(height: 16),
        locationAndSetupTime(),
        const Divider(),
        _priceRow(
          "Daily Rent",
          "\$${_product!.dailyRent?.toStringAsFixed(2) ?? '0.00'}",
        ),

        // _priceRow("Security Deposit", "\$${(_product!.price * .2).toStringAsFixed(0)}"),
        // const SizedBox(height: 8),
        _priceRow(
          "Total Rent",
          "\$${(rentDays * rentQuantity * (_product!.dailyRent ?? 0.0)).toStringAsFixed(2)}",
          // rentDays == 0
          //     ? "\$0.00"
          //     : "\$${(rentDays * 50 + 200).toStringAsFixed(2)}",
          bold: true,
        ),
      ],
    ),
  );
  Widget _buildQuantitySelector() {
    return Row(
      children: [
        const Text('Quantity:'),
        const Spacer(),
        IconButton(
          onPressed: rentQuantity > 1
              ? () => setState(() => rentQuantity--)
              : null,
          icon: const Icon(Icons.remove),
        ),
        Text('$rentQuantity'),
        IconButton(
          onPressed: () => setState(() => rentQuantity++),
          icon: const Icon(Icons.add),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month, size: 18),
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
  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Configuration
        const Text(
          "Configuration",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            _product!.configuration == 0
                ? "No configuration"
                : "${_product!.configuration} ",

            style: const TextStyle(fontSize: 14),
          ),
        ),
        const SizedBox(height: 16),

        // Warranty
        const Text("Warranty", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            _product!.warranty == "0" || _product!.warranty.isEmpty
                ? "No warranty"
                : "${_product!.warranty} months",
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  // ---------------- BUY ----------------
  Widget _buyConfig() => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const Text(
        //   "Configuration",
        //   style: TextStyle(fontWeight: FontWeight.bold),
        // ),
        // const SizedBox(height: 8),
        // Container(
        //   width: double.infinity,
        //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        //   decoration: BoxDecoration(
        //     color: Colors.grey.shade100,
        //     borderRadius: BorderRadius.circular(12),
        //     border: Border.all(color: Colors.grey.shade300),
        //   ),
        //   child: Text(
        //     _product!.configuration == 0
        //         ? "No configuration"
        //         : "${_product!.configuration} ",

        //     style: const TextStyle(fontSize: 14),
        //   ),
        // ),

        // const SizedBox(height: 16),
        // const Text("Warranty", style: TextStyle(fontWeight: FontWeight.bold)),
        // const SizedBox(height: 8),
        // Container(
        //   width: double.infinity,
        //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        //   decoration: BoxDecoration(
        //     color: Colors.grey.shade100,
        //     borderRadius: BorderRadius.circular(12),
        //     border: Border.all(color: Colors.grey.shade300),
        //   ),
        //   child: Text(
        //     _product!.warranty == 0 || _product!.warranty.isEmpty
        //         ? "No warranty"
        //         : "${_product!.warranty} ",
        //     style: const TextStyle(fontSize: 14),
        //   ),
        // ),
        _buildProductInfo(),
        const SizedBox(height: 20),
        locationAndSetupTime(),
        const SizedBox(height: 20),
        _priceRow("Total Price", "\$${_product!.price}", bold: true),

        // if (_product!.stock > 0) ...[
        //   _priceRow("Total Stock", "\$${_product!.stock}", bold: true),
        // ],

        // في مكان عرض السعر أو فوق الزر
        // if (_product!.stock == 0)
        //   Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 16),
        //     child: Container(
        //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        //       decoration: BoxDecoration(
        //         color: Colors.red.shade100,
        //         borderRadius: BorderRadius.circular(12),
        //       ),
        //       child: const Row(
        //         mainAxisSize: MainAxisSize.min,
        //         children: [
        //           Icon(Icons.warning, color: Colors.red, size: 18),
        //           SizedBox(width: 8),
        //           Text(
        //             "Out of Stock",
        //             style: TextStyle(
        //               color: Colors.red,
        //               fontWeight: FontWeight.bold,
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        if (_product!.stock > 0 && _product!.stock < 10)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "⚠️ Only ${_product!.stock} left in stock!",
              style: const TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ),
      ],
    ),
  );

  // Widget _dropdown(
  //   String value,
  //   List<String> items,
  //   Function(String?) onChanged,
  // ) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 12),
  //     decoration: BoxDecoration(
  //       color: Colors.grey.shade200,
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: DropdownButton<String>(
  //       value: value,
  //       isExpanded: true,
  //       underline: const SizedBox(),
  //       items: items
  //           .map((e) => DropdownMenuItem(value: e, child: Text(e)))
  //           .toList(),
  //       onChanged: onChanged,
  //     ),
  //   );
  // }

  // ---------------- TABS ----------------
  Widget _tabs() => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [_tabItem("Specifications", 0), _tabItem("Reviews", 1)],
    ),
  );

  Widget _tabItem(String text, int index) => Expanded(
    child: GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: selectedTab == index ? Colors.blue : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            color: selectedTab == index ? Colors.blue : Colors.transparent,
          ),
        ],
      ),
    ),
  );

  // ---------------- SPECIFICATIONS ----------------
  List<Map<String, String>> _parseSpecifications() {
    List<Map<String, String>> result = [];

    for (var item in _product!.specification) {
      if (item is Map<String, dynamic>) {
        String name = item['name']?.toString() ?? '';
        String value = item['value']?.toString() ?? '';
        if (name.isNotEmpty && value.isNotEmpty) {
          result.add({'name': name, 'value': value});
        }
      }
    }

    return result;
  }

  Widget _specifications() => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        // المواصفات
        if (_product!.specification.isNotEmpty)
          ..._parseSpecifications().map((spec) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),

              child: Row(
                //crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${spec['name']}:",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  Text(
                    spec['value']!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }).toList()
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 70.0),
            child: const Text(
              "No specifications available",
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),

        // // باقي البيانات (الضمان، مدة التجهيز، الكمية)
        // if (_product!.warranty != '0') ...[
        //   const SizedBox(height: 8),
        //   _SpecRow("Warranty", "${_product!.warranty} months"),
        // ],

        // if (_product!.setupDuration > 0) ...[
        //   _SpecRow("Setup Duration", "${_product!.setupDuration} days"),
        // ],

        // if (_product!.stock > 0)
        //   _SpecRow("In Stock", "${_product!.stock} units")
        // else
        //   _SpecRow("Stock", "Out of Stock"),
      ],
    ),
  );
  // ---------------- REVIEWS ----------------
  Widget _reviewsSection() => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Average Rating
        Center(
          child: Column(
            children: [
              const Text(
                "Average Rating",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 6),
              Text(
                averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < averageRating.round() ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "based on ${reviews.length} reviews",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Reviews List (من API)
        if (reviews.isNotEmpty)
          ...reviews.map(
          
            (r) { 
              print('Review Url: ${r.profileImageUrl}');
              return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                        CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade200,
              child: r.profileImageUrl != null && r.profileImageUrl!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        r.profileImageUrl!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        cacheWidth: 80,
                        cacheHeight: 80,
                        errorBuilder: (context, error, stackTrace) {
                          print('❌ Image load error: $error');
                          return const Icon(Icons.person, size: 24, color: Colors.grey);
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                      ),
                    )
                  : const Icon(Icons.person, size: 24, color: Colors.grey),
            ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          r.doctorName ?? " ",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        "${r.createdAt.day}/${r.createdAt.month}/${r.createdAt.year}",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),

                      if (r.doctorId ==
                          ApiService.doctorId) // تقييم المستخدم الحالي
                        IconButton(
                          onPressed: () => _deleteReview(r),
                          icon: const Icon(
                            Icons.delete,
                            size: 18,
                            color: Colors.red,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < r.rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(r.comment),
                ],
              ),
            );
            },
          ).toList() 
        else
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text("No reviews yet", style: TextStyle(color: Colors.grey)),
          ),

        const SizedBox(height: 20),

        // Leave Review
        const Text(
          "Leave A Review",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(
            5,
            (i) => GestureDetector(
              onTap: () => setState(() => userRating = i + 1),
              child: Icon(
                i < userRating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: reviewController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Share Your Experience With This Product...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005EA6),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _submitReview,
            child: const Text(
              "Submit Review",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    ),
  );
  Future<void> _submitReview() async {
    if (reviewController.text.isEmpty || userRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a rating and comment')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await _apiService.addReview(
        productId: _product!.id,
        rating: userRating,
        comment: reviewController.text,
      );

      if (result['success'] == true) {
        // ✅ إضافة التقييم محلياً (أو إعادة تحميل المنتج)
        final newReview = Review(
          id: result['data']['id'], // Assuming the API returns the new review ID
          productId: _product!.id,
          doctorId: ApiService.doctorId ?? 0,
          rating: userRating,
          comment: reviewController.text,
          createdAt: DateTime.now(),
          doctorName: ApiService.doctorName ?? ' ',
          canDelete: true,
        );

        setState(() {
          _product = Product(
            // نسخ كل البيانات مع إضافة التقييم الجديد
            id: _product!.id,
            supplierId: _product!.supplierId,
            name: _product!.name,
            brand: _product!.brand,
            price: _product!.price,
            imagePath: _product!.imagePath,
            stock: _product!.stock,
            isRentable: _product!.isRentable,
            restockDate: _product!.restockDate,
            status: _product!.status,
            images: _product!.images,
            description: _product!.description,
            specification: _product!.specification,
            warranty: _product!.warranty,
            setupDuration: _product!.setupDuration,
            supplierData: _product!.supplierData,
            reviews: [newReview, ..._product!.reviews],
          );
          userRating = 0;
          reviewController.clear();
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully!')),
        );
      } else {
        throw result['error'] ?? 'Failed to submit review';
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception:', ''))),
      );
    }
  }

  Future<void> _deleteReview(Review review) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    setState(() => isLoading = true);

    try {
      final result = await _apiService.deleteReview(review.id);

      if (result['success'] == true) {
        // ✅ إزالة التقييم من القائمة محلياً
        setState(() {
          final updatedReviews = List<Review>.from(_product!.reviews);
          updatedReviews.removeWhere((r) => r.id == review.id);
          _product = Product(
            id: _product!.id,
            supplierId: _product!.supplierId,
            name: _product!.name,
            brand: _product!.brand,
            price: _product!.price,
            imagePath: _product!.imagePath,
            stock: _product!.stock,
            isRentable: _product!.isRentable,
            restockDate: _product!.restockDate,
            status: _product!.status,
            images: _product!.images,
            description: _product!.description,
            specification: _product!.specification,
            warranty: _product!.warranty,
            setupDuration: _product!.setupDuration,
            supplierData: _product!.supplierData,
            reviews: updatedReviews,
          );
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review deleted successfully!')),
        );
      } else {
        throw Exception(result['error'] ?? 'Failed to delete review');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception:', ''))),
      );
    }
  }

  // ---------------- ACTION BUTTON ----------------
  Widget _buildNotifyButton() {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final isNotified = notificationProvider.isNotified(_product!.id);
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isNotified
                ? Color.fromARGB(255, 238, 235, 235)
                : Colors.amber,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () async {
            if (isNotified) {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Cancel Notification'),
                  content: const Text(
                    'Are you sure you want to cancel this notification?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'Yes',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm != true) return;

              try {
                await _apiService.undoRestockNotification(_product!.id);
                notificationProvider.setNotified(_product!.id, false);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notification cancelled')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceAll('Exception:', '')),
                  ),
                );
              }
            } else {
              try {
                await _apiService.requestRestockNotification(_product!.id);
                notificationProvider.setNotified(_product!.id, true);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notification requested!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceAll('Exception:', '')),
                  ),
                );
              }
            }
          },
          child: Text(
            isNotified ? "Un Notify" : "Notify Me",
            style: TextStyle(
              color: isNotified ? Colors.red : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  final CartService _cartService = CartService();
  Widget _actionButton() {
     if (selectedPurchase == 0) {
    // ✅ Rent Now: يظهر لو isRentable == true و rentalStock > 0
    final bool canRent = _product!.isRentable && (_product!.rentalStock ?? 0) > 0;
    
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: canRent ? Colors.green : Colors.grey,
        ),
        onPressed: canRent ? _rentNow : null,
        child: Text(
          'Rent Now',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
// ✅ حالة Buy
  if (selectedPurchase == 1) {
    // ✅ Out of Stock (stock == 0 و restockDate == null)
    if (_product!.stock == 0 && _product!.restockDate == null) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: Colors.grey,
          ),
          onPressed: null,
          child: const Text(
            "Out of Stock",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    if (_product!.stock == 0 && _product!.restockDate != null) {
      return _buildNotifyButton();
    }
    // if (_product!.stock == 0 && _product!.restockDate == null) {
    //   return Padding(
    //     padding: const EdgeInsets.all(12),
    //     child: ElevatedButton(
    //       style: ElevatedButton.styleFrom(
    //         padding: const EdgeInsets.symmetric(vertical: 14),
    //         backgroundColor: Colors.grey,
    //       ),
    //       onPressed: null,
    //       child: const Text(
    //         "Out of Stock",
    //         style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    //       ),
    //     ),
    //   );
    // }
    
    return Padding(
      padding: const EdgeInsets.all(12),
      child:  ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor:
                     Colors.blue,
              ),

              onPressed:() async {
                      //there is change by mohamed
                      final result = await _cartService.addToCart(
                        productId: _product!.id,
                        quantity: 1,
                        type: "sale",
                      );

                      if (result['success'] != false) {
                        // ✅ ضيفه local برضو لو عايز
                        cartItemsGlobal.add(
                          CartItem(
                            daily_rent: 0,
                            name: _product!.name,
                            image: _product!.imagePath,
                            quantity: 1,
                            price: _product!.price,
                            type: 'sale',
                            dateRange: '',
                            id: _product!.id,
                            productId: _product!.id,
                          ),
                        );

                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     SnackBar(content: Text("${p.name} added to cart ✅")),
                        //   );
                        // } else { //there is change by mohamed
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     SnackBar(content: Text(result['message'] ?? "Error")),
                        //   );
                        // }

                        // SnackBar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Product added to cart 🛒"),
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
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result['message'] ?? "Error")),
                        );
                      }
                    },
              child: Text(
                "Add To Cart",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
         
              
  
    );
  }
   return const SizedBox.shrink();
  }
  
 
  

  // ---------------- HELPERS ----------------
  Widget _card({required Widget child}) => Padding(
    padding: const EdgeInsets.all(16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    ),
  );

  Widget _priceRow(String title, String value, {bool bold = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: TextStyle(
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ],
  );
}

// ---------------- SPEC ROW ----------------
// class _SpecRow extends StatelessWidget {    //////comment by mohamed
//   final String title;
//   final String value;

//   const _SpecRow(this.title, this.value);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(title, style: const TextStyle(color: Colors.grey)),
//           Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }
// }
