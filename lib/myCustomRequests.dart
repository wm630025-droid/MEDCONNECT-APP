import 'package:flutter/material.dart';
import 'package:medconnect_app/core/app_colorMycustom.dart';
import 'package:medconnect_app/customRequest.dart';
import 'package:medconnect_app/responseScreen.dart';
import 'package:medconnect_app/models/request_status.dart';
import 'package:medconnect_app/data/custom_request_store.dart';
import 'package:medconnect_app/acceptedSupplier.dart';


class MyCustomRequestsPage extends StatelessWidget {
 


  const MyCustomRequestsPage({super.key});
   


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF101C22)
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CustomRequestScreen(
                  requestType: "Tools",
                ),
              ),
            );
          },
        ),
        title: const Text("My Custom Requests"),
        centerTitle: true,
      ),
      body: ListView(
  padding: const EdgeInsets.all(16),
  children: [
    const _FilterDropdown(),
    const SizedBox(height: 16),

    // ✅ الكروت الجديدة (Open)
    ...myCustomRequests.map(
  (request) => InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SupplierBidsPage(),
        ),
      );
    },
    child: RequestCard(
      status: RequestStatus.open,
      statusColor: AppTheme.statusOpen,
      statusBg: AppTheme.statusOpenBg,
      title: request.products,
      description: request.description,
      budget: request.budget,
      created:
          "${request.createdOn.day}/${request.createdOn.month}/${request.createdOn.month}",
      expires:
          "${request.expiresOn.day}/${request.expiresOn.month}/${request.expiresOn.year}",
    ),
  ),
),


          InkWell(
  borderRadius: BorderRadius.circular(16),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>  SupplierBidsPage(),
      ),
    );
  },
  
  child: RequestCard(
     status: RequestStatus.open,
    statusColor: AppTheme.statusOpen,
    statusBg: AppTheme.statusOpenBg,
    title: [
      "Portable X-Ray Machine",
      "Surgical Mask N95 (Box of 50)",
    ],
    description:
        "Looking for a lightweight, mobile X-ray unit for emergency room use. Must be DICOM compatible.",
    budget: "\$15,000",
    created: "Jul 15, 2023",
    expires: "Aug 14, 2023",
    showNotification: true,
  ),
  ),
        
