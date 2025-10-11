import 'package:flutter/material.dart';
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
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AddressContainer(selectedAddress: defaultAddress),
            const SizedBox(height: 10),

            const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                "Delivery Time",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 7),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: AllColors.textfieldborderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.5,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  DeliveryTimeCards(
                    title: "Today",
                    time: "9 AM - 12 PM",
                    selected: true,
                  ),
                  DeliveryTimeCards(title: "Today", time: "1 PM - 4 PM"),
                  DeliveryTimeCards(title: "Tomorrow", time: "9 AM - 12 PM"),
                  DeliveryTimeCards(title: "Tomorrow", time: "1 PM - 4 PM"),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                "Payment Options",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: AllColors.textfieldborderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  PaymentOptionCard(
                    icon: Icons.qr_code,
                    title: "UPI",
                    badge: "Instant",
                    selected: true,
                  ),
                  PaymentOptionCard(
                    icon: Icons.credit_card,
                    title: "Card Payment",
                    badge: "Secure",
                  ),
                  PaymentOptionCard(
                    icon: Icons.local_shipping,
                    title: "Cash on Delivery",
                    badge: "Easy",
                  ),
                  PaymentOptionCard(
                    icon: Icons.account_balance_wallet,
                    title: "Wallet",
                    badge: "Fast",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: SizedBox(
                height: 40,
                child: Row(
                  children: [
                    InfoIconButton(),

                    Expanded(
                      flex: 3,
                      child: const CommonTextField(label: 'Enter Coupon Code'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: CommonButton(
                        buttonValue: 'Apply',
                        backgroundColor: AllColors.iconColor,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 5,
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AllColors.textfieldborderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 17,
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
                      color: Colors.blue[600],
                    ),
                  ],
                ),
              ),
            ),
            const Divider(indent: 20, endIndent: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
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
