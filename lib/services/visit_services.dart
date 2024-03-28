import 'dart:convert';

import 'package:http/http.dart';
import 'package:truck_monitoring_apps/config/global.dart';
import 'package:truck_monitoring_apps/models/tracking_visits.dart';
import 'package:truck_monitoring_apps/utils/logger.dart';
import 'package:truck_monitoring_apps/utils/server_response.dart';

import '../models/detail_tracking.dart';

class VisitServices {
  final String createVisitUrl = "visit-create";
  final String updateVisitUrl = "visit-update";
  final String deleteVisitUrl = "visit-delete/";
  final String uploadPhotoUrl = "visit-upload-photo";
  final String getByIdUrl = "visit/";
  final String getByCustomerIdUrl = "visit-by-customer/";

  Future<ServerResponse> getVisitByCustomerId(
      String customerId, String trackingId, String token) async {
    String url = "$baseUrl$apiUrl$getByCustomerIdUrl$customerId/$trackingId";
    var headers = headersWithToken(token);
    try {
      var response = await get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var converted = jsonDecode(response.body);
        TrackingVisits visit = TrackingVisits.fromJson(converted['data']);
        return ServerResponse(status: StatusResponse.success, data: visit);
      } else {
        printLog(
            "Failed on getting visit ${response.statusCode} -> ${response.body}");
        return ServerResponse(
            status: StatusResponse.failed, message: "Failed on getting visit");
      }
    } catch (e) {
      printLog("Error on getting visit detail $e");
      return ServerResponse(
          status: StatusResponse.error,
          message: "Error on getting visit detail");
    }
  }

  Future<ServerResponse> getVisitById(String id, String token) async {
    String url = "$baseUrl$apiUrl$getByIdUrl$id";
    var headers = headersWithToken(token);
    try {
      var response = await get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var converted = jsonDecode(response.body);
        TrackingVisits visit = TrackingVisits.fromJson(converted['data']);
        return ServerResponse(status: StatusResponse.success, data: visit);
      } else {
        printLog(
            "Failed on getting visit ${response.statusCode} -> ${response.body}");
        return ServerResponse(
            status: StatusResponse.failed, message: "Failed on getting visit");
      }
    } catch (e) {
      printLog("Error on getting visit detail $e");
      return ServerResponse(
          status: StatusResponse.error,
          message: "Error on getting visit detail");
    }
  }

  Future<ServerResponse> updatePhoto(
      String filePath, String token, String id) async {
    String url = "$baseUrl$apiUrl$uploadPhotoUrl";
    // try {
    printLog("Update Visiting Photo : $url");
    var request = MultipartRequest("POST", Uri.parse(url));
    var multipartFile = await MultipartFile.fromPath("photo", filePath);
    var headers = headersWithToken(token);
    request.headers.addAll(headers);
    request.files.add(multipartFile);
    request.fields['id'] = id;
    var response = await request.send();
    if (response.statusCode == 200) {
      var reason = await response.stream.bytesToString();
      printLog(
          "Success upload visiting photo : ${response.reasonPhrase} -> $reason");
      // var converted = jsonDecode(reason);
      return ServerResponse(
        status: StatusResponse.success,
        message: "Upload success",
      );
    } else {
      var reason = await response.stream.bytesToString();
      printLog(
          "Upload visiting photo Failed : ${response.statusCode} -> $reason");
      return ServerResponse(
          status: StatusResponse.failed,
          message: "Upload visiting photoFailed");
    }
    // } catch (e) {
    //   printLog('Error on Uploading visiting photo : $e');
    //   return ServerResponse(
    //       status: StatusResponse.error, message: "Error Upload Visiting photo");
    // }
  }

  Future<ServerResponse> deleteVisit(String id, String token) async {
    String url = "$baseUrl$apiUrl$deleteVisitUrl$id";
    var headers = headersWithToken(token);
    try {
      var response = await delete(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        // var converted = jsonDecode(response.body);
        return ServerResponse(
            status: StatusResponse.success,
            message: "Visitting successfully deleted");
      } else {
        printLog(
            "Failed to delete visitting report ${response.statusCode} -> ${response.body}");
        return ServerResponse(
            status: StatusResponse.failed,
            message: "Failed to delete visitting report");
      }
    } catch (e) {
      printLog("Error on deleting visitting report $e");
      return ServerResponse(
          status: StatusResponse.error,
          message: "Error on deleting visitting report");
    }
  }

  Future<ServerResponse> updateVisit(TrackingVisits newData, String token,
      GeoLocationCollection? geoLocationCollection) async {
    String url = "$baseUrl$apiUrl$updateVisitUrl";
    var headers = headersWithToken(token);
    try {
      var body = newData.toMap();
      if (geoLocCol != null) {
        printLog("Geo Location Item : ${geoLocCol.items.length}");
        body['geolocation_col'] = geoLocCol.convertToBase64();
      }
      var response =
          await put(Uri.parse(url), body: jsonEncode(body), headers: headers);
      if (response.statusCode == 200) {
        var converted = jsonDecode(response.body);
        TrackingVisits visit = TrackingVisits.fromJson(converted['data']);
        return ServerResponse(status: StatusResponse.success, data: visit);
      } else {
        printLog(
            "Failed on update visitting report ${response.statusCode} -> ${response.body}");
        return ServerResponse(
            status: StatusResponse.failed,
            message: "Failed on update visitting report");
      }
    } catch (e) {
      printLog("Error on updating visiting report $e");
      return ServerResponse(
          status: StatusResponse.error,
          message: "Error on updating visting report");
    }
  }

  Future<ServerResponse> createVisit(TrackingVisits visits, String token,
      GeoLocationCollection? geoLocationCollection) async {
    String url = "$baseUrl$apiUrl$createVisitUrl";
    var body = visits.toMap();
    if (geoLocationCollection != null) {
      body['geolocation_col'] = geoLocCol.convertToBase64();
    }
    var headers = headersWithToken(token);
    try {
      var response =
          await post(Uri.parse(url), headers: headers, body: jsonEncode(body));
      if (response.statusCode == 200) {
        var converted = jsonDecode(response.body);
        TrackingVisits visits = TrackingVisits.fromJson(converted['data']);
        return ServerResponse(status: StatusResponse.success, data: visits);
      } else {
        printLog(
            "Failed to create visiting report ${response.statusCode} -> ${response.body}");
        return ServerResponse(
            status: StatusResponse.failed,
            message: "Failed to create visiting report");
      }
    } catch (e) {
      printLog("Error on creating visiting report $e");
      return ServerResponse(
          status: StatusResponse.error,
          message: "Error on creating visit report");
    }
  }
}
