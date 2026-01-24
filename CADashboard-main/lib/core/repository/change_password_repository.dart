import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/model/change_password_model.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordRepo extends ApiClient{

  Future<void> changePassword({
    required String newPassword, required String oldPassword,
    required Function(int success, String message, ChangePasswordModel response) successResponse,
    required Function(int success, String message,) failedResponse,
}) async {

    SharedPreferences preferences = await SharedPreferences.getInstance();

    Map<String, String> queryParam = {
      'tokenID' : preferences.getString(PreferenceHelper.userToken) ?? "",
      'oldPassword' : oldPassword,
      'newPassword' : newPassword,
      'emailid' : preferences.getString(PreferenceHelper.userEmail) ?? "",
      'fullname' : preferences.getString(PreferenceHelper.fullName) ?? "",
      'username' : preferences.getString(PreferenceHelper.userName) ?? "",
    };

    var result = await getMethod(url: Uri.parse(Urls.ChangePassword),queryParam: queryParam);

    try{
      ChangePasswordModel changePasswordModel = ChangePasswordModel.fromJson(result);
      if(changePasswordModel.success == 1){
        successResponse(changePasswordModel.success!, 'Change Password Successfully', changePasswordModel);
      }else{
        failedResponse(changePasswordModel.success!, changePasswordModel.message ?? 'Change Password Failed');
      }
    }catch (e){
      failedResponse(0,errorMessage);
    }

  }

}