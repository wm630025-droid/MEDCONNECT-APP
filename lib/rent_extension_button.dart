import 'package:flutter/material.dart';
import 'package:medconnect_app/services/order_services.dart';
import 'package:medconnect_app/models/order_model.dart';
import 'package:medconnect_app/wep_app.dart';

class RentExtensionButton extends StatefulWidget {
  final int orderId;
  final DateTime rentStartDate;
  final DateTime rentEndDate;
  final bool isDelivered; // ✅ جديد - بيحدد لو الطلب اتأكد
  final ExtendRentInfo? extendRentInfo; // ✅ جديد - بيجي من الـ API مباشرة
  final int maxRentalDays;
  final VoidCallback? onExtended;

  const RentExtensionButton({
    super.key,
    required this.orderId,
    required this.rentStartDate,
    required this.rentEndDate,
    required this.isDelivered,
    this.extendRentInfo,
    this.maxRentalDays = 10,
    this.onExtended,
  });

  @override
  State<RentExtensionButton> createState() => _RentExtensionButtonState();
}

class _RentExtensionButtonState extends State<RentExtensionButton> {
  bool _loading = false;

  int get _rentedDays =>
      widget.rentEndDate.difference(widget.rentStartDate).inDays + 1;

  int get _remainingExtendableDays =>
      (widget.maxRentalDays - _rentedDays).clamp(0, widget.maxRentalDays);

  bool get _isWithinExtendWindow {
    final deadline = widget.rentEndDate.subtract(const Duration(days: 2));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDay = DateTime(deadline.year, deadline.month, deadline.day);
    return !today.isAfter(deadlineDay);
  }

  // ✅ هل فيه extend_rent record أصلاً (سواء pending أو خلص)؟
  bool get _hasActiveExtend => widget.extendRentInfo != null;

  // ✅ هل الدفع لسه معلق؟
  bool get _isExtendPending =>
      widget.extendRentInfo != null &&
      widget.extendRentInfo!.status.toLowerCase() == 'pending';

  // ✅ هل الإيجار اتمد فعلاً ونجح الدفع؟
  bool get _isExtendCompleted =>
      widget.extendRentInfo != null &&
      widget.extendRentInfo!.status.toLowerCase() != 'pending';

  bool get _canExtend =>
      widget.isDelivered &&
      !_hasActiveExtend && // ✅ يمنع لو فيه أي extend record أصلاً
      _remainingExtendableDays > 0 &&
      _isWithinExtendWindow;

  String get _disabledReason {
    if (!widget.isDelivered) return "Available once the product is delivered";
    if (_isExtendPending) {
      return "An extension payment is pending for this item.";
    }
    if (_isExtendCompleted) {
      return "You've already extended this rental once. Extension is allowed only one time.";
    }
    if (_remainingExtendableDays <= 0) {
      return "Maximum rental period reached (${widget.maxRentalDays} days)";
    }
    if (!_isWithinExtendWindow) {
      return "Extension only available up to 2 days before rental ends";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    // ✅ لو فيه extend record (pending أو completed) اعرض الـ chip بدل الزرار
    if (_hasActiveExtend) {
      return _buildStatusChip();
    }

    if (!_canExtend) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _disabledReason,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _loading ? null : _showExtendDialog,
        icon: const Icon(Icons.timer_outlined, size: 18),
        label: Text(_loading ? "Loading..." : "Extend Rent"),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF3A7DFF),
          side: const BorderSide(color: Color(0xFF3A7DFF)),
        ),
      ),
    );
  }

  // ✅ الـ Chip الشيك اللي بيعرض حالة الـ extend
  Widget _buildStatusChip() {
    final info = widget.extendRentInfo!;
    final isPending = info.status.toLowerCase() == 'pending';
    final color = isPending ? Colors.orange : Colors.green;
    final icon = isPending ? Icons.hourglass_top_rounded : Icons.check_circle_rounded;
    final label = isPending
        ? "Extension Pending Payment"
        : "Extended ";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          if (isPending)
            TextButton(
              onPressed: _loading ? null : () => _resumePendingPayment(info),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                _loading ? "..." : "Complete Payment",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  // ✅ لو المستخدم عايز يكمل دفع كان معلق (اختياري - لو عندك endpoint بيرجع نفس اللينك تاني)
  Future<void> _resumePendingPayment(ExtendRentInfo info) async {
    // لو مفيش عندك API بيرجع رابط الدفع بتاع الفاتورة المعلقة تاني، احذف الزرار ده من _buildStatusChip
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please contact support to complete this payment.')),
    );
  }

  void _showExtendDialog() {
    int selectedDays = 1;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text("Extend Rental Period"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Maximum extension available: $_remainingExtendableDays day(s)"),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedDays,
                decoration: const InputDecoration(
                  labelText: "Extension days",
                  border: OutlineInputBorder(),
                ),
                items: List.generate(_remainingExtendableDays, (i) => i + 1)
                    .map((d) => DropdownMenuItem(value: d, child: Text("$d day(s)")))
                    .toList(),
                onChanged: (v) => setStateDialog(() => selectedDays = v ?? 1),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _confirmExtend(selectedDays);
              },
              child: const Text("Confirm"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmExtend(int days) async {
    setState(() => _loading = true);

    try {
      final result = await OrderServices.extendRent(
        orderId: widget.orderId,
        extensionDays: days,
      );

      setState(() => _loading = false);
      if (!mounted) return;

      final redirectUrl = result['redirectUrl'] as String?;
      if (redirectUrl == null) return;

      final paymentSuccess = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => InAppWebViewScreen(url: redirectUrl),
        ),
      );

      if (!mounted) return;

      if (paymentSuccess == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful! Your rental has been extended.'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onExtended?.call(); // ✅ بيعمل reload للأوردر عشان الـ extend_rent يظهر
      } else if (paymentSuccess == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment was not completed.'),
            backgroundColor: Colors.orange,
          ),
        );
        widget.onExtended?.call(); // ✅ برضو نعمل reload عشان يظهر status: pending
      }
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}