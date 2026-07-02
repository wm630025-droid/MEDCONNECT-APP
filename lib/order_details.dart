import 'package:flutter/material.dart';
import 'package:medconnect_app/models/order_model.dart';
import 'package:medconnect_app/services/order_services.dart';
import 'package:medconnect_app/shimmerSkeleton.dart';

class OrderDetailsPage extends StatefulWidget {
  final int orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  // في بداية الـ State
  String selectedIssue = "None";

  final List<String> issueTypes = [
    "None",
    "Late delivery",
    "wrong product",
    "payment dispute",
    "quality complaint",
  ];
  late Future<Order> orderFuture;
  bool _isCancelling = false;

 Future<void> _cancelOrder(Order order) async {
  final status = order.status.toLowerCase();

  // يسمح فقط بـ pending أو confirmed
  if (status != 'pending' && status != 'confirmed') {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Cancellation only available for Pending or Confirmed status orders.',
        ),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  try {
    setState(() {
      _isCancelling = true;
    });

    // ✅ لو المستخدم اختار سبب إلغاء، نحدّثه في الـ API قبل الإلغاء
    if (selectedIssue != "None" && selectedIssue.isNotEmpty) {
      final assignResult = await OrderServices.assignOrderIssue(
        orderId: order.id,
        orderIssue: selectedIssue,
      );

      if (assignResult['success'] != true) {
        throw Exception(assignResult['message'] ?? 'Failed to assign issue');
      }
    }

    // ✅ ثانياً: إلغاء الطلب
    final result = await OrderServices.cancelDoctorOrder(widget.orderId);
    print(result);

    // اعمل refresh للبيانات
    setState(() {
      orderFuture = OrderServices.fetchDoctorOrder(widget.orderId);
    });

    // اعرض رسالة النجاح
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? 'Order cancelled successfully'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          e.toString().replaceAll('Exception: ', ''),
        ),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    setState(() {
      _isCancelling = false;
    });
  }
}

 @override
