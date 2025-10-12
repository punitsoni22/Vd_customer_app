import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vd_customer_app/core/routing/routes.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_appbar.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_button.dart';
import 'package:vd_customer_app/core/utils/prefs/prefs.dart';
import 'package:vd_customer_app/feature/profile_screen/widgets/profile_orders_container.dart';
import 'package:vd_customer_app/feature/profile_screen/widgets/profile_header_cont.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Profile'),
      backgroundColor: AllColors.backgroundColor,

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ProfileHeader(
              name: 'Hello Emma',
              phoneNumber: '9746132587',
              ontouch: () {},
            ),
            OrdersCard(),
            SizedBox(height: 10),
            CommonButton(
              onTap: () async {
                await Prefs.clear(Prefs.keyAuthToken);
                await Prefs.clear(Prefs.keyUserId);
                GoRouter.of(context).go(AppRoutes.authScreen);
                
              },
              color: AllColors.olivegreenColor,
              buttonValue: 'Logout',
            ),
          ],
        ),
      ),
    );
  }
}
