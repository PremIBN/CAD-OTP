import 'dart:developer';

import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/model/account/ar_priority_list_model.dart';
import 'package:cadashboard/core/model/account/receivable_data_model.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReceivableDataRepo extends ApiClient{

  Future<void> getReceivableData({
    String? client,String? firm,String? fy,String? group,String? branch,String? currency,String? priority,
    required Function(ReceivableDataModel response) success,
    required Function(String message) failed,
  }) async {

    SharedPreferences pre = await SharedPreferences.getInstance();
    String date = DateFormat('dd-MMM-yyyy').format(DateTime.now());
    
    Map<String, String> queryParam = {
      'tokenID' : pre.getString(PreferenceHelper.userToken) ?? "",
      'strSearch' : "Date,~${date}_FirmType,${firm ?? ""}_Client,${client ?? "-1"}_Service,undefined_OrgGroupID,${group ?? "0"}_Branch,${branch ?? "0"}_Currency,${currency ?? "0"}_Priority,${priority ?? "0"}",
      'financialyear' : fy ?? pre.getString(PreferenceHelper.financialYearID) ?? "",
      'isBulkUpdate' : "0",
    };

    log("Params :- $queryParam");

    var result = await getMethod(
      url: Uri.parse(Urls.ReceivableData),
      queryParam: queryParam,
    );
    try{
      ReceivableDataModel model = ReceivableDataModel.fromJson(result);
      success(model);
    } catch (e) {
      log("ReceivableData :---> $e");
      failed(errorMessage);
    }
  }

  Future<void> getCurrencyWiseTotalAmountDetails({
    String? client,String? fy,String? branch,String? currency,
    required Function(ReceivableDataModel response) success,
    required Function(String message) failed, }) async {

    SharedPreferences pre = await SharedPreferences.getInstance();

    Map<String, String> queryParam = {
      'tokenID' : pre.getString(PreferenceHelper.userToken) ?? "",
      'financialYearID' : fy ?? pre.getString(PreferenceHelper.financialYearID) ?? "",
      'clientID' : client ?? "-1",
      'currency' : currency ?? pre.getString(PreferenceHelper.currency) ?? "0",
      'branchID' : branch ?? "0"
    };

    var result = await getMethod(
      url: Uri.parse(Urls.GetCurrencyWiseTotalAmountDetails),
      queryParam: queryParam, 
    );

    try{
      ReceivableDataModel model = ReceivableDataModel.fromJson(result);
      success(model);
    } catch (e) {
      log("ReceivableDataRepo Exception : --> $e");
      failed(errorMessage);
    }

  }


  Future<void> getARPriorityList({
    required Function(List<ArPriorityListModel> response) success,
    required Function(String message) failed,
  }) async {
    var result = await getMethod(
      url: Uri.parse(Urls.ARPriorityList),
      queryParam: {"codeGroup":Urls.aRPriority}
    );
    try{
      List<ArPriorityListModel> list = (result as List).map((e) => ArPriorityListModel.fromJson(e)).toList();
      success(list);
    } catch (e) {
      log("ArPriorityList Exception :--> $e");
      failed(errorMessage);
    }
  }

}