// ignore_for_file: file_names

import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/model/client/client_dropdown_model.dart';
import 'package:cadashboard/core/model/client/std_code_model.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/main.dart';

class ClientTypeRepo extends ApiClient{

  Future<void> getClientTypeList({
    required String queryParam,
    required Function(List<ClientDropDownModel> response) success,
    required Function(String message) failed }) async {

    var result = await getMethod(
      url: Uri.parse(Urls.ClientDropDown),
      queryParam: {'codeGroup' : queryParam}
    );

    try {
      List<ClientDropDownModel> list = [];
      for(int i=0;i<result.length;i++){
        list.add(ClientDropDownModel.fromJson(result[i]));
      }
      success(list);
    } catch (e) {
      // CheckTokenModel tokenModel = CheckTokenModel.fromJson(result);
      appPrint('ClientDropDown Exception :----> $e');
      failed(errorMessage);
    }
  }

  Future<void> getSTDCodeList({
    required Function(List<StdCodeModel> response) success,
    required Function(String message) failed }) async {

    var result = await getMethod(
      url: Uri.parse(Urls.STDCodeList)
    );

    try {
      List<StdCodeModel> list = [];
      for(int i=0;i<result.length;i++){
        list.add(StdCodeModel.fromJson(result[i]));
      }
      success(list);
    } catch (e) {
      // CheckTokenModel tokenModel = CheckTokenModel.fromJson(result);
      appPrint('StdCode Exception :----> $e');
      failed(errorMessage);
    }
  }

}