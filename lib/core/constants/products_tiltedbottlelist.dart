import 'package:vd_customer_app/core/utils/common_widgets/common_listview_cards.dart';

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
    'price': '₹100',
    'image': 'assets/Bigbottle.png',
  },
);
