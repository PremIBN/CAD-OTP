import 'package:cadashboard/main.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';

class LogoutRepo extends ApiClient {

  Future<void> logoutUser({required String perform, required Function(String message) response, required String latitude, required String longitude,}) async{

    SharedPreferences preferences = await SharedPreferences.getInstance();

    var result = await getMethod(
      url: Uri.parse(Urls.LogoutUser),
      queryParam: {
        'tokenID' : preferences.getString(PreferenceHelper.userToken)!,
        'latlng': "$latitude,$longitude",
      },
      skipLocationCheck: true,
    );

    try {
      appPrint(result);
      if (result == 'Record inserted successfully.') {
        response('$perform Successfully');
      } else {
        response("Something is wrong");
      }
    } catch (e) {
      response('$errorMessage :: $e');
    }
  }

}