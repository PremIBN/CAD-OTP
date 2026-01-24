import 'package:cadashboard/core/common/common_function.dart';
import 'package:cadashboard/core/model/notification_model.dart';
import 'package:cadashboard/core/utils/base_model.dart';
import 'package:cadashboard/core/utils/view_state.dart';
import 'package:flutter/cupertino.dart';

class NotificationVM extends BaseModel{

  ValueNotifier<ViewState> viewLoader = ValueNotifier(ViewState.loading);

  List<NotificationModel> notification = [];

  int maxNotification = 0;

  Future<void> getNotification(BuildContext context) async {

    notificationRepo.getNotification(
      success: (response) {
        notification = response;
        maxNotification = response.length;
        viewLoader.value = ViewState.success;
      },
      failed: (message) {
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }

  Future<void> clearNotification(BuildContext context) async {

    notificationRepo.clearNotification(
      success: (response) {
        CommonFunction.showSnackBar(context: context, isError: false, message: response);
        viewLoader.value = ViewState.loading;
        getNotification(context);
      },
      failed: (message) {
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }

}