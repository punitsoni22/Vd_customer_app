import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vd_customer_app/core/models/product_model.dart';
import 'package:vd_customer_app/core/routing/routes.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

class HomeProductCard extends StatelessWidget {
  final Product product;
  final double width;
  final double height;

  const HomeProductCard({
    super.key,
    required this.product,
    this.width = 160,
    this.height = 240,
  });

  String _title(Product p) {
    final name = (p.productName.isNotEmpty ? p.productName : 'ALKALINE WATER')
        .toUpperCase();
    return name;
  }

  @override
  Widget build(BuildContext context) {
    final String? imgUrl = (product.images.isNotEmpty)
        ? product.images.first.signedUrl
        : null;

    return InkWell(
      onTap: () {
        context.pushNamed(
          AppRoutes.productDetailScreen,
          extra: {'productId': product.id},
        );
      },
      child: SizedBox(
        width: width,
        height: height,
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
                  child: Row(
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
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Container(
                              width: 30.w,
                              height: 2.h,
                              decoration: BoxDecoration(
                                color: AllColors.tabBarline,
                                borderRadius: BorderRadius.circular(3),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
