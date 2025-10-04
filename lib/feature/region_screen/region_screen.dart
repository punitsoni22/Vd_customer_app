// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:vd_customer_app/core/constants/pick_region_list.dart';
// import 'package:vd_customer_app/core/routing/routes.dart';
// import 'package:vd_customer_app/core/theme/colors.dart';
// import 'package:vd_customer_app/core/utils/common_widgets/common_appbar.dart';
// import 'package:vd_customer_app/feature/region_screen/widgets/region_cards.dart';

// class RegionScreen extends StatefulWidget {
//   const RegionScreen({super.key});

//   @override
//   State<RegionScreen> createState() => _RegionScreenState();
// }

// class _RegionScreenState extends State<RegionScreen> {
//   int? selectedFeaturedIndex;
//   int? selectedOtherIndex;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CommonAppBar(
//         title: 'Pick a Region',
//       ),
//       backgroundColor: AllColors.backgroundColor,
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 20),
//           child: Column(
//             children: [
//               GridView.builder(
//                 shrinkWrap: true,
//                 physics: NeverScrollableScrollPhysics(),
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3,
//                   crossAxisSpacing: 16,
//                   mainAxisSpacing: 16,
//                   childAspectRatio: 0.9,
//                 ),
//                 itemCount: featuredCities.length,
//                 itemBuilder: (context, index) {
//                   final cities = featuredCities[index];
//                   final isSelected = selectedFeaturedIndex == index;
//                   return GestureDetector(
//                     onTap: () {
//                       GoRouter.of(context).pushNamed(AppRoutes.homeScreen);
//                       setState(() {
//                         selectedFeaturedIndex = index;
//                       });
//                     },
//                     child: CityContainer(city: cities, selected: isSelected),
//                   );
//                 },
//               ),

//               Padding(
//                 padding: const EdgeInsets.all(5.0),
//                 child: Text(
//                   'Other Cities',
//                   style: TextStyle(
//                     fontSize: 20,
//                     color: AllColors.buttonColor,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               GridView.builder(
//                 shrinkWrap: true,
//                 physics: NeverScrollableScrollPhysics(),
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3,
//                   crossAxisSpacing: 16,
//                   mainAxisSpacing: 16,
//                   childAspectRatio: 0.9,
//                 ),
//                 itemCount: otherCity.length,
//                 itemBuilder: (context, index) {
//                   final othercities = otherCity[index];
//                   final isSelected = selectedOtherIndex == index;
//                   return GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         selectedOtherIndex = index;
//                       });
//                     },
//                     child: CityContainer(
//                       city: othercities,
//                       selected: isSelected,
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
