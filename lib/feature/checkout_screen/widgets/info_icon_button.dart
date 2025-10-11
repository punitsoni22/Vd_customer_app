import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/feature/checkout_screen/provider/checkout_provider.dart';

class InfoIconButton extends StatelessWidget {
  const InfoIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        await context.read<CheckoutProvider>().fetchCoupons(0.0);

        final coupons = context.read<CheckoutProvider>().coupons;

        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            if (coupons.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text("No coupons available")),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Available Coupons",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: coupons.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final coupon = coupons[index];
                      return ListTile(
                        title: Text(coupon['code'] ?? 'No Code'),
                        subtitle: Text(
                          "Discount: ₹${(coupon['discountAmount'] ?? coupon['discountValue'] ?? 0.0).toString()}",
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
            );
          },
        );
      },
      icon: Icon(Icons.info_outline, color: Colors.grey),
    );
  }
}
