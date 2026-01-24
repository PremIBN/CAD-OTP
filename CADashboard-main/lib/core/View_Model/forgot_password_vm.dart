import 'package:cadashboard/core/common/common_function.dart';
import 'package:cadashboard/core/utils/base_model.dart';
import 'package:flutter/material.dart';

class ForgotPasswordVM extends BaseModel{

  ValueNotifier<bool> loading = ValueNotifier(false);


  final FocusNode _focusNode = FocusNode();

  void closeKeyboard() {
    _focusNode.unfocus(); // Close the keyboard
  }




  Future<void> forgot(BuildContext context, String username, String email) async {
    forgotRepo.forgot(
      email: email,
      username: username,
      success: (message, code) {
        if(code == 204) {
          CommonFunction.showSnackBar(context: context, isError: true, message: 'Please Enter Correct Username & Email');
          loading.value = false;
        } else {
          CommonFunction.showSnackBar(context: context, isError: false, message: message);
          Navigator.pop(context);
          loading.value = false;
        }
      },
      failed: (message) {
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        loading.value = false;
      },
    );
  }

}