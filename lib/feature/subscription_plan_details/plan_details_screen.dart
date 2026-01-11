import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/models/admin_plan_model.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_appbar.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_button.dart';
import 'package:vd_customer_app/feature/subscription_date_screen/provider/subscription_provider.dart';
import 'package:vd_customer_app/feature/subscription_date_screen/widgets/address_bottom_sheet.dart';
import 'package:vd_customer_app/widget/snack_bar.dart';

class PlanDetailsScreen extends StatefulWidget {
  final int planId;
  const PlanDetailsScreen({super.key, required this.planId});

  @override
  State<PlanDetailsScreen> createState() => _PlanDetailsScreenState();
}

class _PlanDetailsScreenState extends State<PlanDetailsScreen> {
  DateTime? startDate;
  DateTime? endDate;
  String? selectedAddressId;
  String preferredTiming = "7AM - 9AM";
  String remarks = "";
  bool isLoading = false;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SubscriptionProvider>();
      provider.getSpecificAdminPlan(context, widget.planId);
      provider.getAllAddresses(context);
    });
  }

  String _formatApiDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _createSubscription() async {
    if (startDate == null || endDate == null) {
      MySnackBar.showSnackBar(context, "Please select start and end dates");
      return;
    }

    if (selectedAddressId == null) {
      MySnackBar.showSnackBar(context, "Please select delivery address");
      return;
    }

    setState(() {
      isLoading = true;
    });

    final payload = {
      "data": {
        "admin_plan_id": widget.planId,
        "addressId": int.parse(selectedAddressId!),
        "start_date": _formatApiDate(startDate!),
        "end_date": _formatApiDate(endDate!),
        "preferredTiming": preferredTiming,
        "remarks": remarks.isEmpty ? null : remarks,
      },
    };

    final subscriptionProvider = context.read<SubscriptionProvider>();
    final response = await subscriptionProvider.createOrEditSubscription(
      context,
      payload,
    );

    setState(() {
      isLoading = false;
    });

    if (!mounted) return;

    if (response['success'] == true) {
      MySnackBar.showSnackBar(
        context,
        response['message'] ?? 'Subscription created successfully',
      );
      context.pop();
      context.pop(); // Go back to subscription product screen
    } else {
      MySnackBar.showSnackBar(
        context,
        response['message'] ?? 'Failed to create subscription',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CommonAppBar(
        title: 'Plan Details',
        showBack: true,
        onBack: () => context.pop(),
        backgroundColor: Colors.white,
      ),
      body: Consumer<SubscriptionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingPlans) {
            return const Center(child: CircularProgressIndicator());
          }

          final plan = provider.selectedPlan;

          if (plan == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48.sp, color: Colors.grey),
                  SizedBox(height: 16.h),
                  Text(
                    "Plan not found",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPlanHeader(plan),
                SizedBox(height: 12.h),
                _buildSectionTitle('Products Included'),
                SizedBox(height: 6.h),
                _buildProductsList(plan.products),
                _buildSectionTitle('Delivery Details'),
                SizedBox(height: 6.h),
                _buildDeliveryDetails(plan),
                SizedBox(height: 12.h),
                _buildSectionTitle('Subscription Dates'),
                SizedBox(height: 6.h),
                _buildDateFields(),
                SizedBox(height: 12.h),
                _buildSectionTitle('Delivery Address'),
                SizedBox(height: 6.h),
                _buildAddressSelection(provider),
                SizedBox(height: 12.h),
                _buildSectionTitle('Preferred Timing'),
                SizedBox(height: 6.h),
                _buildTimingDropdown(),
                SizedBox(height: 12.h),
                _buildSectionTitle('Remarks (Optional)'),
                SizedBox(height: 6.h),
                _buildRemarksField(),
                SizedBox(height: 40.h),
                CommonButton(
                  buttonValue: 'Create Subscription',
                  isLoading: isLoading,
                  onTap: _createSubscription,
                  backgroundColor: AllColors.tabBarline,
                ),
                SizedBox(height: 20.h),
              ],
            ),
          );
        },
      ),
    );
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

  Widget _buildPlanHeader(AdminPlanModel plan) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  plan.planName,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: AllColors.olivegreenColor,
                    height: 1.2,
                  ),
                ),
              ),
              if (plan.discountPercentage != '0')
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '${plan.discountPercentage}% OFF',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            plan.planDescription,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          SizedBox(height: 10.h),
          Divider(color: Colors.grey, height: 1),
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${plan.finalPrice}',
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              if (plan.discountPercentage != '0') ...[
                SizedBox(width: 10.w),
                Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: Text(
                    '₹${plan.totalPrice}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[400],
                      decoration: TextDecoration.lineThrough,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
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

  Widget _buildProductsList(List<PlanProduct> products) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final product = products[index];
        final String? imgUrl = (product.images.isNotEmpty)
            ? (product.images.first.signedUrl ?? product.images.first.imageUrl)
            : null;

        return _buildCard(
          padding: EdgeInsets.all(12.r),
          child: Row(
            children: [
              Container(
                width: 70.w,
                height: 70.h,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: (imgUrl != null && imgUrl.isNotEmpty)
                      ? Image.network(
                          imgUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.image_outlined,
                            color: Colors.grey[300],
                            size: 32.sp,
                          ),
                        )
                      : Icon(
                          Icons.image_outlined,
                          color: Colors.grey[300],
                          size: 32.sp,
                        ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AllColors.tabBarline.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            '${product.selectedVariant.quantityInMl}ml',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AllColors.tabBarline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '₹${product.selectedVariant.price}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Text(
                          'Qty: ',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${product.quantity}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AllColors.olivegreenColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeliveryDetails(AdminPlanModel plan) {
    return _buildCard(
      child: Column(
        children: [
          _buildDetailRow(
            Icons.calendar_month_outlined,
            'Subscription Type',
            plan.subscriptionType.replaceAll('_', ' '),
          ),
          Divider(color: Colors.grey[100], height: 24.h),
          _buildDetailRow(
            Icons.local_shipping_outlined,
            'Frequency',
            plan.deliveryFrequencyType,
          ),
          if (plan.deliveryDays.isNotEmpty) ...[
            Divider(color: Colors.grey[100], height: 24.h),
            _buildDetailRow(
              Icons.today_outlined,
              'Delivery Days',
              plan.deliveryDays.join(', '),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: AllColors.olivegreenColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AllColors.olivegreenColor, size: 18.sp),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
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
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateFields() {
    return Row(
      children: [
        Expanded(child: _buildDateField('Start Date', startDate, true)),
        SizedBox(width: 12.w),
        Expanded(child: _buildDateField('End Date', endDate, false)),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? value, bool isStart) {
    return GestureDetector(
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
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: AllColors.olivegreenColor,
                ),
              ),
              child: child!,
            );
          },
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
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: value != null
                ? AllColors.olivegreenColor
                : Colors.grey.shade300,
            width: value != null ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16.sp,
                  color: value != null
                      ? AllColors.olivegreenColor
                      : Colors.grey[400],
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    value != null
                        ? "${value.day.toString().padLeft(2, '0')}-${value.month.toString().padLeft(2, '0')}-${value.year}"
                        : 'Select',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: value != null ? Colors.black87 : Colors.grey[400],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSelection(SubscriptionProvider provider) {
    final defaultAddress = provider.addresses.isNotEmpty
        ? provider.addresses.firstWhere(
            (addr) => addr.isDefault,
            orElse: () => provider.addresses.first,
          )
        : null;

    if (selectedAddressId == null && defaultAddress != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          selectedAddressId = defaultAddress.id.toString();
        });
      });
    }

    final selectedAddress =
        selectedAddressId != null && provider.addresses.isNotEmpty
        ? provider.addresses.firstWhere(
            (a) => a.id.toString() == selectedAddressId,
            orElse: () => provider.addresses.first,
          )
        : null;

    return GestureDetector(
      onTap: () async {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
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
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selectedAddressId != null
                ? AllColors.olivegreenColor
                : Colors.grey.shade300,
            width: selectedAddressId != null ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: AllColors.olivegreenColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_outlined,
                color: AllColors.olivegreenColor,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedAddress != null
                        ? selectedAddress.fullAddress
                        : 'Select Delivery Address',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: selectedAddress != null
                          ? Colors.black87
                          : Colors.grey[400],
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16.sp,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimingDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: preferredTiming,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AllColors.olivegreenColor,
          ),
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          items: timings.map((timing) {
            return DropdownMenuItem(value: timing, child: Text(timing));
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                preferredTiming = value;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildRemarksField() {
    return TextField(
      maxLines: 3,
      style: TextStyle(fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: 'Any special instructions for delivery?',
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
        fillColor: Colors.white,
        filled: true,
        contentPadding: EdgeInsets.all(16.r),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AllColors.olivegreenColor),
        ),
      ),
      onChanged: (value) {
        remarks = value;
      },
    );
  }
}
