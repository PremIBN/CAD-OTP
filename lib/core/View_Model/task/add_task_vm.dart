import 'package:cadashboard/core/View_Model/task/task_details_vm.dart';
import 'package:cadashboard/core/common/common_function.dart';
import 'package:cadashboard/core/model/task/add_task/FinancialYear_model.dart';
import 'package:cadashboard/core/model/task/add_task/GetAllCurrency_model.dart';
import 'package:cadashboard/core/model/task/add_task/GetTaskRelatedDropDowns_model.dart';
import 'package:cadashboard/core/model/task/add_task/GetAllDepartment_model.dart';
import 'package:cadashboard/core/model/task/add_task/GetBranchList_model.dart';
import 'package:cadashboard/core/model/task/add_task/PriorityDropDown_model.dart';
import 'package:cadashboard/core/model/task/specific_task_model.dart' as stk;
import 'package:cadashboard/core/utils/base_model.dart';
import 'package:cadashboard/core/utils/view_state.dart';
import 'package:cadashboard/main.dart';
import 'package:cadashboard/ui/screen/login_screen.dart';
import 'package:cadashboard/ui/widget/custom_navigate.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class AddTaskVM extends BaseModel {

  ValueNotifier<ViewState> viewLoader = ValueNotifier(ViewState.loading);
  ValueNotifier<bool> btnLoader = ValueNotifier(false);

  DateTime? startDate, endDate;

  TextEditingController taskNameController = TextEditingController();
  TextEditingController taskNoteController = TextEditingController();
  TextEditingController currencyController = TextEditingController();
  TextEditingController employeeController = TextEditingController();
  TextEditingController clientController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController mandateController = TextEditingController();

  List<ClientListElement> serviceList = [];
  List<TaskStatusList> taskStatusList = [];
  List<ClientListElement> employeeList = [];
  List<ClientListElement> clientList = [];
  List<GetAllCurrencyModel> currencyList = [];
  List<PriorityDropDownModel> priorityList = [];
  List<GetBranchModel> branchList = [];
  List<GetAllDepartmentsModel> departmentList = [];
  List<FinancialYearModel> yearList = [];

  late stk.SpecificTaskModel task;

  int? service;
  int? status;

  List<bool> isChecked = [];
  List<String?> employeeName = [];
  String? assToName;
  List<String?> employeeId = [];
  String? assToID;
  List getSpecificTaskEmp = [];

  int? reviewer;
  int? assignor;

  int? client;
  String? clientName;

  int? branch;
  int? department;
  int? priority;
  int? currency;
  int? fy;
  int? share;
  int billable = 0;



  Future<void> dropDown(BuildContext context) async{

    // SharedPreferences pre = await SharedPreferences.getInstance();
    // var data = AuthenticateUserModel.fromJson(jsonDecode(pre.getString(PreferenceHelper.userData)!));

    dropDownRepo.dropdown(
        successResponse: (response) {
          serviceList.addAll(response.serviceList);
          taskStatusList.addAll(response.taskStatusList);
          employeeList.addAll(response.employeeList);
          clientList = response.clientList;
          ClientListElement internal = ClientListElement(
              displayName: "Internal",
              displayValue: 0,
              codeValue: 2,
              validationErrors: []
          );
          clientList.insert(0, internal);

          isChecked = List.generate(employeeList.length, (index) => false);


          for (var element in getSpecificTaskEmp) {
            for(int index=0; index<employeeList.length; index++){
              if(int.parse(element) == employeeList[index].displayValue){
                isChecked[index] = true;
              }
            }
          }


          status ??= response.taskStatusList[0].displayValue;

          notifyListeners();
          getPriority(context);
        },
        failedResponse: (message, code) {
          appPrint(message);
          CommonFunction.showSnackBar(context: context, isError: true, message: message);
          if(code == 504){
            Navigator.pushAndRemoveUntil(context, cusNavigate(const LoginScreen()), (route) => false);
          }
          viewLoader.value = ViewState.failed;
        },
    );
  }

  Future<void> getPriority(BuildContext context) async {
    priorityDropDownRepo.getPriority(
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
        appPrint(message);
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }

  Future<void> getDepartment(BuildContext context) async {
    departmentRepo.getBranch(
      success: (response) {
        departmentList = response;
        getFinancialYear(context);
      },
      failed: (message) {
        appPrint(message);
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }

  Future<void> getFinancialYear(BuildContext context) async{
    financialYearRepo.getFinancialYear(
      success: (response) {
        yearList = response;
        for (var element in yearList) {
          if(element.codeValue == 1.0){
            fy=element.displayValue;
          }
        }
        getcurrency(context);
      },
      failed: (message) {
        appPrint(message);
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }

  Future<void> getcurrency(BuildContext context) async{
    currencyRepo.getCurrency(
      successresponse: (response) {
        currencyList = response;
        currency = response[0].codeId;
        notifyListeners();

        viewLoader.value = ViewState.success;
      },
      failedResponse: (message) {
        appPrint(message);
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }


  Future<void> addUpdateTask(BuildContext context, String? parentID, String serviceID,String statusID,String employeeId,String clientName,String taskName,String taskNote,
      DateTime startDate,DateTime endDate,int? branch,int? department,String? priority,String billable,String billableAmount,String currencyID,) async {

    addTaskRepo.addUpdateTask(
      parentID: parentID,
        serviceID: serviceID,
        statusID: statusID,
        employeeId: employeeId,
        assigner: assignor.toString(),
        reviewer: reviewer.toString(),
        clientName: clientName,

        taskName: taskName,
        taskNote: taskNote,

        startDate: startDate,
        endDate: endDate,

        branch: branch == null ? "0" : branch.toString(),
        department: department == null ? "0" : department.toString(),
        priority: priority,
        billable: billable,
        billableAmount: billableAmount,
        currencyID: currencyID,
        mandate: mandateController.text,
        success: (response) {
          btnLoader.value = false;
          CommonFunction.showSnackBar(context: context, isError: false, message: 'Task add successfully');
          Navigator.of(context).pop(true);
        },
        failed: (message) {
         btnLoader.value = false;
        },
    );
  }



  Future<void> getSpecificTask(BuildContext context, String taskID) async {

    specificTaskRepo.specificTask(
      taskID: taskID,
      success: (response) {
        taskNameController.text = response.taskName!;
        task = response;
        service = response.serviceId;
        status = response.taskStatusId;
        assToID = response.assignedToEmpId;
        assToName = response.assignedToEmpName;
        assignor = response.assignedByEmpId;
        reviewer = response.reviewerId;
        client = response.clientOrgId;
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
        share = response.isShared;

        employeeController.text = response.assignedToEmpName!;

        getSpecificTaskEmp.addAll(response.assignedToEmpId!.split(",").toList());

        if(response.clientOrgId == 0){
          clientController.text = "Internal";
        } else {
          clientController.text = response.clientName!;
        }
        startDateController.text = DateFormat('dd-MMM-yyyy').format(startDate!);
        endDateController.text = DateFormat('dd-MMM-yyyy').format(endDate!);
        mandateController.text = response.mandateNo!;
        dropDown(context);
      },
      failed: (message) {
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );

  }



  Future<void> updateTask(BuildContext context, String taskId, String statusID, String taskName, DateTime startDate, DateTime endDate, String priority,
      String billable, String billableAmount, int? fy) async {

    addTaskRepo.addUpdateTask(
      taskID: taskId,
      serviceID: service.toString(),
      statusID: statusID,
      employeeId: assToID ?? "0",
      assigner: assignor.toString(),
      reviewer: reviewer.toString(),
      clientName: client.toString(),
      fy: fy?.toString(),
      taskName: taskName,

      startDate: startDate,
      endDate: endDate,

      branch: branch.toString(),
      department: department.toString(),
      priority: priority.toString(),
      billable: billable.toString(),
      billableAmount: billableAmount,
      currencyID: currency == null ? "0" : currency.toString(),
      mandate: mandateController.text,
      success: (response) {
        btnLoader.value = false;
        TaskDetailsVM().viewLoader.value = ViewState.success;
        TaskDetailsVM().updateUI();
        CommonFunction.showSnackBar(context: context, isError: false, message: 'Task Updated Successfully');
        Navigator.of(context).pop(true);
      },
      failed: (message) {
        btnLoader.value = false;
        TaskDetailsVM().viewLoader.value = ViewState.failed;
        TaskDetailsVM().updateUI();
      },
    );
  }

  Future<void> updateSubTask(BuildContext context,String? taskID, String? parentID, String serviceID,String statusID,String employeeId,String clientName,String taskName,String taskNote,
      DateTime startDate,DateTime endDate,int? branch,int? department,String? priority,String billable,String billableAmount,String currencyID,) async {

    addTaskRepo.addUpdateTask(
      taskID: taskID,
      parentID: parentID,
      serviceID: serviceID,
      statusID: statusID,
      employeeId: employeeId,
      assigner: assignor.toString(),
      reviewer: reviewer.toString(),
      clientName: clientName,

      taskName: taskName,
      taskNote: taskNote,

      startDate: startDate,
      endDate: endDate,

      branch: branch == null ? "0" : branch.toString(),
      department: department == null ? "0" : department.toString(),
      priority: priority,
      billable: billable,
      billableAmount: billableAmount,
      currencyID: currencyID,
      mandate: mandateController.text,
      success: (response) {
        btnLoader.value = false;
        TaskDetailsVM().viewLoader.value = ViewState.success;
        TaskDetailsVM().updateUI();
        CommonFunction.showSnackBar(context: context, isError: false, message: 'Task add successfully');
        Navigator.of(context).pop(true);
      },
      failed: (message) {
        btnLoader.value = false;
        TaskDetailsVM().viewLoader.value = ViewState.failed;
        TaskDetailsVM().updateUI();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

}