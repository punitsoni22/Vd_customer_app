import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vd_customer_app/feature/auth_screen/provider/auth_provider.dart';
import 'package:vd_customer_app/feature/profile_screen/profile_screen.dart';
import 'package:vd_customer_app/feature/profile_screen/provider/profileProvider.dart';

void main() {
  testWidgets('Profile tiles are tappable', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({"auth_token": "test_token"});

    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ],
        child: ScreenUtilInit(
          designSize: const Size(393, 850),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return const MaterialApp(home: ProfileScreen());
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Orders'), findsWidgets);
    expect(find.text('Contact Us'), findsOneWidget);
    expect(find.text('Call Us'), findsOneWidget);

    expect(
      find.ancestor(
        of: find.text('Orders').first,
        matching: find.byType(InkWell),
      ),
      findsOneWidget,
    );
    expect(
      find.ancestor(
        of: find.text('Contact Us'),
        matching: find.byType(InkWell),
      ),
      findsOneWidget,
    );
    expect(
      find.ancestor(of: find.text('Call Us'), matching: find.byType(InkWell)),
      findsOneWidget,
    );
  });
}
