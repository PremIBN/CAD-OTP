import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cadashboard/core/common/common_function.dart';
import 'package:cadashboard/core/repository/add_logged_in_area_address_repository.dart';
import 'package:cadashboard/core/repository/login_repository.dart';
import 'package:cadashboard/core/services/notification_permission_dialog_service.dart';
import 'package:cadashboard/core/utils/colors.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:cadashboard/core/View_Model/login_vm.dart';
import 'package:cadashboard/main.dart';
import 'package:cadashboard/ui/screen/home.dart';
import 'package:cadashboard/ui/widget/custom_btn.dart';
import 'package:cadashboard/ui/widget/custom_navigate.dart';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpVerifyScreen extends StatefulWidget {
  /// 10-digit mobile number as entered (web uses this as ContactNo).
  final String contactNo;
  /// Dial code like "+91" used for display only.
  final String dialCode;
  /// Digits-only country code for `GenerateLoginOTP?countrySTDCode=` (e.g. 91).
  final String countrySTDCode;

  const OtpVerifyScreen({
    super.key,
    required this.contactNo,
    required this.dialCode,
    required this.countrySTDCode,
  });

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _otpController = TextEditingController();
  final ValueNotifier<bool> _sending = ValueNotifier(false);
  final ValueNotifier<bool> _verifying = ValueNotifier(false);
  final LoginRepo _loginRepo = LoginRepo();

  Timer? _timer;
  final ValueNotifier<int> _secondsLeft = ValueNotifier(0);

  static const int _resendCooldownSec = 60;
  static const Duration _bootstrapTimeout = Duration(seconds: 12);

  @override
  void initState() {
    super.initState();
    // OTP is already sent from `OtpPhoneScreen` before navigation.
    // Start cooldown so "Resend OTP in" is shown without sending twice.
    _startCooldown();
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

  void _resetOtpFields() {
    _otpController.clear();
    // Rebuild without replacing [PinCodeTextField] identity — avoids framework
    // `_dependents.isEmpty` crashes when combined with SnackBar overlays.
    if (mounted) setState(() {});
  }

  /// User-facing copy for OTP verify API failures (wrong / expired OTP, empty credentials).
  static String _otpVerifyFailureMessage(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return 'Invalid OTP';
    final lower = t.toLowerCase();
    if (lower == 'something went wrong' || lower == 'something went wrong.') {
      return 'Invalid OTP';
    }
    if (lower.contains('invalid otp')) return 'Invalid OTP';
    return t;
  }

  Future<void> _sendOtp() async {
    if (_secondsLeft.value > 0) return;
    _sending.value = true;
    try {
      await _loginRepo.generateLoginOtp(
        mobile: widget.contactNo,
        countrySTDCode: widget.countrySTDCode,
        success: (message) {
          _startCooldown();
          if (!mounted) return;
          CommonFunction.showSnackBarLoginPageOnly(
            context: context,
            isError: false,
            message: message,
          );
        },
        failed: (message) {
          if (!mounted) return;
          CommonFunction.showSnackBarLoginPageOnly(
            context: context,
            isError: true,
            message: message,
          );
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
    final code = _otpController.text.replaceAll(RegExp(r'\D'), '');
    if (code.length != 6) {
      if (!mounted) return;
      _resetOtpFields();
      CommonFunction.showSnackBarLoginPageOnly(
        context: context,
        isError: true,
        message: 'Please enter 6-digit OTP.',
      );
      return;
    }

    _verifying.value = true;
    try {
      // 1) Validate OTP and get credentials from backend
      await _loginRepo.validateOtpAndLogin(
        contactNo: widget.contactNo,
        otp: code,
        success: (userName, password, otpResponseJson) async {
          // 2) Authenticate — try email/mobile/loginMode variants OTP APIs often differ from manual login.
          final prefs = await SharedPreferences.getInstance();
          final device = DeviceInfoPlugin();

          String deviceName = Platform.isAndroid ? 'Android' : Platform.isIOS ? 'iOS' : 'Device';
          try {
            if (Platform.isAndroid) {
              final android = await device.androidInfo.timeout(_bootstrapTimeout);
              deviceName = android.model;
            } else if (Platform.isIOS) {
              final ios = await device.iosInfo.timeout(_bootstrapTimeout);
              deviceName = ios.model;
            }
          } catch (e, st) {
            log('OTP: device info failed: $e');
            log('OTP: device info stack: $st');
          }

          String ipv4 = '0.0.0.0';
          try {
            ipv4 = await Ipify.ipv4().timeout(_bootstrapTimeout);
          } catch (e) {
            log('OTP: ipify failed: $e');
          }

          String latitude = '0';
          String longitude = '0';
          try {
            final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium)
                .timeout(_bootstrapTimeout);
            latitude = pos.latitude.toString();
            longitude = pos.longitude.toString();
          } catch (e) {
            // If location is blocked, backend login should still proceed with 0,0.
            log('OTP: location failed: $e');
          }

          final deviceId = prefs.getString(PreferenceHelper.fcmToken) ?? '';

          await _loginRepo.authenticateUserAfterOtp(
            otpResponseJson: otpResponseJson,
            userName: userName,
            password: password,
            deviceID: deviceId,
            deviceName: deviceName,
            ip: ipv4,
            latitude: latitude,
            longitude: longitude,
            successResponse: (success, message, response) async {
              // Match password login: last-login context, profile prefs, after-login API.
              await prefs.setString(PreferenceHelper.lastLoginDeviceID, deviceId);
              await prefs.setString(PreferenceHelper.lastLoginDeviceName, deviceName);
              await prefs.setString(PreferenceHelper.lastLoginLatitude, latitude);
              await prefs.setString(PreferenceHelper.lastLoginLongitude, longitude);
              await prefs.setString(PreferenceHelper.lastLoginIpAddress, ipv4);

              await LoginVM.persistLoginProfile(prefs, response);

              AddLoggedInAreaAddressRepository().afterLoginApi(
                tokenID: '${response.tokenId}',
                address: '',
                loginDetailID: response.loginDetailId.toString(),
                latitude: latitude,
                longitude: longitude,
                isLogin: '1',
                successResponse: (_success, _message, _response) {},
                failedResponse: (_success, _message) {},
              );

              if (!mounted) return;
              // Do not show "User Authenticate Successfully" toast on success.
              if (message.trim().isNotEmpty) {
                CommonFunction.showSnackBarLoginPageOnly(
                  context: context,
                  isError: false,
                  message: message,
                );
              }
              Navigator.pushAndRemoveUntil(
                context,
                cusNavigate(HomeScreen(tokenId: response.tokenId)),
                (route) => false,
              );
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final ctx = navigatorKey.currentContext;
                if (ctx != null) {
                  unawaited(NotificationPermissionDialogService.show(ctx));
                }
              });
            },
            failedResponse: (success, message) {
              if (!mounted) return;
              CommonFunction.showSnackBarLoginPageOnly(
                context: context,
                isError: true,
                message: message.trim().isEmpty ? 'Login failed.' : message,
              );
            },
          );
        },
        failed: (message) {
          if (!mounted) return;
          final display = _otpVerifyFailureMessage(message);
          _resetOtpFields();
          CommonFunction.showSnackBarLoginPageOnly(
            context: context,
            isError: true,
            message: display,
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      _resetOtpFields();
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
                      'We have sent an OTP to\n${widget.dialCode}${widget.contactNo}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 10),

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
                              if (canResend) {
                                return Text(
                                  'Resend OTP',
                                  style: baseStyle.copyWith(color: AppColor.background),
                                );
                              }
                              return RichText(
                                text: TextSpan(
                                  style: baseStyle,
                                  children: [
                                    const TextSpan(text: 'Resend OTP in '),
                                    TextSpan(
                                      text: _formatMmSs(left),
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

