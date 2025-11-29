import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vd_customer_app/core/routing/routes.dart';
// import 'package:vd_customer_app/core/constants/products_tiltedbottlelist.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_appbar.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_button.dart';

import 'package:provider/provider.dart';
import 'package:vd_customer_app/feature/subscription_product_screen/widgets/subscription_product_card.dart';
// import 'package:vd_customer_app/feature/subscription_product_screen/widgets/subscription_tab_bar.dart';
import 'package:vd_customer_app/feature/product_screen/provider/product_provider.dart';
import 'package:vd_customer_app/feature/subscription_date_screen/provider/subscription_provider.dart';

class SubscriptionProductScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? preSelectedProducts;
  const SubscriptionProductScreen({super.key, this.preSelectedProducts});

  @override
  State<SubscriptionProductScreen> createState() =>
      _SubscriptionProductScreenState();
}

class _SubscriptionProductScreenState extends State<SubscriptionProductScreen> {
  final List<Map<String, dynamic>> _selectedProducts = [];

  void _clearSelectedProducts() {
    _selectedProducts.clear();
    setState(() {});
  }

  void _onProductSelected(Map<String, dynamic> selection) {
    final idx = _selectedProducts.indexWhere(
      (e) =>
          e['productId'] == selection['productId'] &&
          e['variantId'] == selection['variantId'],
    );
    if (idx == -1) {
      _selectedProducts.add(selection);
    } else {
      _selectedProducts[idx]['quantity'] = selection['quantity'];
    }
    setState(() {});
  }

  void _onProductUnselected(int productId, int variantId) {
    _selectedProducts.removeWhere(
      (e) => e['productId'] == productId && e['variantId'] == variantId,
    );
    setState(() {});
  }

  int _getCurrentQuantity(int productId, int variantId) {
    final selected = _selectedProducts.firstWhere(
      (e) => e['productId'] == productId && e['variantId'] == variantId,
      orElse: () => {'quantity': 0},
    );
    return selected['quantity'] ?? 0;
  }

  bool _isProductVariantSelected(int productId, int variantId) {
    return _selectedProducts.any(
      (e) => e['productId'] == productId && e['variantId'] == variantId,
    );
  }

  @override
  void initState() {
    super.initState();

    if (widget.preSelectedProducts != null) {
      _selectedProducts.addAll(widget.preSelectedProducts!);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().getProducts({
        "filterModel": {},
        "orderBy": "productName",
        "orderDir": "ASC",
        "searchText": "",
        "page": 1,
        "pageSize": 10,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    return Consumer<SubscriptionProvider>(
      builder: (context, subscriptionProvider, child) {
        if (subscriptionProvider.subscriptionCreatedSuccessfully) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            subscriptionProvider.clearSuccessFlag();
            _clearSelectedProducts();
          });
        }

        return _buildScaffold(provider);
      },
    );
  }

  Widget _buildScaffold(ProductProvider provider) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(
        title: 'Subscription',
        showBack: widget.preSelectedProducts != null,
        onBack: () => context.pop(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Products',
                style: TextStyle(
                  color: AllColors.olivegreenColor,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.h),
              provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (provider.products.isEmpty)
                  ? const Center(child: Text("No products found"))
                  : GridView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.only(bottom: 18.h),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.products.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.64,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 17,
                      ),

                      itemBuilder: (context, index) {
                        final product = provider.products[index];
                        final hasSelectedVariant = product.variants.any(
                          (variant) =>
                              _isProductVariantSelected(product.id, variant.id),
                        );
                        int currentQuantity = 0;
                        if (hasSelectedVariant) {
                          final selectedVariant = product.variants.firstWhere(
                            (variant) => _isProductVariantSelected(
                              product.id,
                              variant.id,
                            ),
                          );
                          currentQuantity = _getCurrentQuantity(
                            product.id,
                            selectedVariant.id,
                          );
                        }

                        return SubscriptionProductCard(
                          product: product,
                          onSelect: (selection) =>
                              _onProductSelected(selection),
                          onUnselect: (productId, variantId) =>
                              _onProductUnselected(productId, variantId),
                          isSelected: hasSelectedVariant,
                          currentQuantity: currentQuantity,
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        color: Colors.white,
        child: CommonButton(
          onTap: _selectedProducts.isEmpty
              ? null
              : () {
                  context.push(
                    AppRoutes.subscriptionDateScreen,
                    extra: {'selectedProducts': _selectedProducts},
                  );
                },
          buttonValue: 'Confirm Selection (${_selectedProducts.length})',
          color: AllColors.tabBarline,
        ),
      ),
    );
  }
}
