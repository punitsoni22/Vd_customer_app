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
    await provider.checkDeliveryPincode(pinCode);

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
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Step ${checkoutProvider.currentStep} of 2",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AllColors.iconColor,
                          ),
                        ),
                        Text(
                          checkoutProvider.currentStep == 1
                              ? "Address Selection"
                              : "Payment & Review",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    LinearProgressIndicator(
                      value: checkoutProvider.currentStep / 2,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AllColors.iconColor,
                      ),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
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
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: isSelected
                  ? AllColors.iconColor.withValues(alpha: 0.05)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected
                    ? AllColors.iconColor
                    : AllColors.textfieldborderColor,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Radio<int>(
                  value: address.id,
                  groupValue: provider.selectedAddress?.id,
                  activeColor: AllColors.iconColor,
                  onChanged: (val) => provider.selectAddress(address),
                ),
                SizedBox(width: 8.w),
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
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          if (address.isDefault) ...[
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                "Default",
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        address.fullAddress,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 2.h),
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
    final deliveryCharge = 0.0;
    final estimatedTax = 0.0;
    final subtotal = cartProvider.subtotal;
    final totalAmount = subtotal - discount + deliveryCharge - estimatedTax;
    final selectedAddress = checkoutProvider.selectedAddress;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedAddress != null) ...[
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: AllColors.iconColor,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Delivering to:",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          selectedAddress.fullAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
                  TextButton(
                    onPressed: () => checkoutProvider.setStep(1),
                    child: Text(
                      "Change",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AllColors.iconColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
          ],

          Text(
            "Payment Options",
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6.h),
          Column(
            children: [
              PaymentOptionCard(
                icon: Icons.qr_code,
                title: "UPI",
                badge: "Instant",
                selected: _selectedPaymentIndex == 0,
                onTap: () => setState(() => _selectedPaymentIndex = 0),
              ),
              PaymentOptionCard(
                icon: Icons.local_shipping,
                title: "Cash on Delivery",
                badge: "Easy",
                selected: _selectedPaymentIndex == 1,
                onTap: () => setState(() => _selectedPaymentIndex = 1),
              ),
              PaymentOptionCard(
                icon: Icons.qr_code,
                title: "QR Code",
                badge: "Scan",
                selected: _selectedPaymentIndex == 2,
                onTap: () => setState(() => _selectedPaymentIndex = 2),
              ),
            ],
          ),

          SizedBox(height: 12.h),
          Text(
            "Offers & Coupons",
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
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
                                SizedBox(height: 10.h),
                                Container(
                                  width: 50.w,
                                  height: 5.h,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10.r),
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
                                        return Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey[300]!,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                          ),
                                          child: ListTile(
                                            title: Text(
                                              coupon['couponCode'] ?? '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            subtitle: Text(
                                              coupon['description'] ?? '',
                                            ),
                                            trailing: TextButton(
                                              onPressed: () {
                                                Navigator.pop(
                                                  context,
                                                  coupon['couponCode'],
                                                );
                                              },
                                              child: const Text("APPLY"),
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
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AllColors.textfieldborderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
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
          SizedBox(height: 80.h),
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
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
                style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
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
              buttonValue: checkoutProvider.currentStep == 1
                  ? 'Next'
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
                    final qrCode = orderData['qrCode'];
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
