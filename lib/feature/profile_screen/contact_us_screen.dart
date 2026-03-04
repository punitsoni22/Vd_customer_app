import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_appbar.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_button.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_textfield.dart';
import 'package:vd_customer_app/feature/profile_screen/provider/profileProvider.dart';
import 'package:vd_customer_app/widget/snack_bar.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<ProfileProvider>();
      
      final data = {
        "firstName": _firstNameController.text.trim(),
        "lastName": _lastNameController.text.trim(),
        "email": _emailController.text.trim(),
        "phoneNumber": _phoneController.text.trim(),
        "message": _messageController.text.trim(),
      };

      final success = await provider.addContactUs(context, data);
      
      if (success && mounted) {
        MySnackBar.showSnackBar(context, 'Message sent successfully!');
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<ProfileProvider, bool>((p) => p.isLoading);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(
        title: 'Contact Us',
        titleAlignment: BarTitleAlignment.center,
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'We would love to hear from you!',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AllColors.buttonColor,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Please fill out the form below and we will get back to you as soon as possible.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24.h),
              
              Row(
                children: [
                  Expanded(
                    child: CommonTextField(
                      controller: _firstNameController,
                      label: 'First Name',
                      useFloatingLabel: true,
                      padding: EdgeInsets.all(12.w),
                      radius: 10.r,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CommonTextField(
                      controller: _lastNameController,
                      label: 'Last Name',
                      useFloatingLabel: true,
                      padding: EdgeInsets.all(12.w),
                      radius: 10.r,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              
              CommonTextField(
                controller: _emailController,
                label: 'Email',
                useFloatingLabel: true,
                padding: EdgeInsets.all(12.w),
                radius: 10.r,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              
              CommonTextField(
                controller: _phoneController,
                label: 'Phone Number (Optional)',
                useFloatingLabel: true,
                padding: EdgeInsets.all(12.w),
                radius: 10.r,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (value.length != 10) {
                      return 'Phone number must be 10 digits';
                    }
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              
              CommonTextField(
                controller: _messageController,
                label: 'Message',
                useFloatingLabel: true,
                maxLines: 5,
                alignLabelWithHint: true,
                padding: EdgeInsets.all(12.w),
                radius: 10.r,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your message';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32.h),
              
              CommonButton(
                buttonValue: 'Submit',
                isLoading: isLoading,
                onTap: _submitForm,
                isFullWidth: true,
                radius: 10.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
