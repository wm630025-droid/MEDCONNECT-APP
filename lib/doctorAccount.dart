import 'package:flutter/material.dart';
//import 'package:medconnect_app/acceptedSupplier.dart';
import 'package:medconnect_app/customRequest.dart';
import 'package:medconnect_app/mainScreen.dart';
import 'package:medconnect_app/massegesScreen.dart';
import 'package:medconnect_app/myCustomRequests.dart';
import 'package:medconnect_app/core/app_colorDoctor.dart';
import 'package:medconnect_app/doctorProfile.dart';
import 'package:medconnect_app/models/order_model.dart';
import 'package:medconnect_app/order_details.dart';
import 'package:medconnect_app/services/order_services.dart';
import 'package:medconnect_app/services/Get_doctor_profile.dart';
//import 'package:medconnect_app/Screens/homeScreen.dart';
import 'package:shimmer/shimmer.dart';

 
 @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home:  doctorAccountPage(),
    );
  }

// ================= COLORS =================


// ================= SCREEN =================
class doctorAccountPage extends StatefulWidget {
  
   doctorAccountPage({super.key});


  @override
  State<doctorAccountPage> createState() => _doctorAccountPageState();
}
class _doctorAccountPageState extends State<doctorAccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
     // bottomNavigationBar: const BottomNavBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            DashboardHeader(
            
            ),
            const RecentOrdersSection(),
            const OldChatsSection(),
            const CustomRequestsSection(requestType: "", selectedType: "",),
          ],
        ),
      ),
    );
  }
}

// ================= HEADER =================
class DashboardHeader extends StatefulWidget {
  const DashboardHeader({super.key});

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  String doctorFullName = 'Doctor';

  @override
  void initState() {
    super.initState();
    _loadDoctorName();
  }

  Future<void> _loadDoctorName() async {
    final result = await GetDoctorProfile.doctorProfile();
    if (result['success']) {
      final fullname = result['data']['fullname'] ?? 'Doctor';
      setState(() {
        doctorFullName = fullname;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 30),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainScreen(),
                    ),
                  );
                },
              ),
              CircleAvatar(
                radius: 22,
                  backgroundColor: Colors.grey[300],
                  // backgroundImage: const NetworkImage(
                  //   'https://cdn-icons-png.flaticon.com/512/149/149071.png',
                  // ),
                child: IconButton(
                  icon: const Icon(Icons.person, color: Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DoctorProfilePage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Good morning, $doctorFullName!',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}





class ReorderCard extends StatelessWidget {
  final String title, price, imageUrl;

  const ReorderCard({
    super.key,
    required this.title,
    required this.price,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(imageUrl,
                height: 140, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(price, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(.1),
                    foregroundColor: AppColors.primary,
                  ),
                  onPressed: () {},
                  child: const Text("Re-order"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= RECENT ORDERS =================
class RecentOrdersSection extends StatelessWidget {
  const RecentOrdersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return sectionCard(
      title: "Recent Orders",
      child: Column(
        children: [
          const OrderRow(
            "Order #11234",
            "EKG Machine",
            "\$3,500",
            "Delivered",
            Colors.green,
          ),
          const Divider(),

          const OrderRow(
            "Order #11233",
            "Defibrillator",
            "\$2,800",
            "Shipped",
            Colors.orange,
          ),
          const Divider(),

          const OrderRow(
            "Order #11232",
            "Surgical Kit",
            "\$850",
            "Processing",
            Colors.grey,
          ),

          const SizedBox(height: 12),

          // 🔵 View All Orders Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AllOrdersScreen(),
                  ),
                );
              },
              child: const Text(
                "View All Orders",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class OrderRow extends StatelessWidget {
  final String id, item, price, status;
  final Color statusColor;

  const OrderRow(this.id, this.item, this.price, this.status, this.statusColor,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(id, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(item),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(price, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(status, style: TextStyle(color: statusColor)),
        ],
      ),
    );
  }
}

class AllOrdersScreen extends StatefulWidget {
  const AllOrdersScreen({super.key});

  @override
  State<AllOrdersScreen> createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> {
  List<Order> _orders = [];
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoading = false;
  bool _hasLoadedOnce = false;
  String? _errorMessage; // متغير لتخزين رسالة الخطأ

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _refreshOrders() async {
    setState(() {
      _orders = [];
      _currentPage = 1;
      _lastPage = 1;
      _hasLoadedOnce = false;
      _errorMessage = null;
    });
    await _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final result = await OrderServices.fetchDoctorOrders(
        page: _currentPage,
        perPage: 5,
      );

      // التحقق من صحة النتيجة
      if (result.containsKey('orders') && result['orders'] is List) {
        setState(() {
          _orders.addAll(result['orders'] as List<Order>);
          _lastPage = result['lastPage'] ?? 1;
          _hasLoadedOnce = true;
          _errorMessage = null;
        });
      } else {
        throw Exception('Invalid response structure');
      }
    } catch (e) {
      print('Error loading orders: $e');
      setState(() {
        _hasLoadedOnce = true;
        _errorMessage = 'Failed to load orders. Please try again.';
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || _currentPage >= _lastPage) return;

    setState(() {
      _isLoading = true;
    });

    final nextPage = _currentPage + 1;
    try {
      final result = await OrderServices.fetchDoctorOrders(
        page: nextPage,
        perPage: 5,
      );

      if (result.containsKey('orders') && result['orders'] is List) {
        setState(() {
          _orders.addAll(result['orders'] as List<Order>);
          _currentPage = nextPage;
          _lastPage = result['lastPage'] ?? _lastPage;
          _isLoading = false;
        });
      } else {
        throw Exception('Invalid response structure');
      }
    } catch (e) {
      print('Error loading more: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load more orders: $e')),
        );
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No date';
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Orders',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshOrders,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (!_hasLoadedOnce) {
    // عرض 3 بطاقات شيمر أثناء التحميل الأولي
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => _buildOrderShimmer(),
    );
  }
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshOrders,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_orders.isEmpty) {
      return const Center(child: Text('No orders found.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        // عنصر "View More" في النهاية
        if (index == _orders.length) {
          if (_currentPage >= _lastPage) {
            return const SizedBox.shrink();
          }
          return Center(
            child: TextButton(
              onPressed: _isLoading ? null : _loadMore,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('View More'),
            ),
          );
        }

        final order = _orders[index];
        final productNames = order.items.isNotEmpty
            ? order.items.map((item) => item.name).join(', ')
            : 'No item details';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderDetailsPage(orderId: order.id),
              ),
            ).then((_) {
              // تحديث البيانات عند العودة
              _refreshOrders();
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8)
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.invoiceNumber.isNotEmpty
                          ? order.invoiceNumber
                          : 'Order #${order.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      order.status,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: order.status.toLowerCase() == 'confirmed'
                            ? Colors.green
                            : order.status.toLowerCase() == 'cancelled' ||
                                    order.status.toLowerCase() == 'canceled'
                                ? Colors.red
                                : Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: ${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Type: ${order.orderType}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Name: $productNames',
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Date: ${_formatDate(order.createdAt)}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'Items: ${order.items.length}',
                  style: const TextStyle(color: Colors.blue),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _buildOrderShimmer() {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
    ),
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShimmerSkeleton(width: 100, height: 16, borderRadius: BorderRadius.circular(4)),
            ShimmerSkeleton(width: 60, height: 16, borderRadius: BorderRadius.circular(4)),
          ],
        ),
        const SizedBox(height: 8),
        ShimmerSkeleton(width: double.infinity, height: 14, borderRadius: BorderRadius.circular(4)),
        const SizedBox(height: 4),
        ShimmerSkeleton(width: 120, height: 14, borderRadius: BorderRadius.circular(4)),
        const SizedBox(height: 4),
        ShimmerSkeleton(width: 200, height: 14, borderRadius: BorderRadius.circular(4)),
        const SizedBox(height: 4),
        ShimmerSkeleton(width: 150, height: 14, borderRadius: BorderRadius.circular(4)),
        const SizedBox(height: 8),
        ShimmerSkeleton(width: 80, height: 14, borderRadius: BorderRadius.circular(4)),
      ],
    ),
  );
}
}

class ShimmerSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;
  const ShimmerSkeleton({super.key, required this.width, required this.height, this.borderRadius = const BorderRadius.all(Radius.circular(12))});
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      period: const Duration(milliseconds: 1200),
      child: Container(width: width, height: height, decoration: BoxDecoration(color: Colors.white, borderRadius: borderRadius)),
    );
  }
}

// ================= DISCOUNTS =================


// ================= SAVED LISTS =================


// ================= CHATS =================
class OldChatsSection extends StatelessWidget {
  const OldChatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        sectionCard(
          title: "Old Chats with Vendors",
          child: Column(
            children: [
              ListTile(
            
            leading: const Icon(Icons.forum),
            title: const Text("Medtronic Rep",
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text("Re: Anesthesia Machine"),
            trailing: const Text("2d ago"),
            
          ),
          const SizedBox(height: 8),
            ]
          ),
        ),
              // 🔵 View All chats Button
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                       Navigator.push(context, MaterialPageRoute(
                         builder: (_) => MessagesScreen(),
                       ));
                    },
                    child: const Text(
                      "View All Chats",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
        
            ],
        
           
        
      
    );
  }
}

