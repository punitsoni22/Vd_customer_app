import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_appbar.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_button.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_summary_rowtext.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_textfield.dart';
import 'package:vd_customer_app/feature/cart_screen/provider/cart_provider.dart';
import 'package:vd_customer_app/feature/checkout_screen/provider/checkout_provider.dart';
import 'package:flutter/services.dart';
import 'package:vd_customer_app/widget/snack_bar.dart';
import 'widgets/address_container.dart';
import 'widgets/payment_cards.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedPaymentIndex = 0;
  final TextEditingController _couponController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<CheckoutProvider>().fetchAddresses();
      await context.read<CartProvider>().fetchLatestCart(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final checkoutProvider = Provider.of<CheckoutProvider>(context);

    final discount = checkoutProvider.couponDiscount;
    final deliveryCharge = 0.0;
    final estimatedTax = 0.0;
    final subtotal = cartProvider.subtotal;
    final defaultAddress = checkoutProvider.selectedAddress;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(title: 'Checkout', showBack: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AddressContainer(selectedAddress: defaultAddress),
            SizedBox(height: 10.h),

            Padding(
              padding: EdgeInsets.only(left: 16.w),
              child: Text(
                "Payment Options",
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                border: Border.all(color: AllColors.textfieldborderColor),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  PaymentOptionCard(
                    icon: Icons.qr_code,
                    title: "UPI",
                    badge: "Instant",
                    selected: _selectedPaymentIndex == 0,
                    onTap: () => setState(() => _selectedPaymentIndex = 0),
                  ),
                  PaymentOptionCard(
                    icon: Icons.credit_card,
                    title: "Card Payment",
                    badge: "Secure",
                    selected: _selectedPaymentIndex == 1,
                    onTap: () => setState(() => _selectedPaymentIndex = 1),
                  ),
                  PaymentOptionCard(
                    icon: Icons.local_shipping,
                    title: "Cash on Delivery",
                    badge: "Easy",
                    selected: _selectedPaymentIndex == 2,
                    onTap: () => setState(() => _selectedPaymentIndex = 2),
                  ),
                  PaymentOptionCard(
                    icon: Icons.account_balance_wallet,
                    title: "Wallet",
                    badge: "Fast",
                    selected: _selectedPaymentIndex == 3,
                    onTap: () => setState(() => _selectedPaymentIndex = 3),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              child: SizedBox(
                height: 40.h,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final result = await showModalBottomSheet<String>(
                          context: context,
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20.r),
                            ),
                          ),
                          builder: (context) {
                            final cartProvider = context.read<CartProvider>();
                            final checkoutProvider = context
                                .read<CheckoutProvider>();

                            return FutureBuilder(
                              future: checkoutProvider.fetchCoupons(
                                cartProvider.subtotal,
                              ),
                              builder: (context, snapshot) {
                                final coupons = checkoutProvider.coupons;

                                return Container(
                                  constraints: BoxConstraints(
                                    maxHeight:
                                        MediaQuery.of(context).size.height *
                                        0.7,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Handle bar
                                      SizedBox(height: 10.h),
                                      Container(
                                        width: 50.w,
                                        height: 5.h,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(
                                            10.r,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 15.h),

                                      // Title
                                      Text(
                                        "Available Coupons",
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 10.h),
                                      const Divider(),

                                      // Coupons list or empty state
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting)
                                        const Expanded(
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        )
                                      else if (coupons.isEmpty)
                                        Expanded(
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.local_offer_outlined,
                                                  size: 64.sp,
                                                  color: Colors.grey[400],
                                                ),
                                                SizedBox(height: 16.h),
                                                Text(
                                                  "No coupons available",
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    color: Colors.grey[600],
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
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16.w,
                                            ),
                                            itemCount: coupons.length,
                                            separatorBuilder: (_, __) =>
                                                SizedBox(height: 12.h),
                                            itemBuilder: (context, index) {
                                              final coupon = coupons[index];
                                              return _buildCouponCard(
                                                context,
                                                coupon,
                                                cartProvider.subtotal,
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

                        if (result != null && result.isNotEmpty) {
                          _couponController.text = result;
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        child: Icon(Icons.info_outline, color: Colors.grey),
                      ),
                    ),

                    Expanded(
                      flex: 3,
                      child: CommonTextField(
                        controller: _couponController,
                        label: 'Enter Coupon Code',
                        padding: EdgeInsets.symmetric(
                          vertical: 8.h,
                          horizontal: 12.w,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      flex: 2,
                      child: Consumer<CheckoutProvider>(
                        builder: (context, checkoutProvider, child) {
                          return CommonButton(
                            padding: EdgeInsets.symmetric(
                              vertical: 8.h,
                              horizontal: 12.w,
                            ),
                            buttonValue:
                                checkoutProvider.appliedCouponCode != null
                                ? 'Applied'
                                : 'Apply',
                            backgroundColor:
                                checkoutProvider.appliedCouponCode != null
                                ? Colors.green
                                : AllColors.iconColor,
                            onTap: () {
                              if (checkoutProvider.appliedCouponCode != null) {
                                // Remove coupon
                                checkoutProvider.clearCoupon();
                                _couponController.clear();
                                MySnackBar.showSnackBar(
                                  context,
                                  "Coupon removed",
                                );
                              } else {
                                // Apply coupon
                                final couponCode = _couponController.text
                                    .trim()
                                    .toUpperCase();
                                if (couponCode.isNotEmpty) {
                                  final cartProvider = context
                                      .read<CartProvider>();
                                  checkoutProvider.applyCoupon(
                                    couponCode,
                                    cartProvider.subtotal,
                                  );

                                  if (checkoutProvider.couponDiscount > 0) {
                                    checkoutProvider.setAppliedCoupon(
                                      couponCode,
                                    );
                                    MySnackBar.showSnackBar(
                                      context,
                                      "Coupon applied! You save ₹${checkoutProvider.couponDiscount.toStringAsFixed(2)}",
                                    );
                                  } else {
                                    MySnackBar.showSnackBar(
                                      context,
                                      "Invalid or expired coupon code",
                                    );
                                    _couponController.clear();
                                  }
                                }
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 5.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: AllColors.textfieldborderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Summary(
                      label: "Subtotal",
                      value: "₹${subtotal.toStringAsFixed(2)}",
                    ),
                    Summary(
                      label: "Discount",
                      value: "-₹${discount.toStringAsFixed(2)}",
                      color: Colors.red,
                    ),
                    Summary(
                      label: "Delivery Charge",
                      value: deliveryCharge == 0
                          ? "Free"
                          : "₹${deliveryCharge.toStringAsFixed(2)}",
                      color: const Color.fromARGB(255, 237, 98, 98),
                    ),
                    Summary(
                      label: "Estimated Tax",
                      value: "-₹${estimatedTax.toStringAsFixed(2)}",
                    ),
                    const Divider(),
                    Summary(
                      label: "Total Amount",
                      value:
                          "₹${(subtotal - discount + deliveryCharge - estimatedTax).toStringAsFixed(2)}",
                      isBold: true,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
            Divider(indent: 20.w, endIndent: 20.w),
            Padding(
              padding: EdgeInsets.all(8.r),
              child: CommonButton(
                buttonValue: 'Confirm Order',
                backgroundColor: AllColors.iconColor,
                isLoading: checkoutProvider.isLoading,
                onTap: () async {
                  final cartProvider = context.read<CartProvider>();
                  final checkoutProvider = context.read<CheckoutProvider>();

                  await checkoutProvider.placeOrder(
                    cartProvider: cartProvider,
                    context: context,
                    couponCode: checkoutProvider.appliedCouponCode ?? "",
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponCard(
    BuildContext context,
    Map<String, dynamic> coupon,
    double subtotal,
  ) {
    final couponCode = coupon['couponCode'] ?? '';
    final couponValue = coupon['couponValue'] ?? '0';
    final couponType = coupon['couponType'] ?? 'PERCENTAGE';
    final maxUsage = coupon['maxUsage'] ?? 0;
    final timesUsed = coupon['timesUsed'] ?? 0;
    final expiryDate = coupon['expiryDate'] ?? '';

    // Calculate discount amount
    double discountAmount = 0.0;
    String discountText = '';

    if (couponType == 'PERCENTAGE') {
      final percentage = double.tryParse(couponValue.toString()) ?? 0.0;
      discountAmount = (subtotal * percentage) / 100;
      discountText = '$couponValue% OFF';
    } else {
      discountAmount = double.tryParse(couponValue.toString()) ?? 0.0;
      discountText = '₹$couponValue OFF';
    }

    // Ensure discount doesn't exceed subtotal
    if (discountAmount > subtotal) {
      discountAmount = subtotal;
    }

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AllColors.iconColor.withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AllColors.iconColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with discount and copy button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AllColors.iconColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  discountText,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: couponCode));

                  MySnackBar.showSnackBar(
                    context,
                    "Coupon code copied to clipboard",
                  );
                },
                icon: Icon(Icons.copy, color: AllColors.iconColor, size: 20.sp),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Coupon code
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: couponCode));
              MySnackBar.showSnackBar(
                context,
                "Coupon code copied to clipboard",
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: Colors.grey[300]!,
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      couponCode,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  Text(
                    'TAP TO COPY',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Savings info
          Row(
            children: [
              Icon(Icons.savings, color: Colors.green, size: 16.sp),
              SizedBox(width: 4.w),
              Text(
                'You save ₹${discountAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Usage and expiry info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Used: $timesUsed/$maxUsage',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              ),
              Text(
                'Expires: ${_formatDate(expiryDate)}',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Apply button
          GestureDetector(
            onTap: () {
              Navigator.pop(context, couponCode);
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: AllColors.iconColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Text(
                  'Apply Coupon',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'N/A';
    try {
      // Handle the format like "09-Nov-2025 03:36PM"
      final parts = dateString.split(' ');
      if (parts.isNotEmpty) {
        return parts[0]; 
      }
      return dateString;
    } catch (e) {
      return 'N/A';
    }
  }
}
