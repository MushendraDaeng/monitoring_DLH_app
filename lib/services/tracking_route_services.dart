import 'dart:convert';

import 'package:http/http.dart';
import 'package:truck_monitoring_apps/config/global.dart';
import 'package:truck_monitoring_apps/models/route_tracking.dart';
import 'package:truck_monitoring_apps/utils/logger.dart';
import 'package:truck_monitoring_apps/utils/server_response.dart';

class TrackingRouteServices {
  final String getRouteUrl = "route-detail/";
  Future<ServerResponse> getRoute(String id, String token) async {
    String url = "$baseUrl$apiUrl$getRouteUrl$id";
    var headers = headersWithToken(token);
    // try {
    var response = await get(Uri.parse(url), headers: headers);
    if (response.statusCode == 200) {
      var converted = jsonDecode(response.body);
      TrackingRoute route = TrackingRoute.fromJson(converted['route']);
      List<TrackingRouteDetail> routeDetails = [];
      for (var detail in converted['detail']) {
        routeDetails.add(TrackingRouteDetail.fromJson(detail));
      }
      return ServerResponse(
          status: StatusResponse.success,
          data: {'route': route, 'detail': routeDetails});
    } else {
      printLog(
          "Failed to get route detail ${response.statusCode} -> ${response.body}");
      return ServerResponse(
          status: StatusResponse.failed, message: "Failed to get route detail");
    }
    // } catch (e) {
    //   printLog("Error on get route detail $e");
    //   return ServerResponse(
    //       status: StatusResponse.error,
    //       message: "Error on getting route detail");
    // }
  }
}
