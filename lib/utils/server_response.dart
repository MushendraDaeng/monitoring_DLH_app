enum StatusResponse { success, failed, error }

class ServerResponse {
  StatusResponse status;
  String? message;
  dynamic data;
  ServerResponse({required this.status, this.message, this.data});
}

Map<String, String> headersWithToken(String token) {
  return {"Authorization": "Bearer $token", "Content-Type": "Application/json"};
}
