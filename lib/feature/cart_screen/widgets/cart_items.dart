import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/models/product_model.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_add_subt_button.dart';
import 'package:vd_customer_app/feature/cart_screen/provider/cart_provider.dart';

class CartItem extends StatelessWidget {
  final Product item;

  const CartItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final String? imgUrl = (item.images.isNotEmpty)
        ? item.images.first.signedUrl
        : null;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        border: Border.all(color: AllColors.greyborderColor),
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: (imgUrl != null && imgUrl.isNotEmpty)
                ? Image.network(
                    imgUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/Bigbottle.png',
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset('assets/images/Bigbottle.png', fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.productName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        context.read<CartProvider>().removeItem(item);
                        print('Deleted');
                      },
                      child: Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "\$${item.displayPrice}",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),

                AddSubtButton(
                  selfconstraints: BoxConstraints(maxWidth: 80),
                  iconColor: Colors.blue,
                  bordercolor: AllColors.greyborderColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
