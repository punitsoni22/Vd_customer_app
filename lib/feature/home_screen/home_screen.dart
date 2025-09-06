import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_gridview_cards.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_imgae_container.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_listview_cards.dart';
import 'package:vd_customer_app/feature/home_screen/provider/home_screen_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<HomeScreenProvider>();
      final requestData = {
        "filterModel": {},
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
    final provider = context.watch<HomeScreenProvider>();

    return Scaffold(
      backgroundColor: AllColors.backgroundColor,
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  pinned: false,
                  floating: false,
                  expandedHeight: 190,
                  flexibleSpace: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AllColors.olivegreenColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Welcome To ',
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Vedasip',
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: AllColors.iconBackgColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 12.0,
                      left: 15,
                      right: 15,
                    ),
                    child: SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: ImageContainer(width: 350),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 20.0,
                      left: 15,
                      right: 15,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Catalog',
                          style: TextStyle(
                            color: AllColors.olivegreenColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 90,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 10),
                            itemCount: provider.homeProducts.length,
                            itemBuilder: (context, index) {
                              final product = provider.homeProducts[index];
                              final imageUrl = product.images.isNotEmpty
                                  ? (product.images.first.signedUrl ??
                                        'assets/SmallBottlePlaceholder.png')
                                  : 'assets/SmallBottlePlaceholder.png';

                              return SmallBottleCards(
                                smallBottle: SmallBottle(
                                  bottlename: product.productName,
                                  bottleimage: imageUrl,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 30.0,
                      left: 15,
                      right: 15,
                      bottom: 15,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Most Popular Products',
                          style: TextStyle(
                            color: AllColors.olivegreenColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 10),
                        provider.homeProducts.isEmpty
                            ? const Center(
                                child: Text(
                                  "No products found",
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            : GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: provider.homeProducts.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.72,
                                      crossAxisSpacing: 14,
                                      mainAxisSpacing: 14,
                                    ),
                                itemBuilder: (context, index) {
                                  final product = provider.homeProducts[index];
                                  return BigGridContainer(
                                    product: product,
                                    showPrice: false,
                                    showActions: false,
                                  );
                                },
                              ),
                        const SizedBox(height: 20),
                        const ImageContainer(height: 180),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
