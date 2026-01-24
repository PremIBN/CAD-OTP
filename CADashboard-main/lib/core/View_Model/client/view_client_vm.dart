import 'package:cadashboard/core/common/common_function.dart';
import 'package:cadashboard/core/model/client/get_all_client_model.dart';
import 'package:cadashboard/core/utils/base_model.dart';
import 'package:cadashboard/core/utils/preference_helper.dart';
import 'package:cadashboard/core/utils/view_state.dart';
import 'package:cadashboard/main.dart';
import 'package:cadashboard/ui/screen/login_screen.dart';
import 'package:cadashboard/ui/widget/custom_navigate.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewClientVM extends BaseModel{

  ValueNotifier<ViewState> viewLoader = ValueNotifier(ViewState.loading);

  List<ClientList> client = [];

  bool search = false;

  int perPage = 20;
  int startPage = 0;
  int endPage = 15;
  int maxPage = 0;

  TextEditingController searchController = TextEditingController();

  Future<void> checkToken(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    appPrint('-----> Token : ${preferences.getString(PreferenceHelper.userToken)}');
    tokenRepo.checkToken(
      token: preferences.getString(PreferenceHelper.userToken) ?? "",
      successResponse: (success, message, response) {
        getAllClient(context,null,null);
      },
      failedResponse: (success, message, statusCode) {
        appPrint('Client Token : $message');
        CommonFunction.showSnackBar(context: context, isError: true, message: 'Your Session has been Expried');
        Navigator.pushAndRemoveUntil(context, cusNavigate(const LoginScreen()), (route) => false);
        viewLoader.value = ViewState.failed;
      },
    );
  }

  Future<void> getAllClient(BuildContext context,String? search,String? start) async {
    appPrint('StartPage = $startPage : EndPage = $endPage');
    await clientRepo.getClient(
      searchText: search ?? "",
      startPage: startPage.toString(),
      endPage: "10",
      success: (response) {
        appPrint(response.clientList.length);

        if(client.isNotEmpty) {
          client.addAll(response.clientList);
        } else {
          client = response.clientList;
          maxPage = response.records!;
        }
        appPrint(maxPage);
        notifyListeners();
        viewLoader.value = ViewState.success;
      },
      failed: (message) {
        appPrint('Get all Client : $message');
        CommonFunction.showSnackBar(context: context, isError: true, message: message);
        viewLoader.value = ViewState.failed;
      },
    );
  }
}