import 'package:flutter/material.dart';
import 'package:medconnect_app/core/app_colorCustom.dart';
import 'package:medconnect_app/myCustomRequests.dart';
import 'package:medconnect_app/doctorAccount.dart';
import 'package:medconnect_app/models/custom_request_model.dart';
import 'package:medconnect_app/data/custom_request_store.dart';


class CustomRequestScreen extends StatefulWidget {

    final String requestType;

const CustomRequestScreen({super.key, required this.requestType});

  @override
  State<CustomRequestScreen> createState() => _CustomRequestScreenState();
}
final TextEditingController detailsController = TextEditingController();
final TextEditingController budgetController = TextEditingController();


class _CustomRequestScreenState extends State<CustomRequestScreen> {
  bool _validateForm() {
  if (products.isEmpty) {
    _showError("Please add at least one product");
    return false;
  }

  if (selectedDate == null) {
    _showError("Please select request expiry date");
    return false;
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



final List<String> products = [
    "ECG Machine, 12-channel",
    "Ultrasound Probe Cover (Pack of 100)",
  ];
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
                builder: (_) =>  doctorAccountPage(),
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
              "Request Expires On *",
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

            // ---------- ATTACH ----------

            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.attach_file),
              ),
              title: const Text("Attach Files"),
              trailing: const Icon(Icons.chevron_right),

             onTap: ()  {},


            ),
            const SizedBox(height: 80),
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
          onPressed: () {
  if (!_validateForm()) return;

  final newRequest = CustomRequestModel(
    type: widget.requestType,
    products: List.from(products),
    description: detailsController.text.isEmpty
        ? "No description provided."
        : detailsController.text,
    budget: budgetController.text.isEmpty
        ? "No Budget"
        : "\$${budgetController.text}",
    createdOn: DateTime.now(),
    expiresOn: selectedDate!,
  );

  myCustomRequests.insert(0, newRequest);

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const MyCustomRequestsPage(),
    ),
  );
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
