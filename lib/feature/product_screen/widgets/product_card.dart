import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/product_model.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/common_widgets/common_price_display.dart';
import '../../../core/utils/formatters.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final double width;
  final double height;
  const ProductCard({
    super.key,
    required this.product,
    this.width = 160,
    this.height = 280,
  });
  String _title(Product p) {
    final name = (p.productName.isNotEmpty ? p.productName : 'ALKALINE WATER')
        .toUpperCase();
    return name;
  }

  String _quantityinMl(Product p) {
    final formatted = formatVolume(p.variants.first.quantityInMl);
    return formatted.toUpperCase();
  }

  String _price(Product p) {
    final price = double.tryParse(p.variants.first.price) ?? 0.0;
    return '₹${price.toInt()}';
  }

  @override
  Widget build(BuildContext context) {
    final String? imgUrl = (product.images.isNotEmpty)
        ? product.images.first.signedUrl
        : null;
    return InkWell(
      onTap: () {
        context.push(
          AppRoutes.productDetailScreen,
          extra: {'productId': product.id},
        );
      },
      child: SizedBox(
        width: width.w,
        height: height.h,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                blurRadius: 8,
                spreadRadius: 0,
                offset: Offset(0, 2),
                color: Color(0x14000000),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.r),
                    child: SizedBox(
                      width: double.infinity,
                      child: (imgUrl != null && imgUrl.isNotEmpty)
                          ? Image.network(
                              imgUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.asset(
                                'assets/images/Bigbottle.png',
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              'assets/images/Bigbottle.png',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(6.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _title(product),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Container(
                                  width: 30.w,
                                  height: 2.h,
                                  decoration: BoxDecoration(
                                    color: AllColors.tabBarline,
                                    borderRadius: BorderRadius.circular(3.r),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            decoration: BoxDecoration(
                              color: AllColors.buttonColor,
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                  color: Color(0x1A000000),
                                ),
                              ],
                            ),
                            width: 24.w,
                            height: 24.h,
                            child: Icon(
                              Icons.arrow_outward_rounded,
                              size: 12.sp,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Expanded(
                        child: RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: _quantityinMl(product),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2,
                                  color: AllColors.buttonColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Expanded(
                        child: Row(
                          children: [
                            CommonPriceDisplay(
                              price: (double.tryParse(
                                          product.variants.first.price) ??
                                      0)
                                  .toInt()
                                  .toString(),
                              originalPrice: product
                                          .variants.first.originalPrice !=
                                      null
                                  ? (double.tryParse(product
                                              .variants.first.originalPrice!) ??
                                          0)
                                      .toInt()
                                      .toString()
                                  : null,
                              priceStyle: TextStyle(
                                fontSize: 12.sp,
                                letterSpacing: 0.2,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ' Per Bottle',
                              style: TextStyle(
                                fontSize: 12.sp,
                                letterSpacing: 0.2,
                                color: AllColors.buttonColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
