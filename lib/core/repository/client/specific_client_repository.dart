import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/model/client/specific_client_model.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:cadashboard/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpecificClientRepo extends ApiClient{

  Future<void> specificClient({
    required String orgID,
    required Function(SpecificClientModel response) success,
    required Function(String message) failed,
  }) async {

    SharedPreferences preferences = await SharedPreferences.getInstance();

    var result = await getMethod(
      url: Uri.parse(Urls.SpecificClient),
      queryParam: {
        'tokenID' : preferences.getString(PreferenceHelper.userToken),
        'orgID' : orgID
      }
    );

    try {
      SpecificClientModel clientModel = SpecificClientModel.fromJson(result);
      success(clientModel);
    } catch (e) {
      appPrint('SpecificClient Exception : -----> $e');
      failed(errorMessage);
    }

  }

}