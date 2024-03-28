import 'package:flutter/widgets.dart';
import 'package:truck_monitoring_apps/config/global.dart';
import 'package:truck_monitoring_apps/models/detail_tracking.dart';
import 'package:truck_monitoring_apps/models/tracking_visits.dart';
import 'package:truck_monitoring_apps/services/visit_services.dart';
import 'package:truck_monitoring_apps/utils/logger.dart';
import 'package:truck_monitoring_apps/utils/server_response.dart';

class VisitController {
  final VisitServices _services = VisitServices();

  Future<bool> updatePhoto(
      {required String filePath,
      required String id,
      required BuildContext context}) async {
    var token = loggedUser.value.accessToken;
    var response = await _services.updatePhoto(filePath, token, id);
    if (response.status == StatusResponse.success) {
      return true;
    }
    if (context.mounted) {
      showMessage(
          title: "failed", message: response.message!, type: MessageType.error);
    }
    return false;
  }

  Future<bool> deleteVisit(
      {required String id, required BuildContext context}) async {
    var token = loggedUser.value.accessToken;
    var response = await _services.deleteVisit(id, token);
    if (response.status == StatusResponse.success) {
      if (context.mounted) {
        showMessage(
            title: "Success",
            message: response.message!,
            type: MessageType.info);
      }
      return true;
    }
    if (context.mounted) {
      showMessage(
          title: "failed", message: response.message!, type: MessageType.error);
    }
    return false;
  }

  Future<TrackingVisits?> updateVisit(
      {required TrackingVisits visits,
      required BuildContext context,
      GeoLocationCollection? geoLocationCollection}) async {
    var token = loggedUser.value.accessToken;
    var response =
        await _services.updateVisit(visits, token, geoLocationCollection);
    if (response.status == StatusResponse.success) {
      return response.data as TrackingVisits;
    }
    if (context.mounted) {
      showMessage(
          title: "failed", message: response.message!, type: MessageType.error);
    }
    return null;
  }

  Future<TrackingVisits?> createVisit(
      {required TrackingVisits visits,
      required BuildContext context,
      GeoLocationCollection? geoLocationCollection}) async {
    var token = loggedUser.value.accessToken;
    var response =
        await _services.createVisit(visits, token, geoLocationCollection);
    if (response.status == StatusResponse.success) {
      return response.data as TrackingVisits;
    }
    if (context.mounted) {
      showMessage(
          title: "failed", message: response.message!, type: MessageType.error);
    }
    return null;
  }

  Future<TrackingVisits?> getVisitById(String id, BuildContext context) async {
    var token = loggedUser.value.accessToken;
    var response = await _services.getVisitById(id, token);
    if (response.status == StatusResponse.success) {
      return response.data as TrackingVisits;
    }
    if (context.mounted) {
      showMessage(
          title: "Failed", message: response.message!, type: MessageType.error);
    }
    return null;
  }

  Future<TrackingVisits?> getVisitByCustomerId(
      String customerId, String trackingId, BuildContext context) async {
    var token = loggedUser.value.accessToken;
    var response =
        await _services.getVisitByCustomerId(customerId, trackingId, token);
    if (response.status == StatusResponse.success) {
      return response.data as TrackingVisits;
    }
    if (context.mounted) {
      showMessage(
          title: "Failed", message: response.message!, type: MessageType.error);
    }
    return null;
  }
}
