import 'dart:convert';
import 'package:cadashboard/main.dart';
import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/model/login_model.dart';
import 'package:cadashboard/core/model/task/task_effort_model.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskEffortRepo extends ApiClient{

  Future<void> addTaskEffort({
    required String taskID,required String hours,required String minutes,required String effortDate,required String effortNote,
    required String isBillable,required String isApproved,
    required Function(List<TaskEffortModel> response) success,
    required Function(String message) failed }) async {

    SharedPreferences preferences = await SharedPreferences.getInstance();

    var json = await jsonDecode(preferences.getString(PreferenceHelper.userData)!);
    LoginModel model = LoginModel.fromJson(json);


    Map<String, dynamic> body = {
      'TaskEffortID' : "-1",
      'TaskID' : taskID,
      'EmployeeID' : model.employeeId,
      'ActualEffortsHRs' : hours,
      'ActualEffortsMins' : minutes,
      'EffortDate' : effortDate,
      'Notes' : effortNote,
      'IsApproved' : isApproved,
      'IsBillable' : isBillable,
      'FirmName' : model.orgName,
      'FullName' : "${model.firstName} ${model.lastName}",
      'LoginMode' : model.loginMode,
      'Flag' : "0",
      'TokenID' : model.tokenId,
    };

    var result = await postRawMethod(
      url: Uri.parse(Urls.addUpdateTaskEffort),
      header: {"Content-Type": "application/json"},
      body: body,
    );

    try {

      List<TaskEffortModel> list = (result as List).map((e) => TaskEffortModel.fromJson(e)).toList();
      success(list);
    } catch (e) {
      appPrint("TaskEffort Exception :-> $e");
      failed(errorMessage);
    }
  }

}