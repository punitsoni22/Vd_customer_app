import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:vd_customer_app/core/models/product_model.dart';
import 'package:vd_customer_app/core/routing/routes.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/models/cart_model.dart';
import 'package:vd_customer_app/feature/cart_screen/provider/cart_provider.dart';
import 'package:vd_customer_app/widget/snack_bar.dart';
import 'package:provider/provider.dart';

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
        ? (product.images.first.signedUrl ?? product.images.first.rawImageUrl)
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
                aspectRatio: 1.25,
                child: Container(
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.r),
                    child: SizedBox(
                      width: double.infinity,

                      child: (imgUrl != null && imgUrl.isNotEmpty)
                          ? CachedNetworkImage(
                              imageUrl: imgUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              errorWidget: (_, __, ___) => Image.asset(
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
                child: Padding(
                  padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _title(product),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 3.h),
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
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 30.h,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AllColors.buttonColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                onPressed: () async {
                                  if (product.variants.isEmpty) {
                                    MySnackBar.showSnackBar(
                                      context,
                                      'Product is not available right now.',
                                    );
                                    return;
                                  }

                                  final cartProvider = context
                                      .read<CartProvider>();
                                  final result = await cartProvider.addItem(
                                    CartDetail.fromProduct(product),
                                    context: context,
                                  );
                                  if (!context.mounted) return;
                                  MySnackBar.showSnackBar(
                                    context,
                                    result['message']?.toString() ??
                                        'Added to cart',
                                  );
                                },
                                child: Text(
                                  'Add to cart',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: SizedBox(
                              height: 30.h,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AllColors.buttonColor,
                                  side: BorderSide(
                                    color: AllColors.buttonColor,
                                  ),
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                onPressed: () {
                                  if (product.variants.isEmpty) {
                                    MySnackBar.showSnackBar(
                                      context,
                                      'Product is not available right now.',
                                    );
                                    return;
                                  }
                                  final v = product.variants.first;
                                  context.pushNamed(
                                    AppRoutes.subscriptionProductScreen,
                                    extra: {
                                      'preSelectedProducts': [
                                        {
                                          'productId': product.id,
                                          'variantId': v.id,
                                          'quantity': 1,
                                          'price': v.price,
                                          'productName': product.productName,
                                        },
                                      ],
                                    },
                                  );
                                },
                                child: Text(
                                  'Subscribe',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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
