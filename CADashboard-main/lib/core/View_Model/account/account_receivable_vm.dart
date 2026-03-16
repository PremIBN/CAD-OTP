import 'package:cadashboard/core/common/common_function.dart';
import 'package:cadashboard/core/model/account/ar_priority_list_model.dart';
import 'package:cadashboard/core/model/account/receivable_data_model.dart';
import 'package:cadashboard/core/model/client/client_dropdown_model.dart';
import 'package:cadashboard/core/model/client/group_type_dropdown_model.dart';
import 'package:cadashboard/core/model/task/add_task/FinancialYear_model.dart';
import 'package:cadashboard/core/model/task/add_task/GetAllCurrency_model.dart';
import 'package:cadashboard/core/model/task/add_task/GetBranchList_model.dart';
import 'package:cadashboard/core/model/task/add_task/GetTaskRelatedDropDowns_model.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/base_model.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:cadashboard/core/utils/view_state.dart';
import 'package:cadashboard/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountReceivableVM extends BaseModel{

  ValueNotifier<ViewState> viewLoader = ValueNotifier(ViewState.loading);
  ValueNotifier<String> currency = ValueNotifier("Currency");

  List<List<String>> receivableData = [];
  late ReceivableDataModel totalData;

  List<ClientListElement> clientList = [];
  List<FinancialYearModel> fyList = [];
  List<ArPriorityListModel> priorityList = [];
  List<GetBranchModel> branchList = [];
  List<GetAllCurrencyModel> currencyList = [];
  List<ClientDropDownModel> firmType = [];
  List<GroupTypeModel> groupType = [];

  // ignore: non_constant_identifier_names
  String? Client;
  // ignore: non_constant_identifier_names
  String? FY;
  // ignore: non_constant_identifier_names
  String? Branch;
  // ignore: non_constant_identifier_names
  String? Currency;
  // ignore: non_constant_identifier_names
  String? Priority;
  // ignore: non_constant_identifier_names
  String? Firm;
  // ignore: non_constant_identifier_names
  String? Group;
  // ignore: non_constant_identifier_names
  String? Duration;


  int invoiceNo = 2;
  int communicationHistory = 10;
  int clientName = 1;
  int dueDays = 7;
  int flag = 28;
  int invoiceAmount = 4;
  int receivedAmount = 5;
  int balanceAmount = 6;
  int nextFollowupDate = 8;
  int expectedPaymentDate = 9;
  int invoiceCreatedFrom = 27;


  Future<void> getCurrency(BuildContext context) async{
    Client = null;
    FY = null;
    Branch = null;
    Currency = null;
    Priority = null;
    Firm = null;
    Group = null;
    Duration = null;
    receivableData.clear();
    SharedPreferences pre = await SharedPreferences.getInstance();
    currencyRepo.getCurrency(
      successresponse: (response) {
        for (var element in response) {
          if(int.parse(pre.getString(PreferenceHelper.currency)!) == element.codeId){
            currency.value = element.codeName ?? "";
          }
        }
        totalAmountDetails(context);
        viewLoader.value = ViewState.loading;
      },
      failedResponse: (message) {
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }

  Future<void> totalAmountDetails(BuildContext context) async {

    receivableDataRepo.getCurrencyWiseTotalAmountDetails(
      branch: Branch,
      client: Client,
      fy: FY,
      currency: Currency,
      success: (response) {
        totalData = response;
        getReceivableData(context);
      },
      failed: (message) {
        errorMessage = message;
        viewLoader.value = ViewState.failed;
      },
    );
  }

  Future<void> getReceivableData(BuildContext context) async {
    receivableDataRepo.getReceivableData(
      client: Client,
      fy: FY,
      firm: Firm,
      branch: Branch,
      currency: Currency,
      group: Group,
      priority: Priority,
      success: (response) {
        receivableData = response.data;
        // dropDown(context);
        viewLoader.value = ViewState.success;
      },
      failed: (message) {
        errorMessage = message;
        viewLoader.value = ViewState.failed;
      },
    );
  }


  Future<void> dropDown(BuildContext context) async{
    dropDownRepo.dropdown(
      successResponse: (response) {
        if(clientList.isEmpty){
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
          clientList.addAll(response.clientList.reversed);
        }
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  child: Container(
                    height: clientList.length * 50,
                    padding: const EdgeInsets.all(15),
                    child: ListView.builder(
                      itemCount: clientList.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Client = clientList[index].displayValue.toString();
                            notifyListeners();
                            searchData(context, Client);
                            Navigator.pop(context);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(clientList[index].displayName ?? "null",style: const TextStyle(fontSize: 18)),
                              ),
                              const Divider(height: 10,)
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        );
        },
      failedResponse: (message,code) {
        appPrint("-----> $message");
        errorMessage = message;
        Navigator.pop(context);
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }

  Future<void> getFinancialYear(BuildContext context) async  {
    financialYearRepo.getFinancialYear(
      success: (response) {

        if(fyList.isEmpty){
         fyList.addAll(response);
        }
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  child: Container(
                    height: fyList.length * 50,
                    padding: const EdgeInsets.all(15),
                    child: ListView.builder(
                      itemCount: fyList.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            FY = fyList[index].displayValue.toString();
                            notifyListeners();
                            searchData(context, FY);
                            Navigator.pop(context);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(fyList[index].displayName ?? "null",style: const TextStyle(fontSize: 18)),
                              ),
                              const Divider(height: 10,)
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        );
      },
      failed: (message) {
        appPrint(message);
        errorMessage = message;
        Navigator.pop(context);
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }

  Future<void> getPriority(BuildContext context) async {
    receivableDataRepo.getARPriorityList(
      success: (response) {
        if(priorityList.isEmpty){
          priorityList.addAll(response);
        }
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  child: Container(
                    height: priorityList.length * 50,
                    padding: const EdgeInsets.all(15),
                    child: ListView.builder(
                      itemCount: priorityList.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Priority = priorityList[index].displayValue.toString();
                            notifyListeners();
                            searchData(context, Client);
                            Navigator.pop(context);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(priorityList[index].displayName ?? "null",style: const TextStyle(fontSize: 18)),
                              ),
                              const Divider(height: 10,)
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        );
      },
      failed: (message) {
        errorMessage = message;
        Navigator.pop(context);
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }

  Future<void> getBranch(BuildContext context) async {
    branchRepo.getBranch(
      success: (response) {
        if(branchList.isEmpty){
          branchList.addAll(response);
        }
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  child: Container(
                    height: branchList.length * 50,
                    padding: const EdgeInsets.all(15),
                    child: ListView.builder(
                      itemCount: branchList.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Branch = branchList[index].branchId.toString();
                            notifyListeners();
                            searchData(context, Branch);
                            Navigator.pop(context);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(branchList[index].branchName ?? "null",style: const TextStyle(fontSize: 18)),
                              ),
                              const Divider(height: 10,)
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        );
      },
      failed: (message) {
        appPrint(message);
        errorMessage = message;
        Navigator.pop(context);
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }

  Future<void> getcurrency(BuildContext context) async{
    currencyRepo.getCurrencyList(
      successresponse: (response) {
        if(currencyList.isEmpty){
          currencyList.addAll(response);
        }

        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  child: Container(
                    height: currencyList.length * 60,
                    padding: const EdgeInsets.all(15),
                    child: ListView.builder(
                      itemCount: currencyList.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Currency = currencyList[index].codeId.toString();
                            currency.value = currencyList[index].codeName!;
                            notifyListeners();
                            searchData(context, Currency);
                            Navigator.pop(context);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(currencyList[index].codeName ?? "null",style: const TextStyle(fontSize: 18)),
                              ),
                              const Divider(height: 10,)
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        );
      },
      failedResponse: (message) {
        appPrint(message);
        errorMessage = message;
        Navigator.pop(context);
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }

  Future<void> getFirmType(BuildContext context) async {
    clientTypeRepo.getClientTypeList(
      queryParam: Urls.firmType,
      success: (response) {
        if(firmType.isEmpty){
          firmType.addAll(response);
        }
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  child: Container(
                    height: firmType.length * 50,
                    padding: const EdgeInsets.all(15),
                    child: ListView.builder(
                      itemCount: firmType.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Firm = firmType[index].displayValue.toString();
                            notifyListeners();
                            searchData(context, Firm);
                            Navigator.pop(context);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(firmType[index].displayName ?? "null",style: const TextStyle(fontSize: 18)),
                              ),
                              const Divider(height: 10,)
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        );
      },
      failed: (message) {
        appPrint('---------->Firm Type $message');
        errorMessage = message;
        Navigator.pop(context);
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }

  Future<void> getGroupType(BuildContext context) async {
    groupTypeRepo.getGroupType(
      success: (response) {
        var seen = <String>{};
        if(groupType.isEmpty){
          groupType = response.where((student) => seen.add(student.groupName!)).toList();
        }
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  child: Container(
                    height: groupType.length * 50,
                    padding: const EdgeInsets.all(15),
                    child: ListView.builder(
                      itemCount: groupType.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Group = groupType[index].orgGroupId.toString();
                            notifyListeners();
                            searchData(context, Client);
                            Navigator.pop(context);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(groupType[index].groupName ?? "null",style: const TextStyle(fontSize: 18)),
                              ),
                              const Divider(height: 10,)
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        );
      },
      failed: (message) {
        appPrint('---------->Group Type $message');
        errorMessage = message;
        Navigator.pop(context);
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }

  Future searchData(BuildContext context, String? client) async{
    appPrint('Client ----> $client');
    viewLoader.value = ViewState.loading;
    receivableData.clear();
    notifyListeners();
    totalAmountDetails(context);
  }


  @override
  void dispose() {
    viewLoader.dispose();
    currency.dispose();
    super.dispose();
  }


}