import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/feature/subscription_date_screen/provider/subscription_provider.dart'
    as subscription;

import '../../core/theme/colors.dart';
import '../../core/utils/common_widgets/common_appbar.dart';
import '../../core/utils/common_widgets/common_button.dart';
import '../../core/utils/common_widgets/common_summary_rowtext.dart';
import '../../core/utils/common_widgets/common_textfield.dart';
import '../../widget/snack_bar.dart';
import '../cart_screen/provider/cart_provider.dart';
import '../subscription_date_screen/widgets/address_bottom_sheet.dart';
import 'provider/checkout_provider.dart';
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

  Future<void> _handleNextStep(CheckoutProvider provider) async {
    final selectedAddress = provider.selectedAddress;
    if (selectedAddress == null) {
      MySnackBar.showSnackBar(context, "Please select an address");
      return;
    }

    final pinCode = selectedAddress.postalCode;
    final cartProvider = context.read<CartProvider>();
    await provider.checkDeliveryPincode(pinCode, cartProvider.cartId);

    if (provider.isDeliverable) {
      provider.setStep(2);
    } else {
      MySnackBar.showSnackBar(
        context,
        provider.deliveryMessage.isNotEmpty
            ? provider.deliveryMessage
            : "Sorry, we cannot deliver to this address",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final checkoutProvider = context.watch<CheckoutProvider>();

    return PopScope(
      canPop: checkoutProvider.currentStep == 1,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (checkoutProvider.currentStep == 2) {
          checkoutProvider.setStep(1);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: CommonAppBar(
          title: 'Checkout',
          showBack: true,
          onBackTap: () {
            if (checkoutProvider.currentStep == 2) {
              checkoutProvider.setStep(1);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Step ${checkoutProvider.currentStep} of 2",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AllColors.iconColor,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: Text(
                            checkoutProvider.currentStep == 1
                                ? "Address Selection"
                                : "Payment & Review",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Stack(
                      children: [
                        Container(
                          height: 6.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          height: 6.h,
                          width:
                              MediaQuery.of(context).size.width *
                              (checkoutProvider.currentStep / 2),
                          decoration: BoxDecoration(
                            color: AllColors.iconColor,
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: checkoutProvider.currentStep == 1
                    ? _buildStep1(checkoutProvider)
                    : _buildStep2(context, checkoutProvider, cartProvider),
              ),
              _buildBottomBar(context, checkoutProvider, cartProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1(CheckoutProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.addresses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 64.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              "No saved addresses found",
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 24.h),
            CommonButton(
              buttonValue: 'Add New Address',
              backgroundColor: AllColors.buttonColor,
              selfconstraints: BoxConstraints(maxWidth: 200.w),
              onTap: () async {
                final added = await showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const AddressBottomSheet(),
                );
                if (added == true) {
                  if (context.mounted) {
                    Provider.of<subscription.SubscriptionProvider>(
                      context,
                      listen: false,
                    ).getAllAddresses(context);
                    provider.fetchAddresses();
                  }
                }
              },
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: provider.addresses.length + 1,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        if (index == provider.addresses.length) {
          return OutlinedButton.icon(
            onPressed: () async {
              final added = await showModalBottomSheet<bool>(
                context: context,
                isScrollControlled: true,
                builder: (_) => const AddressBottomSheet(),
              );
              if (added == true) {
                if (context.mounted) {
                  Provider.of<subscription.SubscriptionProvider>(
                    context,
                    listen: false,
                  ).getAllAddresses(context);
                  provider.fetchAddresses();
                }
              }
            },
            icon: const Icon(Icons.add),
            label: const Text("Add New Address"),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              side: BorderSide(color: AllColors.iconColor),
              foregroundColor: AllColors.iconColor,
            ),
          );
        }

        final address = provider.addresses[index];
        final isSelected = provider.selectedAddress?.id == address.id;

        return InkWell(
          onTap: () => provider.selectAddress(address),
          borderRadius: BorderRadius.circular(16.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: isSelected
                  ? AllColors.iconColor.withValues(alpha: 0.05)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected ? AllColors.iconColor : Colors.grey.shade200,
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: isSelected ? 0.05 : 0.02,
                  ),
                  blurRadius: isSelected ? 12 : 4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(2.r),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AllColors.iconColor
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? AllColors.iconColor
                          : Colors.transparent,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Address",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          if (address.isDefault) ...[
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(
                                  color: Colors.green.shade200,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                "Default",
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        address.fullAddress,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[800],
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "${address.city}, ${address.state} - ${address.postalCode}",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStep2(
    BuildContext context,
    CheckoutProvider checkoutProvider,
    CartProvider cartProvider,
  ) {
    final discount = checkoutProvider.couponDiscount;
    final subtotal = cartProvider.subtotal;
    final totalAmount = subtotal - discount;
    final selectedAddress = checkoutProvider.selectedAddress;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedAddress != null) ...[
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: AllColors.iconColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          color: AllColors.iconColor,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        "Delivering to",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => checkoutProvider.setStep(1),
                          borderRadius: BorderRadius.circular(8.r),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            child: Text(
                              "Change",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AllColors.iconColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 44.w,
                      ), // Align with text above (icon + padding + spacing)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedAddress.fullAddress,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800],
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "${selectedAddress.city}, ${selectedAddress.postalCode}",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
          ],

          Text(
            "Payment Options",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          Column(
            children: [
              PaymentOptionCard(
                icon: Icons.qr_code_scanner_rounded,
                title: "UPI",
                badge: "Instant",
                selected: _selectedPaymentIndex == 0,
                onTap: () => setState(() => _selectedPaymentIndex = 0),
              ),
              PaymentOptionCard(
                icon: Icons.local_shipping_outlined,
                title: "Cash on Delivery",
                badge: "Easy",
                selected: _selectedPaymentIndex == 1,
                onTap: () => setState(() => _selectedPaymentIndex = 1),
              ),
              PaymentOptionCard(
                icon: Icons.qr_code_2_rounded,
                title: "QR Code",
                badge: "Scan",
                selected: _selectedPaymentIndex == 2,
                onTap: () => setState(() => _selectedPaymentIndex = 2),
              ),
            ],
          ),

          SizedBox(height: 24.h),
          Text(
            "Offers & Coupons",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  final result = await showModalBottomSheet<String>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20.r),
                      ),
                    ),
                    builder: (context) {
                      final cartProvider = context.read<CartProvider>();
                      final checkoutProvider = context.read<CheckoutProvider>();

                      return FutureBuilder(
                        future: checkoutProvider.fetchCoupons(
                          cartProvider.subtotal,
                        ),
                        builder: (context, snapshot) {
                          final coupons = checkoutProvider.coupons;

                          return Container(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.7,
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
                                            color: Colors.grey[300],
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
                                      separatorBuilder: (_, __) =>
                                          SizedBox(height: 12.h),
                                      itemBuilder: (context, index) {
                                        final coupon = coupons[index];
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                              color: Colors.grey.shade200,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.02,
                                                ),
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
                                                Navigator.pop(
                                                  context,
                                                  coupon['couponCode'],
                                                );
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

                  if (result != null && result.isNotEmpty) {
                    _couponController.text = result;
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade300),
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
                        vertical: 12.h,
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
                          MySnackBar.showSnackBar(context, "Coupon removed");
                        } else {
                          final couponCode = _couponController.text
                              .trim()
                              .toUpperCase();
                          if (couponCode.isNotEmpty) {
                            final cartProvider = context.read<CartProvider>();
                            checkoutProvider.applyCoupon(
                              couponCode,
                              cartProvider.subtotal,
                            );

                            if (checkoutProvider.couponDiscount > 0) {
                              checkoutProvider.setAppliedCoupon(couponCode);
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
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
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
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    children: [
                      Summary(
                        label: "Subtotal",
                        value: "₹${subtotal.toStringAsFixed(2)}",
                      ),
                      SizedBox(height: 8.h),
                      Summary(
                        label: "Discount",
                        value: "-₹${discount.toStringAsFixed(2)}",
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                const Divider(),
                SizedBox(height: 8.h),
                Summary(
                  label: "Total Amount",
                  value: "₹${totalAmount.toStringAsFixed(2)}",
                  isBold: true,
                  color: AllColors.iconColor,
                  fontSize: 18.sp,
                ),
              ],
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    CheckoutProvider checkoutProvider,
    CartProvider cartProvider,
  ) {
    final discount = checkoutProvider.couponDiscount;
    final deliveryCharge = 0.0;
    final estimatedTax = 0.0;
    final subtotal = cartProvider.subtotal;
    final totalAmount = subtotal - discount + deliveryCharge - estimatedTax;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Payable Amount",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "₹${totalAmount.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AllColors.iconColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          SizedBox(
            width: 180.w,
            child: CommonButton(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              buttonValue: checkoutProvider.currentStep == 1
                  ? 'Proceed to Pay'
                  : 'Confirm Order',
              backgroundColor: AllColors.iconColor,
              isLoading:
                  checkoutProvider.isLoading ||
                  checkoutProvider.isCheckingDelivery,
              onTap: () async {
                if (checkoutProvider.currentStep == 1) {
                  await _handleNextStep(checkoutProvider);
                } else {
                  String paymentMode = 'ONLINE';
                  if (_selectedPaymentIndex == 1) paymentMode = 'POD';
                  if (_selectedPaymentIndex == 2) paymentMode = 'QR';

                  final orderData = await checkoutProvider.placeOrder(
                    cartProvider: cartProvider,
                    context: context,
                    couponCode: _couponController.text.trim(),
                    paymentMode: paymentMode,
                  );

                  if (orderData != null && context.mounted) {
                    final qrCode = orderData['qrCode']['qrCodeUrl'];
                    if ((paymentMode == 'QR' ||
                        (qrCode != null && qrCode.isNotEmpty))) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) => QRPaymentModal(
                          qrData: qrCode ?? '',
                          orderId: orderData['id'] is int
                              ? orderData['id']
                              : int.tryParse(orderData['id'].toString()) ?? 0,
                          onPaymentSuccess: (order) {
                            checkoutProvider.handleQRPaymentSuccess(
                              order,
                              cartProvider,
                              context,
                            );
                          },
                          onExpired: () {},
                        ),
                      );
                    }
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
