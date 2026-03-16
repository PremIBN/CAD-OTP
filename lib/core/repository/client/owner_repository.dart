import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/model/client/owner_model.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cadashboard/main.dart';

class OwnerRepo extends ApiClient{

  Future<void> ownerDetails({
    required String orgID,
    required Function(List<OwnerModel> response) success,
    required Function(String message) failed,
  }) async {

    SharedPreferences preferences = await SharedPreferences.getInstance();
    
    var result = await getMethod(
      url: Uri.parse(Urls.ownerDetails),
      queryParam: {
        'tokenID' : preferences.getString(PreferenceHelper.userToken),
        'clientorgID' : orgID,
      }
    );

    try {
      List<OwnerModel> list = [];
      for(int i=0; i<result.length; i++){
        list.add(OwnerModel.fromJson(result[i]));
      }
      success(list);
    } catch (e) {
      appPrint('Owner Detail Exception ----> $e');
      failed(errorMessage);
    }
  }

}