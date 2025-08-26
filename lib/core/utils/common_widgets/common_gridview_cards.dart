import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

class BigGridContainer extends StatelessWidget {
  final Map<String, String> product;
  final bool showPrice;
  final bool showActions;

  const BigGridContainer({
    super.key,
    required this.product,
    this.showPrice = true,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/image.png'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(15),
              color: AllColors.imagetealbackColor,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      product['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AllColors.buttonColor,
                      ),
                      child: Icon(
                        Icons.arrow_outward_outlined,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Divider(color: AllColors.tabBarline, indent: 0, endIndent: 135),

                if (showPrice && product['price'] != null) ...[
                  const SizedBox(height: 2),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "${product['price']}",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: ' Per Bottle',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (product['size'] != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    "Size: ${product['size']!}",
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
                if (showActions) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AllColors.iconColor),
                          ),
                          child: Text(
                            'Subscribe',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: AllColors.iconColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: AllColors.buttonColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Add to Cart',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 10, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
