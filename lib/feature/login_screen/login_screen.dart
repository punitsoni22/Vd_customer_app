import 'package:flutter/material.dart';
import 'package:http/http.dart' as Api;
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_button.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_textfield.dart';
import 'package:vd_customer_app/core/utils/prefs/prefs.dart';
import 'package:vd_customer_app/feature/register_screen/provider/signup_provider.dart';

class LoginOtpScreen extends StatefulWidget {
  const LoginOtpScreen({super.key});

  @override
  State<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColors.backgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 12, bottom: 8),
                height: MediaQuery.of(context).size.height * 0.4,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                  color: AllColors.buttonColor,
                  boxShadow: const [
                    BoxShadow(spreadRadius: 0.5, blurRadius: 9),
                  ],
                ),
                child: const Column(
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 50),
                        Expanded(
                          child: LoginState(
                            formKey: _formKey,
                            tabController: _tabController,
                          ),
                        ),
                        const Text(
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
}

class LoginState extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TabController tabController;

  const LoginState({
    super.key,
    required this.formKey,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    final signupEmailController = TextEditingController();
    final signupPasswordController = TextEditingController();
    final loginPhoneController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TabBar(
          controller: tabController,
          indicatorColor: AllColors.olivegreenColor,
          tabs: const [
            Tab(child: Text('Email')),
            Tab(child: Text('Phone Number')),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MyTextField(
                      controller: signupEmailController,
                      label: "Email",
                      keyboardType: TextInputType.emailAddress,
                      preFixIcon: const Icon(Icons.email),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email is required";
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value)) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    MyTextField(
                      controller: signupPasswordController,
                      label: "Password",
                      obscureText: true,
                      preFixIcon: const Icon(Icons.lock),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password is required";
                        }
                        if (value.length < 8) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    CommonButton(
                      buttonValue: "Login",
                      onTap: () {
                        if (formKey.currentState!.validate()) {
                          debugPrint(
                            "Login with email: ${signupEmailController.text}",
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MyTextField(
                      controller: loginPhoneController,
                      label: "Phone Number",
                      keyboardType: TextInputType.phone,
                      preFixIcon: const Icon(Icons.phone),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Phone number is required";
                        }
                        if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                          return "Enter a valid 10-digit phone number";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    CommonButton(
                      buttonValue: "Get OTP",
                      onTap: () {
                        if (formKey.currentState!.validate()) {
                          debugPrint("OTP for: ${loginPhoneController.text}");
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
