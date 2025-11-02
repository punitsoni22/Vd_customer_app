import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/feature/home_screen/provider/home_provider.dart';
import 'package:vd_customer_app/feature/home_screen/widgets/home_product_card.dart';
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
                  expandedHeight: 200.h,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  pinned: false,
                  automaticallyImplyLeading: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12.w),
                      bottomRight: Radius.circular(12.w),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12.w),
                        bottomRight: Radius.circular(12.w),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            "assets/images/homescreen.png",
                            fit: BoxFit.cover,
                          ),

                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.3),
                                  Colors.black.withOpacity(0.05),
                                ],
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.only(left: 0.w, top: 20.h),
                            child: Center(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Welcome to ",
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "Vedasip",
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        color: AllColors.iconBackgColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(22.w),
                      topRight: Radius.circular(22.w),
                    ),
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 22.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20.h),

                          SizedBox(
                            height: 200.h,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 2,
                              itemBuilder: (context, index) {
                                return SubscriptionContainer();
                              },
                            ),
                          ),
                          SizedBox(height: 20.h),

                          Text(
                            "Most Popular Products",
                            style: TextStyle(
                              color: AllColors.olivegreenColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.sp,
                            ),
                          ),
                          SizedBox(height: 15.h),

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
                                        childAspectRatio: 0.66,
                                        crossAxisSpacing: 18,
                                        mainAxisSpacing: 17,
                                      ),
                                  itemBuilder: (context, index) {
                                    final product =
                                        provider.homeProducts[index];
                                    return HomeProductCard(product: product);
                                  },
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
