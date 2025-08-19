import 'package:flutter/material.dart';
import 'package:vd_customer_app/constants/cart_items.dart';
import 'package:vd_customer_app/navigation_bar.dart';
import 'package:vd_customer_app/screens/auth/view/xd.dart';
import 'package:vd_customer_app/theme/colors.dart';
import 'package:vd_customer_app/widgets/app_bar.dart';
import 'package:vd_customer_app/widgets/cart_items_container.dart';
import 'package:vd_customer_app/widgets/custom_button.dart';
import 'package:vd_customer_app/widgets/custom_container.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.backgroundColor,
      appBar: CustomAppBar(title: 'Cart', islineNeeded: true),
      bottomNavigationBar: CommonBottomAppbar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
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
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return CartItem(item: item);
                },
              ),
            ),
            SizedBox(height: 10),
            CustomInfoContainer(
              icon: Icons.location_on_outlined,
              text: 'Delivery Update: Standard Delivery (2-3 Days)',
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: BoxBorder.all(color: AllColors.textfieldborderColor),
              ),
              child: Column(
                children: [
                  RowText(label: "Subtotal", value: "\$17.40"),
                  RowText(label: "Savings", value: "-\$0.00"),
                  Divider(),
                  RowText(label: "Total", value: "\$17.40", isBold: true),
                ],
              ),
            ),
            SizedBox(height: 10),
            CommonButton(
              buttonValue: 'Proceed To Checkout',
              backgroundColor: AllColors.iconColor,
              color: AllColors.iconColor,
            ),
          ],
        ),
      ),
    );
  }
}
