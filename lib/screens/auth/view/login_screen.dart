import 'package:flutter/material.dart';
import 'package:vd_customer_app/theme/colors.dart';
import 'package:vd_customer_app/widgets/custom_button.dart';
import 'package:vd_customer_app/widgets/custom_container.dart';
import 'package:vd_customer_app/widgets/text_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.backgroundColor,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Column(
              children: [
                CustomContainer(text: 'Hello !', text2: 'Welcome to Vedasip'),
                Spacer(flex: 2),
                Text(
                  'Login or SignUp',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AllColors.buttonColor,
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: MyTextField(label: 'Enter Email'),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: MyTextField(label: 'Enter Password'),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: CommonButton(
                    buttonValue: 'Login',
                    onTap: () {
                      Navigator.pushNamed(context, '/region');
                    },
                  ),
                ),
                Spacer(flex: 3),
                Text(
                  'By continuing you agree to our',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'Terms & Condition and Privacy Policy',
                  style: TextStyle(fontSize: 14, color: AllColors.buttonColor),
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
