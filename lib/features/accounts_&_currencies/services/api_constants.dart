class ApiConstants {
  static String baseUrl = 'https://api.xchangeapi.com/';
  static String latest = 'latest/';
}

enum RequestStatus {
  success,
  socketException,
  connectionTimedOut,
  other,
}
