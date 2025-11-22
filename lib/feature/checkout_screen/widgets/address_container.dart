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
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AllColors.textfieldborderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              color: AllColors.iconColor,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                "No address found. Please add a delivery address to continue.",
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
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
                  ).getAllAddresses();

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
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AllColors.textfieldborderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
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
              Icon(
                Icons.location_on_outlined,
                color: AllColors.iconColor,
                size: 22.sp,
              ),
              SizedBox(width: 8.w),
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
                            color: Colors.black,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        if (selectedAddress!.isDefault)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 14.sp,
                                  color: Colors.green,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'Default',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.green[800],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: 6.h),

                    // Full address text
                    Text(
                      selectedAddress!.fullAddress,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.black,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${selectedAddress!.city}, ${selectedAddress!.state}, ${selectedAddress!.country}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color.fromARGB(255, 106, 106, 106),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Postal code: ${selectedAddress!.postalCode}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color.fromARGB(255, 106, 106, 106),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              // Add / Change actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Add button (same as before)
                  GestureDetector(
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
                        ).getAllAddresses();

                        Provider.of<CheckoutProvider>(
                          context,
                          listen: false,
                        ).fetchAddresses();
                      }
                    },
                    child: Container(
                      width: 34.w,
                      height: 34.h,
                      decoration: BoxDecoration(
                        color: AllColors.buttonColor,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(Icons.add, size: 18.sp, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 6.h),

                  // 🔹 Change button – now clearly a button
                  OutlinedButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20.r),
                          ),
                        ),
                        builder: (context) {
                          final addresses = checkoutProvider.addresses;

                          if (addresses.isEmpty) {
                            return Padding(
                              padding: EdgeInsets.all(20.r),
                              child: const Center(
                                child: Text("No addresses available"),
                              ),
                            );
                          }

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 10.h),
                              Container(
                                width: 50.w,
                                height: 5.h,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                "Select Address",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(),
                              Flexible(
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: addresses.length,
                                  separatorBuilder: (_, __) => const Divider(),
                                  itemBuilder: (context, index) {
                                    final addr = addresses[index];
                                    return ListTile(
                                      leading: Icon(
                                        Icons.location_on_outlined,
                                        color: AllColors.iconColor,
                                      ),
                                      title: Text(
                                        addr.fullAddress,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                        '${addr.city}, ${addr.state}',
                                      ),
                                      trailing: addr.isDefault
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.green,
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
                              SizedBox(height: 10.h),
                            ],
                          );
                        },
                      );
                    },
                    icon: Icon(
                      Icons.edit_location_alt_outlined,
                      size: 14.sp,
                      color: AllColors.iconColor,
                    ),
                    label: Text(
                      'Change',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AllColors.iconColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AllColors.iconColor, width: 1),
                      minimumSize: Size(80.w, 32.h),
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
