// ignore_for_file: file_names

import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/model/task/add_task/GetAllCurrency_model.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cadashboard/main.dart';

class GetAllCurrencyRepo extends ApiClient {
  Future<void> getCurrency({
    required Function(List<GetAllCurrencyModel> response) successresponse,
    required Function(
      String message,
    ) failedResponse,
  }) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var result = await getMethod(
        url: Uri.parse(Urls.GetAllCurrency),
        queryParam: {
          'tokenID': preferences.getString(PreferenceHelper.userToken) ?? "",
          "type": ""
        });

    try {
      List<GetAllCurrencyModel> list = (result as List).map((e) => GetAllCurrencyModel.fromJson(e)).toList();
      successresponse(list);
    } catch (e) {
      appPrint('Get Currency Exception ---> $e');
      failedResponse(errorMessage);
    }
  }

  Future<void> getCurrencyList({
    required Function(List<GetAllCurrencyModel> response) successresponse,
    required Function(
      String message,
    ) failedResponse,
  }) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var result =
        await getMethod(url: Uri.parse(Urls.GetAllCurrencyList), queryParam: {
      'tokenID': preferences.getString(PreferenceHelper.userToken) ?? "",
      "type": "long"
    });

    try {
      List<GetAllCurrencyModel> list = (result as List)
          .map((e) => GetAllCurrencyModel.fromJson(e))
          .toSet()
          .toList();
      successresponse(list);
    } catch (e) {
      appPrint('Currency List Exception :------> $e');
      failedResponse(errorMessage);
    }
  }
}
