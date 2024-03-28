import 'package:flutter/widgets.dart';
import 'package:truck_monitoring_apps/config/global.dart';
import 'package:truck_monitoring_apps/models/detail_tracking.dart';
import 'package:truck_monitoring_apps/services/tracking_services.dart';
import 'package:truck_monitoring_apps/utils/logger.dart';
import 'package:truck_monitoring_apps/utils/server_response.dart';

import '../models/trackings.dart';

class TrackingController {
  final TrackingServices _services = TrackingServices();

  Future<Trackings?> getCurrentTracking(BuildContext context) async {
    var token = loggedUser.value.accessToken;
    var response = await _services.getCurrentTracking(token);
    if (response.status == StatusResponse.success) {
      return response.data as Trackings;
    }
    if (context.mounted) {
      showMessage(
          title: "Failed", message: response.message!, type: MessageType.error);
    }
    return null;
  }

  Future<DetailTracking?> updateDetailTracking(
      {required DetailTracking newData, required BuildContext context}) async {
    var token = loggedUser.value.accessToken;
    var response = await _services.updateDetailTracking(newData, token);
    if (response.status == StatusResponse.success) {
      return response.data as DetailTracking;
    }
    if (context.mounted) {
      showMessage(
          title: "Failed", message: response.message!, type: MessageType.error);
    }
    return null;
  }

  Future<Trackings?> startTracking(
      {required Trackings newData, required BuildContext context}) async {
    var token = loggedUser.value.accessToken;
    var response = await _services.startTracking(newData, token);
    if (response.status == StatusResponse.success) {
      return response.data as Trackings;
    }
    if (context.mounted) {
      showMessage(
          title: "Failed", message: response.message!, type: MessageType.error);
    }
    return null;
  }

  Future<Trackings?> stopTracking(
      {required Trackings newData, required BuildContext context,GeoLocationCollection? geoLocationCollection}) async {
    var token = loggedUser.value.accessToken;
    var response = await _services.stopTracking(newData, token,geoLocationCollection);
    if (response.status == StatusResponse.success) {
      return response.data as Trackings;
    }
    if (context.mounted) {
      showMessage(
          title: "Failed", message: response.message!, type: MessageType.error);
    }
    return null;
  }

  Future<Trackings?> updateTracking(
      {required Trackings newData, required BuildContext context}) async {
    var token = loggedUser.value.accessToken;
    var response = await _services.updateTracking(newData, token);
    if (response.status == StatusResponse.success) {
      return response.data as Trackings;
    }
    if (context.mounted) {
      showMessage(
          title: "Failed", message: response.message!, type: MessageType.error);
    }
    return null;
  }

  Future<DetailTracking?> addDetailTracking(
      {required DetailTracking data, required BuildContext context}) async {
    var token = loggedUser.value.accessToken;
    var response = await _services.addDetailTracking(data, token);
    if (response.status == StatusResponse.success) {
      return response.data as DetailTracking;
    }
    if (context.mounted) {
      showMessage(
          title: "Failed", message: response.message!, type: MessageType.error);
    }
    return null;
  }

  Future<List<Trackings>> getTrackingList(
      {required int page,
      required int limit,
      required BuildContext context}) async {
    var token = loggedUser.value.accessToken;
    var response = await _services.getTrackingList(token, page, limit);
    if (response.status == StatusResponse.success) {
      return response.data as List<Trackings>;
    }
    if (context.mounted) {
      showMessage(
          title: "failed", message: response.message!, type: MessageType.error);
    }
    return List.empty();
  }
}
