class ApiConstants {
  static String xchangeApiBaseUrl = 'https://api.xchangeapi.com/';
  static String latest = 'latest/';
  static String tradingEconomicsBaseUrl = 'https://tradingeconomics.com/';
  static String ghCurrencyConversions = 'ghana/currency';
}

enum RequestStatus {
  success,
  socketException,
  connectionTimedOut,
  other,
}
