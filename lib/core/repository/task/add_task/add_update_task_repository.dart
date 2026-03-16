import 'dart:convert';
import 'dart:developer';
import 'package:cadashboard/main.dart';
import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/model/login_model.dart';
import 'package:cadashboard/core/model/task/add_task/add_update_task_model.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddTaskRepo extends ApiClient{

  Future<void> addUpdateTask({ String? taskID, String? parentID, String? mandate, String? assigner, String? reviewer, String? fy,
    required String taskName,required String serviceID, String? taskNote,required String statusID,required String clientName,
    required DateTime startDate,required DateTime endDate,required String branch,required String department,String? priority,
    required String billable,required String currencyID,required String billableAmount,required String employeeId,
    required Function(List<AddUpdateTaskModel> response) success,
    required Function(String message) failed,
  }) async {
    
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var json = await jsonDecode(preferences.getString(PreferenceHelper.userData)!);
    LoginModel model = LoginModel.fromJson(json);

    Map<String, dynamic> body = {
      'TaskID': taskID ?? "-1",
      'ParentTaskId': parentID ?? '0',
      'TaskNumber': 'null',
      'TaskName': taskName,
      'ServiceID':serviceID.toString(),
      'ClientOrgID': clientName.toString(),
      'TaskStatusID':statusID.toString(),
      'CalculatedStatusID':"0",
      'AssignementTypeID':'0',
      'EstimatedEffortHrs':'0',
      'EstimatedEffortMin':'0',
      'StartDate':startDate.toString(),
      'EndDate':endDate.toString(),
      'ComplianceDate':"null",
      'IsBillable': billable.toString(),
      'BillingAmount': billableAmount.toString(),
      'IsInvoiced':'0',
      'TemplateTaskID':'0',
      'AssignedByEmpID': assigner ?? "0",
      'OrgID':model.orgId.toString(),
      'ReminderBeforeDays':'0',
      'CompletionPercent':'0',
      'PriorityId':priority.toString(),
      'IsComplianceTask':'0',
      'FinancialYearID': fy ?? preferences.getString(PreferenceHelper.financialYearID),
      'ComplianceID':'0',
      'IsShared':'0',
      'CurrencyID' : currencyID.toString(),
      'CompletionDate':"null",
      'ActualStartDate':"null",
      'CopiedFromFY':'0',
      'BranchID':branch.toString(),
      'DepartmentID':department.toString(),
      if(taskNote!=null)'Notes': taskNote,
      'AssignedToEmpID':employeeId.toString(),
      'TokenID': preferences.getString(PreferenceHelper.userToken),
      'MandateNo' : mandate ?? "",
      'ReviewerID' : reviewer ?? "0"
    };

    log("====>AddUpdateTask Body :- $body");

    var result = await postMethod(
        url: Uri.parse(Urls.addUpdateTask),
      header: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: body,
    );


    try {

      List<AddUpdateTaskModel> list = (jsonDecode(result) as List).map((e) => AddUpdateTaskModel.fromJson(e)).toList();

      /*List<AddUpdateTask> list = [];

      for (int i=0; i<result['Message'].length; i++){
        log("Object ${result['Message'][i]}");
        list.add(AddUpdateTask.fromJson(result['Message'][i]));
      }*/

      success(list);
    } catch (e) {
      appPrint('--------------------> AddUpdateTask Exception : $e');
      failed(errorMessage);
    }

  }

}