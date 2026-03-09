import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cadashboard/core/common/common_function.dart';
import 'package:cadashboard/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../ui/screen/home.dart';
import '../services/location_dialog_service.dart';
import '../url/api_url.dart';
import '../utils/preference_helper.dart';

class ApiClient{

  String errorMessage = 'Something went Wrong';


  /// With out token api
  Future withOutTokenGetMethod({required Uri url, Map<String, dynamic>? queryParam, Map<String, String>? header}) async {

    var result;

    try {
      var urls = Uri.decodeComponent(url.replace(queryParameters: queryParam).toString());

      log('---->Urls : $urls');

      var response = await http.get(Uri.parse(urls), headers: header);

      result = await handleResponse(response);
    } on TimeoutException catch (e) {
      result = {"Success": 0, "Message": "Server Time out"};
      appPrint(e);
    } on SocketException catch (e) {
      result = {"Success": 0, "Message": "No Internet Found"};
      appPrint(e);
    } on Error catch (e) {
      result = {"Success": 0, "Message": "Something went wrong"};
      appPrint(e);
    }

    return result;
  }

  Future withOutTokenPostMethod({required Uri url, Map<String, String>? queryParam, Map<String, String>? header, Map<String, dynamic>? body}) async {
    var result;

    try{
      log('---->Urls : ${url.replace(queryParameters: queryParam)}');

      var response = await http.post(
          url.replace(queryParameters: queryParam),
          headers: header,
          body: body
      );
      result = await handleResponse(response);
    } on TimeoutException catch (e) {
      result = {"Success": 0, "Message": "Server Time out"};
      appPrint(e);
    } on SocketException catch (e) {
      result = {"Success": 0, "Message": "No Internet Found"};
      appPrint(e);
    } on Exception catch (e) {
      result = {"Success": 0, "Message": e.toString().trim().isNotEmpty ? e.toString() : "Something went wrong"};
      appPrint(e);
    } on Error catch (e) {
      result = {"Success": 0, "Message": "Something went wrong"};
      appPrint(e);
    }

    return result;
  }



  /// With Token api
  /// [skipLocationCheck] when true, location check is bypassed (used for lightweight APIs
  /// like notifications so the UI doesn't block on geo-fence validation).
  Future getMethod({
    required Uri url,
    Map<String, dynamic>? queryParam,
    Map<String, String>? header,
    bool skipLocationCheck = false,
  }) async {

    if (!skipLocationCheck) {
      final access = await requestLocationPermission();

      if (!access) {
        LocationDialogService.show(navigatorKey.currentContext!);
        return {
          "Success": 0,
          "Message":
              "Login not allowed. You’re currently outside the allowed location. Please move closer to your assigned zone to proceed."
        };
      }
      LocationDialogService.hide();
    }

    var result;
    try {
      var urls = Uri.decodeComponent(url.replace(queryParameters: queryParam).toString());

      log('---->Urls : $urls');

      var response = await http.get(Uri.parse(urls), headers: header);

      result = await handleResponse(response);
    } on TimeoutException catch (e) {
      result = {"Success": 0, "Message": "Server Time out"};
      appPrint(e);
    } on SocketException catch (e) {
      result = {"Success": 0, "Message": "No Internet Found"};
      appPrint(e);
    } on Error catch (e) {
      result = {"Success": 0, "Message": "Something went wrong"};
      appPrint(e);
    }

    return result;
  }

  Future postRawMethod({required Uri url, Map<String, String>? queryParam, Map<String, String>? header, Map<String, dynamic>? body}) async {

    final access = await requestLocationPermission();

    if (!access) {
      LocationDialogService.show(navigatorKey.currentContext!);
      return {"Success": 0, "Message": "Login not allowed. You're currently outside the allowed location. Please move closer to your assigned zone to proceed."};
    }
    LocationDialogService.hide();

    var result;

    var b = jsonEncode(body);
    log('RAW Body :---> [$b]');

    try{
      var response = await http.post(
        url.replace(queryParameters: queryParam),
        headers: header,
        body: "[$b]",
      );
      result = await handleResponse(response);
    } on TimeoutException catch (e) {
      result = {"Success": 0, "Message": "Server Time out"};
      appPrint(e);
    } on SocketException catch (e) {
      result = {"Success": 0, "Message": "No Internet Found"};
      appPrint(e);
    } on Error catch (e) {
      result = {"Success": 0, "Message": "Something went wrong"};
      appPrint(e);
    }

    return result;
  }

Future postMethod({
  required Uri url,
  Map<String, String>? queryParam,
  Map<String, String>? header,
  Map<String, dynamic>? body,
  bool skipLocationCheck = false,
}) async {

  if (!skipLocationCheck) {
    final access = await requestLocationPermission();
    if (!access) {
      return {
        "Success": 0,
        "Message":
          "Location permission required. Please enable location."
      };
    }
  }

  final response = await http.post(
    url.replace(queryParameters: queryParam),
    headers: header,
    body: body,
  );

  return handleResponse(response);
}

