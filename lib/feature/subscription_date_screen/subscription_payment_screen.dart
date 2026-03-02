import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_appbar.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_button.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_summary_rowtext.dart';
import 'package:vd_customer_app/feature/checkout_screen/widgets/payment_cards.dart';
import 'package:vd_customer_app/feature/subscription_date_screen/provider/subscription_provider.dart';
import 'package:vd_customer_app/feature/subscription_plan_details/utils/subscription_date_helper.dart';
import 'package:vd_customer_app/widget/snack_bar.dart';

class SubscriptionPaymentScreen extends StatefulWidget {
  final Map<String, dynamic> payload;
  final List<Map<String, dynamic>> selectedProducts;
  final String frequency;
  final DateTime startDate;
  final DateTime endDate;

  const SubscriptionPaymentScreen({
    super.key,
    required this.payload,
    required this.selectedProducts,
    required this.frequency,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<SubscriptionPaymentScreen> createState() =>
      _SubscriptionPaymentScreenState();
}

class _SubscriptionPaymentScreenState extends State<SubscriptionPaymentScreen> {
  bool _isLoading = false;
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateTotalAmount();
  }

  void _calculateTotalAmount() {
    // Calculate total deliveries
    int totalDeliveries = 0;
    
    // We can use SubscriptionDateHelper if available or reimplement logic
    // Based on frequency and dates
    int daysDiff = widget.endDate.difference(widget.startDate).inDays + 1;
    
    final freq = widget.frequency.toLowerCase();
    
    if (freq == 'daily') {
      totalDeliveries = daysDiff;
    } else if (freq == 'weekly') {
      // Logic for weekly depends on selected days
      // We can try to get delivery_days from payload if available
      List<dynamic> deliveryDays = widget.payload['delivery_days'] ?? [];
      if (deliveryDays.isNotEmpty) {
        // Count how many of these days exist in the range
        int count = 0;
        for (int i = 0; i < daysDiff; i++) {
          DateTime date = widget.startDate.add(Duration(days: i));
          // get weekday name
          String dayName = _getDayName(date.weekday);
          if (deliveryDays.contains(dayName)) {
            count++;
          }
        }
        totalDeliveries = count;
      } else {
        // Fallback or assume 1 per week? 
        totalDeliveries = (daysDiff / 7).ceil(); 
      }
    } else if (freq == 'alternate days' || freq == 'alternate_days') {
       totalDeliveries = (daysDiff / 2).ceil();
    } else if (freq == 'custom date' || freq == 'custom_date') {
       List<dynamic> dates = widget.payload['delivery_dates'] ?? [];
       totalDeliveries = dates.length;
    } else {
      totalDeliveries = daysDiff; // Default
    }

    // Calculate product cost
    double productCostPerDelivery = 0.0;
    
    for (var product in widget.selectedProducts) {
      double price = double.tryParse(product['sellingPrice']?.toString() ?? 
                                     product['price']?.toString() ?? '0') ?? 0.0;
      int quantity = int.tryParse(product['quantity']?.toString() ?? '1') ?? 1;
      productCostPerDelivery += price * quantity;
    }

    // If bottles_per_delivery is in payload and overrides product quantity?
    // Assuming product quantity is per delivery.
    
    setState(() {
      _totalAmount = productCostPerDelivery * totalDeliveries;
    });
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  Future<void> _handlePayment() async {
    setState(() {
      _isLoading = true;
    });

    final provider = context.read<SubscriptionProvider>();
    
    // Ensure paymentMode is ONLINE
    final finalPayload = Map<String, dynamic>.from(widget.payload);
    finalPayload['paymentMode'] = 'ONLINE';
    
    final apiPayload = {"data": finalPayload};

    final response = await provider.createOrEditSubscription(context, apiPayload);

    if (!mounted) return;
    
    setState(() {
      _isLoading = false;
    });
    
    if (response['success'] != true && response['message'] != 'Proceeding to payment...') {
       MySnackBar.showSnackBar(
         context,
         response['message'] ?? 'Payment failed. Please try again.',
       );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CommonAppBar(
        title: 'Payment',
        showBack: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount Card
                    Container(
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total Amount",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "₹${_totalAmount.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 32.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 24.h),
                    
                    Text(
                      "Payment Method",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AllColors.iconColor,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    
                    // Only Online Payment Option
                    PaymentOptionCard(
                      icon: Icons.payment,
                      title: "Online Payment",
                      badge: "FASTEST",
                      selected: true,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Bar
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: CommonButton(
                buttonValue: "Pay ₹${_totalAmount.toStringAsFixed(2)}",
                onTap: _isLoading ? null : _handlePayment,
                isLoading: _isLoading,
                backgroundColor: AllColors.buttonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
