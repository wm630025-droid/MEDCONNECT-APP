import 'package:flutter/material.dart';
import 'package:medconnect_app/core/app_colorMycustom.dart';
//import 'package:medconnect_app/customRequest.dart';
import 'package:medconnect_app/doctorProfile.dart';
import 'package:medconnect_app/models/custom_request_model.dart';
import 'package:medconnect_app/responseScreen.dart';

import 'package:medconnect_app/acceptedSupplier.dart';
import 'package:medconnect_app/services/api_service.dart';

class MyCustomRequestsPage extends StatefulWidget {
  const MyCustomRequestsPage({super.key});

  @override
  State<MyCustomRequestsPage> createState() => _MyCustomRequestsPageState();
}

class _MyCustomRequestsPageState extends State<MyCustomRequestsPage> {
  List<CustomRequest> _requests = [];
  bool _isLoading = true;
  String? _error;
  String _currentFilter = 'All';
  final ApiService _apiService = ApiService();
  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  // Future<void> _loadRequests() async {
  //   setState(() {
  //     _isLoading = true;
  //     _error = null;
  //   });

  //   try {
  //     final requests = await _apiService.getCustomRequests(
  //       page: 1,
  //       perPage: 50,
  //       status: _currentFilter == 'All' ? 'all' : _currentFilter.toLowerCase(),
  //     );

  //     if (result['success'] == true) {
  //       final List<dynamic> data = result['data'];
  //       setState(() {
  //         _requests = data.map((json) => CustomRequestResponse.fromJson(json)).toList();
  //         _isLoading = false;
  //       });
  //     } else {
  //       throw Exception(result['message'] ?? 'Failed to load requests');
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _error = e.toString();
  //       _isLoading = false;
  //     });
  //   }
  //}
  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final requests = await _apiService.getCustomRequests(
        status: _currentFilter == 'All' ? 'all' : _currentFilter.toLowerCase(),
      );

