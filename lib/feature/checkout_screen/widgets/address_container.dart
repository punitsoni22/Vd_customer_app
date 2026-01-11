import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/models/address.model.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_button.dart';
import 'package:vd_customer_app/feature/checkout_screen/provider/checkout_provider.dart';
import 'package:vd_customer_app/feature/subscription_date_screen/widgets/address_bottom_sheet.dart';
import 'package:vd_customer_app/feature/subscription_date_screen/provider/subscription_provider.dart'
    as subscription;

class AddressContainer extends StatelessWidget {
  final AddressModel? selectedAddress;

  const AddressContainer({super.key, this.selectedAddress});

  @override
  Widget build(BuildContext context) {
    final checkoutProvider = context.watch<CheckoutProvider>();

    // EMPTY STATE
    if (selectedAddress == null) {
      return Container(
        margin: EdgeInsets.all(8.r),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AllColors.iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_outlined,
                color: AllColors.iconColor,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                "No address found. Please add a delivery address to continue.",
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            CommonButton(
              buttonValue: 'Add',
              backgroundColor: AllColors.buttonColor,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              selfconstraints: BoxConstraints(maxHeight: 34.h, maxWidth: 70.w),
              onTap: () async {
                final added = await showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const AddressBottomSheet(),
                );
                if (added == true) {
                  Provider.of<subscription.SubscriptionProvider>(
                    context,
                    listen: false,
                  ).getAllAddresses(context);

                  Provider.of<CheckoutProvider>(
                    context,
                    listen: false,
                  ).fetchAddresses();
                }
              },
            ),
          ],
        ),
      );
    }

    // MAIN CARD
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: icon + title + chips + actions
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AllColors.iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: AllColors.iconColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // "Deliver to" + Default chip
                    Row(
                      children: [
                        Text(
                          'Deliver to',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        if (selectedAddress!.isDefault)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                color: Colors.green.shade200,
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 12.sp,
                                  color: Colors.green,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'Default',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: 8.h),

                    // Full address text
                    Text(
                      selectedAddress!.fullAddress,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[800],
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${selectedAddress!.city}, ${selectedAddress!.state}, ${selectedAddress!.country}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Postal code: ${selectedAddress!.postalCode}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              // Change button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20.r),
                        ),
                      ),
                      builder: (context) {
                        final addresses = checkoutProvider.addresses;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 12.h),
                            Container(
                              width: 40.w,
                              height: 4.h,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              child: Text(
                                "Select Address",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Divider(height: 1),
                            if (addresses.isEmpty)
                              Padding(
                                padding: EdgeInsets.all(32.r),
                                child: Text(
                                  "No addresses available",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              )
                            else
                              Flexible(
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: addresses.length,
                                  separatorBuilder:
                                      (_, __) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final addr = addresses[index];
                                    final isSelected =
                                        selectedAddress?.id == addr.id;
                                    return ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 20.w,
                                        vertical: 8.h,
                                      ),
                                      leading: Icon(
                                        Icons.location_on_outlined,
                                        color: isSelected
                                            ? AllColors.iconColor
                                            : Colors.grey[600],
                                      ),
                                      title: Text(
                                        addr.fullAddress,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${addr.city}, ${addr.state}',
                                      ),
                                      trailing: isSelected
                                          ? Icon(
                                              Icons.check_circle,
                                              color: AllColors.iconColor,
                                            )
                                          : null,
                                      onTap: () {
                                        checkoutProvider.selectAddress(addr);
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AllColors.iconColor),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'Change',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AllColors.iconColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
