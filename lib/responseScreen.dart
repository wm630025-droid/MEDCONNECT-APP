import 'package:flutter/material.dart';
import 'package:medconnect_app/acceptedSupplier.dart';
import 'package:medconnect_app/chatScreen.dart';
import 'package:medconnect_app/core/app_colorResponse.dart';
import 'package:medconnect_app/models/custom_request_model.dart';
import 'package:medconnect_app/models/offer_request.dart';
//import 'package:medconnect_app/models/offer_request.dart';
import 'package:medconnect_app/myCustomRequests.dart';
import 'package:medconnect_app/services/api_service.dart';
import 'package:medconnect_app/supplierProfile.dart';

class SupplierBidsPage extends StatefulWidget {
  final int customRequestId;
  final String customRequestBudget;
  final CustomRequest request;
  const SupplierBidsPage({super.key, required this.customRequestId , required this.customRequestBudget, required this.request});

  @override
  State<SupplierBidsPage> createState() => _SupplierBidsPageState();
}

class _SupplierBidsPageState extends State<SupplierBidsPage> {
  List<OfferRequest> _offers = [];
  bool _isLoading = true;
  String? _error;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final offers = await _apiService.getOfferRequests(widget.customRequestId);
      setState(() {
        _offers = offers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyCustomRequestsPage()),
            );
          },
        ),
        title: const Text("Supplier offers", overflow: TextOverflow.ellipsis),
        centerTitle: true,
        elevation: 0,
        
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadOffers,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _offers.isEmpty
          ? const Center(child: Text('No offers yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _offers.length,
              itemBuilder: (context, index) {
                return SupplierBidCard(
                  request: widget.request,
                  offer: _offers[index],
                  initiallyExpanded: index == 0,
                  customRequestBudget : widget.customRequestBudget
                );
              },
            ),
    );
  }
}

class SupplierBidCard extends StatefulWidget {
  final OfferRequest offer;
  final bool initiallyExpanded;
  final String customRequestBudget;
    final VoidCallback? onRejected;
    final CustomRequest request;

  const SupplierBidCard({
    super.key,
    required this.offer,
    this.initiallyExpanded = false,
    required this.customRequestBudget,
    this.onRejected, required this.request,
  });

  @override
  State<SupplierBidCard> createState() => _SupplierBidCardState();
}

class _SupplierBidCardState extends State<SupplierBidCard> {
 // bool _isRejected = false;
 // bool _isAccepted = false;
  @override
  // Widget build(BuildContext context) {
  //   final isPending = widget.offer.status.toLowerCase() == 'pending';
  //   final isCancelled = widget.offer.status.toLowerCase() == 'cancelled';
  //  // final isAccepted = widget.offer.status.toLowerCase() == 'accepted';
   
  //   return Card(
  //     margin: const EdgeInsets.only(bottom: 12),
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //     child: ExpansionTile(
  //       initiallyExpanded: widget.initiallyExpanded,
  //       tilePadding: const EdgeInsets.all(16),
  //       childrenPadding: const EdgeInsets.all(16),
  //       title: Row(
  //         children: [
  //           CircleAvatar(
  //             backgroundImage: widget.offer.supplier.companyImageUrl != null
  //                 ? NetworkImage(widget.offer.supplier.companyImageUrl!)
  //                 : null,
  //             child: widget.offer.supplier.companyImageUrl == null
  //                 ? const Icon(Icons.business)
  //                 : null,
  //             radius: 20,
  //           ),
  //           const SizedBox(width: 12),
  //           Expanded(
  //             child: Text(
  //               widget.offer.supplier.companyName,
  //               style: const TextStyle(fontWeight: FontWeight.w600),
  //             ),


              
  //           ),
  //         ],
  //       ),
  //       children: [
  //         if (widget.offer.notes != null)
  //           Container(
  //             padding: const EdgeInsets.all(12),
  //             decoration: BoxDecoration(
  //               color: Theme.of(context).brightness == Brightness.dark
  //                   ? Colors.grey.shade800
  //                   : Colors.grey.shade100,
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 const Text(
  //                   "Note from Supplier",
  //                   style: TextStyle(fontWeight: FontWeight.w600),
  //                 ),
  //                 const SizedBox(height: 4),
  //                 Text(widget.offer.notes!),
  //               ],
  //             ),
  //           ),
  //         const SizedBox(height: 12),
  //         _budgetRow("Delivery Days:", "${widget.offer.deliveryDays} days"),
  //         const SizedBox(height: 6),

  //         _budgetRow("Your Budget :",_formatBudget(widget.customRequestBudget)),
          
  //         _budgetRow(
  //           "Supplier's Bid :",
  //           "\$${widget.offer.price}",
  //           highlight: true,
  //         ),
  //         const SizedBox(height: 16),
  //         if (isPending) _pendingButtons(context),
  //         if (isAccepted) _acceptedButtons(),
  //         if (isCancelled) _cancelledButtons(),
  //       ],
  //     ),
  //   );
  // }
  Widget build(BuildContext context) {
    final isPending = widget.offer.status.toLowerCase() == 'pending';
    final isRejected = widget.offer.status.toLowerCase() == 'rejected';
    final isAccepted = widget.offer.status.toLowerCase() == 'accepted';

    // ✅ لو تم الرفض، نظهر الكارت عادي بس الأزرار تختفي وتظهر كلمة "REJECTED"
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        initiallyExpanded: widget.initiallyExpanded,
        tilePadding: const EdgeInsets.all(16),
        childrenPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.offer.supplier.companyImageUrl != null
                  ? NetworkImage(widget.offer.supplier.companyImageUrl!)
                  : null,
              radius: 20,
              child: widget.offer.supplier.companyImageUrl == null
                  ? const Icon(Icons.business)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.offer.supplier.companyName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (isAccepted)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "ACCEPTED",
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  if (isRejected)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "REJECTED",
                        style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        children: [
          if (widget.offer.notes != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Note from Supplier", style: TextStyle(fontWeight: FontWeight.w600)),
const SizedBox(height: 4),
                  Text(widget.offer.notes!,textAlign: TextAlign.left,),
                ],
              ),
            ),
          const SizedBox(height: 12),
          _budgetRow("Delivery Days:", "${widget.offer.deliveryDays} days"),
          const SizedBox(height: 6),
          _budgetRow("Your Budget:", _formatBudget(widget.customRequestBudget)),
          _budgetRow(
            "Supplier's offer:",
            "\$${widget.offer.price}",
            highlight: true,
          ),
          const SizedBox(height: 16),
          // ✅ الأزرار تختفي لو تم القبول أو الرفض
          if (isPending && !isAccepted && !isRejected) _pendingButtons(context),
         // if (isRejected) _rejectedButtons(),
          if (isAccepted) _acceptedButtons(),
        ],
      ),
    );
  }



  String _formatBudget(String budget) {
  if (budget == "No Budget") return budget;
  if (budget.startsWith('\$')) return budget;
  return "\$$budget";
  }

  // Widget _budgetRow(
  Widget _budgetRow(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: TextStyle(
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            fontSize: highlight ? 18 : 14,
            color: highlight ? AppColors.primary : null,
          ),
        ),
      ],
    );
  }

