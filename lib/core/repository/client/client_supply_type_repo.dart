import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/model/client/client_dropdown_model.dart';
import 'package:cadashboard/main.dart';

class ClientSupplyTypeRepo extends ApiClient {

  Future<void> getClientSupplyTypeList({
    required String queryParam,
    required Function(List<ClientDropDownModel> response) success,
    required Function(String message) failed }) async {

    var result = await getMethod(
      url: Uri.parse(Urls.clientSupplyTypeDropDown),
      queryParam: {'codeGroup' : queryParam}
    );

    try {
      List<ClientDropDownModel> list = [];
      for(int i=0;i<result.length;i++){
        list.add(ClientDropDownModel.fromJson(result[i]));
      }
      success(list);
    } catch (e) {
      appPrint('getClientSupplyTypeList Exception :----> $e');
      failed(errorMessage);
    }
  }
}