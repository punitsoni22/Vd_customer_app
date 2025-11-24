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
  final String paymentMethod;
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
    required this.paymentMethod,
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
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.shade100,
        //     spreadRadius: 1,
        //     blurRadius: 5,
        //   ),
        // ],
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
                        horizontal: 16.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: getStatusColor(status!),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        status!,
                        style: TextStyle(
                          color: statusFontColor(status!),
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
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
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.network(
                  imageUrl.isNotEmpty && imageUrl.startsWith('http')
                      ? imageUrl
                      : 'assets/images/image.png',
                  height: 74.h,
                  width: 74.w,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/image.png',
                    height: 74.h,
                    width: 74.w,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      capitalize(productName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      detail,
                      style: TextStyle(
                        color: AllColors.myOrderTextColor,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          icon2 ?? Icons.account_balance_wallet_outlined,
                          size: 16.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          paymentMethod,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AllColors.myOrderTextColor,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
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
          SizedBox(height: 15.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (onStatusChange != null)
                Expanded(
                  child: PopupMenuButton<int>(
                    onSelected: (val) => onStatusChange!(val),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AllColors.tabBarline.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        _statusLabelFromNumeric(currentStatus),
                        style: TextStyle(fontSize: 13.sp),
                      ),
                    ),
                    itemBuilder: (context) {
                      final List<PopupMenuEntry<int>> items = [];
                      if (currentStatus == null) {
                        items.add(
                          const PopupMenuItem(value: 0, child: Text('Pause')),
                        ); // PAUSED
                        items.add(
                          const PopupMenuItem(value: 1, child: Text('Resume')),
                        ); // RESUMED
                        items.add(
                          const PopupMenuItem(value: 2, child: Text('Cancel')),
                        ); // CANCELLED
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
              SizedBox(width: 10.w),
              Expanded(
                child: CommonButton(
                  buttonValue: button2 ?? "View",
                  onTap: onViewTap ?? () {},
                  color: AllColors.olivegreenColor,
                  selfconstraints: BoxConstraints(minHeight: 37.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: CommonButton(
                  buttonValue: button3 ?? "Invoice",
                  onTap: onInvoiceTap ?? () {},
                  icon: icon3 ?? Icons.download_done,
                  iconSize: 13.sp,
                  variant: ButtonVariant.outlined,
                  borderColor: Colors.grey.shade300,
                  foregroundColor: Colors.black54,
                  selfconstraints: BoxConstraints(minHeight: 37.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  fontSize: 12.sp,
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
      return Colors.grey;
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
      return Colors.grey;
  }
}
