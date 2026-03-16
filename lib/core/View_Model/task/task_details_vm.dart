import 'package:cadashboard/core/common/common_function.dart';
import 'package:cadashboard/core/model/task/specific_task_model.dart';
import 'package:cadashboard/core/utils/base_model.dart';
import 'package:cadashboard/core/utils/view_state.dart';
import 'package:cadashboard/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/preference_helper.dart';

class TaskDetailsVM extends BaseModel{

  ValueNotifier<ViewState> viewLoader = ValueNotifier(ViewState.loading);
  ValueNotifier<bool> btnLoader = ValueNotifier(false);

  /*TextEditingController taskNameController = TextEditingController();
  TextEditingController currencyController = TextEditingController();*/

  TextEditingController addTaskEffort = TextEditingController();
  TextEditingController effortDateController = TextEditingController();
  TextEditingController effortHours = TextEditingController();
  TextEditingController effortMinute = TextEditingController();

  DateTime? startDate, endDate, effortDate;
/*
  List<ClientListElement> serviceList = [];
  List taskStatusList = [];
  List priorityList = [];
  List<ClientListElement> assToList = [];
  List<ClientListElement> clientList = [];
  List<GetBranchModel> branchList = [];
  List<GetAllDepartmentsModel> departmentList = [];
  List<GetAllCurrencyModel> currencyList = [];

  int? service;
  int? status;
  int? assTo;
  String? assToName;
  int? client;
  String? clientName;
  int? branch;
  int? department;
  int? priority;
  int? currency;
  int? share;
  int? billable;*/
  int isBillable = 0;
  int isApproved = 1;

  late SpecificTaskModel task;

  int? restrictTillDays;

  getRestrictTillDays () async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    restrictTillDays = preferences.getInt(PreferenceHelper.restrictTillDays);
    notifyListeners();
  }


  Future<void> getSpecificTask(BuildContext context, String taskID) async {

    specificTaskRepo.specificTask(
      taskID: taskID,
      success: (response) {
        /*taskNameController.text = response.taskName!;*/
        task = response;
        /*service = response.serviceId;
        assToName = response.assignedToEmpName;
        clientName = response.clientName;
        status = response.taskStatusId;
        startDate = response.startDate;
        endDate = response.endDate;
        branch = response.branchId;
        department = response.departmentId;
        billable = response.isBillable;
        currencyController.text = response.billingAmount.toString();
        currency = response.currencyId;
        priority = response.priorityId;
        share = response.isShared;*/

        appPrint("======> ${response.serviceId} : ${response.serviceName}");
        viewLoader.value = ViewState.success;
        // dropDown(context);
      },
      failed: (message) {
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );

  }
/*

  Future<void> dropDown(BuildContext context) async{
    dropDownRepo.dropdown(
      successResponse: (response) {

        response.employeeList.forEach((element) {
          print("=======> ${element.displayValue} : ${element.displayName}");
        });

        taskStatusList = response.taskStatusList;
        serviceList = response.serviceList;
        assToList = response.employeeList;
        clientList = response.clientList;
        notifyListeners();
        getPriority(context);
      },
      failedResponse: (message, code) {
        print(message);
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        if(code == 504){
          Navigator.pushAndRemoveUntil(context, cusNavigate(const LoginScreen()), (route) => false);
        }
        viewLoader.value = ViewState.failed;
      },
    );
  }

  Future<void> getPriority(BuildContext context) async {
    priorityDropDownRepo.getpriority(
      success: (response) {
        priorityList = response;
        getBranch(context);
      },
      failed: (success, message, statusCode) {
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
        if(statusCode == 504){
          Navigator.pushAndRemoveUntil(context, cusNavigate(const LoginScreen()), (route) => false);
        }
      },
    );
  }

  Future<void> getBranch(BuildContext context) async {
    branchRepo.getBranch(
      success: (response) {
        branchList = response;
        getDepartment(context);
      },
      failed: (message) {
        print(message);
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }

  Future<void> getDepartment(BuildContext context) async {
    departmentRepo.getBranch(
      success: (response) {
        departmentList = response;
        getcurrency(context);
      },
      failed: (message) {
        print(message);
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }

  Future<void> getcurrency(BuildContext context) async{
    currencyRepo.getCurrency(
      successresponse: (response) {
        currencyList = response;
        notifyListeners();
        viewLoader.value = ViewState.success;
      },
      failedResponse: (message) {
        print(message);
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }
*/


  /*Future<void> updateTask(BuildContext context, String taskId, String statusID, String taskName, DateTime startDate, DateTime endDate, String priority,
      String billable, String billableAmount) async {

    addTaskRepo.addUpdateTask(
      taskID: taskId,
      serviceID: service.toString(),
      statusID: statusID,
      employeeId: assTo.toString(),
      clientName: client.toString(),

      taskName: taskName,

      startDate: startDate,
      endDate: endDate,

      branch: branch.toString(),
      department: department.toString(),
      priority: priority.toString(),
      billable: billable.toString(),
      billableAmount: billableAmount,
      currencyID: currency.toString(),

      success: (response) {
        btnLoader.value = false;
        CommonFunction.showSnackBar(context: context, isError: false, message: 'Task Updated Successfully');
        Navigator.of(context).pop(true);
      },
      failed: (message) {
        btnLoader.value = false;
      },
    );
  }*/


  Future<void> addNote(BuildContext context, String taskID, String taskNote) async {
    noteRepo.addTaskNote(
      taskID: taskID,
      taskNote: taskNote,
      success: (response) {
        btnLoader.value = false;
        Navigator.pop(context);
        viewLoader.value = ViewState.loading;
        getSpecificTask(context, taskID);
        CommonFunction.showSnackBar(context: context, isError: false, message: 'Note added successfully');
      },
      failed: (message) {
        btnLoader.value = false;
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
      },
    );
  }

  Future<void> speechToAddNote(BuildContext context, String taskID, String taskNote) async {
    noteRepo.addTaskNote(
      taskID: taskID,
      taskNote: taskNote,
      success: (response) {
        getSpecificTask(context, taskID);
        CommonFunction.showSnackBar(context: context, isError: false, message: 'Note added successfully');
      },
      failed: (message) {
        viewLoader.value = ViewState.success;
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
      },
    );
  }


  Future<void> addEffort(BuildContext context, String taskID, String hours, String minutes, String effortDate, String effortNote,
      String isBillable, String isApproved,) async {

    effortRepo.addTaskEffort(
        taskID: taskID,
        hours: hours,
        minutes: minutes,
        effortDate: effortDate,
        effortNote: effortNote,
        isBillable: isBillable,
        isApproved: isApproved,
        success: (response) {
          btnLoader.value = false;
          Navigator.pop(context);
          CommonFunction.showSnackBar(context: context, isError: false, message: "Effort Add Successfully.");
          viewLoader.value = ViewState.loading;
          getSpecificTask(context, taskID);
        },
        failed: (message) {
          CommonFunction.showSnackBar(context: context, isError: true, message: message);
          btnLoader.value = false;
        },
    );

  }

}