import 'dart:convert';

import 'package:http/http.dart';
import 'package:truck_monitoring_apps/config/global.dart';
import 'package:truck_monitoring_apps/models/detail_tracking.dart';
import 'package:truck_monitoring_apps/utils/logger.dart';
import 'package:truck_monitoring_apps/utils/server_response.dart';

import '../models/trackings.dart';

class TrackingServices {
  final String getTrakckingUrl = "tracking-list/";
  final String addDetailUrl = "tracking-add-detail";
  final String updateUrl = "tracking-update";
  final String updateDetailUrl = "tracking-update-detail";
  final String getCurrentTrackingUrl = 'tracking-by-driver-current-date';
  final String startTrackingUrl = "start-tracking";
  final String stopTrackingUrl = "stop-tracking";

  Future<ServerResponse> getCurrentTracking(String token) async {
    String url = "$baseUrl$apiUrl$getCurrentTrackingUrl";
    var headers = headersWithToken(token);
    try {
      var response = await get(Uri.parse(url), headers: headers);
      printLog(
          "Response from get current Trackings : ${response.statusCode} -> ${response.body}");
      if (response.statusCode == 200) {
        var converted = jsonDecode(response.body);
        Trackings tracking = Trackings.fromJson(converted['data']);
        return ServerResponse(status: StatusResponse.success, data: tracking);
      } else {
        printLog(
            'Failed to get current tracking ${response.statusCode}->${response.body}');
        return ServerResponse(
            status: StatusResponse.failed,
            message: "Failed to get current tracking");
      }
    } catch (e) {
      printLog("Error on getting current tracking $e");
      return ServerResponse(
          status: StatusResponse.error,
          message: "Error on getting current tracking");
    }
  }

  Future<ServerResponse> updateDetailTracking(
      DetailTracking newData, String token) async {
    String url = "$baseUrl$apiUrl$updateDetailUrl";
    var headers = headersWithToken(token);
    try {
      var body = newData.toMap();
      var response =
          await put(Uri.parse(url), headers: headers, body: jsonEncode(body));
      printLog(
          "Response on update detail tracking ${response.statusCode} -> ${response.body}");
      if (response.statusCode == 200) {
        var converted = jsonDecode(response.body);
        DetailTracking tracking = DetailTracking.fromJson(converted['data']);
        return ServerResponse(status: StatusResponse.success, data: tracking);
      } else {
        return ServerResponse(
            status: StatusResponse.failed,
            message: "Failed to update detail tracking ");
      }
    } catch (e) {
      printLog("Error on update detail tracking $e");
      return ServerResponse(
          status: StatusResponse.error,
          message: "Error on update detail tracking");
    }
  }

  Future<ServerResponse> startTracking(Trackings newData, String token) async {
    String url = "$baseUrl$apiUrl$startTrackingUrl";
    var headers = headersWithToken(token);
    try {
      var body = {
        "id": newData.id,
        "driver_id": newData.driverId,
        "truck_id": newData.truckId,
        "start_location": newData.startLocation,
        "start_time": newData.startTime.toString()
      };
      printLog("Url : $url");
      var response =
          await post(Uri.parse(url), headers: headers, body: jsonEncode(body));
      printLog(
          "Response on update tracking ${response.statusCode} -> ${response.body}");
      if (response.statusCode == 200) {
        var converted = jsonDecode(response.body);
        Trackings tracking = Trackings.fromJson(converted['data']);
        return ServerResponse(status: StatusResponse.success, data: tracking);
      } else {
        return ServerResponse(
            status: StatusResponse.failed,
            message: "Failed to update tracking ");
      }
    } catch (e) {
      printLog("Error on update tracking $e");
      return ServerResponse(
          status: StatusResponse.error, message: "Error on update tracking");
    }
  }

  Future<ServerResponse> stopTracking(Trackings newData, String token,
      GeoLocationCollection? geoLocationCollection) async {
    String url = "$baseUrl$apiUrl$stopTrackingUrl";
    var headers = headersWithToken(token);
    try {
      var body = {
        "id": newData.id,
        "driver_id": newData.driverId,
        "truck_id": newData.truckId,
        "stop_location": newData.stopLocation,
        "stop_time": newData.stopTime.toString()
      };
      if (geoLocationCollection != null) {
        body["geolocation_col"] = geoLocCol.convertToBase64();
      }
      var response =
          await post(Uri.parse(url), headers: headers, body: jsonEncode(body));
      printLog(
          "Response on update tracking ${response.statusCode} -> ${response.body}");
      if (response.statusCode == 200) {
        var converted = jsonDecode(response.body);
        Trackings tracking = Trackings.fromJson(converted['data']);
        return ServerResponse(status: StatusResponse.success, data: tracking);
      } else {
        return ServerResponse(
            status: StatusResponse.failed,
            message: "Failed to update tracking ");
      }
    } catch (e) {
      printLog("Error on update tracking $e");
      return ServerResponse(
          status: StatusResponse.error, message: "Error on update tracking");
    }
  }

  Future<ServerResponse> updateTracking(Trackings newData, String token) async {
    String url = "$baseUrl$apiUrl$updateUrl";
    var headers = headersWithToken(token);
    try {
      var body = newData.toMap();
      var response =
          await put(Uri.parse(url), headers: headers, body: jsonEncode(body));
      printLog(
          "Response on update tracking ${response.statusCode} -> ${response.body}");
      if (response.statusCode == 200) {
        var converted = jsonDecode(response.body);
        Trackings tracking = Trackings.fromJson(converted['data']);
        return ServerResponse(status: StatusResponse.success, data: tracking);
      } else {
        return ServerResponse(
            status: StatusResponse.failed,
            message: "Failed to update tracking ");
      }
    } catch (e) {
      printLog("Error on update tracking $e");
      return ServerResponse(
          status: StatusResponse.error, message: "Error on update tracking");
    }
  }

  Future<ServerResponse> addDetailTracking(
      DetailTracking detail, String token) async {
    String url = "$baseUrl$apiUrl$addDetailUrl";
    var headers = headersWithToken(token);

    try {
      var response = await post(Uri.parse(url),
          headers: headers, body: jsonEncode(detail.toMap()));
      printLog(
          "Response from add detail tracking : ${response.statusCode} -> ${response.body}");
      if (response.statusCode == 200) {
        var converted = jsonDecode(response.body);
        DetailTracking detail = DetailTracking.fromJson(converted['data']);
        return ServerResponse(status: StatusResponse.success, data: detail);
      } else {
        return ServerResponse(
            status: StatusResponse.failed, message: "Failed to add Detail");
      }
    } catch (e) {
      printLog("Error on adding detail tracking $e");
      return ServerResponse(
          status: StatusResponse.error,
          message: "Error on adding detail tracking");
    }
  }

  Future<ServerResponse> getTrackingList(
      String token, int page, int limit) async {
    String url = "$baseUrl$apiUrl$getTrakckingUrl$page/$limit";
    var headers = headersWithToken(token);
    try {
      var response = await get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var converted = jsonDecode(response.body);
        List<Trackings> trackings = [];
        for (var tracking in converted['data']) {
          trackings.add(Trackings.fromJson(tracking));
        }
        return ServerResponse(status: StatusResponse.success, data: trackings);
      } else {
        printLog(
            "Failed to get tracking list ${response.statusCode} -> ${response.body}");
        return ServerResponse(
            status: StatusResponse.failed,
            message: "Failed to get tracking list");
      }
    } catch (e) {
      printLog("Error to get tracking list $e");
      return ServerResponse(
          status: StatusResponse.error, message: "Error to get tracking");
    }
  }
}
