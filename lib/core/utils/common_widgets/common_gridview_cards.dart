import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/models/product_model.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

class BigGridContainer extends StatelessWidget {
  final Product product;
  final bool showPrice;
  final bool showActions;
  final double? height;

  const BigGridContainer({
    super.key,
    required this.product,
    this.showPrice = true,
    this.showActions = true,
    this.height,
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
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: SizedBox(
                height: height ?? 170,
                width: double.infinity,
                child:
                    (product.images.isNotEmpty &&
                        product.images.first.signedUrl != null &&
                        product.images.first.signedUrl!.isNotEmpty)
                    ? Image.network(
                        product.images.first.signedUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/Bigbottle.png',
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset('assets/Bigbottle.png', fit: BoxFit.cover),
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.productName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AllColors.buttonColor,
                        ),
                        child: const Icon(
                          Icons.arrow_outward_outlined,
                          size: 15,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 0),
                  Divider(
                    color: AllColors.tabBarline,
                    endIndent: 130,
                    thickness: 1,
                  ),

                  if (showPrice && product.variants.isNotEmpty) ...[
                    const SizedBox(height: 3),

                    Text(
                      "${product.variants.first.quantityInMl} ml",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),

                    const SizedBox(height: 1),

                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "${product.variants.first.price}",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const TextSpan(
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

                  if (showActions) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6),
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
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: AllColors.buttonColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Add to Cart',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
