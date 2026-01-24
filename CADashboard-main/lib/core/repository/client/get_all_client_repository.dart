import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/model/client/get_all_client_model.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:cadashboard/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetClientRepo extends ApiClient{

  Future<void> getClient({
    String? searchText,required String startPage, required String endPage,
    required Function(GetAllClientModel response) success,
    required Function(String message) failed }) async {

    SharedPreferences preferences = await SharedPreferences.getInstance();

    var  result = await getMethod(
      url: Uri.parse(Urls.GetAllClient),
      queryParam: {
        'tokenID' : preferences.getString(PreferenceHelper.userToken) ?? "",
        'startLimit' : startPage,
        'endLimit' : endPage,
        'sort' : "DESC",   //"ASC",
        'strSearch' : 'FirmType,0_Country,0_State,0_City,0_SearchText,$searchText,_orgGroupID,0_BranchID,0_ClientTypeID,0',
        'isBulkUpdate' : "0",
        'sortdata' : "1",
      }
    );

    try {
      GetAllClientModel clientModel = GetAllClientModel.fromJson(result);
      success(clientModel);
    } catch (e) {
      appPrint('GetAllClient ------>   $e');
      failed(errorMessage);
    }

  }

}