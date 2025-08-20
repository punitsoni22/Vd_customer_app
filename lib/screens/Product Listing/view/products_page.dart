import 'package:flutter/material.dart';
import 'package:vd_customer_app/constants/products_tiltedbottlelist.dart';
import 'package:vd_customer_app/theme/colors.dart';
import 'package:vd_customer_app/widgets/app_bar.dart';
import 'package:vd_customer_app/navigation_bar.dart';
import 'package:vd_customer_app/widgets/gridview_container.dart';
import 'package:vd_customer_app/widgets/listview_container.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.backgroundColor,
      appBar: CustomAppBar(
        title: 'Products',
        actions: [
          Icon(Icons.search_sharp, color: AllColors.buttonColor, size: 32),
        ],
        islineNeeded: false,
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                separatorBuilder: (context, index) => SizedBox(width: 10),
                itemCount: smallbottleslist.length,
                itemBuilder: (context, index) {
                  final smallbottles = smallbottleslist[index];
                  return SmallBottleCards(smallBottle: smallbottles);
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.6,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return BigGridContainer(product: product);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