  /// POST with single JSON object body (no array wrapper). For APIs that expect one object.
  Future postJsonMethod({
    required Uri url,
    Map<String, String>? queryParam,
    Map<String, String>? header,
    Map<String, dynamic>? body,
  }) async {
    var result;
    try {
      final bodyStr = body != null ? jsonEncode(body) : null;
      log('postJson Body :---> $bodyStr');
      var response = await http.post(
        url.replace(queryParameters: queryParam),
        headers: {...?header, 'Content-Type': 'application/json'},
        body: bodyStr,
      );
      result = await handleResponse(response);
    } on TimeoutException catch (e) {
      result = {"Success": 0, "Message": "Server Time out"};
      appPrint(e);
    } on SocketException catch (e) {
      result = {"Success": 0, "Message": "No Internet Found"};
      appPrint(e);
    } on Error catch (e) {
      result = {"Success": 0, "Message": "Something went wrong"};
      appPrint(e);
    }
    return result;
  }


  /// call check location api in every api call.
  Future<bool> requestLocationPermission({String? loginDetailID, String? token}) async {
    LocationPermission permission;
    // Check if location services are enabled

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if(Platform.isIOS){
      if (!serviceEnabled) {
        locationDialog(
          context: navigatorKey.currentContext!,
          onTapGotIt: () => Navigator.pop(navigatorKey.currentContext!),
        );
        return false;
      }
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      return await checkLocation(
        latitude: position.latitude.toString(),
        longitude: position.longitude.toString(),
        token: token,
        loginDetailID: loginDetailID
      );
    } catch (e) {
      CommonFunction.showSnackBar(context: navigatorKey.currentContext!, isError: true, message: e.toString());
      return false;
    }
  }

  Future checkGetMethod({required Uri url, Map<String, dynamic>? queryParam, Map<String, String>? header}) async {

    var result;

    try {
      var urls = Uri.decodeComponent(url.replace(queryParameters: queryParam).toString());

      log('---->Urls : $urls');

      var response = await http.get(Uri.parse(urls), headers: header);

      result = await handleResponse(response);
    } on TimeoutException catch (e) {
      result = {"Success": 0, "Message": "Server Time out"};
      appPrint(e);
    } on SocketException catch (e) {
      result = {"Success": 0, "Message": "No Internet Found"};
      appPrint(e);
    } on Error catch (e) {
      result = {"Success": 0, "Message": "Something went wrong"};
      appPrint(e);
    }

    return result;
  }

  Future<bool> checkLocation({required String latitude, required String longitude, String? loginDetailID, String? token}) async {

    SharedPreferences preferences = await SharedPreferences.getInstance();

    var result = await checkGetMethod(
        url: Uri.parse(Urls.checkLocation),
        queryParam: {
          'tokenID' : token ?? preferences.getString(PreferenceHelper.userToken),
          'latitude' : latitude,
          'longitude' : longitude,
          'LoginDetailID' : loginDetailID ?? preferences.getString(PreferenceHelper.loginDetailID),
        }
    );

    try {
      if(result == true){
        // onResponse(true, "Location Access");
        return true;
      } else {
        // onResponse(false, "You are not able to access this app in this location.");
        return false;
      }
    } catch (e) {
      appPrint("LocationRepo Exception :--> $e");
      // onResponse(false, errorMessage);
      return false;
    }

  }


  /// Handle Response
  Future handleResponse(http.Response response) async {
    log('----->${response.statusCode}');
    appPrint("Response :-> ${response.body}");
    switch(response.statusCode){
      case 200:
        return await jsonDecode(response.body);
      case 201:
        return response.body;
      case 203:
        return await jsonDecode(response.body);
      case 204:
        return {"Success": 0, "Message": errorMessage, "StatusCode": response.statusCode};
      case 304:
        log(response.body);
      case 400:
        return {"Success": 0, "Message": response.body.toString(), "StatusCode": response.statusCode};
      case 401:
      case 403:
        return {"Success": 0, "Message": response.body.toString(), "StatusCode": response.statusCode};
      case 500:
        return {"Success": 0, "Message": "Internal Server Error : ${response.statusCode}", "StatusCode": response.statusCode};
      case 503:
        return {"Success": 0, "Message": "The service is unavailable", "StatusCode": response.statusCode};
      case 504:
        return {"Success": 0, "Message": "Your Session has been Expired", "StatusCode": response.statusCode};
      default:
        return {"Success": 0, "Message": 'Error occurred while communication with server with status code : ${response.statusCode} : ${response.body}', "StatusCode": response.statusCode};
    }
  }
}



class BadRequestException implements Exception {
  final String message;

  BadRequestException(this.message);

  @override
  String toString() {
    return 'BadRequestException: $message';
  }
}

class UnauthorisedException implements Exception {
  final String message;

  UnauthorisedException(this.message);

  @override
  String toString() {
    return 'UnauthorisedException: $message';
  }
}

class FetchDataException implements Exception {
  final String message;

  FetchDataException(this.message);

  @override
  String toString() {
    return 'FetchDataException: $message';
  }
}