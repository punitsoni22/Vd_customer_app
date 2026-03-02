import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../core/models/address.model.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/common_widgets/common_button.dart';
import '../../../core/utils/common_widgets/common_calendar.dart';
import '../../../widget/snack_bar.dart';
import '../../profile_screen/provider/profileProvider.dart';
import '../provider/subscription_provider.dart';
import '../subscription_payment_screen.dart';
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
  String preferredTiming = "7AM - 9AM";
  String remarks = "";

  final List<String> items = [
    "Daily",
    "Weekly",
    "Alternate Days",
    "Custom Date",
  ];

  final List<String> timings = [
    "7AM - 9AM",
    "9AM - 11AM",
    "11AM - 1PM",
    "1PM - 3PM",
    "3PM - 5PM",
    "5PM - 7PM",
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
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
      ).getAllAddresses(context);
    });
  }

  Widget _buildCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      padding: padding ?? EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = AllColors.olivegreenColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Delivery Frequency'),
        SizedBox(height: 6.h),
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40.h,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
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
                    value: selectedValue,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: primary,
                    ),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: primary,
                    ),
                    dropdownColor: Colors.white,
                    menuMaxHeight: 260.h,
                    borderRadius: BorderRadius.circular(10.r),
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
                                  color: isSelected
                                      ? primary
                                      : Colors.grey.shade700,
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
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              _buildWidgetForSelection(selectedValue),
            ],
          ),
        ),

        SizedBox(height: 12.h),

        Consumer<SubscriptionProvider>(
          builder: (context, subProvider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Delivery Address'),
                SizedBox(height: 6.h),
                _buildCard(child: _buildAddressSelection(subProvider, primary)),

                SizedBox(height: 12.h),

                _buildSectionTitle('Subscription Dates'),
                SizedBox(height: 6.h),
                _buildCard(
                  child: Column(
                    children: [
                      _dateField(
                        'Start Date',
                        startDate,
                        context,
                        isStart: true,
                      ),
                      SizedBox(height: 12.h),
                      _dateField('End Date', endDate, context, isStart: false),
                      if (startDate != null && endDate != null) ...[
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: AllColors.olivegreenColor.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: AllColors.olivegreenColor.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.date_range,
                                size: 16.sp,
                                color: AllColors.olivegreenColor,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "Total Duration: ${endDate!.difference(startDate!).inDays + 1} Days",
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AllColors.olivegreenColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 12.h),

                _buildSectionTitle('Preferred Timing'),
                SizedBox(height: 6.h),
                _buildCard(child: _buildTimingDropdown(primary)),

                SizedBox(height: 12.h),

                _buildSectionTitle('Remarks (Optional)'),
                SizedBox(height: 6.h),
                _buildCard(child: _buildRemarksField(primary)),

                SizedBox(height: 40.h),

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

                          final subProvider = Provider.of<SubscriptionProvider>(
                            context,
                            listen: false,
                          );

                          AddressModel? selectedAddrObj;
                          try {
                            selectedAddrObj = subProvider.addresses.firstWhere(
                              (element) =>
                                  element.id.toString() == selectedAddressId,
                            );
                          } catch (_) {}

                          if (selectedAddrObj != null) {
                            await subProvider.checkDeliveryPincode(
                              selectedAddrObj.postalCode,
                            );

                            if (!subProvider.isDeliverable) {
                              setState(() {
                                isLoading = false;
                              });
                              if (mounted) {
                                MySnackBar.showSnackBar(
                                  context,
                                  subProvider.deliveryMessage.isNotEmpty
                                      ? subProvider.deliveryMessage
                                      : "Sorry, we cannot deliver to this address",
                                );
                              }
                              return;
                            }
                          } else {
                            setState(() {
                              isLoading = false;
                            });
                            if (mounted) {
                              MySnackBar.showSnackBar(
                                context,
                                'Selected address not found.',
                              );
                            }
                            return;
                          }

                          final freq = selectedValue;
                          final profileProvider = Provider.of<ProfileProvider>(
                            context,
                            listen: false,
                          );
                          final customerNameStr =
                              profileProvider.fullName ?? '';

                          final payload = <String, dynamic>{
                            "customerName": customerNameStr,
                            "delivery_frequency_type": freq
                                .toLowerCase()
                                .replaceAll(' ', '_'),
                            "start_date": _formatApiDate(startDate!),
                            "end_date": _formatApiDate(endDate!),
                            "bottles_per_delivery": bottlesPerDelivery,
                            "products": widget.selectedProducts ?? [],
                            "addressId": int.parse(selectedAddressId!),
                            "preferredTiming": preferredTiming,
                            "remarks": remarks.isEmpty ? null : remarks,
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

                          setState(() {
                            isLoading = false;
                          });

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SubscriptionPaymentScreen(
                                payload: payload,
                                selectedProducts: widget.selectedProducts ?? [],
                                frequency: freq,
                                startDate: startDate!,
                                endDate: endDate!,
                              ),
                            ),
                          );
                        },
                  buttonValue: 'Proceed to Payment',
                  isLoading: isLoading,
                ),
                SizedBox(height: 20.h),
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
            fontSize: 12.sp,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        GestureDetector(
          onTap: () async {
            DateTime initialDate;
            DateTime firstDate;
            final now = DateTime.now();
            final tomorrow = DateTime(now.year, now.month, now.day + 1);

            if (isStart) {
              initialDate = value ?? tomorrow;
              firstDate = tomorrow;
            } else {
              if (startDate != null) {
                firstDate = startDate!.add(const Duration(days: 1));
              } else {
                firstDate = tomorrow.add(const Duration(days: 1));
              }
              initialDate = value ?? firstDate;
              if (initialDate.isBefore(firstDate)) {
                initialDate = firstDate;
              }
            }

            final picked = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: firstDate,
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
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
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
                  child: Text(
                    value != null ? _formatDate(value) : 'Select Date',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: value != null ? Colors.black87 : Colors.grey[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18.sp,
                  color: AllColors.olivegreenColor,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Delivery Days',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.5,
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
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
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
    );
  }

  Widget _customWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: CustomCalendar(
            startDate: startDate,
            endDate: endDate,
            initiallySelectedDates: selectedCustomDates,
            onSelectionChanged: (List<DateTime> selectedDates) {
              setState(() {
                selectedCustomDates = selectedDates;
              });
            },
          ),
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
    );
  }

  Widget _buildAddressSelection(SubscriptionProvider provider, Color primary) {
    if (selectedAddressId == null && provider.addresses.isNotEmpty) {
      final defaultAddress = provider.addresses.firstWhere(
        (addr) => addr.isDefault,
        orElse: () => provider.addresses.first,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && selectedAddressId == null) {
          setState(() {
            selectedAddressId = defaultAddress.id.toString();
          });
        }
      });
    }

    return GestureDetector(
      onTap: () async {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => AddressBottomSheet(
            addresses: provider.addresses,
            selectedId: selectedAddressId,
            onSelected: (id) {
              setState(() {
                selectedAddressId = id;
              });
            },
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AllColors.olivegreenColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on,
              color: AllColors.olivegreenColor,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Address',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  selectedAddressId != null && provider.addresses.isNotEmpty
                      ? provider.addresses
                            .firstWhere(
                              (a) => a.id.toString() == selectedAddressId,
                              orElse: () => provider.addresses.first,
                            )
                            .fullAddress
                      : 'Tap to select address',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: selectedAddressId != null
                        ? Colors.black87
                        : Colors.grey[400],
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 14.sp,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildTimingDropdown(Color primary) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: primary.withValues(alpha: 0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: preferredTiming,
          isExpanded: true,
          icon: Icon(Icons.access_time, color: primary, size: 18.sp),
          style: TextStyle(fontSize: 14.sp, color: AllColors.buttonColor),
          dropdownColor: Colors.white,
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                preferredTiming = newValue;
              });
            }
          },
          items: timings.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRemarksField(Color primary) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: primary.withValues(alpha: 0.3)),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            remarks = value;
          });
        },
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'e.g., Leave at doorstep',
          hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8.h),
          isDense: true,
        ),
        style: TextStyle(fontSize: 14.sp, color: AllColors.buttonColor),
      ),
    );
  }
}
