// ignore_for_file: file_names

import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/model/task/add_task/GetBranchList_model.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetBranchRepo extends ApiClient{

  Future<void> getBranch({
    required Function(List<GetBranchModel> response) success,
    required Function(String message) failed,}) async {

    SharedPreferences preferences = await SharedPreferences.getInstance();

    var result = await getMethod(
        url: Uri.parse(Urls.GetBranch),
        queryParam: {
          'tokenID' : preferences.getString(PreferenceHelper.userToken) ?? "null",
        }
    );
    try{
      List<GetBranchModel> getbranch = [];
      for (int i=0; i<result.length; i++){
        getbranch.add(GetBranchModel.fromJson(result[i]));
      }
      success(getbranch);
    } catch (e) {
      failed("$errorMessage : $e");
    }
  }


}