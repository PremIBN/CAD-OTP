import 'dart:io';
import 'package:cadashboard/core/View_Model/login_vm.dart';
import 'package:cadashboard/core/utils/colors.dart';
import 'package:cadashboard/core/utils/images.dart';
import 'package:cadashboard/core/utils/stateless_base_view.dart';
import 'package:cadashboard/main.dart';
import 'package:cadashboard/ui/screen/home.dart';
import 'package:cadashboard/ui/widget/custom_btn.dart';
import 'package:cadashboard/ui/widget/custom_navigate.dart';
import 'package:cadashboard/ui/widget/custom_textfield.dart';
import 'package:cadashboard/ui/screen/forgot_password.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:upgrader/upgrader.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final formKey = GlobalKey<FormState>();
  final forgotFormKey = GlobalKey<FormState>();

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

        requestLocationPermission() async {
          LocationPermission permission;
          // Check if location services are enabled

          bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (Platform.isIOS) {
            if (!serviceEnabled) {
              if (buildContext.mounted) {
                locationDialog(
                  context: buildContext,
                  onTapGotIt: () => Navigator.pop(buildContext),
                );
              }
              model.buttonLoader.value = false;
              return false;
            }
          }

          permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
            if (permission == LocationPermission.denied) {
              model.buttonLoader.value = false;
              return false;
            }
          }

          if (permission == LocationPermission.deniedForever) {
            model.buttonLoader.value = false;
            return false ;
          }

          final position = await Geolocator.getCurrentPosition();
          if (!buildContext.mounted) return false;
          model.login(buildContext, model.usernameController.text, model.passwordController.text,
            position.latitude.toString(), position.longitude.toString()).then((value) {
          });

          return true;
        }


        return Scaffold(
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
                                requestLocationPermission();
                              }
                            },
                          );
                        },
                      ),
                    ],
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

class UpgradeApp extends StatelessWidget {
  final Widget child;

  const UpgradeApp({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      dialogStyle: Platform.isIOS ? UpgradeDialogStyle.cupertino : UpgradeDialogStyle.material,
      barrierDismissible: false,
      showLater: false,
      showIgnore: false,
      upgrader: Upgrader(),
      child: child,
    );
  }
}
