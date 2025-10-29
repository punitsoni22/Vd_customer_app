import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/routing/routes.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_summary_rowtext.dart';
import 'package:vd_customer_app/core/utils/prefs/prefs.dart';
import 'package:vd_customer_app/feature/cart_screen/provider/cart_provider.dart';
import 'package:vd_customer_app/feature/cart_screen/widgets/cart_info_container.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_appbar.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_button.dart';
import 'package:vd_customer_app/feature/cart_screen/widgets/cart_items.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // initial fetch is handled centrally by BottomBarScreen when this tab
    // is created. Avoid doing network calls here to prevent duplicate calls.
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CartProvider>();
    final items = provider.cartItems;
    final subtotal = provider.subtotal;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(title: 'Cart'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 21.0, vertical: 10),
        child: Column(
          children: [
            CustomInfoContainer(
              icon: Icons.info_outline,
              text:
                  'Your Cart contains both Regular and subscription items. They will be processed separately at the checkout',
              backgroundColor: AllColors.cartinfocontainercolor,
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final provider = context.read<CartProvider>();
                  final userIdString = await Prefs.getString(Prefs.keyUserId);
                  if (userIdString != null) {
                    await provider.fetchLatestCart();
                  }
                },
                child: items.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 100),
                          Center(child: Text("Your cart is empty")),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(12),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final product = items[index];
                          return CartItem(item: product);
                        },
                      ),
              ),
            ),
            const SizedBox(height: 10),
            CustomInfoContainer(
              borderColor: AllColors.greyborderColor,
              icon: Icons.location_on_outlined,
              text: 'Delivery Update: Standard Delivery (2-3 Days)',
              textColor: const Color.fromARGB(255, 81, 81, 81),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AllColors.greyborderColor),
              ),
              child: Column(
                children: [
                  Summary(
                    label: "Subtotal",
                    value: "₹${subtotal.toStringAsFixed(2)}",
                  ),
                  const Summary(label: "Savings", value: "-₹0.00"),
                  const Divider(),
                  Summary(
                    label: "Total",
                    value: "₹${subtotal.toStringAsFixed(2)}",
                    isBold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            CommonButton(
              onTap: () {
                context.pushNamed(AppRoutes.checkoutScreen);
              },
              buttonValue: 'Proceed To Checkout',
              backgroundColor: AllColors.iconColor,
            ),
          ],
        ),
      ),
    );
  }
}
