import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_appbar.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_button.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_summary_rowtext.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_textfield.dart';
import 'package:vd_customer_app/feature/cart_screen/provider/cart_provider.dart';
import 'package:vd_customer_app/feature/checkout_screen/provider/checkout_provider.dart';
import 'package:vd_customer_app/widget/snack_bar.dart';

import 'widgets/address_container.dart';
import 'widgets/payment_cards.dart';
import 'widgets/qr_payment_modal.dart';

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
    final cartProvider = context.watch<CartProvider>();
    final checkoutProvider = context.watch<CheckoutProvider>();

    final discount = checkoutProvider.couponDiscount;
    final deliveryCharge = 0.0;
    final estimatedTax = 0.0;
    final subtotal = cartProvider.subtotal;
    final totalAmount = subtotal - discount + deliveryCharge - estimatedTax;
    final defaultAddress = checkoutProvider.selectedAddress;

    return Scaffold(
      appBar: const CommonAppBar(title: 'Checkout', showBack: true),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// ADDRESS SECTION
                    Text(
                      "Delivery Address",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    AddressContainer(selectedAddress: defaultAddress),
                    SizedBox(height: 12.h),
                    Text(
                      "Payment Options",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Column(
                      children: [
                        PaymentOptionCard(
                          icon: Icons.qr_code,
                          title: "UPI",
                          badge: "Instant",
                          selected: _selectedPaymentIndex == 0,
                          onTap: () =>
                              setState(() => _selectedPaymentIndex = 0),
                        ),
                        PaymentOptionCard(
                          icon: Icons.local_shipping,
                          title: "Cash on Delivery",
                          badge: "Easy",
                          selected: _selectedPaymentIndex == 1,
                          onTap: () =>
                              setState(() => _selectedPaymentIndex = 1),
                        ),
                        PaymentOptionCard(
                          icon: Icons.qr_code,
                          title: "QR Code",
                          badge: "Scan",
                          selected: _selectedPaymentIndex == 2,
                          onTap: () =>
                              setState(() => _selectedPaymentIndex = 2),
                        ),
                      ],
                    ),

                    SizedBox(height: 12.h),

                    /// COUPON SECTION
                    Text(
                      "Offers & Coupons",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
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
                                final cartProvider = context
                                    .read<CartProvider>();
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
                                          SizedBox(height: 10.h),
                                          Container(
                                            width: 50.w,
                                            height: 5.h,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                            ),
                                          ),
                                          SizedBox(height: 15.h),
                                          Text(
                                            "Available Coupons",
                                            style: TextStyle(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 10.h),
                                          const Divider(),

                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting)
                                            const Expanded(
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(),
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
                                                      Icons
                                                          .local_offer_outlined,
                                                      size: 64,
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
                            padding: EdgeInsets.all(6.w),
                            child: Icon(
                              Icons.local_offer_outlined,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 3,
                          child: CommonTextField(
                            controller: _couponController,
                            label: 'Enter Coupon Code',
                          ),
                        ),

                        SizedBox(width: 8.w),

                        Expanded(
                          flex: 2,
                          child: Consumer<CheckoutProvider>(
                            builder: (context, checkoutProvider, child) {
                              final isApplied =
                                  checkoutProvider.appliedCouponCode != null;

                              return CommonButton(
                                padding: EdgeInsets.symmetric(
                                  vertical: 8.h,
                                  horizontal: 10.w,
                                ),
                                buttonValue: isApplied ? 'Applied' : 'Apply',
                                backgroundColor: isApplied
                                    ? Colors.green
                                    : AllColors.iconColor,
                                onTap: () {
                                  if (isApplied) {
                                    checkoutProvider.clearCoupon();
                                    _couponController.clear();
                                    MySnackBar.showSnackBar(
                                      context,
                                      "Coupon removed",
                                    );
                                  } else {
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

                    SizedBox(height: 12.h),

                    /// ORDER SUMMARY
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AllColors.textfieldborderColor,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Summary',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h),
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
                            color: deliveryCharge == 0
                                ? Colors.green
                                : const Color.fromARGB(255, 237, 98, 98),
                          ),
                          Summary(
                            label: "Estimated Tax",
                            value: "-₹${estimatedTax.toStringAsFixed(2)}",
                          ),
                          const Divider(),
                          Summary(
                            label: "Total Amount",
                            value: "₹${totalAmount.toStringAsFixed(2)}",
                            isBold: true,
                            color: AllColors.iconColor,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 80.h), // Spacer so content isn't hidden
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Payable Amount",
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "₹${totalAmount.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AllColors.iconColor,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 160.w,
                    child: CommonButton(
                      buttonValue: 'Confirm Order',
                      backgroundColor: AllColors.iconColor,
                      isLoading: checkoutProvider.isLoading,
                      onTap: () async {
                        final cartProvider = context.read<CartProvider>();
                        final checkoutProvider = context
                            .read<CheckoutProvider>();

                        // Map selected index to payment mode
                        String paymentMode = 'ONLINE';
                        if (_selectedPaymentIndex == 1) paymentMode = 'POD';
                        if (_selectedPaymentIndex == 2) paymentMode = 'QR';

                        final orderData = await checkoutProvider.placeOrder(
                          cartProvider: cartProvider,
                          context: context,
                          couponCode: checkoutProvider.appliedCouponCode ?? "",
                          paymentMode: paymentMode,
                        );

                        // If QR data present, show QR modal
                        if (orderData != null &&
                            (orderData['qrCode'] != null &&
                                orderData['qrCode'].toString().isNotEmpty)) {
                          // Extract QR URL from qrCode object
                          String qrUrl = '';
                          final qrCode = orderData['qrCode'];

                          if (qrCode is Map<String, dynamic>) {
                            // If qrCode is an object, extract the URL
                            qrUrl =
                                qrCode['qrCodeUrl']?.toString() ??
                                qrCode['qrCodeString']?.toString() ??
                                qrCode['image_url']?.toString() ??
                                '';
                          } else if (qrCode is String) {
                            // If qrCode is already a string URL
                            qrUrl = qrCode;
                          }

                          if (qrUrl.isEmpty) {
                            MySnackBar.showSnackBar(
                              context,
                              'QR code not available. Please try again.',
                            );
                            return;
                          }

                          final orderId = orderData['id'] is int
                              ? orderData['id'] as int
                              : int.tryParse(
                                      orderData['id']?.toString() ?? '',
                                    ) ??
                                    0;

                          if (!mounted) return;

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (ctx) => QRPaymentModal(
                              qrData: qrUrl,
                              orderId: orderId,
                              onPaymentSuccess: (order) async {
                                // Use the provider method to handle success
                                await checkoutProvider.handleQRPaymentSuccess(
                                  order,
                                  cartProvider,
                                  context,
                                );
                              },
                              onExpired: () {
                                MySnackBar.showSnackBar(
                                  context,
                                  'QR code expired. Please try again.',
                                );
                              },
                            ),
                          );
                        }
                      },
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

    if (discountAmount > subtotal) {
      discountAmount = subtotal;
    }

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AllColors.iconColor.withOpacity(0.08), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AllColors.iconColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
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

          /// COUPON CODE
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

          /// SAVINGS
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

          /// META
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

          /// APPLY BUTTON
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
      final parts = dateString.split(' ');
      if (parts.isNotEmpty) {
        return parts[0]; // e.g., "09-Nov-2025"
      }
      return dateString;
    } catch (_) {
      return 'N/A';
    }
  }
}
