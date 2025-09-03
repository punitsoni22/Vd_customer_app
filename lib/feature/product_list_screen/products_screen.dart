import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/constants/products_tiltedbottlelist.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_appbar.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_gridview_cards.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_listview_cards.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        alignment: Alignment.centerLeft,
        title: 'Products',
        actions: [
          Icon(Icons.search_sharp, color: AllColors.buttonColor, size: 32),
        ],
        islineNeeded: false,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 120,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 20,
                ),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.59,
                    crossAxisSpacing: 19,
                    mainAxisSpacing: 17,
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
      ),
    );
  }
}
