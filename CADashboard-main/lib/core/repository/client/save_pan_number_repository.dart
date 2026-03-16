import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cadashboard/main.dart';

class SavePanRepo extends ApiClient{

  Future<void> savePanNumber({
    required String orgID, required String panNumber,
    required Function(String message) success,
    required Function(String message) failed,
  }) async {

    SharedPreferences preferences = await SharedPreferences.getInstance();

     var result = await getMethod(
       url: Uri.parse(Urls.SavePanNumber),
       queryParam: {
         'tokenID' : preferences.getString(PreferenceHelper.userToken),
         'orgAttributeID' : "-1",
         'attributeID' : "1",
         'clientOrgID' : orgID,
         'orgAttributeValue' : panNumber,
         'documentID' : "",
       }
     );

     try {
       appPrint('Save Pan ---------> $result');
       success('Client Add Successfully');
     } catch (e) {
       appPrint('Save Pan ----------> $result');
       failed(errorMessage);
     }

  }

}