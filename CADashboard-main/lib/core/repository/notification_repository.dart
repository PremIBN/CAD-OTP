import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/model/notification_model.dart';
import 'package:cadashboard/core/url/api_url.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cadashboard/main.dart';

class NotificationRepo extends ApiClient{

  Future<void> getNotification({
    required Function(List<NotificationModel> response) success,
    required Function(String message) failed }) async {
    
    SharedPreferences preferences = await SharedPreferences.getInstance();
    
    var result = await getMethod(
      url: Uri.parse(Urls.notification),
      queryParam: {
        'tokenID' : preferences.getString(PreferenceHelper.userToken),
      }
    );

    // try {

      appPrint("NotificationRepo result :--> $result");

      List<NotificationModel> list = (result as List).map((e) => NotificationModel.fromJson(e)).toList();

      success(list);

    // } catch (e) {
    //   appPrint("NotificationRepo Exception :--> $e");
    //   failed(errorMessage);
    // }

  }
  
  
  Future<void> clearNotification({
    required Function(String message) success,
    required Function(String message) failed }) async {
    
    SharedPreferences preferences = await SharedPreferences.getInstance();
    
    var result = await getMethod(
      url: Uri.parse(Urls.clearNotification),
      queryParam: {
        'tokenID' : preferences.getString(PreferenceHelper.userToken),
      }
    );

    try{
      if("Record inserted successfully." == result){
        success("All Notification Cleared Successfully");
      } else {
        failed("Something wrong");
      }
    } catch (e) {
      appPrint('---> Clear Notification :- $e');
      failed(errorMessage);
    }
    
  }

}