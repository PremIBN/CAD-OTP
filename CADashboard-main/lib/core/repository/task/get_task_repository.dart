import 'dart:developer';
import 'package:cadashboard/main.dart';
import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/model/task/GetAllOrgTasks_model.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetTaskRepo extends ApiClient {
  Future<List<GetAllOrgTasksModel>?> gettask({
    required String statusid,required String start,
    required String tasktypeid, String? parentTaskID, String? client, String? employee, String? fy,
    required Function(List<GetAllOrgTasksModel> response) success,
    required Function(String message) failed,
  }) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    appPrint('financialyearid :------> ${preferences.getString(PreferenceHelper.financialYearID) ?? 'null'}');

    Map<String, dynamic> queryParam = {
      'tokenID': preferences.getString(PreferenceHelper.userToken) ?? "null",
      'startLimit': start,
      'endLimit': "10",
      'taskID': "0",
      'parentTaskID': parentTaskID ?? "0",
      'assigntoemployeeid': employee ?? "0",
      'statusid':  statusid,
      'tasktypeid': tasktypeid,
      'financialyearid': fy ?? preferences.getString(PreferenceHelper.financialYearID),
      'startdate': "",
      'enddate': "",
      'assignbyemployeeid': "0",
      'clientid': client ?? "-1",
      'datetype': "2",
      'service': "",
      'complianceid': "0",
      'priority': "",
      'isbillable': "-1",
      'tasknumber': "",
      'sort' : "DESC",   //"ASC",
    };

    var result = await getMethod(
      url: Uri.parse(Urls.GetAllOrgTasks),
      queryParam: queryParam,
    );

    try {
      List<GetAllOrgTasksModel> list = (result as List)
          .map((data) => GetAllOrgTasksModel.fromJson(data))
          .toList();

      success(list);
      return list;
    } catch (e) {
      log("GetTask Exception :----> $e");
      failed(errorMessage);
      return null;
    }
  }
}
