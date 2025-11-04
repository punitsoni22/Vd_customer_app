import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/models/cart_model.dart';
import 'package:vd_customer_app/core/models/product_model.dart';
import 'package:vd_customer_app/core/routing/routes.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_button.dart';
import 'package:vd_customer_app/feature/cart_screen/provider/cart_provider.dart';
import 'package:vd_customer_app/feature/product_detail_screen/provider/product_detail_provider.dart';

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
    final quantityInml = (p.variants.first.quantityInMl)
        .toString()
        .toUpperCase();
    return '$quantityInml ';
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
              Expanded(
                flex: 5,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.r),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
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
                      SizedBox(height: 8.h),
                      Expanded(
                        child: RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: _quantityinMl(product),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2,
                                  color: AllColors.buttonColor,
                                ),
                              ),

                              TextSpan(
                                text: 'Litre',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,

                                  color: AllColors.buttonColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Expanded(
                        child: RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: _price(product),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  letterSpacing: 0.2,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: ' Per Bottle',
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
