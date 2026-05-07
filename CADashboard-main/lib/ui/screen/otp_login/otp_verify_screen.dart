import 'dart:async';

import 'package:cadashboard/core/common/common_function.dart';
import 'package:cadashboard/core/utils/colors.dart';
import 'package:cadashboard/ui/widget/custom_btn.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String phoneE164;

  const OtpVerifyScreen({
    super.key,
    required this.phoneE164,
  });

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _otpController = TextEditingController();
  final ValueNotifier<bool> _sending = ValueNotifier(false);
  final ValueNotifier<bool> _verifying = ValueNotifier(false);

  String? _verificationId;
  int? _resendToken;

  Timer? _timer;
  final ValueNotifier<int> _secondsLeft = ValueNotifier(0);

  static const int _resendCooldownSec = 30;
  static const bool _showPhoneNumber = false;

  @override
  void initState() {
    super.initState();
    _sendOtp();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _sending.dispose();
    _verifying.dispose();
    _secondsLeft.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    _secondsLeft.value = _resendCooldownSec;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final next = _secondsLeft.value - 1;
      _secondsLeft.value = next;
      if (next <= 0) {
        t.cancel();
      }
    });
  }

  String _formatMmSs(int seconds) {
    final s = seconds.clamp(0, 24 * 60 * 60);
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final r = (s % 60).toString().padLeft(2, '0');
    return '$m:$r';
  }

  Future<void> _sendOtp() async {
    if (_secondsLeft.value > 0) return;
    _sending.value = true;
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneE164,
        forceResendingToken: _resendToken,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification can happen on Android; proceed to sign in.
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            if (!mounted) return;
            CommonFunction.showSnackBarLoginPageOnly(
              context: context,
              isError: false,
              message: 'OTP verified.',
            );
            Navigator.pop(context);
          } catch (e) {
            // Ignore; user can still enter OTP manually.
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          CommonFunction.showSnackBarLoginPageOnly(
            context: context,
            isError: true,
            message: e.message ?? e.code,
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          _startCooldown();
          if (!mounted) return;
          CommonFunction.showSnackBarLoginPageOnly(
            context: context,
            isError: false,
            message: 'OTP sent.',
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      if (!mounted) return;
      CommonFunction.showSnackBarLoginPageOnly(
        context: context,
        isError: true,
        message: 'Failed to send OTP. Please try again.',
      );
    } finally {
      _sending.value = false;
    }
  }

  Future<void> _verifyOtp() async {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      CommonFunction.showSnackBarLoginPageOnly(
        context: context,
        isError: true,
        message: 'Please enter 6-digit OTP.',
      );
      return;
    }
    if (_verificationId == null || _verificationId!.isEmpty) {
      CommonFunction.showSnackBarLoginPageOnly(
        context: context,
        isError: true,
        message: 'OTP not ready yet. Please resend OTP.',
      );
      return;
    }

    _verifying.value = true;
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (!mounted) return;

      // Backend integration will be added later. For now, just confirm OTP success.
      CommonFunction.showSnackBarLoginPageOnly(
        context: context,
        isError: false,
        message: 'OTP verified. Backend login will be added later.',
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      CommonFunction.showSnackBarLoginPageOnly(
        context: context,
        isError: true,
        message: e.message ?? e.code,
      );
    } catch (e) {
      if (!mounted) return;
      CommonFunction.showSnackBarLoginPageOnly(
        context: context,
        isError: true,
        message: 'OTP verification failed. Please try again.',
      );
    } finally {
      _verifying.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.07),
                    const Text(
                      'Enter Verification Code',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _showPhoneNumber ? 'We have sent an OTP to\n${widget.phoneE164}' : 'We have sent an OTP to',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    if (_showPhoneNumber) const SizedBox(height: 10) else const SizedBox(height: 18),

                    // Illustration
                    SizedBox(
                      height: 150,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 140,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppColor.background.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(80),
                            ),
                          ),
                          Icon(
                            Icons.chat_bubble_rounded,
                            size: 76,
                            color: AppColor.background.withValues(alpha: 0.65),
                          ),
                          Positioned(
                            right: 44,
                            bottom: 34,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: AppColor.logoColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),
                    PinCodeTextField(
                      appContext: context,
                      length: 6,
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      animationType: AnimationType.fade,
                      cursorColor: AppColor.background,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(10),
                        fieldHeight: 48,
                        fieldWidth: 44,
                        activeColor: AppColor.background,
                        selectedColor: AppColor.background,
                        inactiveColor: Colors.grey.shade300,
                        activeFillColor: Colors.white,
                        selectedFillColor: Colors.white,
                        inactiveFillColor: Colors.white,
                      ),
                      enableActiveFill: true,
                      onChanged: (_) {},
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<int>(
                      valueListenable: _secondsLeft,
                      builder: (context, left, child) {
                        final canResend = left <= 0;
                        return TextButton(
                          onPressed: canResend ? _sendOtp : null,
                          child: ValueListenableBuilder<bool>(
                            valueListenable: _sending,
                            builder: (context, sending, child) {
                              final baseStyle = TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade700,
                              );
                              if (sending) {
                                return Text('Sending OTP...', style: baseStyle);
                              }
                              return RichText(
                                text: TextSpan(
                                  style: baseStyle,
                                  children: [
                                    const TextSpan(text: 'Resend OTP in '),
                                    TextSpan(
                                      text: canResend ? '00:00' : _formatMmSs(left),
                                      style: const TextStyle(color: AppColor.background),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder<bool>(
                      valueListenable: _verifying,
                      builder: (context, verifying, child) {
                        return CusBtn(
                          btnName: 'Verify OTP',
                          loading: verifying,
                          localizeText: false,
                          onTap: _verifyOtp,
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 4,
              left: 4,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                color: AppColor.background,
                tooltip: 'Back',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

