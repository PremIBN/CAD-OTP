import 'dart:developer';

import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/model/task/specific_task_model.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpecificTaskRepo extends ApiClient{

  Future<void> specificTask({
    required String taskID,
    required Function(SpecificTaskModel response) success,
    required Function(String message) failed }) async {

    SharedPreferences preferences = await SharedPreferences.getInstance();

    var result = await getMethod(
      url: Uri.parse(Urls.getAllTaskDetailsByID),
      queryParam: {
        'tokenID' : preferences.getString(PreferenceHelper.userToken),
        'taskID' : taskID,
      }
    );
    try {
      SpecificTaskModel model = SpecificTaskModel.fromJson(result);
      success(model);
    } catch (e) {
      log('SpecificTask Exception :-----> $e');
      failed(errorMessage);
    }
  }
}