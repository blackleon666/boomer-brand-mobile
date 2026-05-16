class AppConstants {
  static const String appName = 'Boomer Brand';
  static const String adminToken = 'boomer-admin-2026';
  static const String baseUrl = 'http://localhost:10000';
  static const String duckDnsUrl = 'http://boomerbot.duckdns.org:10000';
  
  static const Duration timeout = Duration(seconds: 30);
  static const Duration refreshInterval = Duration(seconds: 30);
}

class ApiEndpoints {
  static const String health = '/health';
  static const String stats = '/api/stats';
  static const String orders = '/api/orders';
  static const String products = '/api/products';
  static const String feedbacks = '/api/feedbacks';
  static const String logs = '/api/logs';
  static const String restart = '/api/restart';

  static String orderConfirm(String orderId) => '/api/orders/$orderId/confirm';
  static String orderReject(String orderId) => '/api/orders/$orderId/reject';
  static String orderTracking(String orderId) => '/api/orders/$orderId/tracking';
  static String orderStatus(String orderId) => '/api/orders/$orderId/status';
}