import 'dart:convert';
import 'dart:developer';

import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/model/task/task_note_model.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskNoteRepo extends ApiClient{

  Future<void> addTaskNote({
    required String taskID,required String taskNote,String? taskNoteID,
    required Function(TaskNoteModel response) success,
    required Function(String message) failed }) async {

    SharedPreferences preferences = await SharedPreferences.getInstance();

    Map<String, dynamic> body = {
      'TaskNotesID' : taskNoteID ?? "-1",
      'TaskID' : taskID,
      'FinancialYearID' : preferences.getString(PreferenceHelper.financialYearID),
      'Notes' : taskNote,
      'TokenID' : preferences.getString(PreferenceHelper.userToken)
    };

    var result = await postMethod(
      url: Uri.parse(Urls.addUpdateTaskNote),
      header: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: body,
    );

    try{
      var json = jsonDecode(result);
      TaskNoteModel model = TaskNoteModel.fromJson(json);
      success(model);
    } catch (e) {
      log('==> TaskNote Exception :- $e');
      failed(errorMessage);
    }

  }

}