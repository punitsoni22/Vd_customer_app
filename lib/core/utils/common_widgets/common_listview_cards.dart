import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

class SmallBottle {
  final String bottlename;
  final String bottleimage;

  SmallBottle({required this.bottlename, required this.bottleimage});
}

class SmallBottleCards extends StatelessWidget {
  final SmallBottle smallBottle;
  const SmallBottleCards({super.key, required this.smallBottle});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: AllColors.buttonColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 78,
              width: 78,
              child: smallBottle.bottleimage.startsWith('http')
                  ? Image.network(
                      smallBottle.bottleimage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/SmallBottlePlaceholder.png',
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      'assets/SmallBottlePlaceholder.png',
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          smallBottle.bottlename,
          style: TextStyle(
            color: AllColors.olivegreenColor,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
