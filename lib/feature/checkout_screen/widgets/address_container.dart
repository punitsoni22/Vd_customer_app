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

    if (selectedAddress == null) {
      return Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: AllColors.textfieldborderColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(child: Text("No address found")),
      );
    }

    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: AllColors.textfieldborderColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Delivery Address',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AllColors.buttonColor,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(5.r),
                        boxShadow: const [],
                      ),
                      width: 40.w,
                      height: 40.h,
                      child: Icon(Icons.add, size: 20.sp, color: Colors.white),
                    ),
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
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: AllColors.textfieldborderColor),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: CommonButton(
                      padding: EdgeInsets.all(0),
                      selfconstraints: BoxConstraints(
                        maxHeight: 25.h,
                        maxWidth: 60.w,
                      ),
                      color: Colors.transparent,
                      buttonValue: 'Change',
                      textStyle: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (context) {
                            final addresses = checkoutProvider.addresses;

                            if (addresses.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(20),
                                child: Center(
                                  child: Text("No addresses available"),
                                ),
                              );
                            }

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 10),
                                Container(
                                  width: 50,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Select Address",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Divider(),
                                Flexible(
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    itemCount: addresses.length,
                                    separatorBuilder: (_, __) =>
                                        const Divider(),
                                    itemBuilder: (context, index) {
                                      final addr = addresses[index];
                                      return ListTile(
                                        title: Text(addr.fullAddress),
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
                                const SizedBox(height: 10),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            selectedAddress!.fullAddress,
            style: const TextStyle(fontSize: 17, color: Colors.black),
          ),
          const SizedBox(height: 0),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${selectedAddress!.city}, ${selectedAddress!.state}, ${selectedAddress!.country}',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color.fromARGB(255, 106, 106, 106),
                  ),
                  maxLines: 3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            'Postal code: ${selectedAddress!.postalCode}',
            style: const TextStyle(
              fontSize: 14,
              color: Color.fromARGB(255, 106, 106, 106),
            ),
          ),
        ],
      ),
    );
  }
}
