import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_appbar.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_button.dart';
import 'package:vd_customer_app/feature/checkout_screen/provider/checkout_provider.dart';
import 'package:vd_customer_app/feature/checkout_screen/widgets/payment_cards.dart';
import 'package:vd_customer_app/feature/subscription_date_screen/provider/subscription_provider.dart';
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
  final TextEditingController _couponController = TextEditingController();
  String? _appliedCouponCode;
  double _couponDiscount = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateTotalAmount();
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
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
      double price =
          double.tryParse(
            product['sellingPrice']?.toString() ??
                product['price']?.toString() ??
                '0',
          ) ??
          0.0;
      int quantity = int.tryParse(product['quantity']?.toString() ?? '1') ?? 1;
      productCostPerDelivery += price * quantity;
    }

    // If bottles_per_delivery is in payload and overrides product quantity?
    // Assuming product quantity is per delivery.

    setState(() {
      _totalAmount = productCostPerDelivery * totalDeliveries;
      _couponDiscount = 0.0;
      _appliedCouponCode = null;
      _couponController.clear();
    });
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  void _applyCouponFromList(
    String code,
    List<Map<String, dynamic>> coupons,
    double subtotal,
  ) {
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) return;

    Map<String, dynamic>? matched;
    for (final c in coupons) {
      final cCode = c['couponCode']?.toString().trim().toUpperCase();
      if (cCode == normalized) {
        matched = c;
        break;
      }
    }

    if (matched == null) {
      setState(() {
        _appliedCouponCode = null;
        _couponDiscount = 0.0;
      });
      MySnackBar.showSnackBar(context, 'Invalid or expired coupon code');
      return;
    }

    final couponValue =
        double.tryParse(matched['couponValue']?.toString() ?? '') ?? 0.0;
    final couponType = matched['couponType'] ?? 'PERCENTAGE';

    double discount = 0.0;
    if (couponType == 'PERCENTAGE') {
      discount = (subtotal * couponValue) / 100;
    } else {
      discount = couponValue;
    }
    if (discount > subtotal) discount = subtotal;

    if (discount <= 0) {
      setState(() {
        _appliedCouponCode = null;
        _couponDiscount = 0.0;
      });
      MySnackBar.showSnackBar(context, 'Invalid or expired coupon code');
      return;
    }

    setState(() {
      _appliedCouponCode = normalized;
      _couponDiscount = discount;
    });
    _couponController.text = normalized;
    MySnackBar.showSnackBar(
      context,
      'Coupon applied! You save ₹${discount.toStringAsFixed(2)}',
    );
  }

  Future<void> _openCouponsSheet() async {
    final checkoutProvider = context.read<CheckoutProvider>();
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return FutureBuilder(
          future: checkoutProvider.fetchCoupons(_totalAmount),
          builder: (context, snapshot) {
            final coupons = checkoutProvider.coupons;
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: Column(
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
                  SizedBox(height: 16.h),
                  Text(
                    "Available Coupons",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  const Divider(height: 1),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (coupons.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_offer_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              "No coupons available",
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.all(12.r),
                        itemCount: coupons.length,
                        separatorBuilder: (_, __) => SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final coupon = coupons[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.confirmation_num_outlined,
                                  color: Colors.orange,
                                  size: 20.sp,
                                ),
                              ),
                              title: Text(
                                coupon['couponCode'] ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                              ),
                              trailing: TextButton(
                                onPressed: () {
                                  Navigator.pop(context, coupon['couponCode']);
                                },
                                child: Text(
                                  "APPLY",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AllColors.iconColor,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  SizedBox(height: 20.h),
                ],
              ),
            );
          },
        );
      },
    );

    if (!mounted) return;
    if (result != null && result.trim().isNotEmpty) {
      final coupons = context.read<CheckoutProvider>().coupons;
      _applyCouponFromList(result, coupons, _totalAmount);
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
    if ((_appliedCouponCode ?? '').trim().isNotEmpty) {
      finalPayload['couponCode'] = _appliedCouponCode!.trim();
    }

    final apiPayload = {"data": finalPayload};

    final response = await provider.createOrEditSubscription(
      context,
      apiPayload,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (response['success'] != true &&
        response['message'] != 'Proceeding to payment...') {
      MySnackBar.showSnackBar(
        context,
        response['message'] ?? 'Payment failed. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final payableAmount = (_totalAmount - _couponDiscount) < 0
        ? 0.0
        : (_totalAmount - _couponDiscount);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CommonAppBar(title: 'Payment', showBack: true),
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
                            "₹${payableAmount.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 32.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (_couponDiscount > 0) ...[
                            SizedBox(height: 8.h),
                            Text(
                              'You saved ₹${_couponDiscount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AllColors.olivegreenColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    Container(
                      padding: EdgeInsets.all(16.r),
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
                            "Offers & Coupons",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: _openCouponsSheet,
                                child: Container(
                                  padding: EdgeInsets.all(12.r),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.local_offer_outlined,
                                    color: AllColors.iconColor,
                                    size: 24.sp,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: TextField(
                                  controller: _couponController,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  decoration: InputDecoration(
                                    hintText: "Enter coupon code",
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 10.h,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                      borderSide: BorderSide(
                                        color: AllColors.buttonColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              SizedBox(
                                height: 44.h,
                                child: Consumer<CheckoutProvider>(
                                  builder: (context, checkoutProvider, _) {
                                    final isApplied =
                                        (_appliedCouponCode ?? '').isNotEmpty &&
                                        _couponDiscount > 0;
                                    return ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isApplied
                                            ? Colors.green
                                            : AllColors.buttonColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10.r,
                                          ),
                                        ),
                                      ),
                                      onPressed: () async {
                                        if (isApplied) {
                                          setState(() {
                                            _appliedCouponCode = null;
                                            _couponDiscount = 0.0;
                                          });
                                          _couponController.clear();
                                          MySnackBar.showSnackBar(
                                            context,
                                            'Coupon removed',
                                          );
                                          return;
                                        }

                                        final code = _couponController.text
                                            .trim()
                                            .toUpperCase();
                                        if (code.isEmpty) return;

                                        if (checkoutProvider.coupons.isEmpty) {
                                          await checkoutProvider.fetchCoupons(
                                            _totalAmount,
                                          );
                                        }
                                        if (!mounted) return;

                                        _applyCouponFromList(
                                          code,
                                          checkoutProvider.coupons,
                                          _totalAmount,
                                        );
                                      },
                                      child: Text(
                                        isApplied ? 'Applied' : 'Apply',
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          if ((_appliedCouponCode ?? '').trim().isNotEmpty &&
                              _couponDiscount > 0) ...[
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 16.sp,
                                  color: AllColors.olivegreenColor,
                                ),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    'Applied: ${_appliedCouponCode!.trim()} (save ₹${_couponDiscount.toStringAsFixed(2)})',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _appliedCouponCode = null;
                                      _couponDiscount = 0.0;
                                    });
                                    _couponController.clear();
                                  },
                                  child: const Text('Remove'),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

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
                buttonValue: "Pay ₹${payableAmount.toStringAsFixed(2)}",
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
