import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/model/check_token_model.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/main.dart';

class ForgotRepo extends ApiClient{

  Future<void> forgot({
    required String email, required String username,
    required Function(String message, int code) success,
    required Function(String message) failed,
  }) async {

    var result = await withOutTokenGetMethod(
      url: Uri.parse(Urls.forgotPassword),
      queryParam: {
        'email' : email,
        'username' : username,
      }
    );

    try{
      CheckTokenModel model = CheckTokenModel.fromJson(result);
      success('Reset Password link sent to your Email',model.statusCode ?? 000);
    } catch (e) {
      CheckTokenModel model = CheckTokenModel.fromJson(result);
      appPrint('Forgot Password :----> $e');
      failed(model.message ?? errorMessage);
    }

  }

}