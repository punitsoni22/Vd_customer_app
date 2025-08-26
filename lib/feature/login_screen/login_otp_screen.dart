import 'package:flutter/material.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_button.dart';

import 'package:vd_customer_app/core/utils/common_widgets/common_textfield.dart';

class LoginOtpScreen extends StatefulWidget {
  const LoginOtpScreen({super.key});

  @override
  State<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> {
  bool isOtpStage = false;

  // final TextEditingController emailController = TextEditingController();

  // final TextEditingController passwordController = TextEditingController();

  // final TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.backgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.only(left: 12, bottom: 8),
                height: MediaQuery.of(context).size.height * 0.4,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                  color: AllColors.buttonColor,

                  boxShadow: [BoxShadow(spreadRadius: 0.5, blurRadius: 9)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Hello!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    Text(
                      'Welcome to Vedasip',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                      if (!isOtpStage) ...[_loginstate()] else ...[_otpstate()],

                      const Spacer(flex: 3),

                      Text(
                        'By continuing you agree to our',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        'Terms & Condition and Privacy Policy',
                        style: TextStyle(
                          fontSize: 14,
                          color: AllColors.buttonColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            top: -19,
            right: 0,
            child: Image.asset('assets/Bottlee.png', width: 238, height: 400),
          ),
        ],
      ),
    );
  }

  Widget _loginstate() {
    return Column(
      children: [
        Text(
          'Login or SignUp',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AllColors.buttonColor,
          ),
        ),
        SizedBox(height: 20),
        MyTextField(
          label: 'Email',
          // controller: emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        MyTextField(
          label: 'Password',
          // controller: passwordController,
          obscureText: true,
        ),
        const SizedBox(height: 30),
        CommonButton(
          buttonValue: 'Login',
          onTap: () {
            setState(() {
              isOtpStage = true;
            });
          },
        ),
      ],
    );
  }

  Widget _otpstate() {
    return Column(
      children: [
        Text(
          'OTP Verification',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AllColors.buttonColor,
          ),
        ),
        const SizedBox(height: 20),
        MyTextField(label: 'Enter OTP', keyboardType: TextInputType.number),
        const SizedBox(height: 30),
        CommonButton(buttonValue: 'Continue'),
      ],
    );
  }
}
