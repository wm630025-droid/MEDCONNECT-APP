import 'package:flutter/material.dart';
import 'package:medconnect_app/cartScreen.dart';
import 'package:medconnect_app/models/product.dart';
import 'package:medconnect_app/homeScreen.dart';
import 'package:medconnect_app/services/api_service.dart';
import 'package:medconnect_app/supplierProfile.dart';
import 'package:provider/provider.dart';
import '../providers/wishlist_provider.dart';

// Global cart items list

// ---------------- MODELS ----------------
class Review {
  final String name;
  final String comment;
  final int rating;
  final DateTime date;

  Review({
    required this.name,
    required this.comment,
    required this.rating,
    required this.date,
  });
}

// ---------------- PAGE ----------------
class ProductDetailsPage extends StatefulWidget {
  final int productId;
  final Product? product;
  const ProductDetailsPage({super.key, required this.productId, this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int currentImage = 0;
  int selectedPurchase = 1; // 0 Rent - 1 Buy
  int selectedTab = 0;
  Product? _product;
  bool _isLoading = true;
  String? _error;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    // لو المنتج جاي من HomeScreen (مش محتاج API)
    if (widget.product != null) {
      setState(() {
        _product = widget.product;
        _isLoading = false;
      });
    }

    // // لو محتاجين نجيب من API
    // setState(() {
    //   _isLoading = true;
    //   _error = null;
    // });
    print(" product config : ${_product!.configuration}");
    try {
      final freshproduct = await _apiService.fetchProductById(widget.productId);
      setState(() {
        _product = freshproduct;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // -------- Rent --------
  DateTime? rentStartDate;
  DateTime? rentEndDate;

  // -------- Buy --------
  String selectedConfig = "Standard Unit";
  double get price {
    return selectedConfig == "Total price"
        ? _product!.price
        : _product!.price; // Example price difference
  }

  String selectedWarranty = "1-Year Standard Warranty";

  // -------- Reviews --------
  double get averageRating {
    if (reviews.isEmpty) return 0;
    return reviews.fold<int>(0, (s, r) => s + r.rating) / reviews.length;
  }

  int userRating = 0;
  final TextEditingController reviewController = TextEditingController();

  List<Review> reviews = [
    Review(
      name: "Dr. Ahmed",
      comment: "High quality and very reliable.",
      rating: 5,
      date: DateTime.now(),
    ),
  ];

  int get rentDays {
    if (rentStartDate == null || rentEndDate == null) return 0;
    return rentEndDate!.difference(rentStartDate!).inDays + 1;
  }

  bool isInWishlist = false;
  bool isInEquipmentList = false;
  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    f(_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Product Details")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Product Details")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProduct,
                child: const Text('Retry'),
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
    final wishlistProvider = Provider.of<WishlistProvider>(
      context,
      listen: true,
    );
    final isInWishlist = wishlistProvider.isInWishlist(_product!.id);
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
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          wishlistProvider.toggleWishlist(_product!.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                wishlistProvider.isInWishlist(_product!.id)
                                    ? "Added to wishlist"
                                    : "Removed from wishlist",
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: Icon(
                          isInWishlist ? Icons.favorite : Icons.favorite_border,
                          color: isInWishlist ? Colors.red : Colors.black,
                        ),
                        label: Text(
                          "Wishlist",
                          style: TextStyle(
                            color: isInWishlist ? Colors.red : Colors.black,
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(
                            () => isInEquipmentList = !isInEquipmentList,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isInEquipmentList
                                    ? "Added to equipment list"
                                    : "Removed from equipment list",
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.bookmark_border,
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
                          "Main Clinic",
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
        _product!.images[i],
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
    String supplierName = 'xxxxxx'; // اسم افتراضي

    if (_product!.supplierData != null) {
      supplierName = _product!.supplierData!['company_name'] ?? 'xxxxxx';
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
                        const Text(
                          "4.8 (120 Reviews)",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
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
        const SizedBox(height: 16),
        locationAndSetupTime(),
        const Divider(),
        _priceRow("Daily Rate", "\$50 / Day"),
        _priceRow("Security Deposit", "\$200"),
        const SizedBox(height: 8),
        _priceRow(
          "Total Rent",
          rentDays == 0
              ? "\$0.00"
              : "\$${(rentDays * 50 + 200).toStringAsFixed(2)}",
          bold: true,
        ),
      ],
    ),
  );

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

  // ---------------- BUY ----------------
  Widget _buyConfig() => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            _product!.warranty == 0 || _product!.warranty.isEmpty
                ? "No warranty"
                : "${_product!.warranty} ",
            style: const TextStyle(fontSize: 14),
          ),
        ),
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
          const Text(
            "No specifications available",
            style: TextStyle(color: Colors.grey),
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
        // ---------- Average Rating ----------
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

        // ---------- Reviews List ----------
        ...reviews.map(
          (r) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 6),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      "assets/images/doctorProfile.png",
                      height: 30,
                      width: 30,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        r.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      "${r.date.day}/${r.date.month}/${r.date.year}",
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
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
          ),
        ),

        const SizedBox(height: 20),

        // ---------- Leave Review ----------
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
            onPressed: () {
              if (reviewController.text.isEmpty || userRating == 0) return;

              setState(() {
                reviews.insert(
                  0,
                  Review(
                    name: "You",
                    comment: reviewController.text,
                    rating: userRating,
                    date: DateTime.now(),
                  ),
                );
                reviewController.clear();
                userRating = 0;
              });
            },
            child: const Text(
              "Submit Review",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    ),
  );

  // ---------------- ACTION BUTTON ----------------
  Widget _actionButton() => Padding(
    padding: const EdgeInsets.all(12),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        backgroundColor: _product!.stock == 0
            ? Colors.grey
            : (selectedPurchase == 0 ? Colors.green : Colors.blue),
      ),
      onPressed: _product!.stock == 0
          ? null // disabled
          : () {
              // إضافة للمنتج
              cartItemsGlobal.add(
                CartItem(
                  name: _product!.name,
                  image: _product!.imagePath,
                  quantity: 1,
                  price: _product!.price,
                  type: selectedPurchase == 0 ? "rent" : "buy",
                  dateRange: selectedPurchase == 0 ? "3 Days" : "",
                  daily_rent: 50,
                ),
              );

              // SnackBar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    selectedPurchase == 0
                        ? "Product added for rent 🛒"
                        : "Product added to cart 🛒",
                  ),
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
            },
      child: Text(
        _product!.stock == 0
            ? "Out of Stock"
            : (_product!.stock == 0 && _product!.restockDate != null
                  ? "Notify Me"
                  : (selectedPurchase == 0 ? "Rent Now" : "Add To Cart")),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );

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
class _SpecRow extends StatelessWidget {
  final String title;
  final String value;

  const _SpecRow(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
