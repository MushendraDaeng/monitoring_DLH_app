class TrackingRoute {
  String id, name;
  String? description;
  TrackingRoute({required this.id, required this.name, this.description});
  factory TrackingRoute.fromJson(dynamic json) {
    return TrackingRoute(
        id: json['id'], name: json['name'], description: json['description']);
  }
  Map<String, String> toMap() {
    return {'id': id, 'name': name, 'description': description ?? ''};
  }
}

class TrackingRouteDetail {
  String id, customerId, customerName, routeId;
  double customerLat, customerLng;
  String? customerVillage, customerDistrict, customerStatus;
  TrackingRouteDetail(
      {required this.id,
      required this.customerId,
      required this.customerName,
      required this.customerLat,
      required this.customerLng,
      required this.routeId,
      this.customerDistrict,
      this.customerStatus,
      this.customerVillage});
  factory TrackingRouteDetail.fromJson(dynamic json) {
    return TrackingRouteDetail(
        id: json['id'],
        customerId: json['customer_id'],
        customerName: json['customer_name'],
        customerLat: json['customer_lat'],
        customerLng: json['customer_lng'],
        routeId: json['route_id'],
        customerDistrict: json['customer_district'],
        customerStatus: json['customer_status'],
        customerVillage: json['customer_village']);
  }
}
