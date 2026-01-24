import 'dart:convert';
import 'dart:developer';

import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/model/login_model.dart';
import 'package:cadashboard/core/model/check_token_model.dart';
import 'package:cadashboard/core/model/task/add_task/GetTaskRelatedDropDowns_model.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddTaskDropDownRepo extends ApiClient{

  Future<void> dropdown({
    required Function(GetTaskRelatedDropDownsModel response) successResponse,
    required Function(String message, int statusCode) failedResponse }) async {

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var jsonData = await jsonDecode(preferences.getString(PreferenceHelper.userData) ?? "");
    LoginModel userDataModel = LoginModel.fromJson(jsonData);

    Map<String, String> queryParam = {
      'tokenID' : userDataModel.tokenId ?? "",
      'financialYear' : userDataModel.financialYearId.toString(),
    };

    var result = await getMethod(url: Uri.parse(Urls.GetTaskRelatedDropDowns),queryParam: queryParam);

    try{
      GetTaskRelatedDropDownsModel getTaskRelatedDropDownsModel = GetTaskRelatedDropDownsModel.fromJson(result);
      if(getTaskRelatedDropDownsModel.success == 0){
        failedResponse(getTaskRelatedDropDownsModel.message ?? errorMessage, getTaskRelatedDropDownsModel.statusCode ?? 001);
      } else {
        successResponse(getTaskRelatedDropDownsModel);
      }
    } catch (e) {
      CheckTokenModel tokenModel = CheckTokenModel.fromJson(result);
      log("DropDown Exception :----> $e");
      failedResponse(errorMessage, tokenModel.statusCode ?? 000);
    }
  }

}