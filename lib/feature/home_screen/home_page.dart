import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/constants/products_tiltedbottlelist.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/feature/home_screen/widgets/common_clipper.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_gridview_cards.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_imgae_container.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_listview_cards.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_textfield.dart';
import 'package:vd_customer_app/feature/home_screen/widgets/dropdown_menu.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: false,
            floating: false,
            expandedHeight: 190,
            flexibleSpace: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
              // clipper: MyCustomClipper(),
              child: Container(
                width: double.infinity,

                decoration: BoxDecoration(color: AllColors.olivegreenColor),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // MyDropdown(
                      //   items: ['Mumbai', 'Udaipur', 'Jaipur'],

                      //   hintText: 'Choose Location',
                      //   onChanged: (value) {},
                      // ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
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
              padding: const EdgeInsets.only(top: 12.0, left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ImageContainer(width: 350),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Catalog',
                    style: TextStyle(
                      color: AllColors.olivegreenColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),
                      itemCount: smallbottleslist.length,
                      itemBuilder: (context, index) {
                        final smallbottles = smallbottleslist[index];
                        return SmallBottleCards(smallBottle: smallbottles);
                      },
                    ),
                  ),
                  const SizedBox(height: 30),

                  Text(
                    'Most Popular Products',
                    style: TextStyle(
                      color: AllColors.olivegreenColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                    ),
                  ),
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return BigGridContainer(
                        product: product,
                        showPrice: false,
                        showActions: false,
                      );
                    },
                  ),

                  ImageContainer(height: 180),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
