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
    final cartProvider = context.read<CartProvider>();
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        border: Border.all(color: AllColors.greyborderColor),
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: (imgUrl != null && imgUrl.isNotEmpty)
                ? Image.network(
                    imgUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/Bigbottle.png',
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset('assets/images/Bigbottle.png', fit: BoxFit.cover),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                    GestureDetector(
                      onTap: () => cartProvider.removeItem(item),
                      child: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  "₹${(item.price)}",
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
                SizedBox(height: 3.h),
                AddSubtButton(
                  quantity: item.quantity,
                  onAdd: () => cartProvider.increaseQuantity(item),
                  onSubtract: () => cartProvider.decreaseQuantity(item),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
