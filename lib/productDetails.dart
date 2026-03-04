import 'package:flutter/material.dart';
import 'package:medconnect_app/cartScreen.dart';
import 'package:medconnect_app/models/product.dart';
import 'package:medconnect_app/homeScreen.dart';
import 'package:medconnect_app/supplierProfile.dart';

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
  final Product product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
  

}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int currentImage = 0;
  int selectedPurchase = 1; // 0 Rent - 1 Buy
  int selectedTab = 0;

  // -------- Rent --------
  DateTime? rentStartDate;
  DateTime? rentEndDate;

  // -------- Buy --------
  String selectedConfig = "Standard Unit";
  double get price {
    return selectedConfig == "Total price"
        ? widget.product.price
        : widget.product.price; // Example price difference
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

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Product Details",
            style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _imageSlider(),
            _imageDots(),
            const SizedBox(height: 8),

            _supplierCard(context),
            _rentBuySwitch(),

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

  // ---------------- IMAGE SLIDER ----------------
  Widget _imageSlider() => SizedBox(
        height: 260,
        child: PageView.builder(
          itemCount: widget.product.images.length,
          onPageChanged: (i) => setState(() => currentImage = i),
          itemBuilder: (_, i) => Image.asset(
            widget.product.images[i],
            fit: BoxFit.contain,
          ),
        ),
      );

  Widget _imageDots() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.product.images.length,
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
  Widget _supplierCard(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SupplierProfileScreen(),
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
            children: const [
              CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(Icons.business, color: Colors.white),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "MedEquip Solutions Inc.",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          "4.8 (120 Reviews)",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );

  
    

  // ---------------- RENT / BUY SWITCH ----------------
  Widget _rentBuySwitch() => Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              _switchItem("Rent", 0),
              _switchItem("Buy", 1),
            ],
          ),
        ),
      );

  Widget _switchItem(String title, int index) => Expanded(
        child: GestureDetector(
          onTap: () => setState(() => selectedPurchase = index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color:
                  selectedPurchase == index ? Colors.blue : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  color:
                      selectedPurchase == index ? Colors.white : Colors.black,
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
            const Text("Rental Period",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _dateBox("Start Date", true)),
                const SizedBox(width: 12),
                Expanded(child: _dateBox("End Date", false)),
              ],
            ),
            const SizedBox(height: 16),
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
            color: Colors.grey.shade200,
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
            const Text("Configuration",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _dropdown(
              selectedConfig,
              ["Standard Unit", "Advanced Unit"],
              (v) => setState(() => selectedConfig = v!),
            ),
            const SizedBox(height: 16),
            const Text("Warranty",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _dropdown(
              selectedWarranty,
              ["1-Year Standard Warranty", "2-Year Extended Warranty"],
              (v) => setState(() => selectedWarranty = v!),
            ),
            const SizedBox(height: 20),
            _priceRow("Total Price",  "\$${widget.product.price}", bold: true ),

          ],
        ),
      );

  Widget _dropdown(
      String value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  // ---------------- TABS ----------------
  Widget _tabs() => Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _tabItem("Specifications", 0),
            _tabItem("Reviews", 1),
          ],
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
                color:
                    selectedTab == index ? Colors.blue : Colors.transparent,
              ),
            ],
          ),
        ),
      );

  // ---------------- SPECIFICATIONS ----------------
  Widget _specifications() => _card(
        child: Column(
          children: const [
            _SpecRow("Dimensions", "296 × 209 × 81 mm"),
            _SpecRow("Weight", "2.5 kg"),
            _SpecRow("Power", "AC/DC + Battery"),
            _SpecRow("Display", "7-inch LCD"),
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
                const Text("Average Rating",
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 6),
                Text(
                  averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < averageRating.round()
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "based on ${reviews.length} reviews",
                  style:
                      const TextStyle(color: Colors.grey, fontSize: 12),
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
                       Image.asset(
                        "assets/images/doctorProfile.png",
                        height: 30,
                        width: 30,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          r.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        "${r.date.day}/${r.date.month}/${r.date.year}",
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < r.rating
                            ? Icons.star
                            : Icons.star_border,
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
          const Text("Leave A Review",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          Row(
            children: List.generate(
              5,
              (i) => GestureDetector(
                onTap: () =>
                    setState(() => userRating = i + 1),
                child: Icon(
                  i < userRating
                      ? Icons.star
                      : Icons.star_border,
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
              hintText:
                  "Share Your Experience With This Product...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF005EA6),
                padding:
                    const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                if (reviewController.text.isEmpty ||
                    userRating == 0) return;

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
              child: const Text("Submit Review",
                  style: TextStyle(color: Colors.white)),
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
      backgroundColor:
          selectedPurchase == 0 ? Colors.blue : Colors.blue,
    ),
   onPressed: () {
  cartItemsGlobal.add(
    CartItem(
      name: widget.product.name,
      image: widget.product.imagePath,
      quantity: 1,
      price: widget.product.price,
      type: selectedPurchase == 0 ? "rent" : "buy",
      dateRange: selectedPurchase == 0 ? "3 Days" : "",
      daily_rent: 50,
    ),
  );

  // 🟦 SnackBar
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
          // روح على صفحة الكارت
          Navigator.push(context, MaterialPageRoute(builder: (_) => CartPage()));
        },
          // روح على صفحة الكارت
          // Navigator.push(context, MaterialPageRoute(builder: (_) => CartScreen()));
        
      ),
    ),
  );
},
    child: Text(
      selectedPurchase == 0 ? "Rent Now" : "Add To Cart",
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
          Text(title,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
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
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
