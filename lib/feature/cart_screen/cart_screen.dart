import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/routing/routes.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/common_widgets/common_appbar.dart';
import '../../core/utils/common_widgets/common_button.dart';
import '../../core/utils/common_widgets/common_summary_rowtext.dart';
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CommonAppBar(title: 'My Cart'),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  Text(
                    'Items (${items.length})',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.refresh, size: 16.sp, color: Colors.grey[600]),
                      SizedBox(width: 4.w),
                      Text(
                        'Pull to refresh',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final provider = context.read<CartProvider>();
                  await provider.fetchLatestCart(context);
                },
                child: items.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: 80.h),
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 64.sp,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16.h),
                          Center(
                            child: Text(
                              "Your cart is empty",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Center(
                            child: Text(
                              "Add products to see them here.",
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
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

            Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                final subtotal = cartProvider.subtotal;

                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: AllColors.outlineColor),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Price Details',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${items.length} item${items.length == 1 ? '' : 's'}',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Summary(
                              label:
                                  "Subtotal${cartProvider.hasPendingChanges ? ' (Updated)' : ''}",
                              value: "₹${subtotal.toStringAsFixed(2)}",
                            ),
                            const Summary(label: "Savings", value: "-₹0.00"),
                            const Divider(),
                            Summary(
                              label:
                                  "Total${cartProvider.hasPendingChanges ? ' (Updated)' : ''}",
                              value: "₹${subtotal.toStringAsFixed(2)}",
                              isBold: true,
                            ),
                            if (cartProvider.hasPendingChanges)
                              Padding(
                                padding: EdgeInsets.only(top: 6.h),
                                child: Text(
                                  "* Total reflects unsaved changes",
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.orange[700],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      SizedBox(height: 10.h),
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
                                    buttonValue: cartProvider.isUpdatingQuantity
                                        ? 'Saving...'
                                        : 'Save Changes',
                                    backgroundColor: AllColors.iconColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                          ],
                        ),
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
