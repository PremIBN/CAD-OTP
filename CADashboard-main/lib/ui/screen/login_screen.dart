import 'dart:async';
import 'dart:io';
import 'package:cadashboard/core/View_Model/login_vm.dart';
import 'package:cadashboard/core/common/common_function.dart';
import 'package:cadashboard/core/utils/colors.dart';
import 'package:cadashboard/core/utils/images.dart';
import 'package:cadashboard/core/utils/stateless_base_view.dart';
import 'package:cadashboard/ui/widget/custom_btn.dart';
import 'package:cadashboard/ui/widget/custom_navigate.dart';
import 'package:cadashboard/ui/widget/custom_textfield.dart';
import 'package:cadashboard/ui/widget/upgrade_app.dart';
import 'package:cadashboard/ui/screen/forgot_password.dart';
import 'package:cadashboard/ui/screen/otp_login/otp_phone_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final formKey = GlobalKey<FormState>();
  final forgotFormKey = GlobalKey<FormState>();
  static const Duration _locationTimeout = Duration(seconds: 20);
  static const Duration _geoServiceTimeout = Duration(seconds: 15);
  static const Duration _permissionTimeout = Duration(seconds: 60);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext loginContext) {
    Size size = MediaQuery.of(loginContext).size;
    return StatelessBaseView(
      model: LoginVM(),
      builder: (buildContext, model, child) {

        Future<void> loginWithFallbackCoords() async {
          if (!buildContext.mounted) return;
          await model.login(
            buildContext,
            model.usernameController.text,
            model.passwordController.text,
            '0',
            '0',
          );
        }

        Future<bool> requestLocationPermission() async {
          LocationPermission permission;

          void clearLoaderIfNeeded() {
            if (!buildContext.mounted) return;
            model.buttonLoader.value = false;
          }

          try {
            final serviceEnabled = await Geolocator.isLocationServiceEnabled()
                .timeout(_geoServiceTimeout, onTimeout: () => false);
            if (Platform.isIOS) {
              if (!serviceEnabled) {
                if (!buildContext.mounted) {
                  clearLoaderIfNeeded();
                  return false;
                }
                await loginWithFallbackCoords();
                return true;
              }
            }

            permission = await Geolocator.checkPermission().timeout(
              _geoServiceTimeout,
              onTimeout: () => LocationPermission.denied,
            );
            if (permission == LocationPermission.denied) {
              permission = await Geolocator.requestPermission().timeout(
                _permissionTimeout,
                onTimeout: () => LocationPermission.denied,
              );
              if (permission == LocationPermission.denied) {
                if (Platform.isIOS) {
                  if (!buildContext.mounted) {
                    clearLoaderIfNeeded();
                    return false;
                  }
                  await loginWithFallbackCoords();
                  return true;
                }
                clearLoaderIfNeeded();
                if (buildContext.mounted) {
                  CommonFunction.showSnackBarLoginPageOnly(
                    context: buildContext,
                    isError: true,
                    message: 'Location permission is required to sign in.',
                  );
                }
                return false;
              }
            }

            if (permission == LocationPermission.deniedForever) {
              if (Platform.isIOS) {
                if (!buildContext.mounted) {
                  clearLoaderIfNeeded();
                  return false;
                }
                await loginWithFallbackCoords();
                return true;
              }
              clearLoaderIfNeeded();
              if (buildContext.mounted) {
                CommonFunction.showSnackBarLoginPageOnly(
                  context: buildContext,
                  isError: true,
                  message: 'Location permission is required to sign in.',
                );
              }
              return false;
            }

            Position position;
            try {
              position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high,
              ).timeout(_locationTimeout);
            } catch (e) {
              if (Platform.isIOS) {
                if (!buildContext.mounted) {
                  clearLoaderIfNeeded();
                  return false;
                }
                await loginWithFallbackCoords();
                return true;
              }
              clearLoaderIfNeeded();
              if (buildContext.mounted) {
                CommonFunction.showSnackBarLoginPageOnly(
                  context: buildContext,
                  isError: true,
                  message: 'Unable to get location. Please enable GPS and try again.',
                );
              }
              return false;
            }
            if (!buildContext.mounted) {
              clearLoaderIfNeeded();
              return false;
            }
            await model.login(
              buildContext,
              model.usernameController.text,
              model.passwordController.text,
              position.latitude.toString(),
              position.longitude.toString(),
            );
            return true;
          } catch (e) {
            clearLoaderIfNeeded();
            if (buildContext.mounted) {
              CommonFunction.showSnackBarLoginPageOnly(
                context: buildContext,
                isError: true,
                message: 'Sign-in could not start. Please try again.',
              );
            }
            return false;
          }
        }


        // Login stays English / LTR regardless of app language (CusField/CusBtn use locale for ApiTextLocalizer).
        return Localizations.override(
          context: buildContext,
          locale: const Locale('en'),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Scaffold(
              body: UpgradeApp(
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: size.height * 0.15),
                          Image.asset(AppImages.logoText,width: 300,),
                          SizedBox(height: size.height * 0.1),
                          Form(
                            key: formKey,
                            child: Column(
                              children: [
                                CusField(
                                  controller: model.usernameController,
                                  hint: 'Enter Username',
                                  icon: const Icon(Icons.person_outline_outlined),
                                  onValidator: (value) {
                                    return model.usernameController.text.isEmpty
                                        ? 'Please enter email.'
                                        : null;
                                  },
                                  onChanged: (value) {
                                    value.isEmpty ? !formKey.currentState!.validate() : formKey.currentState!.validate();
                                  },
                                ),
                                SizedBox(height: size.height * 0.03),
                                ValueListenableBuilder(
                                  valueListenable: model.visible,
                                  builder: (context, value, child) {
                                    return CusField(
                                      controller: model.passwordController,
                                      visible: value,
                                      hint: 'Enter Password',
                                      icon: const Icon(Icons.password),
                                      suffixIcon: IconButton(
                                        icon: Icon(value ? Icons.visibility_off : Icons.visibility),
                                        onPressed: () {
                                          value ? model.visible.value=false : model.visible.value=true;
                                        },
                                      ),
                                      onValidator: (value) {
                                        return model.passwordController.text.isEmpty ? 'Please enter password.' : null;
                                      },
                                      onChanged: (value) {
                                        value.isEmpty ? !formKey.currentState!.validate() : formKey.currentState!.validate();
                                      },
                                    );
                                  },
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: size.height * 0.006),
                          Align(
                            alignment: FractionalOffset.centerRight,
                            child: TextButton(
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.background,
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(context, cusNavigate(const ForgotPasswore()));
                              },
                            ),
                          ),
                          SizedBox(height: size.height * 0.006),
                          ValueListenableBuilder(
                            valueListenable: model.buttonLoader,
                            builder: (context, value, child) {
                              return CusBtn(
                                btnName: 'Login',
                                loading: value,
                                onTap: () async {
                                  if (formKey.currentState!.validate()) {
                                    model.buttonLoader.value = true;
                                    await requestLocationPermission();
                                  }
                                },
                              );
                            },
                          ),
                          SizedBox(height: size.height * 0.02),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: AppColor.background.withValues(alpha: 0.25),
                                  thickness: 1,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: AppColor.background.withValues(alpha: 0.25),
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.015),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.phone_android),
                              label: const Text(
                                'Continue with OTP',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColor.background,
                                side: const BorderSide(color: AppColor.background, width: 1.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(context, cusNavigate(const OtpPhoneScreen()));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// UpgradeApp moved to lib/ui/widget/upgrade_app.dart
