import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_button.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_calendar.dart';
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
  String customerName = "John Doe";
  String subscriptionType = "1_week";
  int bottlesPerDelivery = 2;
  DateTime? startDate;
  DateTime? endDate;
  String? selectedAddressId;
  List<String> selectedDeliveryDays = [];
  List<DateTime> selectedCustomDates = [];
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<SubscriptionProvider>(
        context,
        listen: false,
      ).getAllAddresses(),
    );
  }

  String selectedValue = "Daily";

  final List<String> items = [
    "Daily",
    "Weekly",
    "Alternate Day",
    "Custom Date",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 38.h,
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AllColors.olivegreenColor, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.teal),
              style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
              onChanged: (String? newValue) {
                setState(() {
                  selectedValue = newValue!;
                });
              },
              items: items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        _buildWidgetForSelection(selectedValue),

        SizedBox(height: 18.h),

        Consumer<SubscriptionProvider>(
          builder: (context, subProvider, _) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(
                  color: AllColors.olivegreenColor.withOpacity(0.2),
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Details',
                    style: TextStyle(
                      color: AllColors.olivegreenColor,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedAddressId,
                          isExpanded: true,
                          decoration: InputDecoration(
                            hintText: 'Select Address',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(
                                color: AllColors.olivegreenColor.withOpacity(
                                  0.3,
                                ),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(
                                color: AllColors.olivegreenColor.withOpacity(
                                  0.3,
                                ),
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            isDense: true,
                          ),
                          items: subProvider.addresses.map((address) {
                            return DropdownMenuItem<String>(
                              value: address.id.toString(),
                              child: Text(address.fullAddress),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedAddressId = val;
                            });
                          },
                        ),
                      ),

                      // SizedBox(width: 8.w),
                      // Container(
                      //   decoration: BoxDecoration(
                      //     color: AllColors.olivegreenColor.withOpacity(0.15),
                      //     borderRadius: BorderRadius.circular(8.r),
                      //   ),
                      //   child: IconButton(
                      //     icon: Icon(
                      //       Icons.add,
                      //       color: AllColors.olivegreenColor,
                      //     ),
                      //     onPressed: () async {
                      //       // open bottom sheet to add address
                      //       final added = await showModalBottomSheet<bool>(
                      //         context: context,
                      //         isScrollControlled: true,
                      //         builder: (_) => const AddressBottomSheet(),
                      //       );
                      //       // if added, refresh addresses
                      //       if (added == true) {
                      //         Provider.of<SubscriptionProvider>(
                      //           context,
                      //           listen: false,
                      //         ).getAllAddresses();
                      //       }
                      //     },
                      //   ),
                      // ),
                    ],
                  ),
                  SizedBox(height: 18.h),

                  Row(
                    children: [
                      Expanded(
                        child: _dateField(
                          'Start Date',
                          startDate,
                          context,
                          isStart: true,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _dateField(
                          'End Date',
                          endDate,
                          context,
                          isStart: false,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  CommonButton(
                    onTap: isLoading
                        ? null
                        : () async {
                            if (selectedAddressId == null ||
                                startDate == null ||
                                endDate == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Please select address, start date, and end date.',
                                  ),
                                ),
                              );
                              return;
                            }
                            setState(() {
                              isLoading = true;
                            });
                            final freq = selectedValue;
                            final payload = <String, dynamic>{
                              "customerName": customerName,
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Please select at least one delivery day.',
                                    ),
                                  ),
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Please select at least one delivery date.',
                                    ),
                                  ),
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
                                context.go('/bottom_bar_screen');
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    response["message"] ??
                                        "Failed to create subscription",
                                  ),
                                ),
                              );
                            }
                          },
                    buttonValue: 'Create Subscription',
                    isLoading: isLoading,
                  ),
                ],
              ),
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
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: AllColors.olivegreenColor.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Text(
                    value != null ? _formatDate(value) : 'Select Date',
                    style: TextStyle(fontSize: 14.sp, color: Colors.black),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: AllColors.olivegreenColor,
                ),
                onPressed: () async {
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
              ),
            ],
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
      case "Alternate Day":
        return _alternateDayWidget();
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
            childAspectRatio: 2.4,
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
                          ? AllColors.olivegreenColor
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
                color: AllColors.olivegreenColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: AllColors.olivegreenColor.withOpacity(0.3),
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

  Widget _alternateDayWidget() => _simpleBox("Alternate Day");
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
                color: AllColors.olivegreenColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: AllColors.olivegreenColor.withOpacity(0.3),
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
                      color: AllColors.olivegreenColor.withOpacity(0.8),
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

  Widget _simpleBox(String text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        border: Border.all(color: AllColors.olivegreenColor),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(text),
    );
  }
}