RequestCard(
           status: RequestStatus.cancelled,
            statusColor: AppTheme.statusCancelled,
            statusBg: AppTheme.statusCancelledBg,
            title: [
              "ECG Machine, 12-lead",
              "Ultrasound Probe Cover (100 pack)"
            ],
            description:
                "Need a portable ECG with interpretation software.",
            budget: "\$5,000",
            created: "Jul 05, 2023",
            expires: "Aug 04, 2023",
            cancelled: true,
          ),
         InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AcceptedSupplierDetailsPage(),
              ),
            );
          },
          child: RequestCard(
            status: RequestStatus.applied,
            statusColor: AppTheme.statusNegotiation,
            statusBg: AppTheme.statusNegotiationBg,
            title: ["Ventilator, ICU Grade"],
            description:
                "Requesting quotes for 5 units. Please include warranty and service options.",
            budget: "\$50,000",
            created: "Jul 12, 2023",
            expires: "Aug 11, 2023",
          ),
         ),
         InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AcceptedSupplierDetailsPage(),
              ),
            );
          },
          child:RequestCard(
            status: RequestStatus.shipped,
            statusColor: AppTheme.statusShipped,
            statusBg: AppTheme.statusShippedBg,
            title: ["Defibrillator Pads (10 packs)"],
            description: "No description provided.",
            budget: "No Budget",
            created: "Jul 10, 2023",
            expires: "Aug 09, 2023",
          ),
          ),
          InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AcceptedSupplierDetailsPage(),
              ),
            );
          },
         child: RequestCard(
            status: RequestStatus.delivered,
            statusColor: AppTheme.statusDelivered,
            statusBg: AppTheme.statusDeliveredBg,
            title: ["Anesthesia Machine"],
            description:
                "Model with advanced ventilation modes required.",
            budget: "\$22,000",
            created: "Jun 28, 2023",
            expires: "Jul 28, 2023",
          ),
          ),

          RequestCard(
            status: RequestStatus.expired,
            statusColor: AppTheme.statusExpired,
            statusBg: AppTheme.statusExpiredBg,
            title: ["Infusion Pumps (3 units)"],
            description: "No description provided.",
            budget: "No Budget",
            created: "May 20, 2023",
            expires: "Jun 19, 2023",
          ),
        ],
      ),
    );
  }
}
Widget requestActions(RequestStatus status) {
  switch (status) {
    case RequestStatus.open:
      return OutlinedButton(
        onPressed: () {
          // cancel logic
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
        ),
        child: const Text(
          "Cancel",
          style: TextStyle(color: Colors.red),
        ),
      );

    case RequestStatus.cancelled:
    case RequestStatus.delivered:
    case RequestStatus.expired:
      return Row(
        
        mainAxisSize: MainAxisSize.min,
        children: [
        const SizedBox(width: 4),
          OutlinedButton(
            onPressed: () {},
            child: const Text("Delete"),
          ),
          const SizedBox(width: 6),
          OutlinedButton(
  onPressed: () {},
  style: OutlinedButton.styleFrom(
     backgroundColor: AppTheme.primary,

    side: BorderSide(color: AppTheme.primary),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    ),
  ),
  child: Text(
    "Re-request",
    style: TextStyle(
      color:AppTheme.statusNegotiationBg,
      fontWeight: FontWeight.w600,
    ),
  ),
),
        ],
      );
        
    case RequestStatus.applied:
    case RequestStatus.shipped:
      return const SizedBox();
  }
  
}
class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown();

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.filter_list),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      value: "All",
      items: const [
        DropdownMenuItem(value: "All", child: Text("Filter by Status: All")),
        DropdownMenuItem(value: "Open", child: Text("Open")),
        DropdownMenuItem(value: "Applied", child: Text("Applied")),
        DropdownMenuItem(value: "Delivered", child: Text("Delivered")),
        DropdownMenuItem(value: "Cancelled", child: Text("Cancelled")),
      ],
      onChanged: (_) {},
    );
  }
}
class RequestCard extends StatelessWidget {
  final RequestStatus status;
  final Color statusColor;
  final Color statusBg;
  final List<String> title;
  final String description;
  final String budget;
  final String created;
  final String expires;
  final bool cancelled;
  final bool showNotification;

  const RequestCard({
    super.key,
    required this.status,
    required this.statusColor,
    required this.statusBg,
    required this.title,
    required this.description,
    required this.budget,
    required this.created,
    required this.expires,
    this.cancelled = false,
    this.showNotification = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = cancelled ? Colors.grey : null;

    return Opacity(
      opacity: cancelled ? 0.7 : 1,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Chip(
                    label: Text(status.name),
                    backgroundColor: statusBg,
                    labelStyle: TextStyle(color: statusColor),
                  ),
                  const Spacer(),
                  if (showNotification)
                    Stack(
                      children: const [
                        Icon(Icons.notifications, color: AppTheme.primary),
                        Positioned(
                          right: 0,
                          child: CircleAvatar(
                            radius: 7,
                            backgroundColor: Colors.red,
                            child: Text("3",
                                style: TextStyle(
                                    fontSize: 9, color: Colors.white)),
                          ),
                        )
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              ...title.map(
                (t) => Text(
                  t,
                  style: TextStyle(
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w600,
                    decoration:
                        cancelled ? TextDecoration.lineThrough : null,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(color: textColor),
              ),
              const SizedBox(height: 8),
              Text(
                "Budget: $budget",
                style: TextStyle(
                  fontFamily: "Inter",
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Created: $created\nExpires: $expires",
                      style: const TextStyle(fontSize: 12)),
                    
            requestActions(status), // الحالة بتاعة الكارد
                  
               ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
                     