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
import 'package:vd_customer_app/feature/checkout_screen/widgets/info_icon_button.dart';
import 'widgets/address_container.dart';
import 'widgets/delivery_time_cards.dart';
import 'widgets/payment_cards.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedDeliveryIndex = 0;
  int _selectedPaymentIndex = 0;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<CheckoutProvider>().fetchAddresses();
      await context.read<CartProvider>().fetchLatestCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final checkoutProvider = Provider.of<CheckoutProvider>(context);

    final discount = 0.0;
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
                    InfoIconButton(),

                    Expanded(
                      flex: 3,
                      child: CommonTextField(
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
                      child: CommonButton(
                        padding: EdgeInsets.symmetric(
                          vertical: 8.h,
                          horizontal: 12.w,
                        ),
                        buttonValue: 'Apply',
                        backgroundColor: AllColors.iconColor,
                        onTap: () {},
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
              child: checkoutProvider.isLoading
                  ? const CircularProgressIndicator()
                  : CommonButton(
                      buttonValue: 'Confirm Order',
                      backgroundColor: AllColors.iconColor,
                      onTap: () async {
                        final cartProvider = context.read<CartProvider>();
                        final checkoutProvider = context
                            .read<CheckoutProvider>();

                        await checkoutProvider.placeOrder(
                          cartProvider: cartProvider,
                          context: context,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
