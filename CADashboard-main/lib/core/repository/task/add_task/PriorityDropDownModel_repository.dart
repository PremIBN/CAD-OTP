// ignore_for_file: file_names

import 'dart:developer';

import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/model/task/add_task/PriorityDropDown_model.dart';
import 'package:cadashboard/core/url/api_url.dart';

class PriorityDropDownRepo extends ApiClient{
  
  Future<void> getPriority({
    required Function(List<PriorityDropDownModel> response) success,
    required Function(int success, String message, int statusCode) failed,}) async {
    
    var result = await getMethod(
      url: Uri.parse(Urls.PriorityDropDown),
      queryParam: {
          'codeGroup' : "TaskPriority",
      }
    );
    try{
      List<PriorityDropDownModel> priorityDropDownModel = [];
      for (int i=0; i<result.length; i++){
        priorityDropDownModel.add(PriorityDropDownModel.fromJson(result[i]));
      }
      if(priorityDropDownModel[0].statusCode == 504){
        failed(0, priorityDropDownModel[0].message ?? errorMessage, priorityDropDownModel[0].statusCode ?? 001);
      } else {
        success(priorityDropDownModel);
      }
    } catch (e) {
      log("PriorityDropDownRepo Exception -----> $e");
      failed(0, "$errorMessage $e" , 000);
    }
  }
  
}