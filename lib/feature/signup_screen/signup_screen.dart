import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/routing/routes.dart';

import '../../core/theme/colors.dart';
import '../../core/utils/common_widgets/common_button.dart';
import '../../core/utils/common_widgets/common_textfield.dart';
import '../../core/utils/validators.dart';
import 'provider/signup_provider.dart';
import 'widget/header.dart';
import 'widget/terms.dart';

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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AllColors.backgroundColor,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Header(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 20.h),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        ],
                        validator: Validators.phone10,
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: 10.h),
                      CommonTextField(
                        label: 'Password',
                        controller: _passwordCtrl,
                        obscureText: true,
                        validator: Validators.passwordStrong,
                        textInputAction: TextInputAction.done,
                      ),
                      SizedBox(height: 30.h),
                      Selector<SignupProvider, bool>(
                        selector: (_, p) => p.isLoading,
                        builder: (context, isLoading, _) {
                          return CommonButton(
                            buttonValue: 'Sign Up',
                            isFullWidth: true,
                            isLoading: isLoading,
                            onTap: () async {
                              final valid =
                                  _formKey.currentState?.validate() ?? false;
                              if (!valid) return;

                              await context.read<SignupProvider>().signup(
                                email: _emailCtrl.text,
                                password: _passwordCtrl.text,
                                fullName: _nameCtrl.text,
                                mobileNumber: _phoneCtrl.text,
                                context: context,
                              );
                            },
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
                      SizedBox(height: 40.h),
                      const Terms(),
                    ],
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
