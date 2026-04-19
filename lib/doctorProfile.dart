import 'package:flutter/material.dart';
//import 'package:medconnect_app/acceptedSupplier.dart';
import 'package:medconnect_app/customRequest.dart';
import 'package:medconnect_app/mainScreen.dart';
import 'package:medconnect_app/massegesScreen.dart';
import 'package:medconnect_app/myCustomRequests.dart';
import 'package:medconnect_app/core/app_colorDoctor.dart';
//import 'package:medconnect_app/homeScreen.dart';

 
 @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: AppColors.bgLight,
        useMaterial3: true,
      ),
      home: const doctorProfilePage(),
    );
  }

// ================= COLORS =================


// ================= SCREEN =================
class doctorProfilePage extends StatelessWidget {
  const doctorProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     // bottomNavigationBar: const BottomNavBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 120),
          children: const [
            DashboardHeader(),
            RecentOrdersSection(),
            DiscountsSection(),
            SavedListsTile(),
            OldChatsSection(),
            CustomRequestsSection(requestType: "", selectedType: "",),
          ],
        ),
      ),
    );
  }
}

// ================= HEADER =================
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

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
                backgroundColor: AppColors.secondary.withOpacity(.2),
                child: const Icon(Icons.person),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Good morning, Dr. Emily",
            style: TextStyle(
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
                // TODO: Navigate to All Orders Screen
                // Navigator.push(context, MaterialPageRoute(
                //   builder: (_) => const AllOrdersScreen(),
                // ));
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

// ================= DISCOUNTS =================
class DiscountsSection extends StatelessWidget {
  const DiscountsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return sectionCard(
      title: "Discounts For You",
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.sell, color: AppColors.secondary),
        ),
        title: const Text("15% off on GE Healthcare",
            style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: const Text("Expires in 5 days"),
        trailing: const Text("Apply",
            style: TextStyle(
                color: AppColors.primary, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ================= SAVED LISTS =================
class SavedListsTile extends StatelessWidget {
  const SavedListsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return sectionCard(
      title: "My Saved Lists",
      child: ListTile(
        leading: const Icon(Icons.list_alt),
        title: const Text("2 Total Saved Lists",
            style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: const Text("Tap to view your lists"),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

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
