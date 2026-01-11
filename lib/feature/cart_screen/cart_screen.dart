import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/routing/routes.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/common_widgets/common_appbar.dart';
import '../../core/utils/common_widgets/common_button.dart';
import '../../widget/snack_bar.dart';
import 'provider/cart_provider.dart';
import 'widgets/cart_items.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final items = cartProvider.cartItems;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CommonAppBar(
        title: 'My Cart',
        showBack: true,
        titleAlignment: BarTitleAlignment.center,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  Text(
                    'Items (${items.length})',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  if (items.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.refresh,
                            size: 14.sp,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Pull to refresh',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                color: AllColors.buttonColor,
                backgroundColor: Colors.white,
                onRefresh: () async {
                  final provider = context.read<CartProvider>();
                  await provider.fetchLatestCart(context);
                },
                child: items.isEmpty
                    ? SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: 0.6.sh,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(24.r),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.03,
                                      ),
                                      blurRadius: 20,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 48.sp,
                                  color: Colors.grey[300],
                                ),
                              ),
                              SizedBox(height: 24.h),
                              Text(
                                "Your cart is empty",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                "Looks like you haven't added\nany items to the cart yet.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[500],
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 4.h,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final product = items[index];
                          return CartItem(item: product);
                        },
                      ),
              ),
            ),

            if (items.isNotEmpty)
              Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  final subtotal = cartProvider.subtotal;

                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.r),
                        topRight: Radius.circular(24.r),
                      ),
                    ),
                    padding: EdgeInsets.all(12.r),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Order Summary',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${items.length} Items',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Total Amount",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    "₹${subtotal.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w800,
                                      color: AllColors.buttonColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20.h),
                        if (cartProvider.hasPendingChanges)
                          Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: CommonButton(
                                      onTap: cartProvider.isUpdatingQuantity
                                          ? null
                                          : () => cartProvider
                                                .cancelQuantityChanges(),
                                      buttonValue: 'Cancel',
                                      backgroundColor: Colors.grey[400]!,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: CommonButton(
                                      onTap: cartProvider.isUpdatingQuantity
                                          ? null
                                          : () => cartProvider
                                                .saveQuantityChanges(context),
                                      buttonValue:
                                          cartProvider.isUpdatingQuantity
                                          ? 'Saving...'
                                          : 'Save Changes',
                                      backgroundColor: AllColors.iconColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                            ],
                          )
                        else
                          CommonButton(
                            onTap: () {
                              final cp = context.read<CartProvider>();
                              if (cp.hasPendingChanges) {
                                MySnackBar.showSnackBar(
                                  context,
                                  'Please save or cancel your changes first',
                                );
                                return;
                              }
                              if (cp.cartId == null) {
                                MySnackBar.showSnackBar(
                                  context,
                                  'No products added to cart',
                                );
                                return;
                              }
                              context.pushNamed(AppRoutes.checkoutScreen);
                            },
                            buttonValue: 'Proceed to Checkout',
                            backgroundColor: AllColors.iconColor,
                          ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
