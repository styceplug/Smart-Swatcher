import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/otp_box.dart';
import '../../../widgets/snackbars.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final AuthController authController = Get.find<AuthController>();
  Timer? _resendTimer;
  int _secondsRemaining = 30;
  String _otp = '';

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendCooldown([int duration = 30]) {
    _resendTimer?.cancel();
    setState(() {
      _secondsRemaining = duration;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() {
          _secondsRemaining = 0;
        });
        return;
      }
      setState(() {
        _secondsRemaining--;
      });
    });
  }

  Future<void> _verify() async {
    if (_otp.length < 6) {
      CustomSnackBar.failure(message: 'Enter the 6-digit verification code');
      return;
    }
    await authController.verifyOtp(_otp);
  }

  Future<void> _resend() async {
    if (_secondsRemaining > 0) return;
    final success = await authController.resendOtp();
    if (success && mounted) {
      _startResendCooldown();
    }
  }

  Future<void> _handleBack() async {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    await authController.exitOtpFlowToLogin();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleBack();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppbar(
          leadingIcon: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: _handleBack,
          ),
        ),
        body: SafeArea(
          child: Obx(() {
            final flow = authController.pendingOtpFlow.value;
            final destination = flow?.destination?.trim();
            final title =
                flow?.accountType == AccountType.company
                    ? 'Verify your company email'
                    : 'Verify your email';
            final subtitle =
                destination != null && destination.isNotEmpty
                    ? 'Enter the 6-digit code sent to $destination'
                    : 'Enter the 6-digit code sent to your email address';

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width20,
                vertical: Dimensions.height15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width10,
                      vertical: Dimensions.height8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary1,
                      borderRadius: BorderRadius.circular(Dimensions.radius30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.mail_outline_rounded,
                          color: AppColors.primary5,
                          size: 18,
                        ),
                        SizedBox(width: Dimensions.width8),
                        const Text(
                          'Email verification',
                          style: TextStyle(
                            color: AppColors.primary5,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Dimensions.height24),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: Dimensions.font23,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: Dimensions.height10),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: Dimensions.font15,
                      fontWeight: FontWeight.w400,
                      height: 1.45,
                      color: AppColors.grey5,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: Dimensions.height40),
                  OtpInput(
                    length: 6,
                    boxSize: 48,
                    onCompleted: (value) {
                      setState(() {
                        _otp = value;
                      });
                    },
                  ),
                  SizedBox(height: Dimensions.height24),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(Dimensions.width15),
                    decoration: BoxDecoration(
                      color: AppColors.grey1,
                      borderRadius: BorderRadius.circular(
                        Dimensions.radius20,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Didn’t get the code?',
                          style: TextStyle(
                            fontSize: Dimensions.font15,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: Dimensions.height5),
                        Text(
                          _secondsRemaining > 0
                              ? 'You can request another code in ${_secondsRemaining.toString().padLeft(2, '0')}s'
                              : 'Request another verification code',
                          style: TextStyle(
                            fontSize: Dimensions.font13,
                            color: AppColors.grey5,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: Dimensions.height12),
                        TextButton(
                          onPressed: _secondsRemaining > 0 ? null : _resend,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            _secondsRemaining > 0
                                ? 'Resend unavailable'
                                : 'Resend code',
                            style: TextStyle(
                              color:
                                  _secondsRemaining > 0
                                      ? AppColors.grey4
                                      : AppColors.primary5,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  CustomButton(
                    text: 'Verify code',
                    onPressed: _verify,
                    isDisabled: _otp.length < 6,
                    backgroundColor: AppColors.primary5,
                  ),
                  SizedBox(height: Dimensions.height15),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
