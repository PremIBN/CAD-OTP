import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/model/client/branchList_model.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:cadashboard/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BranchListRepo extends ApiClient{

  Future<void> getBranchType({
    required Function(List<BranchTypeModel> response) success,
    required Function(String message ) failed }) async {

    SharedPreferences preferences = await SharedPreferences.getInstance();

    var result = await getMethod(
        url: Uri.parse(Urls.BranchList),
        queryParam: {'tokenID' : preferences.getString(PreferenceHelper.userToken) ?? ""}
    );

    try{
      List<BranchTypeModel> list = [];
      for(int i=0; i<result.length; i++){
        list.add(BranchTypeModel.fromJson(result[i]));
      }
      success(list);
    } catch (e) {
      appPrint('BranchTypeModel ---> $e');
      failed(errorMessage);
    }

  }

}