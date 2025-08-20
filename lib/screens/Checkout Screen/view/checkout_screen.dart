import 'package:flutter/material.dart';
import 'package:vd_customer_app/theme/colors.dart';
import 'package:vd_customer_app/widgets/app_bar.dart';
import 'package:vd_customer_app/widgets/cart_items_container.dart';
import 'package:vd_customer_app/widgets/custom_button.dart';
import 'package:vd_customer_app/widgets/custom_container.dart';
import 'package:vd_customer_app/widgets/gridview_container.dart';
import 'package:vd_customer_app/widgets/listview_container.dart';
import 'package:vd_customer_app/widgets/text_field.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.backgroundColor,
      appBar: CustomAppBar(title: 'Checkout', islineNeeded: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            AddressContainer(
              address: '14 , Wing -C \nGokuldham Society , Powder Gali',
              number: '9874563211',
              icon: Icons.location_on_outlined,
              name: 'Jetha LAL',
              title: 'Delivery Address',
            ),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                "Delivery Time",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 7),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              padding: EdgeInsets.all(10),
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
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  DeliveryCard(
                    title: "Today",
                    time: "9 AM - 12 PM",
                    selected: true,
                  ),
                  DeliveryCard(title: "Today", time: "1 PM - 4 PM"),
                  DeliveryCard(title: "Tomorrow", time: "9 AM - 12 PM"),
                  DeliveryCard(title: "Tomorrow", time: "1 PM - 4 PM"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                "Payment Options",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 7),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: BoxBorder.all(color: AllColors.textfieldborderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: const [
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
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 5),
              child: Text(
                'Apply Coupon',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: SizedBox(
                height: 40,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: MyTextField(label: 'Enter Coupon Code'),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: CommonButton(
                        buttonValue: 'Apply',
                        backgroundColor: AllColors.iconColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 5,
              ),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AllColors.textfieldborderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    RowText(label: "Subtotal", value: "\$750"),
                    RowText(label: "Discount", value: "-\$50.00"),
                    RowText(
                      label: "Delivery Charge",
                      value: "Free",
                      color: const Color.fromARGB(255, 237, 98, 98),
                    ),
                    RowText(label: "Estimated Tax", value: "-\$45"),
                    Divider(),
                    RowText(
                      label: "Total  Amount",
                      value: "\$755.00",
                      isBold: true,
                      color: Colors.blue[600],
                    ),
                  ],
                ),
              ),
            ),
            Divider(indent: 20, endIndent: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CommonButton(
                buttonValue: 'Confirm Order',
                backgroundColor: AllColors.iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
