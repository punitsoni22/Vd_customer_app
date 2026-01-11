import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vd_customer_app/core/services/api_services.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

class QRPaymentModal extends StatefulWidget {
  final String qrData;
  final int orderId;
  final void Function(Map<String, dynamic> order) onPaymentSuccess;
  final VoidCallback onExpired;

  const QRPaymentModal({
    super.key,
    required this.qrData,
    required this.orderId,
    required this.onPaymentSuccess,
    required this.onExpired,
  });

  @override
  State<QRPaymentModal> createState() => _QRPaymentModalState();
}

class _QRPaymentModalState extends State<QRPaymentModal> {
  Timer? _timer;
  Timer? _displayTimer;
  int _elapsed = 0;
  final int _timeoutSeconds = 600;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _checkStatus());
    _displayTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _elapsed += 1;
        });

        if (_elapsed >= _timeoutSeconds) {
          _timer?.cancel();
          _displayTimer?.cancel();
          if (mounted) {
            Navigator.of(context).pop();
            widget.onExpired();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _displayTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    if (_isChecking) return;
    if (!mounted) return;

    _isChecking = true;

    try {
      final resp = await Api.post('getAllOrders', {
        "data": {"page": 1, "pageSize": 20},
      });

      bool isSuccess =
          resp['success'] == true || resp['dataResponse']?['returnCode'] == 0;

      if (isSuccess) {
        final items = resp['data']?['items'] as List? ?? [];
        final order = items.cast<Map<String, dynamic>>().firstWhere(
          (o) => o['id'] == widget.orderId,
          orElse: () => {},
        );

        if (order.isNotEmpty) {
          final paymentStatus =
              order['paymentStatus']?.toString().toLowerCase() ?? '';
          final orderStatus = order['status']?.toString().toLowerCase() ?? '';

          final isPaid =
              paymentStatus == 'paid' ||
              paymentStatus == 'success' ||
              paymentStatus == 'completed' ||
              orderStatus == 'completed' ||
              orderStatus == 'confirmed';

          if (isPaid) {
            _timer?.cancel();
            _displayTimer?.cancel();
            if (mounted) {
              Navigator.of(context).pop();
              widget.onPaymentSuccess(order);
            }
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('QR Payment polling error: $e');
    } finally {
      _isChecking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUrl = widget.qrData.startsWith('http');
    final remainingSeconds = _timeoutSeconds - _elapsed;
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;

    return WillPopScope(
      onWillPop: () async {
        _timer?.cancel();
        _displayTimer?.cancel();
        widget.onExpired();
        return true;
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      color: AllColors.iconColor,
                      size: 28.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Scan to Pay',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _timer?.cancel();
                        Navigator.of(context).pop();
                        widget.onExpired();
                      },
                      icon: const Icon(Icons.close),
                      color: Colors.grey[600],
                    ),
                  ],
                ),

                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AllColors.iconColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AllColors.iconColor.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: isUrl
                      ? Image.network(
                          widget.qrData,
                          height: 240.h,
                          width: 240.w,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              height: 240.h,
                              width: 240.w,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AllColors.iconColor,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (c, e, s) => Container(
                            height: 240.h,
                            width: 240.w,
                            color: Colors.grey[100],
                            child: Icon(
                              Icons.qr_code,
                              size: 100.sp,
                              color: Colors.grey[400],
                            ),
                          ),
                        )
                      : Container(
                          height: 240.h,
                          width: 240.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.r),
                            child: SelectableText(
                              widget.qrData,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ),
                ),

                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: AllColors.iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16.w,
                        height: 16.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AllColors.iconColor,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Flexible(
                        child: Text(
                          'Waiting for payment confirmation...',
                          style: TextStyle(
                            color: AllColors.iconColor,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: remainingSeconds < 30
                        ? Colors.red.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 16.sp,
                        color: remainingSeconds < 30
                            ? Colors.red
                            : Colors.orange,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Expires in $minutes:${seconds.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: remainingSeconds < 30
                              ? Colors.red
                              : Colors.orange,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      _timer?.cancel();
                      _displayTimer?.cancel();
                      Navigator.of(context).pop();
                      widget.onExpired();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      side: BorderSide(color: Colors.grey[400]!, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Cancel Payment',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
