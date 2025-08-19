import 'package:flutter/material.dart';
import 'package:vd_customer_app/theme/colors.dart';

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
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/Bigbottle.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                color: AllColors.imagetealbackColor,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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

                if (showPrice && product['price'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    product['price']!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                if (product['size'] != null) ...[
                  const SizedBox(height: 4),
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
                            color: AllColors.backgroundColor,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AllColors.iconColor),
                          ),
                          child: Text(
                            'Subscribe',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
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
                            style: TextStyle(fontSize: 12, color: Colors.white),
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

class DeliveryCard extends StatelessWidget {
  final String title;
  final String time;
  final bool selected;

  const DeliveryCard({
    super.key,
    required this.title,
    required this.time,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: selected ? AllColors.iconColor : AllColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.access_time,
            color: selected ? Colors.white : Colors.black,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : Colors.black,
            ),
          ),
          Text(
            time,
            style: TextStyle(color: selected ? Colors.white : Colors.black54),
          ),
        ],
      ),
    );
  }
}
