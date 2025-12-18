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
      backgroundColor: Colors.white,
      appBar: CommonAppBar(
        title: 'Plan Details',
        showBack: true,
        onBack: () => context.pop(),
      ),
      body: Consumer<SubscriptionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingPlans) {
            return const Center(child: CircularProgressIndicator());
          }

          final plan = provider.selectedPlan;

          if (plan == null) {
            return const Center(child: Text("Plan not found"));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPlanHeader(plan),
                SizedBox(height: 20.h),
                _buildSectionTitle('Products Included'),
                SizedBox(height: 10.h),
                _buildProductsList(plan.products),
                SizedBox(height: 20.h),
                _buildSectionTitle('Delivery Details'),
                SizedBox(height: 10.h),
                _buildDeliveryDetails(plan),
                SizedBox(height: 20.h),
                _buildSectionTitle('Subscription Dates'),
                SizedBox(height: 10.h),
                _buildDateFields(),
                SizedBox(height: 20.h),
                _buildSectionTitle('Delivery Address'),
                SizedBox(height: 10.h),
                _buildAddressSelection(provider),
                SizedBox(height: 20.h),
                _buildSectionTitle('Preferred Timing'),
                SizedBox(height: 10.h),
                _buildTimingDropdown(),
                SizedBox(height: 20.h),
                _buildSectionTitle('Remarks (Optional)'),
                SizedBox(height: 10.h),
                _buildRemarksField(),
                SizedBox(height: 30.h),
                CommonButton(
                  buttonValue: 'Create Subscription',
                  isLoading: isLoading,
                  onTap: _createSubscription,
                  backgroundColor: AllColors.tabBarline,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlanHeader(AdminPlanModel plan) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AllColors.olivegreenColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AllColors.olivegreenColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan.planName,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AllColors.olivegreenColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            plan.planDescription,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Text(
                '₹${plan.finalPrice}',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AllColors.olivegreenColor,
                ),
              ),
              if (plan.discountPercentage != '0') ...[
                SizedBox(width: 8.w),
                Text(
                  '₹${plan.totalPrice}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                SizedBox(width: 4.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    '${plan.discountPercentage}% OFF',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: AllColors.olivegreenColor,
      ),
    );
  }

  Widget _buildProductsList(List<PlanProduct> products) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              if (product.images.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.network(
                    product.images.first.imageUrl,
                    width: 60.w,
                    height: 60.h,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60.w,
                      height: 60.h,
                      color: Colors.grey.shade200,
                      child: Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${product.selectedVariant.quantityInMl}ml - ₹${product.selectedVariant.price}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Qty: ${product.quantity}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AllColors.olivegreenColor,
                      ),
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
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, color: AllColors.olivegreenColor),
              SizedBox(width: 8.w),
              Text(
                'Subscription Type: ${plan.subscriptionType.replaceAll('_', ' ')}',
                style: TextStyle(fontSize: 13.sp),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.local_shipping, color: AllColors.olivegreenColor),
              SizedBox(width: 8.w),
              Text(
                'Frequency: ${plan.deliveryFrequencyType}',
                style: TextStyle(fontSize: 13.sp),
              ),
            ],
          ),
          if (plan.deliveryDays.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.today, color: AllColors.olivegreenColor),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Delivery Days: ${plan.deliveryDays.join(', ')}',
                    style: TextStyle(fontSize: 13.sp),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateFields() {
    return Column(
      children: [
        _buildDateField('Start Date', startDate, true),
        SizedBox(height: 12.h),
        _buildDateField('End Date', endDate, false),
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
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AllColors.olivegreenColor),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    value != null
                        ? "${value.day.toString().padLeft(2, '0')}-${value.month.toString().padLeft(2, '0')}-${value.year}"
                        : 'Select $label',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
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
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on, color: AllColors.olivegreenColor),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                selectedAddressId != null
                    ? provider.addresses
                          .firstWhere(
                            (a) => a.id.toString() == selectedAddressId,
                          )
                          .fullAddress
                    : 'Select Address',
                style: TextStyle(fontSize: 14.sp),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildTimingDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: preferredTiming,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: AllColors.olivegreenColor),
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
      decoration: InputDecoration(
        hintText: 'Enter any special instructions...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
      onChanged: (value) {
        remarks = value;
      },
    );
  }
}
