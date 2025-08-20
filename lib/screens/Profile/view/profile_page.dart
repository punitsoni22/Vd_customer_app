import 'package:flutter/material.dart';
import 'package:vd_customer_app/navigation_bar.dart';
import 'package:vd_customer_app/theme/colors.dart';
import 'package:vd_customer_app/widgets/app_bar.dart';
import 'package:vd_customer_app/widgets/custom_button.dart';
import 'package:vd_customer_app/widgets/profile_body_container.dart';
import 'package:vd_customer_app/widgets/profile_header_cont.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Profile', islineNeeded: true),
      backgroundColor: AllColors.backgroundColor,

      body: Column(
        children: [
          ProfileHeader(
            name: 'Hello Emma',
            phoneNumber: '9746132587',
            ontouch: () {},
          ),
          OrdersCard(),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
