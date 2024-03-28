class DriverModel {
  String id, userName, name, password, phone, gender;
  String? _accessToken, photo;
  DateTime? dob;
  set accessToken(String value) => _accessToken = value;
  String get accessToken => _accessToken ?? '';
  DriverModel(
      {required this.id,
      required this.userName,
      required this.name,
      required this.password,
      required this.phone,
      required this.gender,
      this.photo,
      this.dob});
  factory DriverModel.fromJson(dynamic json) {
    return DriverModel(
        id: json['id'],
        userName: json['user_name'],
        name: json['name'],
        password: json['password'] ?? 'hidden',
        phone: json['phone'],
        gender: json['gender'],
        photo: json['photo'],
        dob: DateTime.parse((json['dob'] ?? DateTime.now()).toString()));
  }
  void copyFrom(DriverModel driver) {
    id = driver.id;
    dob = driver.dob;
    userName = driver.userName;
    name = driver.name;
    photo = driver.photo;
    gender = driver.gender;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'name': name,
      'password': password,
      'phone': phone,
      'gender': gender,
      'dob': dob ?? DateTime.now().toString()
    };
  }
}