      setState(() {
        _requests = requests;
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
                builder: (context) => const doctorProfilePage(
                  //  requestType: "Tools",
                ),
              ),
            );
          },
        ),
        title: const Text("My Custom Requests"),
        centerTitle: true,
      ),
      body: Column(
      children: [
        // ✅ الفلتر دايماً موجود في الأعلى (حتى لو مفيش بيانات)
        _buildFilterDropdown(),
        
        // ✅ باقي المحتوى (تحميل، خطأ، أو قائمة)
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_error!),
                          SizedBox(height: 10,),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blueAccent,

                            ),

                            onPressed: _loadRequests,
                            child: const Text(
                              'Retry',
                             // style: TextStyle(color: Colors.blueAccent ),
                              ),
                          ),
                        ],
                      ),
                    )
                  : _requests.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.inbox, size: 80, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                'No ${_currentFilter == 'All' ? '' : _currentFilter} requests found',
                                style: const TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _currentFilter = 'All';
                                    _loadRequests();
                                  });
                                },
                                child: const Text(
                                  'Show all requests',
                                  style: TextStyle(color: Colors.blueAccent ),
                                  ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _requests.length,
                          itemBuilder: (context, index) {
                            return _buildRequestCard(_requests[index]);
                          },
                        ),
        ),
      ],
    ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButton<String>(
        value: _currentFilter,
        isExpanded: true,
        underline: const SizedBox(),

        items: const [
          DropdownMenuItem(value: "All", child: Text("filter by Status: All")),
          DropdownMenuItem(value: "open", child: Text("open")),
          DropdownMenuItem(value: "in negotiation", child: Text("In negotiation")),
          DropdownMenuItem(value: "Delivered", child: Text("Delivered")),
          DropdownMenuItem(value: "Cancelled", child: Text("Cancelled")),
          DropdownMenuItem(value: "Expired", child: Text("Expired")),
        ],

        onChanged: (value) {
          if (value != null && value != _currentFilter) {
            setState(() {
              _currentFilter = value;
              _loadRequests();
            });
          }
        },
      ),
    );
  }

  Widget _buildRequestCard(CustomRequest request) {
    final isOpen = request.status.toLowerCase() == 'open';
    final isInNegotiation = request.status.toLowerCase() == 'in negotiation';
    final isShipped = request.status.toLowerCase() == 'shipped';
    final isDelivered = request.status.toLowerCase() == 'delivered';
    final isCancelled = request.status.toLowerCase() == 'cancelled';
    final isExpired = request.status.toLowerCase() == 'expired';

    final showNotification = isOpen;
    final showDelete = isDelivered || isCancelled || isExpired;
    final showReRequest = isCancelled || isExpired || isDelivered;
    final showCancelButton = isOpen;
    final isCardClickable = isInNegotiation || isDelivered || isShipped;

    return GestureDetector(
      onTap: isCardClickable
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AcceptedSupplierDetailsPage(),
                ),
              );
            }
          : null,

      child: Opacity(
        opacity: isCancelled || isExpired ? 0.5 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Status and Notification Icon
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildStatusChip(request.status),
                    const Spacer(),
                    if (showNotification)
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SupplierBidsPage(
                                customRequestId: request.id
                              ),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            const Icon(
                              Icons.notifications,
                              color: Color(0xFF0066FF),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),

                                child: const Text(
                                  "3",
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Product Items
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: request.item
                      .map(
                        (item) => Text(
                          item,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            decoration: isCancelled ? TextDecoration.lineThrough : null,
                           // color: isCancelled ? Colors.grey : Colors.black,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

              // Description
              if (request.additionalDetails != null &&
                  request.additionalDetails!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    request.additionalDetails!,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
                SizedBox(height: 15,),
              // Budget
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Budget: ${request.budget ?? 'No Budget'}",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                     decoration: isCancelled ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),

              // Dates
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Created: ${_formatDate(request.createdAt)}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            "Expires: ${_formatDateString(request.expiresAt)}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showCancelButton)
                          SizedBox(
                            width: 100,
                            height: 40,
                            child: 
                             OutlinedButton(
                              onPressed: () {
                                // TODO: إلغاء الطلب
                                _cancelRequest(request);
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),

                          ),

                        if (showCancelButton && (showDelete || showReRequest))
                          const SizedBox(width: 8),
                        if (showDelete)
                          SizedBox(
                             width: 100,
                          height: 40,
                            child: OutlinedButton(
                              onPressed: () {
                                // TODO: حذف الطلب
                                _deleteRequest(request);
                              },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text("Delete"),
                            ),
                          ),
                        SizedBox(width: 5),
                        if (showReRequest)
                          SizedBox(
                             width: 120,
                          height: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: إعادة الطلب
                                // _reRequest(request);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0066FF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Re-request",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'open':
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color.fromARGB(255, 22, 100, 179);
        break;
      case 'in negotiation':
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFF57C00);
        break;
      case 'shipped':
        bgColor = const Color.fromARGB(255, 248, 150, 252);
        textColor = const Color.fromARGB(255, 152, 66, 156);
        break;
      case 'delivered':
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        break;
      case 'cancelled':
        bgColor = const Color.fromARGB(255, 198, 223, 245);
        textColor = const Color.fromARGB(255, 129, 155, 239);
        break;
      case 'expired':
        bgColor = const Color(0xFFF5F5F5);
        textColor = const Color(0xFF9E9E9E);
        break;
      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
    }
    String Capitalize(String status) {
      if (status.isEmpty) return status;
      return status[0].toUpperCase() + status.substring(1).toLowerCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        Capitalize(status),
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  String _formatDateString(String dateStr) {
    final date = DateTime.parse(dateStr);
    return "${date.day}/${date.month}/${date.year}";
  }

  // void _showCancelDialog(CustomRequest request) {
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       title: const Text('Cancel Request'),
  //       content: const Text('Are you sure you want to cancel this request?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(ctx),
  //           child: const Text('No'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(ctx);
  //             // TODO: استدعاء API الإلغاء
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               const SnackBar(content: Text('Request cancelled')),
  //             );
  //           },
  //           child: const Text('Yes', style: TextStyle(color: Colors.red)),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Future<void> _cancelRequest(CustomRequest request) async {
  final shouldCancel = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Cancel Request'),
      content: const Text('Are you sure you want to cancel this request?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Yes', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  if (shouldCancel != true) return;

  setState(() => _isLoading = true);

  try {
    final result = await _apiService.cancelCustomRequest(request.id);
    
    if (result['success'] == true) {
      // ✅ تحديث الحالة محلياً
      setState(() {
        final index = _requests.indexWhere((r) => r.id == request.id);
        if (index != -1) {
          _requests[index] = CustomRequest(
            id: request.id,
            doctorId: request.doctorId,
            type: request.type,
            item: request.item,
            expiresAt: request.expiresAt,
            rentStartDate: request.rentStartDate,
            rentEndDate: request.rentEndDate,
            status: 'cancelled',
            additionalDetails: request.additionalDetails,
            budget: request.budget,
            createdAt: request.createdAt,
            updatedAt: DateTime.now(),
          );
        }
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request cancelled successfully')),
      );
    } else {
      throw Exception(result['error'] ?? 'Failed to cancel');
    }
  } catch (e) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString().replaceAll('Exception:', ''))),
    );
  }
}

  // void _deleteRequest(CustomRequest request) {
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       title: const Text('Delete Request'),
  //       content: const Text('Are you sure you want to delete this request?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(ctx),
  //           child: const Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(ctx);
  //             // TODO: استدعاء API الحذف
  //             setState(() {
  //               _requests.remove(request);
  //             });
  //             ScaffoldMessenger.of(
  //               context,
  //             ).showSnackBar(const SnackBar(content: Text('Request deleted')));
  //           },
  //           child: const Text('Delete', style: TextStyle(color: Colors.red)),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Future<void> _deleteRequest(CustomRequest request) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete Request'),
      content: const Text('Are you sure you want to permanently delete this request?'),
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

  setState(() => _isLoading = true);

  try {
    final result = await _apiService.deleteCustomRequest(request.id);
    
    if (result['success'] == true) {
      // ✅ حذف من القائمة محلياً
      setState(() {
        _requests.removeWhere((r) => r.id == request.id);
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request deleted permanently')),
      );
    } else {
      throw Exception(result['error'] ?? 'Failed to delete');
    }
  } catch (e) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString().replaceAll('Exception:', ''))),
    );
  }
}

  // void _reRequest(CustomRequest request) {
  //   // TODO: فتح شاشة CustomRequestScreen مع بيانات الطلب القديم
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('Re-request feature coming soon')),
  //   );
  // }
}

