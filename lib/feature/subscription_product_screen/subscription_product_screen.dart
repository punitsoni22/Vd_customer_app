import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/models/admin_plan_model.dart';
import 'package:vd_customer_app/core/routing/routes.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_appbar.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_button.dart';
import 'package:vd_customer_app/feature/auth_screen/provider/auth_provider.dart';
import 'package:vd_customer_app/feature/product_screen/provider/product_provider.dart';
import 'package:vd_customer_app/feature/subscription_date_screen/provider/subscription_provider.dart';
import 'package:vd_customer_app/feature/subscription_product_screen/widgets/subscription_product_card.dart';

class SubscriptionProductScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? preSelectedProducts;
  const SubscriptionProductScreen({super.key, this.preSelectedProducts});

  @override
  State<SubscriptionProductScreen> createState() =>
      _SubscriptionProductScreenState();
}

enum SubscriptionMode { custom, plan }

class _SubscriptionProductScreenState extends State<SubscriptionProductScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _plansScrollController;
  final List<Map<String, dynamic>> _selectedProducts = [];
  AdminPlanModel? _selectedPlan;

  void _clearSelectedProducts() {
    _selectedProducts.clear();
    setState(() {});
  }

  void _onPlansScroll() {
    if (_plansScrollController.position.pixels >=
        _plansScrollController.position.maxScrollExtent - 50) {
      final subscriptionProvider = context.read<SubscriptionProvider>();
      subscriptionProvider.getAllActivePlans(context);
    }
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
      _selectedProducts[idx] = selection;
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

  Future<void> _refreshData() async {
    final productProvider = context.read<ProductProvider>();
    final subscriptionProvider = context.read<SubscriptionProvider>();

    await Future.wait([
      productProvider.getProducts({
        "filterModel": {},
        "orderBy": "productName",
        "orderDir": "ASC",
        "searchText": "",
        "page": 1,
        "pageSize": 10,
      }, forceRefresh: true),
      subscriptionProvider.getAllActivePlans(context, forceRefresh: true),
    ]);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _plansScrollController = ScrollController();
    _plansScrollController.addListener(_onPlansScroll);

    if (widget.preSelectedProducts != null) {
      _selectedProducts.addAll(widget.preSelectedProducts!);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = context.read<ProductProvider>();
      final subscriptionProvider = context.read<SubscriptionProvider>();

      productProvider.getProducts({
        "filterModel": {},
        "orderBy": "productName",
        "orderDir": "ASC",
        "searchText": "",
        "page": 1,
        "pageSize": 10,
      });

      subscriptionProvider.getAllActivePlans(context, forceRefresh: true);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _plansScrollController.dispose();
    super.dispose();
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

        final authProvider = context.watch<AuthProvider>();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: CommonAppBar(
            title: 'Subscription',
            showBack: widget.preSelectedProducts != null,
            onBack: () => context.pop(),
          ),
          body: Column(
            children: [
              Container(
                margin: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AllColors.olivegreenColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AllColors.olivegreenColor.withValues(alpha: 0.3),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: AllColors.olivegreenColor,
                  indicator: BoxDecoration(
                    color: AllColors.olivegreenColor,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Custom Subscription'),
                    Tab(text: 'Subscription Plans'),
                  ],
                  onTap: (index) {
                    setState(() {
                      if (index == 0) {
                        _selectedPlan = null;
                      } else {
                        _selectedProducts.clear();
                      }
                    });
                  },
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCustomTab(provider),
                    _buildPlansTab(
                      subscriptionProvider,
                      authProvider.isLoggedIn,
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(),
        );
      },
    );
  }

  Widget _buildCustomTab(ProductProvider provider) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AllColors.olivegreenColor,
      child: SingleChildScrollView(
        controller: _plansScrollController,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                          (variant) =>
                              _isProductVariantSelected(product.id, variant.id),
                        );
                        currentQuantity = _getCurrentQuantity(
                          product.id,
                          selectedVariant.id,
                        );
                      }

                      return SubscriptionProductCard(
                        product: product,
                        onSelect: (selection) => _onProductSelected(selection),
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
    );
  }

  Widget _buildPlansTab(SubscriptionProvider provider, bool isLoggedIn) {
    if (!isLoggedIn) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.subscriptions_outlined,
                size: 80.sp,
                color: AllColors.olivegreenColor.withValues(alpha: 0.5),
              ),
              SizedBox(height: 24.h),
              Text(
                'Login Required',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: AllColors.olivegreenColor,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Please login to view subscription plans',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
              ),
              SizedBox(height: 32.h),
              CommonButton(
                onTap: () {
                  context.pushNamed(AppRoutes.loginScreen);
                },
                buttonValue: 'Login',
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AllColors.olivegreenColor,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Plans',
              style: TextStyle(
                color: AllColors.olivegreenColor,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            if (provider.isLoadingPlans)
              const Center(child: CircularProgressIndicator())
            else if (provider.adminPlans.isEmpty)
              const Center(child: Text("No plans available"))
            else ...[
              ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.adminPlans.length,
                    itemBuilder: (context, index) {
                      final plan = provider.adminPlans[index];
                      final isSelected = _selectedPlan?.id == plan.id;
                      String? planImageUrl;
                      for (var product in plan.products) {
                        for (var image in product.images) {
                          if (image.signedUrl != null &&
                              image.signedUrl!.isNotEmpty) {
                            planImageUrl = image.signedUrl;
                            break;
                          } else if (image.imageUrl.isNotEmpty) {
                            planImageUrl = image.imageUrl;
                            break;
                          }
                        }
                        if (planImageUrl != null) break;
                      }

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPlan = isSelected ? null : plan;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AllColors.olivegreenColor.withValues(
                                    alpha: 0.1,
                                  )
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isSelected
                                  ? AllColors.olivegreenColor
                                  : Colors.grey.shade300,
                              width: isSelected ? 2.w : 1.w,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (planImageUrl != null)
                                Container(
                                  width: 80.w,
                                  height: 80.w,
                                  margin: EdgeInsets.only(right: 12.w),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.r),
                                    color: Colors.grey.shade100,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: CachedNetworkImage(
                                      imageUrl: planImageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const Center(
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                        'assets/images/Bigbottle.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            plan.planName,
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color: AllColors.olivegreenColor,
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          Icon(
                                            Icons.check_circle,
                                            color: AllColors.olivegreenColor,
                                            size: 24.sp,
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 6.h),
                                    Text(
                                      plan.planDescription,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Row(
                                      children: [
                                        Text(
                                          '₹${plan.finalPrice}',
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AllColors.olivegreenColor,
                                          ),
                                        ),
                                        if (plan.discountPercentage != '0') ...[
                                          SizedBox(width: 8.w),
                                          Text(
                                            '₹${plan.totalPrice}',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.grey,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            '${plan.discountPercentage}% OFF',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      '${plan.products.length} Product${plan.products.length > 1 ? 's' : ''} • ${plan.subscriptionType.replaceAll('_', ' ')} • ${plan.deliveryFrequencyType}',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              if (provider.isMorePlansLoading)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final bool isCustomMode = _tabController.index == 0;
    final bool hasSelection = isCustomMode
        ? _selectedProducts.isNotEmpty
        : _selectedPlan != null;

    String buttonText = isCustomMode
        ? 'Confirm Selection (${_selectedProducts.length})'
        : _selectedPlan != null
        ? 'View Plan Details'
        : 'Select a Plan';

    return BottomAppBar(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
      color: Colors.white,
      child: CommonButton(
        onTap: !hasSelection
            ? null
            : () {
                if (isCustomMode) {
                  context.push(
                    AppRoutes.subscriptionDateScreen,
                    extra: {'selectedProducts': _selectedProducts},
                  );
                } else if (_selectedPlan != null) {
                  context.pushNamed(
                    AppRoutes.planDetailsScreen,
                    extra: {'planId': _selectedPlan!.id},
                  );
                }
              },
        buttonValue: buttonText,
      ),
    );
  }
}
