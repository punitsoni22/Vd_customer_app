import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_button.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_textfield.dart';
import 'package:vd_customer_app/feature/login_screen/provider/login_provider.dart';

import '../../core/routing/routes.dart';
import '../signup_screen/widget/header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum _Stage { login, otp }

class _LoginScreenState extends State<LoginScreen> {
  _Stage _stage = _Stage.login;

  final _formKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();

  // login inputs
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // otp input
  final _otpCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LoginProvider>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                  Header(),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 20.h,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: _stage == _Stage.login
                          ? _LoginStep(
                              key: const ValueKey('_login'),
                              formKey: _formKey,
                              emailCtrl: _emailCtrl,
                              passwordCtrl: _passwordCtrl,
                              phoneCtrl: _phoneCtrl,
                              provider: provider,
                              onOtpRequested: () {
                                if (provider.success) {
                                  setState(() => _stage = _Stage.otp);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        provider.message ??
                                            'OTP sent successfully',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        provider.message ??
                                            'OTP request failed',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                            )
                          : _OtpStep(
                              key: const ValueKey('_otp'),
                              formKey: _otpFormKey,
                              otpCtrl: _otpCtrl,
                              provider: provider,
                              onBackToLogin: () =>
                                  setState(() => _stage = _Stage.login),
                              onResentOtp: () {
                                setState(() => _stage = _Stage.login);
                              },
                            ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Center(
                    child: Text(
                      'By continuing you agree to our',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Terms & Condition and Privacy Policy',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AllColors.buttonColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController phoneCtrl;
  final LoginProvider provider;
  final VoidCallback onOtpRequested;

  const _LoginStep({
    super.key,
    required this.formKey,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.phoneCtrl,
    required this.provider,
    required this.onOtpRequested,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              labelColor: AllColors.olivegreenColor,
              unselectedLabelColor: Colors.grey,
              indicator: BoxDecoration(
                color: AllColors.olivegreenColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AllColors.olivegreenColor,
                  width: 1.5.w,
                ),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
              ),
              tabs: [
                Tab(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 6.h,
                      horizontal: 10.w,
                    ),
                    child: Text('Email'),
                  ),
                ),
                Tab(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 6.h,
                      horizontal: 10.w,
                    ),
                    child: Text('Phone Number'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.h),
            SizedBox(
              height: 320.h,
              child: TabBarView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CommonTextField(
                        controller: emailCtrl,
                        label: "Email",
                        keyboardType: TextInputType.emailAddress,
                        onChanged: provider.setEmail,
                        validator: (v) {
                          final s = v?.trim() ?? '';
                          if (s.isEmpty) return "Email is required";
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(s)) {
                            return "Enter a valid email";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 14.h),
                      CommonTextField(
                        controller: passwordCtrl,
                        label: "Password",
                        obscureText: true,
                        onChanged: provider.setPassword,
                        validator: (v) {
                          final s = v ?? '';
                          if (s.isEmpty) return "Password is required";
                          final re = RegExp(
                            r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$',
                          );
                          if (!re.hasMatch(s)) {
                            return "Upper, lower, number & special char, 8+ chars";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24.h),
                      CommonButton(
                        buttonValue: 'Login',
                        isFullWidth: true,
                        isLoading: provider.isLoading,
                        onTap: () async {
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          await provider.loginViaEmail(context);
                          if (!context.mounted) return;
                          final msg = provider.message;
                          if (msg != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(msg),
                                backgroundColor: provider.success
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(50.w, 30.h),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          alignment: Alignment.center,
                        ),
                        onPressed: () {
                          context.replaceNamed(AppRoutes.signupScreen);
                        },
                        child: Text(
                          'New user? Create an account',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AllColors.buttonColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CommonTextField(
                        controller: phoneCtrl,
                        label: "Phone Number",
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: provider.setNumber,
                        validator: (v) {
                          final s = v?.trim() ?? '';
                          if (s.isEmpty) return "Phone number is required";
                          if (!RegExp(r'^\d{10}$').hasMatch(s)) {
                            return "Enter a valid 10-digit phone number";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24.h),
                      CommonButton(
                        buttonValue: 'Login via OTP',
                        isFullWidth: true,
                        isLoading: provider.isLoading,
                        onTap: () async {
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          await provider.loginViaOtp(context);
                          if (!context.mounted) return;
                          onOtpRequested();
                        },
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(50.w, 30.h),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          alignment: Alignment.center,
                        ),
                        onPressed: () {
                          context.replaceNamed(AppRoutes.signupScreen);
                        },
                        child: Text(
                          'New user? Create an account',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AllColors.buttonColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController otpCtrl;
  final LoginProvider provider;
  final VoidCallback onBackToLogin;
  final VoidCallback onResentOtp;

  const _OtpStep({
    super.key,
    required this.formKey,
    required this.otpCtrl,
    required this.provider,
    required this.onBackToLogin,
    required this.onResentOtp,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        key: const ValueKey('otpForm'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 18.h),
          CommonTextField(
            controller: otpCtrl,
            label: "OTP",
            keyboardType: TextInputType.number,
            validator: (v) {
              final s = v?.trim() ?? '';
              if (s.isEmpty) return "OTP is required";
              if (s.length < 6) return "Enter a valid OTP";
              return null;
            },
          ),
          SizedBox(height: 24.h),
          CommonButton(
            buttonValue: 'Verify',
            isFullWidth: true,
            isLoading: provider.isLoading,
            onTap: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              await provider.verifyOtp(context, otpCtrl.text);
              if (!context.mounted) return;
              final msg =
                  provider.message ??
                  (provider.success
                      ? "OTP verified successfully"
                      : "OTP verification failed");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(msg),
                  backgroundColor: provider.success ? Colors.green : Colors.red,
                ),
              );
              // If you want to allow retry without leaving page:
              // if (!provider.success) onBackToLogin();
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size(50.w, 30.h),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: Alignment.center,
            ),
            onPressed: provider.isLoading ? null : onBackToLogin,
            child: Text(
              'Edit Phone Number',
              style: TextStyle(fontSize: 14.sp, color: Colors.black54),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size(50.w, 30.h),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: Alignment.center,
            ),
            onPressed: () async {
              await provider.loginViaOtp(context);
            },
            child: Text(
              'Didn’t get the code? Resend',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
