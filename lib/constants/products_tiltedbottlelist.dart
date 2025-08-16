import 'package:vd_customer_app/widgets/listview_container.dart';

List<SmallBottle> smallbottleslist = [
  SmallBottle(bottlename: 'Water Bottle', bottleimage: 'assets/Bigbottle.png'),
  SmallBottle(bottlename: 'Water Bottle', bottleimage: 'assets/Bigbottle.png'),
  SmallBottle(bottlename: 'Water Bottle', bottleimage: 'assets/Bigbottle.png'),
  SmallBottle(bottlename: 'Water Bottle', bottleimage: 'assets/Bigbottle.png'),
  SmallBottle(bottlename: 'Water Bottle', bottleimage: 'assets/Bigbottle.png'),
];

List<Map<String, String>> products = List.generate(
  8,
  (index) => {
    'name': 'ALKALINE WATER - 1L',
    'price': '₹100 / Per Bottle',
    'image': 'assets/Bigbottle.png',
  },
);