void initState() {
  super.initState();
  orderFuture = OrderServices.fetchDoctorOrder(widget.orderId).then((order) {
    setState(() {
      selectedIssue = order.orderIssue.isNotEmpty ? order.orderIssue : "None";
    });
    return order;
  });
}

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3A7DFF);
    const backgroundColor = Color(0xFFF8F9FA);
    const textColor = Color(0xFF333333);
    const secondaryText = Color(0xFF617C89);
    const outlineColor = Color(0xFFE0E0E0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // ================= Bottom Navigation =================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 10, bottom: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFF1F1F1))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _bottomItem(
              icon: Icons.medical_services_outlined,
              title: "Shop",
              selected: false,
            ),
            _bottomItem(
              icon: Icons.inventory_2,
              title: "Orders",
              selected: true,
            ),
            _bottomItem(
              icon: Icons.monitor_heart_outlined,
              title: "Health",
              selected: false,
            ),
            _bottomItem(
              icon: Icons.person_outline,
              title: "Profile",
              selected: false,
            ),
          ],
        ),
      ),

      body: FutureBuilder<Order>(
        future: orderFuture,
        builder: (context, snapshot) {
         

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
  return _buildSkeletonLoader();
}
if (!snapshot.hasData) {
  return const Center(child: Text('No order found'));
}
          final order = snapshot.data!;
          final isOrderCancelled =
              order.status.toLowerCase() == 'cancelled'; // ✅ هنا

          selectedIssue = order.orderIssue;
          print("ORDER ID: ${order.id}");
          for (var item in order.items) {
            print("ITEM ORDER ID: ${item.orderId}");
          }
          print(order.items.length);
          return SafeArea(
            child: Column(
              children: [
                // ================= App Bar =================
                Container(
                  height: 65,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFEAEAEA)),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: primaryColor,
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),

                      const Spacer(),
                      const Text(
                        "Secure Access",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 24),
                    ],
                  ),
                ),

                // ================= Body =================
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ================= Title =================
                        const Text(
                          "Order Details",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),

                        const SizedBox(height: 4),

                        const Text(
                          "Managing clinical supply procurement",
                          style: TextStyle(fontSize: 14, color: secondaryText),
                        ),

                        const SizedBox(height: 18),

                        // ================= Status =================
                       Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 18,
    vertical: 10,
  ),
  decoration: BoxDecoration(
    color: Colors.white, // خلفية بيضاء
    borderRadius: BorderRadius.circular(50),
    border: Border.all(
      color: order.status.toLowerCase() == 'confirmed'
          ? Colors.green // اخضر للحواف
          : order.status.toLowerCase() == 'cancelled'
          ? Colors.red // احمر للحواف
          : Colors.orange, // برتقالي للحواف
      width: 1.5,
    ),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const SizedBox(width: 8),
      Text(
        order.status.toUpperCase(), // تحويل إلى uppercase
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          color: order.status.toLowerCase() == 'confirmed'
              ? Colors.green
              : order.status.toLowerCase() == 'cancelled'
              ? Colors.red
              : Colors.orange,
        ),
      ),
      const SizedBox(width: 8),
    ],
  ),
),

                        const SizedBox(height: 28),

                        // ================= Invoice Card =================
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: outlineColor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "INVOICE NUMBER",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                  color: secondaryText,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                order.invoiceNumber.isNotEmpty == true
                                    ? order.invoiceNumber
                                    : "N/A",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: primaryColor,
                                ),
                              ),

                              const SizedBox(height: 24),

                              Divider(color: Colors.grey.shade300),

                              const SizedBox(height: 20),

                              Row(
                                children: [
                                  Expanded(
                                    child: _infoItem(
                                      icon: Icons.calendar_today_outlined,
                                      title: "ORDER DATE",
                                      value:
                                          "${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}",
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: _infoItem(
                                      icon: Icons.update,
                                      title: "UPDATED AT",
                                      value:
                                          "${order.updatedAt.day}/${order.updatedAt.month}/${order.updatedAt.year}",
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ================= Financial Card =================
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(.35),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: -40,
                                bottom: -40,
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(.08),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "FINANCIAL OVERVIEW",
                                    style: TextStyle(
                                      fontSize: 11,
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white.withOpacity(.7),
                                    ),
                                  ),

                                  const SizedBox(height: 28),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Subtotal",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text(
                                        "\$${order.subtotal}",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 18),

                                  Divider(color: Colors.white.withOpacity(.25)),

                                  const SizedBox(height: 18),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Total Amount",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text(
                                        "\$${order.total}",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 34),

                        // ================= Order Items Title =================
                        Row(
                          children: const [
                            Icon(
                              Icons.inventory_2_outlined,
                              color: secondaryText,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "ORDER ITEMS",
                              style: TextStyle(
                                fontSize: 15,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w700,
                                color: secondaryText,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // ================= Product Card =================
                        if (order.items.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: outlineColor),
                            ),
                            child: const Center(
                              child: Text(
                                "No items found",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: secondaryText,
                                ),
                              ),
                            ),
                          )
                        else
                          Column(
                            children: order.items.map((item) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(color: outlineColor),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name.isNotEmpty == true
                                          ? item.name
                                          : "Unnamed Product",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: textColor,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    Text(
                                      item.description.isNotEmpty == true
                                          ? item.description
                                          : "No description available",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: secondaryText,
                                      ),
                                    ),

                                    const SizedBox(height: 18),

                                    Row(
                                      children: [
                                        _smallTag(
                                          title: "QTY",
                                          value: "${item.quantity.toString()}",
                                        ),

                                        const SizedBox(width: 16),

                                        _smallTag(
                                          title: "UNIT",
                                          value:
                                              "\$${item.unitPrice.toStringAsFixed(2)}",
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 50),

                        // ================= Assign Issue =================
                        const Text(
                          "ASSIGN ISSUE",
                          style: TextStyle(
                            fontSize: 15,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                            color: secondaryText,
                          ),
                        ),

                        const SizedBox(height: 18),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            color: isOrderCancelled
                                ? Colors.grey.shade50
                                : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isOrderCancelled
                                  ? Colors.grey.shade300
                                  : outlineColor,
                            ),
                          ),
                          child: isOrderCancelled
                              ? // ✅ إذا كان الطلب ملغي، عرض نص ثابت
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.block,
                                        size: 20,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        "Not available for cancelled orders",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedIssue,
                                    isExpanded: true,
                                    items: issueTypes.map((issue) {
                                      return DropdownMenuItem(
                                        value: issue,
                                        child: Text(
                                          issue,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontStyle: FontStyle.italic,
                                            color: textColor,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) async {
                                      if (value == null) return;

                                      try {
                                        final result =
                                            await OrderServices.assignOrderIssue(
                                              orderId: order.id,
                                              orderIssue: value,
                                            );

                                        setState(() {
                                          selectedIssue = value;
                                          Duration(seconds: 1);
                                          orderFuture =
                                              OrderServices.fetchDoctorOrder(
                                                widget.orderId,
                                              );
                                        });

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              result['message'] ??
                                                  'Issue assigned successfully',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(e.toString()),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                        ),

                        const SizedBox(height: 38),

                        // ================= Actions =================
                        const Text(
                          "ACTIONS",
                          style: TextStyle(
                            fontSize: 15,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                            color: secondaryText,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ✅ حالات مختلفة للأزرار
                        if (order.status.toLowerCase() == 'cancelled')
                          // زر معطل - ملغي
                          Container(
                            height: 64,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.block,
                                    color: Colors.grey.shade500,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Order Cancelled",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (order.status.toLowerCase() == 'delivered' ||
                            order.status.toLowerCase() == 'completed')
                          // زر معطل - تم التوصيل
                          Container(
                            height: 64,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green.shade600,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Order Completed",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.green.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          // زر الإلغاء النشط
                          GestureDetector(
                            onTap: _isCancelling
                                ? null
                                : () => _cancelOrder(order),
                            child: Container(
                              height: 64,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 77, 80, 255),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Center(
                                child: _isCancelling
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          
                                          const SizedBox(width: 10),
                                          const Text(
                                            "Cancel Order",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 14),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= Bottom Item =================
  Widget _bottomItem({
    required IconData icon,
    required String title,
    required bool selected,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFEAF1FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: selected ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: selected
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF94A3B8),
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ================= Info Item =================
  Widget _infoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF617C89)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: Color(0xFF617C89),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  // ================= Small Tag =================
  Widget _smallTag({required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: Color(0xFF617C89),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }
  // ================= Skeleton Loader =================
  Widget _buildSkeletonLoader() {
    return SafeArea(
      child: Column(
        children: [
          // App Bar placeholder
          Container(
            height: 65,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFEAEAEA))),
            ),
            child: Row(
              children: [
                const Icon(Icons.arrow_back, color: Color(0xFF3A7DFF), size: 30),
                const Spacer(),
                const Text(
                  "Secure Access",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 24),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title placeholder
                  const ShimmerSkeleton(width: 160, height: 24),
                  const SizedBox(height: 8),
                  const ShimmerSkeleton(width: 220, height: 14),

                  const SizedBox(height: 18),

                  // Status badge placeholder
                  const ShimmerSkeleton(
                    width: 120,
                    height: 34,
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),

                  const SizedBox(height: 28),

                  // Invoice card placeholder
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ShimmerSkeleton(width: 130, height: 12),
                        const SizedBox(height: 12),
                        const ShimmerSkeleton(width: 180, height: 22),
                        const SizedBox(height: 24),
                        Divider(color: Colors.grey.shade300),
                        const SizedBox(height: 20),
                        Row(
                          children: const [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ShimmerSkeleton(width: 90, height: 11),
                                  SizedBox(height: 10),
                                  ShimmerSkeleton(width: 80, height: 17),
                                ],
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ShimmerSkeleton(width: 90, height: 11),
                                  SizedBox(height: 10),
                                  ShimmerSkeleton(width: 80, height: 17),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Financial overview placeholder
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ShimmerSkeleton(width: 150, height: 11),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            ShimmerSkeleton(width: 70, height: 18),
                            ShimmerSkeleton(width: 60, height: 18),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Divider(color: Colors.grey.shade300),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            ShimmerSkeleton(width: 90, height: 18),
                            ShimmerSkeleton(width: 100, height: 32),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 34),

                  // Order items title placeholder
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          color: Colors.grey.shade400),
                      const SizedBox(width: 10),
                      const ShimmerSkeleton(width: 120, height: 14),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Item cards placeholder (x2)
                  ...List.generate(
                    2,
                    (index) => Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ShimmerSkeleton(width: 180, height: 20),
                          const SizedBox(height: 8),
                          const ShimmerSkeleton(width: double.infinity, height: 14),
                          const SizedBox(height: 4),
                          const ShimmerSkeleton(width: 140, height: 14),
                          const SizedBox(height: 18),
                          Row(
                            children: const [
                              ShimmerSkeleton(width: 70, height: 34),
                              SizedBox(width: 16),
                              ShimmerSkeleton(width: 80, height: 34),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Assign issue placeholder
                  const ShimmerSkeleton(width: 110, height: 14),
                  const SizedBox(height: 18),
                  ShimmerSkeleton(
                    width: double.infinity,
                    height: 56,
                    borderRadius: BorderRadius.circular(18),
                  ),

                  const SizedBox(height: 38),

                  // Actions placeholder
                  const ShimmerSkeleton(width: 90, height: 14),
                  const SizedBox(height: 18),
                  ShimmerSkeleton(
                    width: double.infinity,
                    height: 64,
                    borderRadius: BorderRadius.circular(18),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
