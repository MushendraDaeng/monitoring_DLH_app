import 'dart:convert';

import 'package:http/http.dart';
import 'package:truck_monitoring_apps/config/global.dart';
import 'package:truck_monitoring_apps/models/customer.dart';
import 'package:truck_monitoring_apps/utils/logger.dart';
import 'package:truck_monitoring_apps/utils/server_response.dart';

class CustomerServices {
  final String getCustomerUrl = "customer-list/";
  final String getCustomerByIdUrl = "customer-by-id/";

  Future<ServerResponse> getCustomerById(String id, String token) async {
    String url = "$baseUrl$apiUrl$getCustomerByIdUrl$id";
    var headers = headersWithToken(token);
    // try {
    var response = await get(Uri.parse(url), headers: headers);
    if (response.statusCode == 200) {
      var converted = jsonDecode(response.body);
      Customer customer = Customer.fromJson(converted['data']);
      return ServerResponse(status: StatusResponse.success, data: customer);
    } else {
      printLog(
          "Failed to get customer by id ${response.statusCode} -> ${response.body}");
      return ServerResponse(
          status: StatusResponse.failed,
          message: "Failed to get customer by ID");
    }
    // } catch (e) {
    //   printLog("Error on getting customer by id $e");
    //   return ServerResponse(
    //       status: StatusResponse.error,
    //       message: "Error on getting customer by id");
    // }
  }

  Future<ServerResponse> getCustomer(int page, int limit, String token) async {
    String url = "$baseUrl$apiUrl$getCustomerUrl$page/$limit";
    var headers = headersWithToken(token);
    try {
      var response = await get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var converted = jsonDecode(response.body);
        List<Customer> customers = [];
        for (var customer in converted['data']) {
          customers.add(Customer.fromJson(customer));
        }
        return ServerResponse(status: StatusResponse.success, data: customers);
      } else {
        printLog(
            "failed to get customer list ${response.statusCode} -> ${response.body}");
        return ServerResponse(
            status: StatusResponse.failed, message: "Failed to get customer");
      }
    } catch (e) {
      printLog("Error on getting customer list $e");
      return ServerResponse(
          status: StatusResponse.error,
          message: "Error on getting customer list");
    }
  }
}
