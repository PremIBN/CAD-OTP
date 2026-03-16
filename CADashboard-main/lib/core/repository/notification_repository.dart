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
      },
      skipLocationCheck: true,
    );

    try {
      appPrint("NotificationRepo result :--> $result");

      if (result is List) {
        final list = <NotificationModel>[];
        for (final e in result) {
          try {
            if (e is Map<String, dynamic>) {
              list.add(NotificationModel.fromJson(e));
            } else if (e is Map) {
              list.add(NotificationModel.fromJson(Map<String, dynamic>.from(e)));
            }
          } catch (_) { /* skip malformed item */ }
        }
        success(list);
        return;
      }
      if (result is Map) {
        final msg = result['Message'] ?? result['message'] ?? errorMessage;
        failed(msg is String ? msg : errorMessage);
        return;
      }
      failed(errorMessage);
    } catch (e) {
      appPrint("NotificationRepo Exception :--> $e");
      failed(errorMessage);
    }
  }
  
  
  Future<void> clearNotification({
    required Function(String message) success,
    required Function(String message) failed }) async {
    
    SharedPreferences preferences = await SharedPreferences.getInstance();
    
    var result = await getMethod(
      url: Uri.parse(Urls.clearNotification),
      queryParam: {
        'tokenID' : preferences.getString(PreferenceHelper.userToken),
      },
      skipLocationCheck: true,
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