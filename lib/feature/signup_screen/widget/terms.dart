import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/colors.dart';

class Terms extends StatelessWidget {
  const Terms({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'By continuing you agree to our',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
        ),
        Text(
          'Terms & Condition and Privacy Policy',
          style: TextStyle(fontSize: 14.sp, color: AllColors.buttonColor),
        ),
      ],
    );
  }
}
