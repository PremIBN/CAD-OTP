import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/model/client/group_type_dropdown_model.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cadashboard/main.dart';

class GroupTypeRepo extends ApiClient{

  Future<void> getGroupType({
    required Function(List<GroupTypeModel> response) success,
    required Function(String message ) failed }) async {

    SharedPreferences preferences = await SharedPreferences.getInstance();

    var result = await getMethod(
      url: Uri.parse(Urls.GroupTypeDropDown),
      queryParam: {'tokenID' : preferences.getString(PreferenceHelper.userToken) ?? ""}
    );

    try{
      List<GroupTypeModel> list = [];
      for(int i=0; i<result.length; i++){
        list.add(GroupTypeModel.fromJson(result[i]));
      }
      success(list);
    } catch (e) {
      appPrint('GroupDorpDown ---> $e');
      failed(errorMessage);
    }

}

}