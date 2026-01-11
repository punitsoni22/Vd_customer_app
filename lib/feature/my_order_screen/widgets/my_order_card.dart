import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_button.dart';

class MyOrderCard extends StatelessWidget {
  final String id;
  final String date;
  final String? status;
  final String imageUrl;
  final String productName;
  final String detail;
  final String? paymentMethod;
  final String? warning;
  final String? button1;
  final String? button2;
  final String? button3;
  final IconData? icon2;
  final IconData? icon3;
  final String? invoiceUrl;
  final String? invoiceNumber;
  final VoidCallback? onInvoiceTap;
  final VoidCallback? onViewTap;
  final Function(int)? onStatusChange;
  final int? currentStatus;

  const MyOrderCard({
    super.key,
    required this.id,
    required this.date,
    this.status,
    required this.imageUrl,
    required this.productName,
    required this.detail,
    this.paymentMethod,
    this.warning,
    this.button1,
    this.button2,
    this.button3,
    this.icon2,
    this.icon3,
    this.invoiceUrl,
    this.invoiceNumber,
    this.onInvoiceTap,
    this.onViewTap,
    this.onStatusChange,
    this.currentStatus,
  });

  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                id,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
              ),
              (status != null && status!.isNotEmpty)
                  ? Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: getStatusColor(status!),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        status!,
                        style: TextStyle(
                          color: statusFontColor(status!),
                          fontWeight: FontWeight.w500,
                          fontSize: 10.sp,
                        ),
                      ),
                    )
                  : (currentStatus != null)
                  ? Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        _statusLabelFromNumeric(currentStatus),
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                        ),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
          Text(
            date,
            style: TextStyle(
              color: AllColors.myOrderTextColor,
              fontSize: 13.sp,
            ),
          ),

          SizedBox(height: 10.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    imageUrl.isNotEmpty && imageUrl.startsWith('http')
                        ? imageUrl
                        : 'assets/images/image.png',
                    height: 80.h,
                    width: 80.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/image.png',
                      height: 80.h,
                      width: 80.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      capitalize(productName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      detail,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    if (paymentMethod != '')
                      Row(
                        children: [
                          Icon(
                            icon2 ?? Icons.calendar_today_outlined,
                            size: 14.sp,
                            color: AllColors.olivegreenColor,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            paymentMethod!,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AllColors.olivegreenColor,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          warning != null
              ? Text(
                  warning ??
                      'Auto-debit is scheduled from your Visa card ending in 1234.',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                  ),
                )
              : const SizedBox(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (onStatusChange != null)
                Expanded(
                  child: PopupMenuButton<int>(
                    onSelected: (val) => onStatusChange!(val),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AllColors.tabBarline.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: AllColors.tabBarline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _statusLabelFromNumeric(currentStatus),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AllColors.tabBarline,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 16.sp,
                            color: AllColors.tabBarline,
                          ),
                        ],
                      ),
                    ),
                    itemBuilder: (context) {
                      final List<PopupMenuEntry<int>> items = [];
                      if (currentStatus == null) {
                        items.add(
                          const PopupMenuItem(value: 0, child: Text('Pause')),
                        );
                        items.add(
                          const PopupMenuItem(value: 1, child: Text('Resume')),
                        );
                        items.add(
                          const PopupMenuItem(value: 2, child: Text('Cancel')),
                        );
                      } else {
                        final st = currentStatus!;
                        if (st == 1) {
                          items.add(
                            const PopupMenuItem(value: 0, child: Text('Pause')),
                          );
                          items.add(
                            const PopupMenuItem(
                              value: 2,
                              child: Text('Cancel'),
                            ),
                          );
                        } else if (st == 0) {
                          items.add(
                            const PopupMenuItem(
                              value: 1,
                              child: Text('Resume'),
                            ),
                          );
                          items.add(
                            const PopupMenuItem(
                              value: 2,
                              child: Text('Cancel'),
                            ),
                          );
                        }
                      }
                      return items;
                    },
                  ),
                )
              else
                SizedBox(width: 10.w),
              SizedBox(width: 12.w),
              Expanded(
                child: CommonButton(
                  buttonValue: button2 ?? "View",
                  onTap: onViewTap ?? () {},
                  color: AllColors.olivegreenColor,
                  selfconstraints: BoxConstraints(minHeight: 40.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 8.h,
                  ),
                  fontSize: 13.sp,
                  radius: 8.r,
                  elevation: 0,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CommonButton(
                  buttonValue: button3 ?? "Invoice",
                  onTap: onInvoiceTap ?? () {},
                  icon: icon3 ?? Icons.download_rounded,
                  iconSize: 16.sp,
                  variant: ButtonVariant.outlined,
                  borderColor: Colors.grey.shade300,
                  foregroundColor: Colors.black87,
                  selfconstraints: BoxConstraints(minHeight: 40.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 8.h,
                  ),
                  fontSize: 13.sp,
                  radius: 8.r,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _statusLabelFromNumeric(int? st) {
    switch (st) {
      case 0:
        return 'Paused';
      case 1:
        return 'Resumed';
      case 2:
        return 'Cancelled';
      default:
        return 'Status';
    }
  }
}

Color getStatusColor(String status) {
  switch (status) {
    case 'Paused':
      return Colors.orange.shade100;
    case 'Resumed':
      return Colors.green.shade100;
    case 'Cancelled':
      return Colors.red.shade100;
    case 'DELIVERED':
      return Colors.blue.shade50;
    case 'ACTIVE':
      return Colors.green.shade100;
    case 'PENDING':
      return Colors.red.shade100;
    case 'OUT FOR DELIVERY':
      return Colors.blue.shade50;

    default:
      return Colors.black;
  }
}

Color statusFontColor(String status) {
  switch (status) {
    case 'Paused':
      return Colors.orange.shade700;
    case 'Resumed':
      return Colors.green.shade700;
    case 'Cancelled':
      return Colors.red.shade700;
    case 'DELIVERED':
      return Colors.blue;
    case 'ACTIVE':
      return Colors.green;
    case 'PENDING':
      return const Color.fromARGB(255, 204, 57, 47);
    case 'OUT FOR DELIVERY':
      return Colors.blue.shade50;

    default:
      return Colors.white;
  }
}
