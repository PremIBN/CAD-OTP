import 'package:cadashboard/core/common/common_function.dart';
import 'package:cadashboard/core/utils/base_model.dart';
import 'package:cadashboard/ui/screen/login_screen.dart';
import 'package:cadashboard/ui/widget/custom_navigate.dart';
import 'package:flutter/material.dart';

class ChangePasswordVM extends BaseModel{

  ValueNotifier<bool> buttonLoader = ValueNotifier(false);

  TextEditingController oldController = TextEditingController();
  TextEditingController newController = TextEditingController();

  bool visiable1 = false;
  bool visiable2 = false;

  Future<void> changePassword(BuildContext context) async{

    // SharedPreferences preferences = await SharedPreferences.getInstance();

    changePasswordRepo.changePassword(
        newPassword: newController.text,
        oldPassword: oldController.text,
        successResponse: (success, message, response) {
          buttonLoader.value = false;
          CommonFunction.showSnackBar(context: context, isError: false, message: message);
          Navigator.pushReplacement(context, cusNavigate(const LoginScreen()));
        },
        failedResponse: (success, message) {
          buttonLoader.value = false;
          CommonFunction.showSnackBar(context: context, isError: true, message: message);
        },
    );
  }

}