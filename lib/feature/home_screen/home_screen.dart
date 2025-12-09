import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/feature/auth_screen/provider/auth_provider.dart';
import 'package:vd_customer_app/feature/home_screen/provider/home_provider.dart';
import 'package:vd_customer_app/feature/home_screen/widgets/home_product_card.dart';
import 'package:vd_customer_app/feature/profile_screen/provider/profileProvider.dart';

import '../../core/routing/routes.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/common_widgets/common_subscription_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _didFetchOnce = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_didFetchOnce) return;
      _didFetchOnce = true;

      final provider = context.read<HomeProvider>();
      final requestData = {
        "filterModel": const {},
        "orderBy": "productName",
        "orderDir": "ASC",
        "searchText": "",
        "page": 1,
        "pageSize": 10,
      };
      provider.fetchHomeProducts(requestData);

      // Only fetch profile if user is logged in
      final isLoggedIn = context.read<AuthProvider>().isLoggedIn;
      if (isLoggedIn) {
        context.read<ProfileProvider>().fetchSpecificUser(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 160.h,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  pinned: false,
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleSpaceBar(
                    background: ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24.w),
                        bottomRight: Radius.circular(24.w),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(24.w),
                              bottomRight: Radius.circular(24.w),
                            ),
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Image.asset(
                                "assets/images/home_background.png",
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),

                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.55),
                                  Colors.black.withValues(alpha: 0.25),
                                  Colors.black.withValues(alpha: 0.05),
                                ],
                              ),
                            ),
                          ),
                          SafeArea(
                            bottom: false,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox.shrink(),
                                  const Spacer(),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Welcome to ",
                                          style: TextStyle(
                                            fontSize: 26.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(
                                          text: "Vedasip",
                                          style: TextStyle(
                                            fontSize: 26.sp,
                                            color: AllColors.iconBackgColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 180.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 2,
                            itemBuilder: (context, index) {
                              return const SubscriptionContainer();
                            },
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          "Most Popular Products",
                          style: TextStyle(
                            color: AllColors.olivegreenColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        provider.homeProducts.isEmpty
                            ? Center(
                                child: Text(
                                  "No products found",
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.only(bottom: 20.h),
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: provider.homeProducts.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.8  ,
                                      crossAxisSpacing: 18,
                                      mainAxisSpacing: 17,
                                    ),
                                itemBuilder: (context, index) {
                                  final product = provider.homeProducts[index];
                                  return HomeProductCard(product: product);
                                },
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
