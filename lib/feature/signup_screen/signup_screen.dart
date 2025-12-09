import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/routing/routes.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/common_widgets/common_button.dart';
import '../../core/utils/common_widgets/common_textfield.dart';
import '../../core/utils/validators.dart';
import '../../widget/snack_bar.dart';
import 'provider/signup_provider.dart';
import 'widget/header.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _passwordCtrl;
  bool _submitted = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SignupProvider>();
    final autovalidateMode = _submitted
        ? AutovalidateMode.onUserInteraction
        : AutovalidateMode.disabled;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AllColors.backgroundColor,
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Header(),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 20.h,
                    ),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: autovalidateMode,
                      child: Column(
                        children: [
                          Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: AllColors.buttonColor,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          CommonTextField(
                            label: 'Name',
                            controller: _nameCtrl,
                            validator: Validators.name,
                            textInputAction: TextInputAction.next,
                          ),
                          SizedBox(height: 10.h),
                          CommonTextField(
                            label: 'Email',
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.email,
                            textInputAction: TextInputAction.next,
                          ),
                          SizedBox(height: 10.h),
                          CommonTextField(
                            label: 'Phone Number',
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            validator: Validators.phone10,
                            textInputAction: TextInputAction.next,
                          ),
                          SizedBox(height: 10.h),
                          CommonTextField(
                            label: 'Password',
                            controller: _passwordCtrl,
                            obscureText: !_isPasswordVisible,
                            suFFixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            validator: Validators.passwordStrong,
                            textInputAction: TextInputAction.done,
                          ),
                          SizedBox(height: 30.h),
                          SizedBox(height: 20.h),
                          Row(
                            children: [
                              Checkbox(
                                value: provider.isPrivacyPolicyAccepted,
                                onChanged: provider.togglePrivacyPolicy,
                                activeColor: AllColors.buttonColor,
                              ),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    text: 'I agree to the Privacy Policy',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: const Color(0xFF888888),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: ' (read)',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: AllColors.buttonColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            final uri = Uri.parse(
                                              'https://veedasip.com/privacy-policy',
                                            );
                                            try {
                                              final launched = await launchUrl(
                                                uri,
                                                mode: LaunchMode
                                                    .externalApplication,
                                              );
                                              if (!launched) {
                                                if (context.mounted) {
                                                  MySnackBar.showSnackBar(
                                                    context,
                                                    'Could not open privacy policy',
                                                  );
                                                }
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                MySnackBar.showSnackBar(
                                                  context,
                                                  'Could not open privacy policy',
                                                );
                                              }
                                            }
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 14.h),
                          CommonButton(
                            buttonValue: 'Sign Up',
                            isFullWidth: true,
                            isLoading: provider.isLoading,
                            onTap: () async {
                              // First submit → turn on autovalidation
                              if (!_submitted) {
                                setState(() {
                                  _submitted = true;
                                });
                              }

                              final valid =
                                  _formKey.currentState?.validate() ?? false;
                              if (!valid) return;

                              if (!provider.isPrivacyPolicyAccepted) {
                                MySnackBar.showSnackBar(
                                  context,
                                  "Please accept the Privacy Policy",
                                );
                                return;
                              }

                              await provider.signup(
                                email: _emailCtrl.text,
                                password: _passwordCtrl.text,
                                fullName: _nameCtrl.text,
                                mobileNumber: _phoneCtrl.text,
                                context: context,
                              );
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
                              context.replaceNamed(AppRoutes.loginScreen);
                            },
                            child: Text(
                              "Already have an account? Log In",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AllColors.buttonColor,
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10.h,
                left: 16.w,
                child: GestureDetector(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.goNamed(AppRoutes.bottomBarScreen);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 20.sp,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
