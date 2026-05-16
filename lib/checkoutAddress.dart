import 'package:flutter/material.dart';
import 'package:medconnect_app/cartScreen.dart';
import 'package:medconnect_app/checkoutSummary.dart';
import 'package:medconnect_app/homeScreen.dart';
import 'package:medconnect_app/models/rental_item.dart';
import 'package:medconnect_app/services/Get_Doctor_Profile.dart';

class CheckoutAddressPage extends StatefulWidget {

final bool isRentalMode;
  final RentalItem? rentalItem;



   final List<CartItem> ?cartItems;


  const CheckoutAddressPage({super.key
  , this.cartItems,
    this.isRentalMode = false,
    this.rentalItem,
  final List<CartItem> cartItems;

  const CheckoutAddressPage({
    super.key,
    required this.cartItems,
  });

  @override
  State<CheckoutAddressPage> createState() => _CheckoutAddressPageState();
}

class _CheckoutAddressPageState extends State<CheckoutAddressPage> {
  // متغيرات العنوان
  String address = '';
  String governorate = '';
  bool isLoading = true;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    loadAddress();
  }

  // جلب العنوان من الـ API
  Future<void> loadAddress() async {
    setState(() {
      isLoading = true;
    });

    final result = await GetDoctorProfile.doctorProfile();

    if (result['success']) {
      final data = result['data'];
      setState(() {
        address = data['address'] ?? '';
        governorate = data['governorate'] ?? '';
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to load address'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // تحديث العنوان
 // تحديث العنوان - ترجع true إذا نجحت، false إذا فشلت
// تحديث العنوان - ترجع Map تحتوي على success والرسالة
Future<Map<String, dynamic>> updateAddress(String newAddress) async {
  setState(() {
    isUpdating = true;
  });

  final result = await GetDoctorProfile.updateAddress(newAddress);

  setState(() {
    isUpdating = false;
  });

  if (result['success']) {
    setState(() {
      address = newAddress;
    });
    return {
      'success': true,
      'message': result['message'] ?? 'Address updated successfully',
    };
  } else {
    return {
      'success': false,
      'message': result['message'] ?? 'Failed to update address',
    };
  }
}


List<CartItem> get cartItemsForCheckout {
  if (widget.isRentalMode && widget.rentalItem != null) {
    return [
      CartItem(
        id: widget.rentalItem!.productId,
        name: widget.rentalItem!.name,
        image: widget.rentalItem!.image,
        quantity: widget.rentalItem!.quantity,
        price: widget.rentalItem!.price,
        type: 'rent',
        daily_rent: widget.rentalItem!.price / 30,
         productId: widget.rentalItem!.productId,
      ),
    ];
  }
  return widget.cartItems ?? cartItemsGlobal;
}





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CartPage()),
            );
          },
        ),
        title: const Text("Checkout", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepper(),
                  const SizedBox(height: 24),

                  const Text(
                    "Delivery Information",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckoutSummaryPage(
                        cartItems: cartItemsForCheckout,
                        subtotal: cartItemsForCheckout.fold(0.0, (sum, item) => sum + (item.price * item.quantity)),
                        taxes: 0.0,
                        total: 0.0,
                        selectedAddress: addresses[selectedAddress],
                        isRentablMode:widget.isRentalMode,
                        rentalItem:widget.rentalItem,
                     ),
                    )
                  );
                },
                child: const Text(
                  "Continue To Summary",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  // ---------------- STEP INDICATOR ----------------

  Widget _buildStepper() {
    return Row(
      children: [
        _step(true, 'Address', isBlueText: true),
        _line(true),
        _step(false, 'Summary'),
        _line(false),
        _step(false, 'Payment'),
      ],
    );
  }

  Widget _step(bool active, String title, {bool isBlueText = false}) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: active ? const Color(0xFF0D6EFD) : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isBlueText ? const Color(0xFF0D6EFD) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(bool active) {
    return const SizedBox(width: 8);
  }

  // ---------------- ADDRESS CARD (Single) ----------------

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(
          color: address.isNotEmpty ? const Color(0xFF0A4C8B) : Colors.grey.shade300,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.location_on, color: Color(0xFF0A4C8B)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Delivery Address",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  address.isEmpty ? "No address added yet" : address,
                  style: TextStyle(
                    color: address.isEmpty ? Colors.grey.shade500 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.edit,
              color: const Color(0xFF0A4C8B),
              size: 20,
            ),
            onPressed: () => _showEditAddressDialog(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // ---------------- EDIT ADDRESS DIALOG ----------------

  void _showEditAddressDialog() {
    final TextEditingController controller = TextEditingController(text: address);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Delivery Address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter your delivery address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF0A4C8B), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                  onPressed: () async {
  final newAddress = controller.text.trim();
  if (newAddress.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please enter an address"),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  setState(() {
    isUpdating = true;
  });

  final result = await updateAddress(newAddress); // result هي Map

  setState(() {
    isUpdating = false;
  });

  if (result['success']) {
    Navigator.pop(context); // إغلاق الديالوج
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']), // ✅ رسالة من الـ API
        backgroundColor: Colors.green,
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']), // ✅ رسالة من الـ API
        backgroundColor: Colors.red,
      ),
    );
  }
},
                    
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A4C8B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}