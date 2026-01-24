import 'dart:convert';
import 'dart:developer';

import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/model/login_model.dart';
import 'package:cadashboard/core/model/check_token_model.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:cadashboard/core/utils/utils.dart';
import 'package:cadashboard/main.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginRepo extends ApiClient{

  Future<void> authenticateUser ({
    required String username, required String password, required String loginMode,
    required String deviceID, required String deviceName, required String ip ,
    required String latitude, required String longitude,
    required Function(int success, String message, LoginModel response) successResponse,
    required Function(int success, String message) failedResponse }) async {

    Map<String, String> queryParam = {
      'userName' : username,
      'password' : password,
      'loginMode' : loginMode,
      'deviceID' : deviceID,
      'deviceName' : deviceName,
      'latlng': "$latitude,$longitude",
      'ip' : ip,
    };

    var result = await withOutTokenPostMethod(url: Uri.parse(Urls.AuthenticateUser),queryParam: queryParam);
    SharedPreferences preferences = await SharedPreferences.getInstance();

    try{
      LoginModel authenticateUserModel = LoginModel.fromJson(result);

      if(authenticateUserModel.success == 1){
        debugPrint("Device ID :-> ${authenticateUserModel.deviceId}");
        String json = jsonEncode(result);
        preferences.setString(PreferenceHelper.userData, json);

        successResponse(1, 'User Authenticate Successfully', authenticateUserModel);
      } else {
        CheckTokenModel tokenModel = CheckTokenModel.fromJson(result);
        failedResponse(0,tokenModel.message!);
      }
    } catch (e) {
      log("Login Exception :---> $e");
      showSnackBar(context: navigatorKey.currentContext!, isError: true, message: "message :: $e");
      failedResponse(0, errorMessage);
    }
  }

}