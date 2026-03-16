import 'package:cadashboard/core/repository/account/receivable_data_repository.dart';
import 'package:cadashboard/core/repository/document/document_repository.dart';
import 'package:cadashboard/core/repository/add_logged_in_area_address_repository.dart';
import 'package:cadashboard/core/repository/change_password_repository.dart';
import 'package:cadashboard/core/repository/check_token_repository.dart';
import 'package:cadashboard/core/repository/client/ClientType_repository.dart';
import 'package:cadashboard/core/repository/client/add_client_repository.dart';
import 'package:cadashboard/core/repository/client/branch_list_repository.dart';
import 'package:cadashboard/core/repository/client/client_address_repository.dart';
import 'package:cadashboard/core/repository/client/client_info_repository.dart';
import 'package:cadashboard/core/repository/client/client_supply_type_repo.dart';
import 'package:cadashboard/core/repository/client/get_all_client_repository.dart';
import 'package:cadashboard/core/repository/client/group_type_dropdown_repository.dart';
import 'package:cadashboard/core/repository/client/owner_repository.dart';
import 'package:cadashboard/core/repository/client/pannumber_check_repository.dart';
import 'package:cadashboard/core/repository/client/save_pan_number_repository.dart';
import 'package:cadashboard/core/repository/client/specific_client_repository.dart';
import 'package:cadashboard/core/repository/forgot_password_repository.dart';
import 'package:cadashboard/core/repository/login_repository.dart';
import 'package:cadashboard/core/repository/logout_repository.dart';
import 'package:cadashboard/core/repository/notification_repository.dart';
import 'package:cadashboard/core/repository/task/GetTaskStatusCount_repository.dart';
import 'package:cadashboard/core/repository/task/add_task/FinancialYear_repository.dart';
import 'package:cadashboard/core/repository/task/add_task/GetAllCurrency_repository.dart';
import 'package:cadashboard/core/repository/task/add_task/GetAllDepartment_repository.dart';
import 'package:cadashboard/core/repository/task/add_task/GetBranch_repository.dart';
import 'package:cadashboard/core/repository/task/add_task/PriorityDropDownModel_repository.dart';
import 'package:cadashboard/core/repository/task/add_task/add_task_dropdown_repository.dart';
import 'package:cadashboard/core/repository/task/add_task/add_update_task_repository.dart';
import 'package:cadashboard/core/repository/task/get_task_repository.dart';
import 'package:cadashboard/core/repository/task/specific_task_repository.dart';
import 'package:cadashboard/core/repository/task/task_effort_repository.dart';
import 'package:cadashboard/core/repository/task/task_note_repository.dart';
import 'package:flutter/cupertino.dart';

class BaseModel with ChangeNotifier {

  String errorMessage = 'Something went wrong';

  /// Authentication
  LoginRepo loginRepository = LoginRepo();
  CheckTokenRepo tokenRepo = CheckTokenRepo();
  ChangePasswordRepo changePasswordRepo = ChangePasswordRepo();
  LogoutRepo logoutRepo = LogoutRepo();
  ForgotRepo forgotRepo = ForgotRepo();
  AddLoggedInAreaAddressRepository addLoggedInAreaAddressRepository = AddLoggedInAreaAddressRepository();


  /// Task
  GetTaskStatusCountRepo getTaskStatusCountRepo = GetTaskStatusCountRepo();
  AddTaskRepo addTaskRepo = AddTaskRepo();
  SpecificTaskRepo specificTaskRepo = SpecificTaskRepo();
  AddTaskDropDownRepo dropDownRepo = AddTaskDropDownRepo();
  GetTaskRepo taskRepo = GetTaskRepo();
  TaskNoteRepo noteRepo = TaskNoteRepo();
  TaskEffortRepo effortRepo = TaskEffortRepo();

  /// Client
  ClientTypeRepo clientTypeRepo = ClientTypeRepo();
  ClientSupplyTypeRepo clientSupplyTypeRepo = ClientSupplyTypeRepo();
  ClientInfoRepo clientInfoRepo = ClientInfoRepo();
  GetClientRepo clientRepo = GetClientRepo();
  AddClientRepo addClientRepo = AddClientRepo();
  SpecificClientRepo specificClientRepo = SpecificClientRepo();
  ClientAddressRepo addressRepo = ClientAddressRepo();
  OwnerRepo ownerRepo = OwnerRepo();

  /// Pan Number
  SavePanRepo savePanRepo = SavePanRepo();
  CheckPANRepo panRepo = CheckPANRepo();

  /// DropDown
  GetAllCurrencyRepo currencyRepo = GetAllCurrencyRepo();
  PriorityDropDownRepo priorityDropDownRepo = PriorityDropDownRepo();
  GetBranchRepo branchRepo = GetBranchRepo();
  DepartmentRepo departmentRepo = DepartmentRepo();
  GroupTypeRepo groupTypeRepo = GroupTypeRepo();
  BranchListRepo branchListRepo = BranchListRepo();
  FinancialYearRepo financialYearRepo = FinancialYearRepo();

  /// Report
  ReceivableDataRepo receivableDataRepo = ReceivableDataRepo();

  /// Document
  DocumentRepository documentRepo = DocumentRepository();

  /// Notification
  NotificationRepo notificationRepo = NotificationRepo();

  updateUI() {
    notifyListeners();
  }
}
