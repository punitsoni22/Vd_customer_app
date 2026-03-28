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
        final hasChanges = provider.pendingQuantityChanges.containsKey(item.id);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            border: Border.all(
              color: hasChanges ? Colors.orange : AllColors.greyborderColor,
              width: hasChanges ? 1.5 : 0.5,
            ),
            color: hasChanges
                ? Colors.orange.withValues(alpha: 0.02)
                : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
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
                  height: 90.w,
                  child: Stack(
                    children: [
                      Positioned.fill(
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
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.05),
                            ],
                          ),
                        ),
                      ),
                    ],
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
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                  height: 1.3,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Consumer<CartProvider>(
                          builder: (context, provider, __) {
                            final bool isRemoving = provider.isItemBeingRemoved(
                              item.id,
                            );

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20.r),
                                onTap: isRemoving
                                    ? null
                                    : () => provider.removeItem(context, item),
                                child: Container(
                                  padding: EdgeInsets.all(4.r),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade100,
                                  ),
                                  child: isRemoving
                                      ? SizedBox(
                                          width: 16.sp,
                                          height: 16.sp,
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
                                          size: 16.sp,
                                          color: Colors.grey.shade500,
                                        ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Unit Price",
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              "₹${item.price.toInt()}",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
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
                                borderRadius: BorderRadius.circular(24.r),
                                border: Border.all(color: Colors.grey.shade200),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: AddSubtButton(
                                quantity: provider.getDisplayQuantity(item),
                                onAdd: () => provider.increaseQuantity(
                                  item,
                                  context: context,
                                ),
                                onSubtract: () => provider.decreaseQuantity(
                                  item,
                                  context: context,
                                ),
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
