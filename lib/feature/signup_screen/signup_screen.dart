import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_button.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_textfield.dart';
import 'package:vd_customer_app/feature/signup_screen/provider/signup_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignupScreen> {
  bool showErrors = false;
  String? nameError;
  String? emailError;
  String? phoneError;
  String? passwordError;

  final _fKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AllColors.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              clipBehavior: Clip.none,
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
                Positioned(
                  top: -19,
                  right: 0,
                  child: Image.asset(
                    'assets/Bottlee.png',
                    width: 238,
                    height: 400,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _signupstate(),
                  const SizedBox(height: 40),
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _signupstate() {
    return Form(
      key: _fKey,
      child: Column(
        children: [
          Text(
            'SignUp',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AllColors.buttonColor,
            ),
          ),
          const SizedBox(height: 10),
          MyTextField(
            label: 'Name',
            controller: nameController,
            errorText: showErrors ? nameError : null,
            onChanged: (value) {
              if (nameError != null) setState(() => nameError = null);
            },
          ),
          const SizedBox(height: 10),
          MyTextField(
            label: 'Email',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            errorText: showErrors ? emailError : null,
            onChanged: (value) {
              if (emailError != null) setState(() => emailError = null);
            },
          ),
          const SizedBox(height: 10),
          MyTextField(
            label: 'Phone Number',
            controller: numberController,
            keyboardType: TextInputType.number,
            errorText: showErrors ? phoneError : null,
            onChanged: (value) {
              if (phoneError != null) setState(() => phoneError = null);
            },
          ),
          const SizedBox(height: 20),
          MyTextField(
            label: 'Password',
            controller: passwordController,
            obscureText: true,
            errorText: showErrors ? passwordError : null,
            onChanged: (value) {
              if (passwordError != null) setState(() => passwordError = null);
            },
          ),
          const SizedBox(height: 30),
          Consumer<SignupProvider>(
            builder: (context, provider, child) {
              return CommonButton(
                buttonValue: 'Sign Up',
                isFullWidth: true,
                onTap: provider.isLoading
                    ? null
                    : () async {
                        setState(() {
                          showErrors = true;

                          nameError = nameController.text.isEmpty
                              ? 'Name is required'
                              : null;

                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );
                          emailError = emailController.text.isEmpty
                              ? 'Email is required'
                              : (!emailRegex.hasMatch(emailController.text)
                                    ? 'Enter a valid email'
                                    : null);

                          phoneError = numberController.text.isEmpty
                              ? 'Phone number is required'
                              : (!RegExp(
                                      r'^[0-9]+$',
                                    ).hasMatch(numberController.text)
                                    ? 'Phone number must be numeric'
                                    : (numberController.text.length != 10
                                          ? 'Phone number must be 10 digits'
                                          : null));

                          final passwordRegex = RegExp(
                            r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$',
                          );
                          passwordError = passwordController.text.isEmpty
                              ? 'Password is required'
                              : (!passwordRegex.hasMatch(
                                      passwordController.text,
                                    )
                                    ? 'Password must be more than 8 characters, include 1 uppercase, 1 number, 1 special char'
                                    : null);
                        });

                        if (nameError == null &&
                            emailError == null &&
                            phoneError == null &&
                            passwordError == null) {
                          final data = {
                            "data": {
                              "emailId": emailController.text.trim(),
                              "password": passwordController.text.trim(),
                              "fullName": nameController.text.trim(),
                              "mobileNumber": numberController.text.trim(),
                            },
                          };
                          log("data: $data");
                          await provider.signup(data, context);
                        }
                      },
                child: provider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : null,
              );
            },
          ),
        ],
      ),
    );
  }
}
