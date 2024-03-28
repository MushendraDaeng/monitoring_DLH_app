import 'package:flutter/widgets.dart';
import 'package:truck_monitoring_apps/config/global.dart';
import 'package:truck_monitoring_apps/models/customer.dart';
import 'package:truck_monitoring_apps/services/customer_services.dart';
import 'package:truck_monitoring_apps/utils/logger.dart';
import 'package:truck_monitoring_apps/utils/server_response.dart';

class CustomerController {
  final CustomerServices _services = CustomerServices();

  Future<List<Customer>> getCustomer(
      {int page = 1, int limit = 10, required BuildContext context}) async {
    var token = loggedUser.value.accessToken;
    var response = await _services.getCustomer(page, limit, token);
    if (response.status == StatusResponse.success) {
      return response.data as List<Customer>;
    }
    if (context.mounted) {
      showMessage(
          title: "Failed", message: response.message!, type: MessageType.error);
    }
    return List.empty();
  }

  Future<Customer?> getCustomerById(String id, BuildContext context) async {
    var token = loggedUser.value.accessToken;
    var response = await _services.getCustomerById(id, token);
    if (response.status == StatusResponse.success) {
      return response.data as Customer;
    }
    if (context.mounted) {
      showMessage(
          title: "Failed", message: response.message!, type: MessageType.error);
    }
    return null;
  }
}