Widget _pendingButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              _rejectOffer(context);
              // TODO: رفض العرض
            },
            child: const Text("Decline"),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            
            onPressed: () {
              _navigateToProfile(context);// TODO: فتح شات مع المورد
            },
            child: const Text("Show profile",style: TextStyle (fontSize : 15,)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(onPressed: () {
              _acceptOffer(context);
              // TODO: قبول العرض
          //    _showAcceptDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text(
              "Accept",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
Future<void> _navigateToChat(BuildContext context) async {
  // ✅ اسم المورد (الشركة)
  final supplierName = widget.offer.supplier.companyName;
  //final supplierId = widget.offer.supplier.id; // ممكن نحتاجها في المستقبل
  // ✅ conversationId = offer.id (أو نحتاج نجيب conversationId من API)
  // بما إن الـ Chat يستخدم conversationId، نحتاج نجيبها
  // لكن مؤقتاً هنستخدم offer.id كـ conversationId
  //final conversationId = await ApiService().getConversationIdWithSupplier(supplierId); // أو نجيبها من API
  //if(conversationId != null){
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChatScreen(
        chatName: supplierName,
        conversationId: null,
        receiverId: widget.offer.supplier.id,
      ),
    ),
  );
// } else {
//   ScaffoldMessenger.of(context).showSnackBar(
//     const SnackBar(content: Text('No conversation found with this supplier')),
//   );
// }
}
  void _acceptOffer(BuildContext context) async {
    final shouldAccept = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Accept Offer'),
        content: const Text('Are you sure you want to accept this offer?\n\nOther offers will be automatically rejected.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Accept', style: TextStyle(color: Colors.green))),
        ],
      ),
    );
    if (shouldAccept != true) return;

    

    try {
      final apiService = ApiService();
      await apiService.respondToOffer(
        offerId: widget.offer.id,
        response: 'accepted',
      );
setState((){
      widget.offer.status = 'accepted';
    });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offer accepted successfully!')),
      );

      // ✅ الانتقال إلى صفحة المورد المقبول
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AcceptedSupplierDetailsPage(
            request: widget.request,
            offer: widget.offer,
            requestBudget: widget.customRequestBudget,
          ),
        ),
      );
    } catch (e) {
      //setState(() => _isAccepted = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception:', ''))),
      );
    }
  }
//   void _acceptOffer(BuildContext context) async {
//   final shouldAccept = await showDialog<bool>(
//     context: context,
//     builder: (ctx) => AlertDialog(
//       title: const Text('Accept Offer'),
//       content: const Text('Are you sure you want to accept this offer?\n\nOther offers will be automatically rejected.'),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(ctx, false),
//           child: const Text('Cancel'),
//         ),
//         TextButton(
//           onPressed: () => Navigator.pop(ctx, true),
//           child: const Text('Accept', style: TextStyle(color: Colors.green)),
//         ),
//       ],
//     ),
//   );

//   if (shouldAccept != true) return;

