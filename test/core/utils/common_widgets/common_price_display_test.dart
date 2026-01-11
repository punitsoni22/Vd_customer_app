import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_price_display.dart';

void main() {
  Widget createWidgetUnderTest(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, childWrapper) {
        return MaterialApp(
          home: Scaffold(
            body: child,
          ),
        );
      },
    );
  }

  testWidgets('CommonPriceDisplay shows only price when originalPrice is null',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        const CommonPriceDisplay(price: '100'),
      ),
    );

    expect(find.text('₹100'), findsOneWidget);
    expect(find.byType(Text), findsOneWidget);
  });

  testWidgets('CommonPriceDisplay shows original price and price when provided',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        const CommonPriceDisplay(
          price: '100',
          originalPrice: '150',
        ),
      ),
    );

    expect(find.text('₹100'), findsOneWidget);
    expect(find.text('₹150'), findsOneWidget);
    
    final originalPriceText = tester.widget<Text>(find.text('₹150'));
    expect(originalPriceText.style?.decoration, TextDecoration.lineThrough);
  });

  testWidgets('CommonPriceDisplay hides original price when it is "0"',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        const CommonPriceDisplay(
          price: '100',
          originalPrice: '0',
        ),
      ),
    );

    expect(find.text('₹100'), findsOneWidget);
    expect(find.text('₹0'), findsNothing);
  });
}
