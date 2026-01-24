import 'dart:developer';

import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/model/check_token_model.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:cadashboard/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddClientRepo extends ApiClient{

  Future addClient({
    required String orgName,required String firstName,required String lastName,required int stdCode,String? email,String? mobile,
    String? firmTypeID,String? industryTypeID,String? referredBy,String? groupId,String? fileNumber,
    String? branch,String? clientType, String? orgID, int? clientSupplyType, DateTime? clientJoiningDate,
    required Function(int success, String message) success,
    required Function(int success, String message) failed,
  }) async {

    SharedPreferences preferences = await SharedPreferences.getInstance();

    Map<String, dynamic> queryParam = {
      'tokenID' : preferences.getString(PreferenceHelper.userToken) ?? "",
      'orgID' : orgID ?? "-1",
      'orgName' : orgName,
      'orgTypeID' : "0",
      'orgLogoMetadata' : null,
      'isSetupComplete' : "0",
      'currencyID' : "1",
      'timeZoneID' : "0",
      'languageID' : "0",
      'firstName' : firstName,
      'lastName' : lastName,
      'email' : email ?? "",
      'userRoleID' : "1",
      'alternateEmail' : null,
      'genderID' : null,
      'dateOfBirth' : null,
      'mobile' : mobile ?? "",
      'notes' : null,
      'userName' : null,
      'password' : null,
      'optInEmail' : "0",
      'optInMobile' : '0',
      'relationTypeID' : '0',
      'firmTypeID' : firmTypeID.toString(),
      'industryTypeID' : industryTypeID ?? "",
      'ReferredBy' : referredBy ?? "",
      'groupid' : groupId ?? "",
      'groupname' : null,
      'fileNumber' : fileNumber ?? "",
      'allowLogin' : false.toString(),
      'effortmailtoclient' : "0",
      'branch' : branch ?? "",
      'clientType' : clientType ?? "",
      "clientSupplyType": clientSupplyType.toString(),
      "clientJoiningDate": clientJoiningDate.toString(),
      'stdcode' : stdCode.toString(),
    };

    var result = await getMethod(
      url: Uri.parse(Urls.AddUpdateClient),
      queryParam: queryParam
    );

    try {
      log(name: "API GET", "Url : ${Urls.AddUpdateClient} \n Client -----> $result \n\n QueryParam : $queryParam \n ===================================================================================");

      if(result.runtimeType == String){
        success(0,result);
      } else {
        CheckTokenModel tokenModel = CheckTokenModel.fromJson(result);
        success(tokenModel.success ?? 0, tokenModel.message ?? errorMessage);
      }
    } catch (e) {
      appPrint('Client Exception ----- > $e');
      failed(0,errorMessage);
    }
  }

}