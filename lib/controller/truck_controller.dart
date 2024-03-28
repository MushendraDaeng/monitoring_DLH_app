import 'package:flutter/widgets.dart';
import 'package:truck_monitoring_apps/config/global.dart';
import 'package:truck_monitoring_apps/models/truck.dart';
import 'package:truck_monitoring_apps/services/truck_services.dart';
import 'package:truck_monitoring_apps/utils/logger.dart';
import 'package:truck_monitoring_apps/utils/server_response.dart';

class TruckController {
  final TruckServices _services = TruckServices();

  Future<List<TruckModel>> getTruckList(
      {required int page,
      required int limit,
      required BuildContext context}) async {
    var token = loggedUser.value.accessToken;
    var response = await _services.getTruck(page, limit, token);
    if (response.status == StatusResponse.success) {
      var data = response.data as List<TruckModel>;

      return data;
    }
    if (context.mounted) {
      showMessage(
          title: "Failed", message: response.message!, type: MessageType.error);
    }
    return List.empty();
  }

  Future<TruckModel?> getTruckById(String id, BuildContext context) async {
    var token = loggedUser.value.accessToken;
    var response = await _services.getTruckById(id, token);
    if (response.status == StatusResponse.success) {
      var data = response.data as TruckModel;
      return data;
    }
    if (context.mounted) {
      showMessage(
          title: "Failed", message: response.message!, type: MessageType.error);
    }
    return null;
  }
}
