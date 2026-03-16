import 'dart:developer';

import 'package:cadashboard/core/api_client/api_client.dart';
import 'package:cadashboard/core/url/api_url.dart';

class AddLoggedInAreaAddressRepository extends ApiClient {

  Future<bool> afterLoginApi({
    required String tokenID, required String address, required String loginDetailID, required String latitude,
    required String longitude, required String isLogin,
    required Function(int success, String message, Map<String, dynamic> response)successResponse,
    required Function(int success, String message) failedResponse}) async {

    var result = await getMethod(
        url: Uri.parse(Urls.addLoggedInAreaAddress(
            tokenID: tokenID,
            address: address,
            loginDetailID: loginDetailID,
            latitude: latitude,
            longitude: longitude,
            isLogin: isLogin)));

    try {
      if (result is String) {
        failedResponse(0, result);
        return false;
      }
      if (result is! Map) {
        failedResponse(0, errorMessage);
        return false;
      }
      final response = Map<String, dynamic>.from(result);
      final success = int.tryParse(response["Success"]?.toString() ?? "0") ?? 0;
      final message = response["Message"]?.toString() ?? errorMessage;

      if (success == 1) {
        successResponse(success, message, response);
        return true;
      } else {
        failedResponse(success, message);
        return false;
      }
    } catch (e) {
      log("AddLoggedInAreaAddressRepository Exception :---> $e");
      failedResponse(0, errorMessage);
      return false;
    }
  }
}
