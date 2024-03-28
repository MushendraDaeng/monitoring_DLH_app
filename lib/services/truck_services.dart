import 'dart:convert';

import 'package:http/http.dart';
import 'package:truck_monitoring_apps/config/global.dart';
import 'package:truck_monitoring_apps/models/truck.dart';
import 'package:truck_monitoring_apps/utils/logger.dart';
import 'package:truck_monitoring_apps/utils/server_response.dart';

class TruckServices {
  final String getTruckUrl = "truck-list/";
  final String getTruckByIdUrl = "truck-by-id/";

  Future<ServerResponse> getTruckById(String id, String token) async {
    String url = "$baseUrl$apiUrl$getTruckByIdUrl$id";
    var headers = headersWithToken(token);
    try {
      var response = await get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var converted = jsonDecode(response.body);
        TruckModel trucks = TruckModel.fromJson(converted['data']);
        return ServerResponse(status: StatusResponse.success, data: trucks);
      } else {
        printLog(
            "Failed to get truck by id : ${response.statusCode} -> ${response.body}");
        return ServerResponse(
            status: StatusResponse.failed, message: "Failed get truck detail");
      }
    } catch (e) {
      printLog("Error on getting truck detail $e");
      return ServerResponse(
          status: StatusResponse.error,
          message: "Error on getting trucks details");
    }
  }

  Future<ServerResponse> getTruck(int page, int limit, String token) async {
    String url = "$baseUrl$apiUrl$getTruckUrl$page/$limit";
    var headers = headersWithToken(token);
    try {
      var response = await get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var converted = jsonDecode(response.body);
        List<TruckModel> trucks = [];
        for (var truck in converted['data']) {
          trucks.add(TruckModel.fromJson(truck));
        }
        return ServerResponse(status: StatusResponse.success, data: trucks);
      } else {
        printLog(
            "Failed to get truck list ${response.statusCode} -> ${response.body}");
        return ServerResponse(
            status: StatusResponse.failed, message: "Failed to get truck list");
      }
    } catch (e) {
      printLog("Error to get Truck list $e");
      return ServerResponse(
          status: StatusResponse.error, message: "Error to get Truck List");
    }
  }
}