// ================= CUSTOM REQUESTS =================
class CustomRequestsSection extends StatelessWidget {
    final String requestType;
    final String selectedType;

  const CustomRequestsSection({super.key, required this.requestType,required this.selectedType});


  void showCustomRequestOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _optionItem(
              title: "Rent devices",
              onTap: () {
                Navigator.pop(ctx); // اقفل الـ bottom sheet
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomRequestScreen(
                      requestType: "Rent devices",
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _optionItem(
              title: "Tools",
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomRequestScreen(
                      requestType: "Tools",
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _optionItem(
              title: "Buy devices",
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomRequestScreen(
                      requestType: "Buy devices",
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}


  Widget _optionItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // الكارد الأبيض
        sectionCard(
          title: "Custom Requests",
          child: ListTile(
            leading: const Icon(Icons.edit_note),
            title: const Text(
              "Request #CR-004",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text("3 quotes received"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MyCustomRequestsPage(),
                ),
              );
            },
            trailing: const Text(
              "Manage",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12), // المسافة اللي في الصورة

        // الزر الأزرق لوحده
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: () {
           showCustomRequestOptions(context);
          if (selectedType.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CustomRequestScreen(requestType: selectedType),

                ),

              );
            };
            },
            icon: const Icon(Icons.add),
            label: const Text("Make A New Custom Request",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )),
          ),
        ),
      ],
    );
  }
}

// ================= BOTTOM NAV =================
// class BottomNavBar extends StatelessWidget {
//   const BottomNavBar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       currentIndex: 0,
//       selectedItemColor: AppColors.primary,
//       unselectedItemColor: AppColors.textSecondary,
//       items: const [
//         BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//         BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Orders"),
//         BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Messages"),
//         BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
//       ],
//     );
//   }
//}

// ================= HELPERS =================
Widget sectionTitle(String text) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(text,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    );

Widget sectionCard({required String title, required Widget child}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8)
              ],
            ),
            child: child,
          ),
        ],
      ),
    );
