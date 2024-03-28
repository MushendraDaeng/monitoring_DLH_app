class TruckModel {
  String id, name, plate, brand, fuelType;
  String? image;
  int? mnfYear;
  TruckModel(
      {required this.id,
      required this.name,
      required this.plate,
      required this.brand,
      required this.fuelType,
      this.image,
      this.mnfYear});
  factory TruckModel.fromJson(dynamic json) {
    return TruckModel(
        id: json['id'],
        name: json['name'],
        plate: json['plate'],
        brand: json['brand'],
        fuelType: json['fuel_type'] ?? '-',
        image: json['foto'] ?? '',
        mnfYear: json['mdfYear'] ?? 0);
  }
  void copyFrom(TruckModel truck) {
    id = truck.id;
    name = truck.name;
    plate = truck.plate;
    brand = truck.brand;
    fuelType = truck.fuelType;
    image = truck.image;
    mnfYear = truck.mnfYear;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'plate': plate,
      'brand': brand,
      'fuelType': fuelType,
      'mnfYear': mnfYear
    };
  }
}
