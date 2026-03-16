// ignore_for_file: file_names

import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/model/task/add_task/GetAllDepartment_model.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DepartmentRepo extends ApiClient{

  Future<void> getBranch({
    required Function(List<GetAllDepartmentsModel> response) success,
    required Function(String message) failed,}) async {

    SharedPreferences preferences = await SharedPreferences.getInstance();

    var result = await getMethod(
        url: Uri.parse(Urls.GetDepartment),
        queryParam: {
          'tokenID' : preferences.getString(PreferenceHelper.userToken) ?? "null",
        }
    );
    try{
      List<GetAllDepartmentsModel> list = [];
      for (int i=0; i<result.length; i++){
        list.add(GetAllDepartmentsModel.fromJson(result[i]));
      }
      success(list);
    } catch (e) {
      failed("$errorMessage : $e");
    }
  }

}