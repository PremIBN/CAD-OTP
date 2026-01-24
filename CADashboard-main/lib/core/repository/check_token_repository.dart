import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/model/check_token_model.dart';
import 'package:cadashboard/core/url/api_url.dart';

class CheckTokenRepo extends ApiClient{

  Future<void> checkToken({
    required String token,
    required Function (bool success, String message, CheckTokenModel response) successResponse,
    required Function (bool success, String message, int statusCode) failedResponse }) async {

    var result = await withOutTokenGetMethod(
        url: Uri.parse(Urls.ValidateToken),
        queryParam: {
          'tokenID' : token,
        }
    );

    try{
      CheckTokenModel tokenModel = CheckTokenModel.fromJson(result);
      if(tokenModel.success == 1){
        successResponse(true, tokenModel.message!, tokenModel);
      } else {
        failedResponse(false, tokenModel.message!,tokenModel.statusCode ?? 001);
      }
    } catch (e) {
      failedResponse(false, errorMessage,000);
    }
  }

}