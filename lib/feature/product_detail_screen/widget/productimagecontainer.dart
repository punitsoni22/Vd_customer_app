import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/feature/product_detail_screen/provider/product_detail_provider.dart';

class ProductImageContainer extends StatelessWidget {
  final double? height;
  final double borderRadius;

  const ProductImageContainer({super.key, this.height, this.borderRadius = 15});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductDetailProvider>();
    final product = provider.selectedProduct;

    final imageUrl = (product != null && product.images.isNotEmpty)
        ? product.images.first.signedUrl
        : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: SizedBox(
        width: double.infinity,
        height: height ?? 205.h,

        child: (imageUrl != null && imageUrl.isNotEmpty)
            ? Image.network(
                imageUrl,
                fit: BoxFit.fill,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/Bigbottle.png',
                  fit: BoxFit.cover,
                ),
              )
            : Image.asset('assets/images/Bigbottle.png', fit: BoxFit.cover),
      ),
    );
  }
}
