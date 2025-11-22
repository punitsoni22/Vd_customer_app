import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vd_customer_app/core/routing/routes.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

import 'package:provider/provider.dart';
import 'package:vd_customer_app/feature/profile_screen/provider/profileProvider.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_button.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_calendar.dart';
import 'package:vd_customer_app/widget/snack_bar.dart';
import '../provider/subscription_provider.dart';
import 'address_bottom_sheet.dart';

class SubscriptionDateDropdown extends StatefulWidget {
  final List<Map<String, dynamic>>? selectedProducts;
  const SubscriptionDateDropdown({super.key, this.selectedProducts});

  @override
  State<SubscriptionDateDropdown> createState() =>
      _SubscriptionDateDropdownState();
}

class _SubscriptionDateDropdownState extends State<SubscriptionDateDropdown> {
  bool isLoading = false;
  String subscriptionType = "1_week";
  int bottlesPerDelivery = 2;
  DateTime? startDate;
  DateTime? endDate;
  String? selectedAddressId;
  List<String> selectedDeliveryDays = [];
  List<DateTime> selectedCustomDates = [];
  String selectedValue = "Daily";

  final List<String> items = [
    "Daily",
    "Weekly",
    "Alternate Days",
    "Custom Date",
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // Ensure profile is loaded so we can use the customer's full name
      final profileProvider = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );
      if (profileProvider.fullName == null) {
        profileProvider.fetchSpecificUser(context);
      }

