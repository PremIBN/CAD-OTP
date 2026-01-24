// ignore_for_file: use_build_context_synchronously

import 'package:cadashboard/core/common/common_function.dart';
import 'package:cadashboard/core/model/task/GetAllOrgTasks_model.dart';
import 'package:cadashboard/core/model/task/add_task/FinancialYear_model.dart';
import 'package:cadashboard/core/model/task/add_task/GetTaskRelatedDropDowns_model.dart';
import 'package:cadashboard/core/utils/base_model.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:cadashboard/core/utils/view_state.dart';
import 'package:cadashboard/main.dart';
import 'package:cadashboard/ui/screen/login_screen.dart';
import 'package:cadashboard/ui/widget/custom_navigate.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskVM extends BaseModel{

  ValueNotifier<ViewState> viewLoader = ValueNotifier(ViewState.loading);
  ValueNotifier<ViewState> taskLoader = ValueNotifier(ViewState.loading);

  late String taskType;
  late String taskStatus;

  List<GetAllOrgTasksModel> getTask = [];

  List tabs = [];
  List tabId = [];

  int tabIndex = -1;
  int task = 0;
  int maxTask = 0;

  List<ClientListElement> serviceList = [];
  List<TaskStatusList> taskStatusList = [];
  List<ClientListElement> employeeList = [];
  List<ClientListElement> clientList = [];
  List<FinancialYearModel> fyList = [];

  Future<void> dropDown(BuildContext context) async{
    dropDownRepo.dropdown(
      successResponse: (response) {
        taskStatusList.addAll(response.taskStatusList);
        employeeList = response.employeeList;
        clientList = response.clientList;
        List<ClientListElement> internal = [
          ClientListElement(
              displayName: "All",
              displayValue: -1,
              codeValue: 2,
              validationErrors: []
          ),
          ClientListElement(
              displayName: "Internal",
              displayValue: 0,
              codeValue: 2,
              validationErrors: []
          )
        ];
        clientList.insertAll(0, internal);
        getFinancialYear(context);
        notifyListeners();
      },
      failedResponse: (message,code) {
        appPrint(message);
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }

  Future<void> getFinancialYear(BuildContext context) async{
    financialYearRepo.getFinancialYear(
      success: (response) {
        fyList = response;
        taskTypeId(context);
      },
      failed: (message) {
        appPrint(message);
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }

  taskTypeId (BuildContext context) async {

    SharedPreferences preferences = await SharedPreferences.getInstance();

    taskType = tabId.join(',');
    appPrint('[-------------> $taskType]');
    preferences.setString(PreferenceHelper.taskType, taskType);

    taskStatus = taskStatusList.map((e){
      return e.displayValue;
    }).join(',');
    appPrint('[-------------> $taskStatus]');
    preferences.setString(PreferenceHelper.taskStatus, taskStatus);

    notifyListeners();
    getTaskList(context,null,null,null);
  }


  Future<void> getTaskList(BuildContext context, String? client, String? employee, String? fy) async {
    getTaskStatusCountRepo.getTaskStatusCount(
      employee: employee,
      client: client,
      fy: fy,
      successResponse: (response) {
        tabs = [
          '${response.dueTodayTaskName} (${response.dueTodayTaskCount})',
          '${response.pastDueTaskName} (${response.pastDueTaskCount})',
          '${response.dueSoonTaskName} (${response.dueSoonTaskCount})',
          '${response.notStartedYetName} (${response.notStartedYet})',
          '${response.workInProgressName} (${response.workInProgressCount})',
          '${response.needApprovalTaskName} (${response.needApprovalTaskCount})',
          '${response.assignedTaskName} (${response.assignedTaskCount})',
          '${response.completedName} (${response.completedCount})',
          '${response.closedTaskName} (${response.closedTaskCount})',
          '${response.pendingFromClientTaskName} (${response.pendingFromClientTaskCount})',
          '${response.invoicedTaskName} (${response.invoicedTaskCount})',
        ];
        tabId = [
          response.dueTodayTaskId,
          response.pastDueTaskId,
          response.dueSoonTaskId,
          response.notStartedYetId,
          response.workInProgressId,
          response.needApprovalTaskId,
          response.assignedTaskId,
          response.completedId,
          response.closedTaskId,
          response.pendingFromClientTaskId,
          response.invoicedTaskId,
        ];

        if(tabIndex == -1){
          tabIndex = tabId[0];
        }

        notifyListeners();
        viewLoader.value = ViewState.success;
        getAllTask(context, tabIndex.toString(), client, employee, fy);
      },
      failedResponse: (success, message, statusCode) {
        errorMessage = message;
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
        if(statusCode == 504){
          Navigator.pushAndRemoveUntil(context, cusNavigate(const LoginScreen()), (route) => false);
        }
      },
    );
  }

  Future<void> getAllTask(BuildContext context,String taskType, String? client, String? employee, String? fy) async {
    taskRepo.gettask(
      start: task.toString(),
      statusid: taskStatus,
      tasktypeid: taskType,
      client: client,
      employee: employee,
      fy: fy,
      success: (response) {
        if(getTask.isNotEmpty){
          getTask.addAll(response);
        } else {
          getTask = response;
          maxTask = response.last.taskId;
        }
        taskLoader.value = ViewState.success;
        notifyListeners();
      },
      failed: (message) {
        appPrint('Get Task  -----> $message');
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        taskLoader.value = ViewState.failed;
      },
    );
  }


  Future searchAll(BuildContext context) async{
    viewLoader.value = ViewState.loading;
    taskLoader.value = ViewState.loading;
    getTask.clear();
    task = 0;
    notifyListeners();
    getTaskList(context, null, null, null);
  }

  Future searchClient(BuildContext context, String? client, String? employee, String? fy) async{

    appPrint('Client ----> $client');

    viewLoader.value = ViewState.loading;
    taskLoader.value = ViewState.loading;
    getTask.clear();
    task = 0;
    notifyListeners();
    getTaskList(context, client, employee, fy);
  }

  /*Future searchEmployee(BuildContext context, String employee) async{

    appPrint('Employee ----> $employee');

    viewLoader.value = ViewState.loading;
    taskLoader.value = ViewState.loading;
    getTask.clear();
    task = 0;
    notifyListeners();
    getTaskList(context, null, employee);
  }*/

@override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    viewLoader.dispose();
  }

}