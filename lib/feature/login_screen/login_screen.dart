import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_button.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_textfield.dart';
import 'package:vd_customer_app/feature/login_screen/provider/login_provider.dart';

class LoginOtpScreen extends StatefulWidget {
  const LoginOtpScreen({super.key});

  @override
  State<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late TabController _tabController;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AllColors.backgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Stack(
          clipBehavior: Clip.none,
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
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 50),
                      LoginState(
                        formKey: _formKey,
                        tabController: _tabController,
                        emailController: emailController,
                        passwordController: passwordController,
                        phoneController: phoneController,
                      ),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          'By continuing you agree to our',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                      Center(
                        child: Text(
                          'Terms & Condition and Privacy Policy',
                          style: TextStyle(
                            fontSize: 14,
                            color: AllColors.buttonColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
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
      ),
    );
  }
}

class LoginState extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TabController tabController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController phoneController;

  const LoginState({
    super.key,
    required this.formKey,
    required this.tabController,
    required this.emailController,
    required this.passwordController,
    required this.phoneController,
  });

  @override
  State<LoginState> createState() => _LoginStateState();
}

class _LoginStateState extends State<LoginState> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LoginProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TabBar(
              labelColor: AllColors.olivegreenColor,
              controller: widget.tabController,
              indicatorColor: AllColors.olivegreenColor,
              tabs: const [
                Tab(child: Text('Email')),
                Tab(child: Text('Phone Number')),
              ],
            ),
            SizedBox(
              height: 300,
              child: TabBarView(
                controller: widget.tabController,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        MyTextField(
                          label: "Email",
                          keyboardType: TextInputType.emailAddress,
                          preFixIcon: const Icon(Icons.email),
                          onChanged: (value) => provider.emailchange(value),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Email is required";
                            }
                            if (!RegExp(
                              r'^[^@]+@[^@]+\.[^@]+',
                            ).hasMatch(value)) {
                              return "Enter a valid email";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        MyTextField(
                          onChanged: (value) => provider.passwordchange(value),
                          label: "Password",
                          obscureText: true,
                          preFixIcon: const Icon(Icons.lock),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Password is required";
                            }
                            final regex = RegExp(
                              r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$',
                            );
                            if (!regex.hasMatch(value)) {
                              return "Password must contain upper, lower, number & special char";
                            }
                            return null;
                          },
                        ),

                        CommonButton(
                          buttonValue: 'Login',
                          isFullWidth: true,
                          onTap: provider.isLoading
                              ? null
                              : () async {
                                  if (widget.formKey.currentState!.validate()) {
                                    await provider.loginViaEmail(context);
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
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        MyTextField(
                          onChanged: (value) => provider.numberchange(value),
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
                          buttonValue: 'Login via OTP',
                          isFullWidth: true,
                          onTap: provider.isLoading
                              ? null
                              : () async {
                                  if (widget.formKey.currentState!.validate()) {
                                    await provider.loginViaOtp(context);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          provider.message ??
                                              (provider.success
                                                  ? "OTP sent successfully"
                                                  : "OTP request failed"),
                                        ),
                                        backgroundColor: provider.success
                                            ? const Color.fromARGB(
                                                255,
                                                76,
                                                176,
                                                80,
                                              )
                                            : Colors.red,
                                      ),
                                    );
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
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
