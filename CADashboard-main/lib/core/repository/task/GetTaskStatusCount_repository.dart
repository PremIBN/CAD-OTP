// ignore_for_file: file_names

import 'dart:convert';

import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/model/login_model.dart';
import 'package:cadashboard/core/model/check_token_model.dart';
import 'package:cadashboard/core/model/task/GetTaskStatusCount_model.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetTaskStatusCountRepo extends ApiClient{

  Future<void> getTaskStatusCount({
    String? client, String? employee, String? fy,
    required Function(GetTaskStatusCountModel response) successResponse,
    required Function(int success, String message, int  statusCode) failedResponse }) async{

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var jsonData = await jsonDecode(preferences.getString(PreferenceHelper.userData) ?? "");
    LoginModel userDataModel = LoginModel.fromJson(jsonData);

    Map<String, String> queryParam = {};

      queryParam = {
        'tokenID' : preferences.getString(PreferenceHelper.userToken) ?? "",
        'financialYear' : fy ?? userDataModel.financialYearId.toString(),
        'organisationId' : userDataModel.orgId.toString(),
        'organizationType' : userDataModel.orgTypeId.toString(),
        'userId' : userDataModel.userId.toString(),
        'employeeId' : employee ?? userDataModel.employeeId.toString(),
        'roleId' : userDataModel.userRoleId.toString(),
        'clientId' : client ?? "-1",
        'startdate' : "",
        'enddate' : "",
        'datetype' : "",
      };


      var result = await getMethod(
          url: Uri.parse(Urls.GetTaskStatusCount),
          queryParam: queryParam
      );

      try{
        GetTaskStatusCountModel getTaskStatusCountModel = GetTaskStatusCountModel.fromJson(result);
        if(getTaskStatusCountModel.success == 0){
          failedResponse(0, getTaskStatusCountModel.message!,getTaskStatusCountModel.statusCode ?? 000);
        } else {
          successResponse(getTaskStatusCountModel);
        }
      } catch (e) {
        CheckTokenModel tokenModel = CheckTokenModel.fromJson(result);
        failedResponse(0,tokenModel.message ?? errorMessage,tokenModel.statusCode ?? 000);
      }
  }
}