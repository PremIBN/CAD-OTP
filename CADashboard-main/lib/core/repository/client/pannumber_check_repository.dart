import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckPANRepo extends ApiClient{

  Future<int> checkPAN({required String panNumber,}) async {
    
    SharedPreferences preferences = await SharedPreferences.getInstance();
    
    var result = await getMethod(
      url: Uri.parse(Urls.PANCheck),
      queryParam: {
        'tokenID' : preferences.getString(PreferenceHelper.userToken) ?? "null",
        'pannumber' : panNumber,
        'orgID' : "-1",
        'groupid' : "0"
      }
    );


    try {
      return result;
    } catch (e) {
      return 1;
    }
    
  }

}