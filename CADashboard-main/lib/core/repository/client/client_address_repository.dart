import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/model/client/client_address_model.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:cadashboard/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientAddressRepo extends ApiClient{

  Future<void> address({
    required String orgID, 
    required Function(List<ClientAddressModel> response) success,
    required Function(String message) failed,
  }) async {

    SharedPreferences preferences = await SharedPreferences.getInstance();
    
    var result = await getMethod(
      url: Uri.parse(Urls.Address),
      queryParam: {
        'tokenID' : preferences.getString(PreferenceHelper.userToken),
        'orgID' : orgID,
      }
    );

    try {
      List<ClientAddressModel> list = [];
      for(int i=0; i<result.length; i++){
        list.add(ClientAddressModel.fromJson(result[i]));
      }
      success(list);
    } catch (e) {
      appPrint('Client Address Exception :----> $e');
      failed(errorMessage);
    }
  }

}