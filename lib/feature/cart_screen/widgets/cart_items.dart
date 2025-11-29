import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/models/cart_model.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/feature/cart_screen/provider/cart_provider.dart';
import 'package:vd_customer_app/feature/cart_screen/widgets/add_sub_button.dart';

class CartItem extends StatelessWidget {
  final CartDetail item;

  const CartItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final String? imgUrl = (item.product?.images.isNotEmpty ?? false)
        ? item.product!.images.first
        : null;

    return Consumer<CartProvider>(
      builder: (context, provider, _) {
        final key = '${item.productId}_${item.variantId}';
        final hasChanges = provider.pendingQuantityChanges.containsKey(key);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            border: Border.all(
              color: hasChanges ? Colors.orange : AllColors.greyborderColor,
              width: hasChanges ? 1.8 : 1,
            ),
            color: hasChanges
                ? Colors.orange.withValues(alpha: 0.03)
                : Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: SizedBox(
                  width: 90.w,
                  child: AspectRatio(
                    aspectRatio: 1,
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
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product?.productName ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              if (hasChanges)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(6.r),
                                    border: Border.all(
                                      color: Colors.orange.shade200,
                                    ),
                                  ),
                                  child: Text(
                                    'Quantity Modified',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: Colors.orange.shade800,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Consumer<CartProvider>(
                          builder: (context, provider, __) {
                            final bool isLoading = provider.isRemovingItem;

                            return InkWell(
                              borderRadius: BorderRadius.circular(20.r),
                              onTap: isLoading
                                  ? null
                                  : () => provider.removeItem(context, item),
                              child: Container(
                                padding: EdgeInsets.all(6.r),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade50,
                                ),
                                child: isLoading
                                    ? SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                Color
                                              >(Colors.red),
                                        ),
                                      )
                                    : Icon(
                                        Icons.close_rounded,
                                        size: 20.sp,
                                        color: Colors.grey.shade400,
                                      ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Price",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              "₹${item.price.toInt()}",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                                color: AllColors.buttonColor,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Consumer<CartProvider>(
                          builder: (context, provider, _) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: AddSubtButton(
                                quantity: provider.getDisplayQuantity(item),
                                onAdd: () => provider.increaseQuantity(item),
                                onSubtract:
                                    () => provider.decreaseQuantity(item),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