      Provider.of<SubscriptionProvider>(
        context,
        listen: false,
      ).getAllAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = AllColors.olivegreenColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 40.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: primary.withValues(alpha: 0.6), width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: primary),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: primary,
              ),
              dropdownColor: Colors.white,
              menuMaxHeight: 260.h,
              borderRadius: BorderRadius.circular(10.r),

              // How selected item looks when closed
              selectedItemBuilder: (BuildContext context) {
                return items.map((value) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: primary,
                      ),
                    ),
                  );
                }).toList();
              },

              onChanged: (String? newValue) {
                if (newValue == null) return;
                setState(() {
                  selectedValue = newValue;
                });
              },

              items: items.map((String value) {
                final bool isSelected = value == selectedValue;

                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected ? primary : Colors.grey.shade700,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_rounded, size: 18.sp, color: primary),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        SizedBox(height: 12.h),
        _buildWidgetForSelection(selectedValue),
        SizedBox(height: 10.h),

        Consumer<SubscriptionProvider>(
          builder: (context, subProvider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Details',
                  style: TextStyle(
                    color: primary,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40.h,
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: primary.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedAddressId,
                            hint: Text(
                              "Select Address",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w400,
                                color: primary.withValues(alpha: 0.8),
                              ),
                            ),
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: primary,
                            ),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                            menuMaxHeight: 260.h,

                            // Selected item appearance
                            selectedItemBuilder: (context) {
                              return subProvider.addresses.map((address) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    address.fullAddress,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                      color: primary,
                                    ),
                                  ),
                                );
                              }).toList();
                            },

                            items: subProvider.addresses.map((address) {
                              final id = address.id.toString();
                              final bool isSelected = selectedAddressId == id;

                              return DropdownMenuItem<String>(
                                value: id,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        address.fullAddress,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? primary
                                              : Colors.grey.shade800,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_rounded,
                                        size: 18.sp,
                                        color: primary,
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),

                            onChanged: (val) {
                              setState(() {
                                selectedAddressId = val;
                              });
                            },
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 8.w),

                    GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AllColors.buttonColor,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        width: 40.w,
                        height: 40.h,
                        child: Icon(
                          Icons.add,
                          size: 22.sp,
                          color: Colors.white,
                        ),
                      ),
                      onTap: () async {
                        final added = await showModalBottomSheet<bool>(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => const AddressBottomSheet(),
                        );
                        if (added == true) {
                          Provider.of<SubscriptionProvider>(
                            context,
                            listen: false,
                          ).getAllAddresses();
                        }
                      },
                    ),
                  ],
                ),

                SizedBox(height: 18.h),

                _dateField('Start Date', startDate, context, isStart: true),
                SizedBox(height: 18.h),
                _dateField('End Date', endDate, context, isStart: false),

                SizedBox(height: 24.h),
                CommonButton(
                  backgroundColor: AllColors.tabBarline,
                  onTap: isLoading
                      ? null
                      : () async {
                          if (selectedAddressId == null ||
                              startDate == null ||
                              endDate == null) {
                            MySnackBar.showSnackBar(
                              context,
                              'Please select address, start date, and end date.',
                            );
                            return;
                          }
                          setState(() {
                            isLoading = true;
                          });
                          final freq = selectedValue;
                          final profileProvider = Provider.of<ProfileProvider>(
                            context,
                            listen: false,
                          );
                          final customerNameStr =
                              profileProvider.fullName ?? '';

                          final payload = <String, dynamic>{
                            "customerName": customerNameStr,
                            "subscription_type": subscriptionType,
                            "delivery_frequency_type": freq
                                .toLowerCase()
                                .replaceAll(' ', '_'),
                            "start_date": _formatApiDate(startDate!),
                            "end_date": _formatApiDate(endDate!),
                            "bottles_per_delivery": bottlesPerDelivery,
                            "products": widget.selectedProducts ?? [],
                            "addressId": int.parse(selectedAddressId!),
                          };
                          if (freq == "Weekly") {
                            if (selectedDeliveryDays.isEmpty) {
                              MySnackBar.showSnackBar(
                                context,
                                'Please select at least one delivery day.',
                              );
                              setState(() {
                                isLoading = false;
                              });
                              return;
                            }
                            payload["delivery_days"] = selectedDeliveryDays;
                            payload["subscription_type"] = "1_week";
                          } else if (freq == "Custom Date") {
                            if (selectedCustomDates.isEmpty) {
                              MySnackBar.showSnackBar(
                                context,
                                'Please select at least one delivery date.',
                              );
                              setState(() {
                                isLoading = false;
                              });
                              return;
                            }
                            payload["delivery_dates"] = selectedCustomDates
                                .map((date) => _formatApiDate(date))
                                .toList();
                          }
                          final apiPayload = {"data": payload};
                          final response =
                              await Provider.of<SubscriptionProvider>(
                                context,
                                listen: false,
                              ).createOrEditSubscription(apiPayload);
                          setState(() {
                            isLoading = false;
                          });
                          if (response["success"] == true) {
                            if (mounted) {
                              context.go(
                                AppRoutes.bottomBarScreen,
                                extra: {'index': 2},
                              );
                            }
                          } else {
                            MySnackBar.showSnackBar(
                              context,
                              response["message"] ??
                                  'Failed to create subscription.',
                            );
                          }
                        },
                  buttonValue: 'Create Subscription',
                  isLoading: isLoading,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _dateField(
    String label,
    DateTime? value,
    BuildContext context, {
    required bool isStart,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AllColors.olivegreenColor,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6.h),
        GestureDetector(
          onTap: () async {
            DateTime initialDate = value ?? DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() {
                if (isStart) {
                  startDate = picked;
                  if (endDate != null && endDate!.isBefore(startDate!)) {
                    endDate = null;
                  }
                } else {
                  endDate = picked;
                }
              });
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: AllColors.olivegreenColor.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    child: Text(
                      value != null ? _formatDate(value) : 'Select Date',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AllColors.buttonColor,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 12.w), // fixed typo here
                  child: Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                    color: AllColors.olivegreenColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatApiDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  Widget _buildWidgetForSelection(String value) {
    switch (value) {
      case "Weekly":
        return _weeklyWidget();
      case "Custom Date":
        return _customWidget();
      default:
        return const SizedBox();
    }
  }

  Widget _weeklyWidget() {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Delivery Days',
            style: TextStyle(
              color: AllColors.olivegreenColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 19,
            mainAxisSpacing: 15,
            childAspectRatio: 2.8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (var day in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'])
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selectedDeliveryDays.contains(day)) {
                        selectedDeliveryDays.remove(day);
                      } else {
                        selectedDeliveryDays.add(day);
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: selectedDeliveryDays.contains(day)
                          ? AllColors.tabBarline
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: selectedDeliveryDays.contains(day)
                            ? AllColors.olivegreenColor
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          color: selectedDeliveryDays.contains(day)
                              ? Colors.white
                              : AllColors.olivegreenColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (selectedDeliveryDays.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AllColors.olivegreenColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: AllColors.olivegreenColor.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'Selected days: ${selectedDeliveryDays.join(', ')}',
                style: TextStyle(
                  color: AllColors.olivegreenColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _customWidget() {
    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCalendar(
            startDate: startDate,
            endDate: endDate,
            initiallySelectedDates: selectedCustomDates,
            onSelectionChanged: (List<DateTime> selectedDates) {
              setState(() {
                selectedCustomDates = selectedDates;
              });
            },
          ),
          if (selectedCustomDates.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AllColors.olivegreenColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: AllColors.olivegreenColor.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected delivery dates (${selectedCustomDates.length}):',
                    style: TextStyle(
                      color: AllColors.olivegreenColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    selectedCustomDates
                        .map((date) => _formatDate(date))
                        .join(', '),
                    style: TextStyle(
                      color: AllColors.olivegreenColor.withValues(alpha: 0.8),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
