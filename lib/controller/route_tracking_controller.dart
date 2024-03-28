import 'package:flutter/widgets.dart';
import 'package:truck_monitoring_apps/config/global.dart';
import 'package:truck_monitoring_apps/services/tracking_route_services.dart';
import 'package:truck_monitoring_apps/utils/logger.dart';
import 'package:truck_monitoring_apps/utils/server_response.dart';

class TrackingRouteController {
  final TrackingRouteServices _services = TrackingRouteServices();

  Future<Map<String, dynamic>> getRoute(
      {required BuildContext context, required String id}) async {
    var token = loggedUser.value.accessToken;
    var response = await _services.getRoute(id, token);
    if (response.status == StatusResponse.success) {
      return response.data;
    }
    if (context.mounted) {
      showMessage(
          title: "Failed", message: response.message!, type: MessageType.error);
    }
    return {};
  }
}
