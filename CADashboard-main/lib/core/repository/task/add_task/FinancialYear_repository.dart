// ignore_for_file: file_names

import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/model/task/add_task/FinancialYear_model.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cadashboard/main.dart';

class FinancialYearRepo extends ApiClient{

  Future<void> getFinancialYear({
    required Function(List<FinancialYearModel> response) success,
    required Function(String message) failed }) async {
    
    SharedPreferences preferences = await SharedPreferences.getInstance();
    
    var result = await getMethod(
      url: Uri.parse(Urls.FinancialYear),
      queryParam: {
        'tokenID' : preferences.getString(PreferenceHelper.userToken),
      }
    );

    try {
      List<FinancialYearModel> list = (result as List).map((e) => FinancialYearModel.fromJson(e)).toList();
      success(list);
    } catch (e) {
      appPrint('----->FinancialYear Exception : $e');
      failed(errorMessage);
    }

  }

}