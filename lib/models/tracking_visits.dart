class TrackingVisits {
  String? id, customerName, customerLat, customerLng, photoUrl, description;
  String customerId, trackingId;
  DateTime? trackingDate;
  TrackingVisits(
      {required this.customerId,
      required this.trackingId,
      this.customerLat,
      this.customerLng,
      this.customerName,
      this.description,
      this.id,
      this.photoUrl,
      this.trackingDate});
  factory TrackingVisits.fromJson(dynamic json) {
    return TrackingVisits(
        customerId: json['customer_id'],
        trackingId: json['tracking_id'],
        id: json['id'],
        customerName: json['customer_name'],
        customerLat: json['customer_lat'],
        customerLng: json['customer_lng'],
        photoUrl: json['photo_url'],
        description: json['description'],
        trackingDate: DateTime.parse(
            (json['tracking_date'] ?? DateTime.now()).toString()));
  }
  Map<String, String> toMap() {
    return {
      'id': id ?? '',
      'customer_id': customerId,
      'customer_name': customerName ?? '',
      'customer_lng': customerLng ?? '',
      'customer_lat': customerLat ?? '',
      'photo_url': photoUrl ?? '',
      'tracking_id': trackingId,
      'description': description ?? '',
      'tracking_date': trackingDate.toString()
    };
  }
}
