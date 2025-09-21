import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_summary_rowtext.dart';
import 'package:vd_customer_app/feature/cart_screen/provider/cart_provider.dart';
import 'package:vd_customer_app/feature/cart_screen/widgets/cart_info_container.dart';
import 'package:vd_customer_app/feature/cart_screen/widgets/cart_items.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_appbar.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_button.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CartProvider>();
    final items = provider.cartItems;

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
              child: ListView.builder(
                padding: const EdgeInsets.all(12),

                itemCount: items.length,
                itemBuilder: (context, index) {
                  final product = items[index];
                  return CartItem(item: product);
                },
              ),
            ),
            SizedBox(height: 10),
            CustomInfoContainer(
              borderColor: AllColors.greyborderColor,
              icon: Icons.location_on_outlined,
              text: 'Delivery Update: Standard Delivery (2-3 Days)',
              textColor: const Color.fromARGB(255, 81, 81, 81),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: BoxBorder.all(color: AllColors.greyborderColor),
              ),
              child: Column(
                children: [
                  Summary(label: "Subtotal", value: "\$17.40"),
                  Summary(label: "Savings", value: "-\$0.00"),
                  Divider(),
                  Summary(label: "Total", value: "\$17.40", isBold: true),
                ],
              ),
            ),
            SizedBox(height: 10),
            CommonButton(
              buttonValue: 'Proceed To Checkout',
              backgroundColor: AllColors.iconColor,
              bordercolor: AllColors.iconColor,
            ),
          ],
        ),
      ),
    );
  }
}
