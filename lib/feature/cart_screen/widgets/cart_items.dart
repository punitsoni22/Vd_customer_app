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
      builder: (context, provider, child) {
        final key = '${item.productId}_${item.variantId}';
        final hasChanges = provider.pendingQuantityChanges.containsKey(key);

        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            border: Border.all(
              color: hasChanges ? Colors.orange : AllColors.greyborderColor,
              width: hasChanges ? 2 : 1,
            ),
            color: hasChanges ? Colors.orange.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
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
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.product?.productName ?? '',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
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
                                      fontSize: 10.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Consumer<CartProvider>(
                          builder: (context, provider, child) {
                            return GestureDetector(
                              onTap: provider.isRemovingItem
                                  ? null
                                  : () => provider.removeItem(context, item),
                              child: provider.isRemovingItem
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.red,
                                            ),
                                      ),
                                    )
                                  : const Icon(Icons.delete, color: Colors.red),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "₹${(item.price)}",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Consumer<CartProvider>(
                      builder: (context, provider, child) {
                        return AddSubtButton(
                          quantity: provider.getDisplayQuantity(item),
                          onAdd: () => provider.increaseQuantity(item),
                          onSubtract: () => provider.decreaseQuantity(item),
                        );
                      },
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
