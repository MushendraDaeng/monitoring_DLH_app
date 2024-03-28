import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:truck_monitoring_apps/config/global.dart';
import 'package:truck_monitoring_apps/models/driver.dart';
import 'package:truck_monitoring_apps/services/driver_services.dart';
import 'package:truck_monitoring_apps/utils/logger.dart';
import 'package:truck_monitoring_apps/utils/server_response.dart';

class DriverController {
  final DriverServices _services = DriverServices();
  final String crdnBoxName = "credentials";

  Future<bool> login(BuildContext context, String uid, String pwd) async {
    var response = await _services.login(uid, pwd);
    if (response.status == StatusResponse.success) {
      loggedUser.value.copyFrom(response.data as DriverModel);
      loggedUser.value.accessToken = (response.data as DriverModel).accessToken;
      loggedUser.refresh();
      bool saved = await savedToLocal(loggedUser.value.accessToken);
      if (!saved) {
        showMessage(
            title: "Error",
            message: "You might need to login again next time!",
            type: MessageType.info);
      }
      return true;
    } else {
      if (context.mounted) {
        showMessage(
            title: "Failed",
            message: response.message!,
            type: MessageType.error);
      }
      return false;
    }
  }

  Future<bool> checkIfLogin(BuildContext context) async {
    var token = await getAccessToken();
    if (token == "") {
      return false;
    }
    loggedUser.value.accessToken = token;
    if (context.mounted) {
      var logged = await getProfile(context);
      if (!logged) {
        var tokenBox = Hive.box(crdnBoxName);
        await tokenBox.clear();
      }
      return logged;
    }
    return false;
  }

  Future<String> getAccessToken() async {
    var tokenBox = Hive.isBoxOpen(crdnBoxName)
        ? Hive.box(crdnBoxName)
        : await Hive.openBox(crdnBoxName);
    if (tokenBox.isEmpty) {
      return "";
    }
    String token = tokenBox.get("token");
    return token;
  }

  Future<bool> savedToLocal(String accessToken) async {
    try {
      var tokenBox = Hive.isBoxOpen(crdnBoxName)
          ? Hive.box(crdnBoxName)
          : await Hive.openBox(crdnBoxName);
      await tokenBox.clear();
      await tokenBox.put("token", accessToken);
      return true;
    } catch (e) {
      printLog("Error on saved credentials to local $e");
      return false;
    }
  }

  Future<bool> removeFromLocal() async {
    try {
      var tokenBox = Hive.isBoxOpen(crdnBoxName)
          ? Hive.box(crdnBoxName)
          : await Hive.openBox(crdnBoxName);
      await tokenBox.clear();
      return true;
    } catch (e, stackTrace) {
      printLog("Error on logout : $e => $stackTrace");
      return false;
    }
  }

  Future<bool> logout(BuildContext context) async {
    var token = loggedUser.value.accessToken;
    var response = await _services.logout(token);
    if (response.status == StatusResponse.success) {
      await removeFromLocal();
      if (context.mounted) {
        showMessage(
            title: "Success",
            message: response.message!,
            type: MessageType.success);
      }
      return true;
    }
    showMessage(
        title: "Failed", message: response.message!, type: MessageType.error);
    return false;
  }

  Future<bool> updatePhotoProfile(String filePath, BuildContext context) async {
    var token = loggedUser.value.accessToken;
    var response = await _services.updateProfilePicture(
        filePath, token, loggedUser.value.id);
    if (response.status == StatusResponse.success) {
      loggedUser.value.photo = response.data as String;
      loggedUser.refresh();
      if (context.mounted) {
        showMessage(
            title: "Success",
            message: response.message!,
            type: MessageType.success);
      }
      return true;
    }
    showMessage(
        title: "Failed", message: response.message!, type: MessageType.error);
    return false;
  }

  Future<bool> updatePassword(
      String oldPwd, String newPwd, BuildContext context) async {
    var token = loggedUser.value.accessToken;
    var response = await _services.updatePassword(
        oldPwd, newPwd, loggedUser.value.id, token);
    if (response.status == StatusResponse.success) {
      if (context.mounted) {
        showMessage(
            title: "Success",
            message: response.message!,
            type: MessageType.success);
      }
      return true;
    }
    showMessage(
        title: "Failed", message: response.message!, type: MessageType.error);
    return false;
  }

  Future<bool> updatetProfile(DriverModel newData, BuildContext context) async {
    var token = loggedUser.value.accessToken;
    var response = await _services.updateProfile(newData, token);
    if (response.status == StatusResponse.success) {
      loggedUser.value.copyFrom(response.data as DriverModel);
      loggedUser.refresh();
      return true;
    } else {
      if (context.mounted) {
        showMessage(
            title: "Failed",
            message: response.message!,
            type: MessageType.error);
      }
      return false;
    }
  }

  Future<bool> getProfile(BuildContext context) async {
    var token = loggedUser.value.accessToken;
    var response = await _services.getProfile(token);
    if (response.status == StatusResponse.success) {
      loggedUser.value.copyFrom(response.data as DriverModel);
      loggedUser.refresh();
      return true;
    } else {
      if (context.mounted) {
        showMessage(
            title: "Failed",
            message: response.message!,
            type: MessageType.error);
      }
      return false;
    }
  }
}
