import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/model/client/client_infomation_model.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cadashboard/main.dart';

class ClientInfoRepo extends ApiClient{

  Future<void> clientInfo({
    required String orgID,
    required Function(List<ClientInfoModel> response) success,
    required Function(String message) failed,
  }) async {

    SharedPreferences preferences = await SharedPreferences.getInstance();

    var result = await getMethod(
      url: Uri.parse(Urls.clientInformation),
      queryParam: {
        'tokenID' : preferences.getString(PreferenceHelper.userToken),
        'orgID' : orgID,
        'attributeTypeID' : "1",
      }
    );


    try {
      List<ClientInfoModel> list = [];
      for(int i=0; i<result.length; i++){
        list.add(ClientInfoModel.fromJson(result[i]));
      }
      success(list);
    } catch (e) {
      appPrint('Client Information Exception :---> $e');
      failed(errorMessage);
    }
  }

}