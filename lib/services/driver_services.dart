import 'dart:convert';

import 'package:http/http.dart';
import 'package:truck_monitoring_apps/config/global.dart';
import 'package:truck_monitoring_apps/models/driver.dart';
import 'package:truck_monitoring_apps/utils/logger.dart';
import 'package:truck_monitoring_apps/utils/server_response.dart';

class DriverServices {
  final String loginUrl = "login-driver";
  final String logoutUrl = "logout-driver";
  final String profileUrl = "driver-profile";
  final String updateProfileUrl = "driver-update";
  final String updatePasswordUrl = "driver-update-password";
  final String uploadPhotoUrl = "driver-upload-photo";

  Future<ServerResponse> updateProfilePicture(
      String filePath, String token, String userId) async {
    String url = "$baseUrl$apiUrl$uploadPhotoUrl";
    try {
      printLog("Update Profile Picture : $url");
      var request = MultipartRequest("POST", Uri.parse(url));
      var multipartFile = await MultipartFile.fromPath("photo", filePath);
      var headers = headersWithToken(token);
      request.headers.addAll(headers);
      request.files.add(multipartFile);
      request.fields["id"] = userId;
      var response = await request.send();
      if (response.statusCode == 200) {
        var reason = await response.stream.bytesToString();
        printLog(
            "Success upload picture : ${response.reasonPhrase} -> $reason");
        var converted = jsonDecode(reason);
        return ServerResponse(
            status: StatusResponse.success,
            message: "Upload success",
            data: converted["data"]);
      } else {
        var reason = await response.stream.bytesToString();
        printLog("Upload Failed : ${response.statusCode} -> $reason");
        return ServerResponse(
            status: StatusResponse.failed, message: "Upload Failed");
      }
    } catch (e) {
      printLog('Error on Uploading : $e');
      return ServerResponse(
          status: StatusResponse.error, message: "Error Upload");
    }
  }

  Future<ServerResponse> updatePassword(
      String oldPwd, String newPwd, String userId, String token) async {
    String url = "$baseUrl$apiUrl$updatePasswordUrl";
    var body = {"id": userId, "old": oldPwd, "password": newPwd};
    var headers = headersWithToken(token);
    try {
      var response =
          await post(Uri.parse(url), headers: headers, body: jsonEncode(body));
      if (response.statusCode == 200) {
        return ServerResponse(
            status: StatusResponse.success,
            message: "Update Password Success!");
      } else {
        printLog(
            "Failed to update password : ${response.statusCode} -> ${response.body}");
        return ServerResponse(
            status: StatusResponse.failed,
            message: "Failed to update password, please try again");
      }
    } catch (e) {
      printLog("Error on updating password : $e");
      return ServerResponse(
          status: StatusResponse.error,
          message: "Error on updating password, please try again! later!");
    }
  }

  Future<ServerResponse> getProfile(String token) async {
    String url = "$baseUrl$apiUrl$profileUrl";
    var headers = headersWithToken(token);
    try {
      var response = await get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var converted = jsonDecode(response.body);
        DriverModel driver = DriverModel.fromJson(converted['data']);
        return ServerResponse(status: StatusResponse.success, data: driver);
      } else {
        printLog(
            "Failed to get profile : ${response.statusCode} - ${response.body}");
        return ServerResponse(
            status: StatusResponse.failed, message: "Failed to get profile");
      }
    } catch (e) {
      printLog("Error on getting profile : $e");
      return ServerResponse(
          status: StatusResponse.error, message: "Error on getting profile");
    }
  }

  Future<ServerResponse> updateProfile(
      DriverModel newData, String token) async {
    String url = "$baseUrl$apiUrl$updateProfileUrl";
    var headers = headersWithToken(token);
    try {
      var body = newData.toMap();
      var response =
          await put(Uri.parse(url), body: jsonEncode(body), headers: headers);
      if (response.statusCode == 200) {
        var converted = jsonDecode(response.body);
        DriverModel driver = DriverModel.fromJson(converted['data']);
        return ServerResponse(status: StatusResponse.success, data: driver);
      } else {
        printLog(
            "Failed on update profile ${response.statusCode} -> ${response.body}");
        return ServerResponse(
            status: StatusResponse.failed, message: "Failed on update profile");
      }
    } catch (e) {
      printLog("Error on updating profile $e");
      return ServerResponse(
          status: StatusResponse.error, message: "Error on updating profile");
    }
  }

  Future<ServerResponse> login(String uid, String pwd) async {
    String url = "$baseUrl$apiUrl$loginUrl";
    var body = {"user_id": uid, "password": pwd};
    printLog("Url : $url, Body : $body");
    // try {
    var response = await post(Uri.parse(url), body: body);
    printLog(
        "Response From Login : ${response.statusCode} -> ${response.body}");
    if (response.statusCode == 200) {
      var converted = jsonDecode(response.body);
      DriverModel driver = DriverModel.fromJson(converted['data']);
      driver.accessToken = converted['token'];
      return ServerResponse(status: StatusResponse.success, data: driver);
    } else {
      printLog("Failed to Login : ${response.statusCode}->${response.body}");
      var converted = jsonDecode(response.body);
      return ServerResponse(
          status: StatusResponse.failed, message: converted['message']);
    }
    // } catch (e) {
    //   printLog("Error on login : $e");
    //   return ServerResponse(
    //       status: StatusResponse.error, message: "Error on login : $e");
    // }
  }

  Future<ServerResponse> logout(String token) async {
    String url = "$baseUrl$apiUrl$logoutUrl";
    var headers = headersWithToken(token);
    try {
      var response = await get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        return ServerResponse(
            status: StatusResponse.success, message: "Logout successfull");
      } else {
        printLog("Failed to logout : ${response.statusCode}->${response.body}");
        return ServerResponse(
            status: StatusResponse.failed,
            message: "Failed to logout, please try again!");
      }
    } catch (e) {
      printLog("Error on logout $e");
      return ServerResponse(
          status: StatusResponse.error,
          message: "Error on logout, please try again!");
    }
  }
}
