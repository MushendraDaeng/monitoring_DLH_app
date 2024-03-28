class Customer {
  String id, name, status;
  double longitude, latitude;
  String? idKategori,
      kategoriName,
      idSubKategori,
      subkategoriName,
      urbanVillage,
      subDistrict,
      tarif;
  Customer(
      {required this.id,
      required this.name,
      required this.status,
      required this.latitude,
      required this.longitude,
      this.idKategori,
      this.idSubKategori,
      this.kategoriName,
      this.subDistrict,
      this.subkategoriName,
      this.tarif,
      this.urbanVillage});
  factory Customer.fromJson(dynamic json) {
    return Customer(
        id: json['id'],
        name: json['name'],
        status: json['status'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        idKategori: json['id_kategori'],
        idSubKategori: json['id_sub_kategori'],
        kategoriName: json['kategori_name'],
        subDistrict: json['sub_district'],
        urbanVillage: json['urban_village'],
        tarif: json['tarif'].toString(),
        subkategoriName: json['sub_kategori_name']);
  }
}
