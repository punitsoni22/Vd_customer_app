import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_button.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_textfield.dart';
import 'package:vd_customer_app/feature/login_screen/provider/login_provider.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final otpController = TextEditingController();
  final phoneController = TextEditingController();
  @override
  void dispose() {
    otpController.dispose();
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
                        'Verify OTP',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                      Text(
                        'Enter the code we sent you',
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
                      OtpState(
                        formKey: _formKey,
                        otpController: otpController,
                        phoneController: phoneController,
                      ),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          'Didn’t get the code? Resend',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
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

class OtpState extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController otpController;
  final TextEditingController phoneController;

  const OtpState({
    super.key,
    required this.formKey,
    required this.otpController,
    required this.phoneController,
  });

  @override
  State<OtpState> createState() => _OtpStateState();
}

class _OtpStateState extends State<OtpState> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MyTextField(
            controller: widget.otpController,
            label: "OTP",
            keyboardType: TextInputType.number,
            preFixIcon: const Icon(Icons.lock_clock),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "OTP is required";
              }
              if (value.length < 6) {
                return "Enter a valid OTP";
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Consumer<LoginProvider>(
            builder: (context, provider, child) {
              return CommonButton(
                buttonValue: 'Verify',
                isFullWidth: true,
                onTap: provider.isLoading
                    ? null
                    : () async {
                        if (widget.formKey.currentState!.validate()) {
                          final data = {
                            "data": {
                              "userName": widget.phoneController.text.trim(),
                              "otp":
                                  int.tryParse(
                                    widget.otpController.text.trim(),
                                  ) ??
                                  0,
                            },
                          };

                          await provider.verifyOtp(data, context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                provider.message ??
                                    (provider.success
                                        ? "OTP verified successfully"
                                        : "OTP verification failed"),
                              ),
                              backgroundColor: provider.success
                                  ? const Color.fromARGB(255, 76, 176, 80)
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
              );
            },
          ),
        ],
      ),
    );
  }
}
