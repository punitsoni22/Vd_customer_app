import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubscriptionContainer extends StatelessWidget {
  final double? height;
  final double borderRadius;
  final String assetPath;

  const SubscriptionContainer({
    super.key,
    this.height,
    this.borderRadius = 12,
    this.assetPath = 'assets/images/banner_image.png',
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        height: height ?? 180,
        padding: EdgeInsets.only(right: 8.w),
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) {
            return Container(
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              child: Text(
                'Asset not found:\n$assetPath',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
            );
          },
        ),
      ),
    );
  }
}
