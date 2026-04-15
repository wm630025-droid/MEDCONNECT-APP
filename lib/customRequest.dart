import 'package:flutter/material.dart';
import 'package:medconnect_app/core/app_colorCustom.dart';
import 'package:medconnect_app/myCustomRequests.dart';
import 'package:medconnect_app/doctorProfile.dart';
import 'package:medconnect_app/models/custom_request_model.dart';
//import 'package:medconnect_app/data/custom_request_store.dart';
import 'package:medconnect_app/services/api_service.dart';


class CustomRequestScreen extends StatefulWidget {

    final String requestType;

const CustomRequestScreen({super.key, required this.requestType});

  @override
  State<CustomRequestScreen> createState() => _CustomRequestScreenState();
}
final TextEditingController detailsController = TextEditingController();
final TextEditingController budgetController = TextEditingController();


class _CustomRequestScreenState extends State<CustomRequestScreen> {



  final ApiService _apiService = ApiService();
  bool _validateForm() {
  if (products.isEmpty) {
    _showError("Please add at least one product");
    return false;
  }

  if (selectedDate == null) {
    _showError("Please select request expiry date");
    return false;
  }
  
  if (widget.requestType == "Rent devices") {
    if (rentalStartDate == null) {
      _showError("Please select rental start date");
      return false;
    }
    if (rentalEndDate == null) {
      _showError("Please select rental end date");
      return false;
    }
    if (rentalEndDate!.isBefore(rentalStartDate!)) {
      _showError("End date must be after start date");
      return false;
    }
  }


  return true;
}
void _showError(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.redAccent,
    ),
  );
}



final List<String> products = [];
  final TextEditingController 
productController = TextEditingController();

DateTime? rentalStartDate;
DateTime? rentalEndDate;
DateTime? selectedDate; // دي Request Expires On

Widget datePickerField({
  required String label,
  required DateTime? value,
  required VoidCallback onTap,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // TYPE BADGE
           


      Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today),
              const SizedBox(width: 8),
              Text(
                value == null
                    ? "mm/dd/yyyy"
                    : "${value.year}/${value.month}/${value.day}",
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const doctorProfilePage(),
              ),
            
            );
          }
        ),
        title: const Text(
          "Custom Request",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      // ---------- BODY ----------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "Type : ${widget.requestType}",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "Can't find what you're looking for? Describe your needs below, and suppliers will get in touch with you.",
              style: TextStyle(color: AppColors.textPrimary),
            ),

            const SizedBox(height: 20),
           
            // ---------- PRODUCTS LIST ----------
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Products List",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 12),

                  ...products.map(
                    (item) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(item)),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: AppColors.textSecondary),
                            onPressed: () {
                              setState(() {
                  products.remove(item);
                                });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,

                    children: [
                      Expanded(
                        child: TextField(
                    controller: productController,
                decoration: InputDecoration(
                 hintText: "Enter product name *",
                   border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
               ),
             ),
           ),
                      ),

                      const SizedBox(width: 8),
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                             ),
                             padding: EdgeInsets.zero,
                          ),
                          onPressed: () {
                            if (productController.text.trim().isEmpty) return;

                             setState(() {
                            products.add(productController.text.trim());
                           productController.clear();
                           });
                          },
                          child: const Icon(Icons.add,
                          color: Colors.white,
                          ),

                        ),
                      )
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ---------- DETAILS ----------
            const Text(
              "Additional Details",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: detailsController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Describe specifications, quantity, etc...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ---------- BUDGET ----------
            const Text(
              "Optional Budget",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: budgetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: "USD ",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),
             if (widget.requestType == "Rent devices") ...[
  Row(
    children: [
      Expanded(
        child: datePickerField(
          label: "Rental Start Date",
          value: rentalStartDate,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
              initialDate: DateTime.now(),
            );
            
            if (date != null) {
              setState(() {
                rentalStartDate = date;
                if(rentalEndDate != null && rentalEndDate!.isBefore(date)){
                  rentalEndDate = null;
                }
              });
            }
          },
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: datePickerField(
          label: "Rental End Date",
          value: rentalEndDate,
          onTap: () async {

            if(rentalStartDate==null){
              _showError('please select start date first');
              return;
            }
            final date = await showDatePicker(
              context: context,
              firstDate: rentalStartDate ?? DateTime.now(),
              lastDate: DateTime(2100),
              initialDate: rentalStartDate ?? DateTime.now(),
            );
            if (date != null) {
              setState(() {
                rentalEndDate = date;
              });
            }
          },
        ),
      ),
    ],
  ),
  const SizedBox(height: 20),
],
          

            
            // ---------- DATE ----------
            const Text(
              "Request Expires Date *",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => selectedDate = date);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderLight),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 8),
                    Text(
                      selectedDate == null
                          ? "Select a date"
                          : "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      // ---------- FOOTER ----------
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
onPressed: () async {
  if (!_validateForm()) return;

  
String _formatDateForPrint(DateTime date) {
  return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}
  print ('-------------------------------------');
  print('📤 Sending rental dates:');
print('   Start Date (raw): $rentalStartDate');
print('   End Date (raw): $rentalEndDate');

if (rentalStartDate != null && rentalEndDate != null) {
  print('   Start Date (formatted): ${_formatDateForPrint(rentalStartDate!)}');
  print('   End Date (formatted): ${_formatDateForPrint(rentalEndDate!)}');
  print('   Is after or equal? ${rentalEndDate!.isAfter(rentalStartDate!) || rentalEndDate!.isAtSameMomentAs(rentalStartDate!)}');
}

String formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
  String _getRequestTypeForApi(String requestType) {
  switch (requestType.toLowerCase()) {
    case 'rent devices':
    case 'rental':
      return 'rental';
    case 'tools':
      return 'tools';
    case 'paid devices':
      return 'paid devices';
    default:
      return 'tools'; // default
  }
}
  // ✅ استخدام الموديل الموحد
  final request = CustomRequest(
    id: 0, // مؤقت، لأن API هو اللي هيولده
    doctorId: 0, // مؤقت
    type: _getRequestTypeForApi(widget.requestType),
    item: List.from(products),
    expiresAt: formatDate(selectedDate!),
    rentStartDate: widget.requestType == "Rent devices" && rentalStartDate != null
        ? formatDate(rentalStartDate!)
        : null,
    rentEndDate: widget.requestType == "Rent devices" && rentalEndDate != null
        ? formatDate(rentalEndDate!)
        : null,
    status: 'open', // مؤقت
    additionalDetails: detailsController.text.isEmpty ? null : detailsController.text,
    budget: budgetController.text.isEmpty ? null : budgetController.text,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
// بعد ما تعملي final request = ...
print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
print('📦 Full Request Body:');
print('   type: ${request.type}');
print('   item: ${request.item}');
print('   expires_at: ${request.expiresAt}');
print('   rent_start_date: ${request.rentStartDate}');
print('   rent_end_date: ${request.rentEndDate}');
print('   additionalDetails: ${request.additionalDetails}');
print('   budget: ${request.budget}');
print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  try {
    final createdRequest = await _apiService.createCustomRequest(request);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request posted successfully!')),
    );
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => MyCustomRequestsPage()),
    );
  } catch (e) {
    _showError(e.toString());
  }
},

          child: const Text(
            "Post Request",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