//   // إظهار مؤشر تحميل
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (ctx) => const Center(child: CircularProgressIndicator()),
//   );

//   try {
//     final apiService = ApiService();
//     final result = await apiService.respondToOffer(
//       offerId: widget.offer.id,
//       response: 'accepted',
//     );

//     // إغلاق مؤشر التحميل
//     Navigator.pop(context);

//     if (result['success'] == true) {
//       // ✅ تحديث واجهة العرض (إخفاء الأزرار)
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Offer accepted successfully!')),
//       );
      
//       // ✅ الذهاب لصفحة AcceptedSupplierDetails مع بيانات المورد
//       // Navigator.pushReplacement(
//       //   context,
//       //   MaterialPageRoute(
//       //     builder: (_) => AcceptedSupplierDetailsPage(
//       //       offer: offer,
//       //     ),
//       //   ),
//       // );
//     } else {
//       throw Exception(result['error'] ?? 'Failed to accept offer');
//     }
//   } catch (e) {
//     Navigator.pop(context); // إغلاق مؤشر التحميل لو كان مفتوح
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(e.toString().replaceAll('Exception:', ''))),
//     );
//   }
// }
 void _rejectOffer(BuildContext context) async {
    final shouldReject = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Offer'),
        content: const Text('Are you sure you want to reject this offer?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reject', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (shouldReject != true) return;

    try {
      final apiService = ApiService();
      await apiService.respondToOffer(
        offerId: widget.offer.id,
        response: 'rejected',
      );
      setState((){
      widget.offer.status = 'rejected';
    });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offer rejected')),
      );
    } catch (e) {
     // setState(() => _isRejected = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception:', ''))),
      );
    }
  }

// void _rejectOffer(BuildContext context) async {
//   final shouldReject = await showDialog<bool>(
//     context: context,
//     builder: (ctx) => AlertDialog(
//       title: const Text('Reject Offer'),
//       content: const Text('Are you sure you want to reject this offer?'),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(ctx, false),
//           child: const Text('Cancel'),
//         ),
//         TextButton(
//           onPressed: () => Navigator.pop(ctx, true),
//           child: const Text('Reject', style: TextStyle(color: Colors.red)),
//         ),
//       ],
//     ),
//   );

//   if (shouldReject != true) return;

//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (ctx) => const Center(child: CircularProgressIndicator()),
//   );

//   try {
//     final apiService = ApiService();
//     final result = await apiService.respondToOffer(
//       offerId: widget.offer.id,
//       response: 'rejected',
//     );

//     Navigator.pop(context);

//     if (result['success'] == true) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Offer rejected')),
//     );
//       // تحديث الحالة محلياً
//       // (يمكن إعادة تحميل الصفحة)
//     } else {
//       throw Exception(result['error'] ?? 'Failed to reject offer');
//     }
//   } catch (e) {
//     Navigator.pop(context);
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(e.toString().replaceAll('Exception:', ''))),
//     );
//   }
// }

  // void _showAcceptDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       title: const Text('Accept Offer'),
  //       content: const Text('Are you sure you want to accept this offer?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(ctx),
  //           child: const Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(ctx);
  //             // TODO: استدعاء API قبول العرض
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               const SnackBar(content: Text('Offer accepted!')),
  //             );
  //           },
  //           child: const Text('Accept', style: TextStyle(color: Colors.green)),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _acceptedButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text("Accepted", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
  
  void _navigateToProfile(BuildContext context) {
    final SupplierId= widget.offer.supplierId;
    final supplierName= widget.offer.supplier.companyName;
    Navigator.push(context, 
    
    MaterialPageRoute(builder: (_)=> SupplierProfileScreen(supplierId: SupplierId, supplierName: supplierName))
    );



  }

  // Widget _rejectedButtons() {
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: ElevatedButton(
  //           onPressed: null,
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: Colors.grey,
  //           ),
  //           child: const Text("Rejected", style: TextStyle(color: Colors.white)),
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
  // Widget _activeButtons(BuildContext context) {
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: OutlinedButton(onPressed: () {}, child: const Text("Cancel")),
  //       ),
  //       const SizedBox(width: 8),
  //       Expanded(
  //         child: OutlinedButton(onPressed: () {}, child: const Text("Chat")),
  //       ),
  //       const SizedBox(width: 8),
  //       Expanded(
  //         child: ElevatedButton(
  //           onPressed: () {
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (context) => const AcceptedSupplierDetailsPage(),
  //               ),
  //             );
  //           },
  //           style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),

  //           child: const Text("Accept", style: TextStyle(color: Colors.white)),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _cancelledButtons() {
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: OutlinedButton(
  //           onPressed: () {},
  //           style: OutlinedButton.styleFrom(
  //             foregroundColor: AppColors.cancelled,
  //           ),
  //           child: const Text("Cancel Offer"),
  //         ),
  //       ),
  //       const SizedBox(width: 8),
  //       Expanded(
  //         child: ElevatedButton(
  //           onPressed: null,
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: AppColors.cancelled,
  //           ),
  //           child: const Text("Offer Cancelled"),
  //         ),
  //       ),
  //     ],
  //   );
  // }

