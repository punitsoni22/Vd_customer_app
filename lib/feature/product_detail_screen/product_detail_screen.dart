import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/models/cart_model.dart';
import 'package:vd_customer_app/core/models/product_model.dart';
import 'package:vd_customer_app/core/routing/routes.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/feature/cart_screen/provider/cart_provider.dart';
import 'package:vd_customer_app/feature/product_detail_screen/widgets/drop_down_volume.dart';
import '../../core/utils/common_widgets/common_add_subt_button.dart';
import '../../core/utils/common_widgets/common_appbar.dart';
import '../../core/utils/common_widgets/common_button.dart';
import '../../core/utils/common_widgets/common_subscription_container.dart';
import '../home_screen/widgets/home_product_card.dart';
import 'provider/product_detail_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int selectedQuantity = 1;
  Variant? selectedVariant;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final data = GoRouterState.of(context).extra as Map?;
      final productId = data?['productId'];
      if (productId != null) {
        final provider = context.read<ProductDetailProvider>();
        provider.fetchSpecificProduct(productId).then((_) {
          if (provider.selectedProduct != null &&
              provider.selectedProduct!.variants.isNotEmpty) {
            setState(() {
              selectedVariant = provider.selectedProduct!.variants.first;
            });
          }
        });
        final requestData = {
          "filterModel": {},
          "orderBy": "productName",
          "orderDir": "ASC",
          "searchText": "",
          "page": 1,
          "pageSize": 10,
        };
        provider.fetchDetailProducts(requestData);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductDetailProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(
        title: 'Product Detail',
        titleAlignment: BarTitleAlignment.center,
        showBack: true,
        onBack: () {
          if (GoRouter.of(context).canPop()) {
            GoRouter.of(context).pop();
          } else {
            GoRouter.of(context).goNamed(AppRoutes.bottomBarScreen);
          }
        },
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: SubscriptionContainer(),
                    ),
                    Text(
                      provider.selectedProduct?.productName ?? 'Product Name',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(
                      endIndent: 300,
                      color: AllColors.tabBarline,
                      thickness: 2,
                    ),
                    Text(
                      provider.selectedProduct?.description ??
                          'pH 9.5+ for improved hydration',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Rs. ${provider.selectedProduct?.displayPrice ?? '00'}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 15),
                        Icon(
                          Icons.star,
                          color: const Color.fromARGB(255, 246, 225, 37),
                        ),
                        Text(
                          '4.5 Review',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Text(
                      'Volume',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AllColors.iconColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: double.infinity,
                      child: DropdownVolume(
                        variants: provider.selectedProduct?.variants ?? [],
                        selectedVariant: selectedVariant,
                        onVariantSelected: (variant) {
                          setState(() {
                            selectedVariant = variant;
                            selectedQuantity = 1;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 10),
                    Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AllColors.iconColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CommonAddSubtButton(
                          radius: 15,
                          initialQuantity: selectedQuantity,
                          onQuantityChanged: (newQuantity) {
                            setState(() {
                              selectedQuantity = newQuantity;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 22.h),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0.h),
                      child: const SubscriptionContainer(),
                    ),
                    Text(
                      'About this Product',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text...",
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Color.fromARGB(255, 54, 54, 54),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'More Popular Products',
                      style: TextStyle(
                        fontSize: 19.sp,
                        color: AllColors.olivegreenColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    provider.detailProducts.isEmpty
                        ? Center(
                            child: Text(
                              "No products found",
                              style: TextStyle(fontSize: 16.sp),
                            ),
                          )
                        : GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: provider.detailProducts.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.6,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                ),
                            itemBuilder: (context, index) {
                              final product = provider.detailProducts[index];
                              return HomeProductCard(product: product);
                            },
                          ),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              GoRouter.of(
                                context,
                              ).pushNamed(AppRoutes.subscriptionProductScreen);
                            },
                            child: CommonButton(
                              buttonValue: 'Subscribe',
                              textStyle: TextStyle(color: AllColors.iconColor),
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: CommonButton(
                            buttonValue: 'Add to Cart',
                            variant: ButtonVariant.filled,
                            color: AllColors.buttonColor,
                            foregroundColor: Colors.white,
                            selfconstraints: BoxConstraints(minHeight: 38.h),
                            fontSize: 14.sp,
                            onTap: () {
                              final productProvider = context
                                  .read<ProductDetailProvider>();
                              final cartProvider = context.read<CartProvider>();
                              final selectedProduct =
                                  productProvider.selectedProduct;
                              if (selectedProduct == null ||
                                  selectedProduct.variants.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Product not available'),
                                  ),
                                );
                                return;
                              }
                              final variant =
                                  selectedVariant ??
                                  selectedProduct.variants.first;
                              cartProvider.addItem(
                                CartDetail(
                                  id: 0,
                                  productId: selectedProduct.id,
                                  variantId: variant.id,
                                  quantity: selectedQuantity,
                                  price: double.tryParse(variant.price) ?? 0,
                                  product: CartProduct(
                                    id: selectedProduct.id,
                                    productName: selectedProduct.productName,
                                    images: selectedProduct.images
                                        .map((e) => e.signedUrl ?? '')
                                        .toList(),
                                  ),
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Added to cart successfully'),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
