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
                borderRadius: BorderRadius.circular(10.r),
                child: Container(
                  width: 68.w,
                  height: 68.w,
                  color: Colors.grey.shade100,
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
              SizedBox(width: 12.w),
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
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              if (hasChanges)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    'Modified',
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      color: Colors.white,
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
                              borderRadius: BorderRadius.circular(16.r),
                              onTap: isLoading
                                  ? null
                                  : () => provider.removeItem(context, item),
                              child: Container(
                                padding: EdgeInsets.all(4.r),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red.withValues(alpha: 0.08),
                                ),
                                child: isLoading
                                    ? SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                Color
                                              >(Colors.red),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Price",
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              "₹${item.price}",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: AllColors.buttonColor,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Consumer<CartProvider>(
                          builder: (context, provider, _) {
                            return AddSubtButton(
                              quantity: provider.getDisplayQuantity(item),
                              onAdd: () => provider.increaseQuantity(item),
                              onSubtract: () => provider.decreaseQuantity(item),
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
