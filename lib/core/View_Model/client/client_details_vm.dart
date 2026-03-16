import 'package:cadashboard/core/common/common_function.dart';
import 'package:cadashboard/core/model/client/client_address_model.dart';
import 'package:cadashboard/core/model/client/client_infomation_model.dart';
import 'package:cadashboard/core/model/client/owner_model.dart';
import 'package:cadashboard/core/model/client/specific_client_model.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/base_model.dart';
import 'package:cadashboard/core/utils/view_state.dart';
import 'package:cadashboard/main.dart';
import 'package:flutter/material.dart';

class ClientDetailsVM extends BaseModel{

  ValueNotifier<ViewState> viewLoader = ValueNotifier(ViewState.loading);

  late SpecificClientModel client;
  List<ClientInfoModel> clientInfo = [];
  List<ClientAddressModel> address = [];
  List<OwnerModel> owner = [];

  String? clientType;
  String? groupType;
  String? branch;

  Future<void> clientDetails(BuildContext context, String orgID) async{
    specificClientRepo.specificClient(
        orgID: orgID,
        success: (response) {
          client = response;
          clientInformation(context, orgID);
        },
        failed: (message) {
          CommonFunction.showSnackBar(context: context, isError: true, message: message);
          viewLoader.value = ViewState.failed;
        },
    );
  }

  Future<void> clientInformation(BuildContext context, String orgID) async{
    clientInfoRepo.clientInfo(
      orgID: orgID,
      success: (response) {
        clientInfo = response;
        clientAddress(context, orgID);
      },
      failed: (message) {
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }

  Future<void> clientAddress(BuildContext context, String orgID) async{
    addressRepo.address(
        orgID: orgID,
        success: (response) {
          address = response;
          ownerDetails(context, orgID);
        },
        failed: (message) {
          CommonFunction.showSnackBar(context: context, isError: true, message: message);
          viewLoader.value = ViewState.failed;
        },
    );
  }

  Future<void> ownerDetails(BuildContext context, String orgID) async{
    ownerRepo.ownerDetails(
      orgID: orgID,
      success: (response) {
        owner = response;
        getClientType(context);
      },
      failed: (message) {
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }

  Future<void> getClientType(BuildContext context) async {
    clientTypeRepo.getClientTypeList(
      queryParam: Urls.clientType,
      success: (response) {

        for (var element in response) {
          if(client.clientTypeId == element.displayValue){
            clientType = element.displayName;
            notifyListeners();
          }
        }

        getGroupType(context);
      },
      failed: (message) {
        appPrint('---------->Client Type $message');
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }

  Future<void> getGroupType(BuildContext context) async {
    groupTypeRepo.getGroupType(
      success: (response) {
        for (var element in response) {
          if(client.orgGroupId == element.orgGroupId){
            groupType = element.groupName;
            notifyListeners();
          }
        }
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
        for (var element in response) {
          if(client.branch == element.branchId){
            branch = element.branchName;
            notifyListeners();
          }
        }
        viewLoader.value = ViewState.success;
      },
      failed: (message) {
        appPrint('---------->Group Type $message');
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }


}