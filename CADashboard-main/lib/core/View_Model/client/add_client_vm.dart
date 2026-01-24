import 'package:cadashboard/core/common/common_function.dart';
import 'package:cadashboard/core/model/client/client_dropdown_model.dart';
import 'package:cadashboard/core/model/client/branchList_model.dart';
import 'package:cadashboard/core/model/client/group_type_dropdown_model.dart';
import 'package:cadashboard/core/model/client/specific_client_model.dart';
import 'package:cadashboard/core/model/client/std_code_model.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/base_model.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:cadashboard/core/utils/view_state.dart';
import 'package:cadashboard/main.dart';
import 'package:cadashboard/ui/screen/login_screen.dart';
import 'package:cadashboard/ui/widget/custom_navigate.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddClientVM extends BaseModel {

  ValueNotifier<ViewState> viewLoader = ValueNotifier(ViewState.loading);
  ValueNotifier<bool> loading = ValueNotifier(false);

  DateTime? startDate;

  TextEditingController companyNameController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController fileNumberController = TextEditingController();
  TextEditingController referredController = TextEditingController();
  TextEditingController panNumberController = TextEditingController();
  TextEditingController startDateController = TextEditingController();

  List<ClientDropDownModel> clientType = [];
  List<ClientDropDownModel> clientSupplyType = [];
  List<StdCodeModel> stdCodeType = [];
  List<ClientDropDownModel> firmType = [];
  List<ClientDropDownModel> industryType = [];
  List<GroupTypeModel> groupType = [];
  List<BranchTypeModel> branchList = [];

  int? client;
  int? clientSupplyTypeValue;
  int? stdCode;
  int? firm;
  int? industry;
  int? group;
  int? branch;


  Future<void> token(BuildContext context, String? orgID) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    tokenRepo.checkToken(
      token: preferences.getString(PreferenceHelper.userToken) ?? "",
      successResponse: (success, message, response) {
        if(orgID != null) {
          clientDetail(context, orgID);
        } else {
          getClientType(context);
        }
      },
      failedResponse: (success, message, statusCode) {
        appPrint('Token : $message');
        CommonFunction.showSnackBar(context: context, isError: true, message: 'Your Session has been Expired');
        Navigator.pushAndRemoveUntil(context, cusNavigate(const LoginScreen()), (route) => false);
        viewLoader.value = ViewState.failed;
      },
    );
  }


  Future<void> getClientType(BuildContext context) async {
    clientTypeRepo.getClientTypeList(
      queryParam: Urls.clientType,
        success: (response) {
          clientType.addAll(response);
          getSTDCode(context);
        },
        failed: (message) {
          appPrint('---------->Client Type $message');
          CommonFunction.showSnackBar(context: context, isError: true, message: message);
          viewLoader.value = ViewState.failed;
        },
    );
  }

  Future<void> getSTDCode(BuildContext context) async {
    clientTypeRepo.getSTDCodeList(
      success: (response) {
        stdCodeType.addAll(response);
        getFirmType(context);
      },
      failed: (message) {
        appPrint('---------->STD Code Type $message');
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }

  Future<void> getFirmType(BuildContext context) async {
    clientTypeRepo.getClientTypeList(
      queryParam: Urls.firmType,
      success: (response) {
        firmType.addAll(response);
        getIndustryType(context);
      },
      failed: (message) {
        appPrint('---------->Firm Type $message');
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }

  Future<void> getIndustryType(BuildContext context) async {
    clientTypeRepo.getClientTypeList(
      queryParam: Urls.industryType,
      success: (response) {
        industryType.addAll(response);
        getGroupType(context);
      },
      failed: (message) {
        appPrint('---------->Industry Type $message');
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }

  Future<void> getGroupType(BuildContext context) async {
    groupTypeRepo.getGroupType(
      success: (response) {
        var seen = <String>{};
        groupType = response.where((student) => seen.add(student.groupName!)).toList();
        getBranchType(context);
      },
      failed: (message) {
        appPrint('---------->Group Type $message');
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }

  Future<void> getBranchType(BuildContext context) async {
    branchListRepo.getBranchType(
      success: (response) {
        branchList.addAll(response);
        getClientSupplyType(context);
      },
      failed: (message) {
        appPrint('---------->Group Type $message');
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }

  Future<void> getClientSupplyType(BuildContext context) async {
    clientSupplyTypeRepo.getClientSupplyTypeList(
      queryParam: "ClientTypeofSupply",
      success: (response) {
        clientSupplyType.addAll(response);
        viewLoader.value = ViewState.success;
      },
      failed: (message) {
        appPrint('---------->Client Type $message');
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }

  Future<void> checkPAN(BuildContext context, String panNumber, int? stdCode, int? firm, int? industry, int? group, int? clientType, int? branch, int? clientSupplyType, DateTime? clientJoiningDate,) async {
    panRepo.checkPAN(panNumber: panNumber,).then((value) {
      if(value == 0){
        addClient(
          context,
          firm: firm,
          industry: industry,
          group: group,
          clientType: clientType,
          branch: branch,
          panNumber: panNumber,
          stdCode: stdCode,
          clientJoiningDate: clientJoiningDate,
          clientSupplyType: clientSupplyType,
        );
      } else {
        CommonFunction.showSnackBar(context: context, isError: true, message: 'PAN number already exists');
        loading.value = false;
      }
    });
  }

  Future<void> addClient(BuildContext context, {
    int? firm,
    int? industry,
    int? group,
    int? clientType,
    int? stdCode,
    int? branch,
    required String panNumber,
    int? clientSupplyType,
    DateTime? clientJoiningDate,
    String? orgID,
  }) async{

    addClientRepo.addClient(
      orgID: orgID,
        orgName: companyNameController.text,
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        email: emailController.text.isEmpty ? "" : emailController.text,
        mobile: phoneNumberController.text.isEmpty ? "" : phoneNumberController.text,
        firmTypeID: firm == null ? "" : firm.toString(),
        industryTypeID: industry == null ? "" : industry.toString(),
        referredBy: referredController.text.trim(),
        groupId: group == null ? "" : group.toString(),
        fileNumber: fileNumberController.text,
        branch: branch == null ? "" : branch.toString(),
        clientType: clientType == null ? "" : clientType.toString(),
        stdCode: stdCode ?? 0,
        clientJoiningDate: clientJoiningDate,
        clientSupplyType: clientSupplyType ?? 0,
        success: (success, message) {
          savePanNumber(context, message, panNumber,orgID);
        },
        failed: (success, message) {
          CommonFunction.showSnackBar(context: context, isError: true, message: message);
          loading.value = false;
        },
    );
  }

  Future<void> savePanNumber(BuildContext context,String orgID, String panNumber, String? orgsID) async {
    savePanRepo.savePanNumber(
      orgID: orgID,
      panNumber: panNumber.trim(),
      success: (message) {
        if(orgsID == null){
          CommonFunction.showSnackBar(context: context, isError: false, message: message);
        } else {
          CommonFunction.showSnackBar(context: context, isError: false, message: 'Client Update Successfully');
        }
        Navigator.pop(context);
        loading.value = false;
      },
      failed: (message) {
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        loading.value = false;
      },
    );
  }


  late SpecificClientModel editClient;


  Future<void> clientDetail(BuildContext context, String orgID) async{
    specificClientRepo.specificClient(
      orgID: orgID,
      success: (response) {
        editClient = response;
        // clientinfo(context, orgID);
        phoneNumberController.text = response.primaryMobile ?? "";
        firstNameController.text = response.firstName ?? "";
        lastNameController.text = response.lastName ?? "";
        companyNameController.text = response.orgName ?? "";
        emailController.text = response.email ?? "";
        panNumberController.text = response.panNumber ?? "";
        referredController.text = response.referredBy ?? "";
        fileNumberController.text = response.fileNumber ?? "";
        if (response.clientJoiningDate != null) startDateController.text = DateFormat('dd-MMM-yyyy').format(DateTime.parse(response.clientJoiningDate.toString()));

        client = response.clientTypeId;
        firm = response.firmTypeId;
        industry = response.industryTypeId;
        group = response.orgGroupId;
        branch = response.branch;
        clientSupplyTypeValue = response.clientSupplyType == 0 ? null : response.clientSupplyType;
        if (response.clientJoiningDate != null) startDate = response.clientJoiningDate;
        stdCode = int.parse(response.stdCode ?? "91");

        notifyListeners();
        getClientType(context);
      },
      failed: (message) {
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }

}