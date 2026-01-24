import 'package:cadashboard/core/common/common_function.dart';
import 'package:cadashboard/core/utils/base_model.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:cadashboard/core/utils/view_state.dart';
import 'package:cadashboard/main.dart';
import 'package:cadashboard/ui/screen/home.dart';
import 'package:cadashboard/ui/screen/login_screen.dart';
import 'package:cadashboard/ui/widget/custom_navigate.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreenVM extends BaseModel{

  ValueNotifier<ViewState> viewLoader = ValueNotifier(ViewState.loading);

  Future<void> checkToken(BuildContext context) async {

    SharedPreferences preferences = await SharedPreferences.getInstance();
    appPrint('-----> Token : ${preferences.getString(PreferenceHelper.userToken)}');

    if(preferences.getString(PreferenceHelper.userToken) == null || preferences.getString(PreferenceHelper.userToken) == "null"){
      Future.delayed(
        const Duration(milliseconds: 1000),
            () async{
          Navigator.pushAndRemoveUntil(context, cusNavigate(const LoginScreen()), (route) => false);
        },
      );
    }else{
      tokenRepo.checkToken(
        token: preferences.getString(PreferenceHelper.userToken) ?? "",
        successResponse: (success, message, response) {
          Future.delayed(
            const Duration(milliseconds: 500,),
                () async{
              Navigator.pushAndRemoveUntil(context, cusNavigate(const HomeScreen()), (route) => false);
            },
          );

          preferences.setBool(PreferenceHelper.isSignIn, true);
          appPrint('Token : $message');
          viewLoader.value = ViewState.success;
        },
        failedResponse: (success, message, code) {
          appPrint('Token : $message');
          CommonFunction.showSnackBar(context: context, isError: true, message: 'Your Session has been Expired');
          Future.delayed(
            const Duration(milliseconds: 500),
                () async{
              Navigator.pushAndRemoveUntil(context, cusNavigate(const LoginScreen()), (route) => false);
            },
          );
          viewLoader.value = ViewState.failed;
        },
      );
    }
  }


}