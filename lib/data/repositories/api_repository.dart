import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../models/models.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiRepository {
  final String baseUrl;
  final String token;
  final http.Client _client;

  ApiRepository({
    this.baseUrl = AppConstants.baseUrl,
    this.token = AppConstants.adminToken,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'X-Admin-Token': token,
  };

  Future<T> _get<T>(String endpoint, T Function(dynamic) parser) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl$endpoint'), headers: _headers)
          .timeout(AppConstants.timeout);

      if (response.statusCode == 200) {
        return parser(json.decode(response.body));
      }
      throw ApiException('Request failed', response.statusCode);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  Future<T> _post<T>(String endpoint, Map<String, dynamic> body, T Function(dynamic) parser) async {
    try {
      final response = await _client
          .post(Uri.parse('$baseUrl$endpoint'), headers: _headers, body: json.encode(body))
          .timeout(AppConstants.timeout);

      if (response.statusCode == 200) {
        return parser(json.decode(response.body));
      }
      throw ApiException('Request failed', response.statusCode);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  Future<bool> checkHealth() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl${ApiEndpoints.health}')).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Stats> getStats() async {
    return _get(ApiEndpoints.stats, (data) => Stats.fromJson(data));
  }

  Future<List<Order>> getOrders() async {
    return _get(ApiEndpoints.orders, (data) {
      final list = data['orders'] as List? ?? [];
      return list.map((e) => Order.fromJson(e)).toList();
    });
  }

  Future<List<Product>> getProducts() async {
    return _get(ApiEndpoints.products, (data) {
      final list = data['products'] as List? ?? [];
      return list.map((e) => Product.fromJson(e)).toList();
    });
  }

  Future<List<Feedback>> getFeedbacks() async {
    return _get(ApiEndpoints.feedbacks, (data) {
      final list = data['feedbacks'] as List? ?? [];
      return list.map((e) => Feedback.fromJson(e)).toList();
    });
  }

  Future<List<String>> getLogs() async {
    return _get(ApiEndpoints.logs, (data) {
      return List<String>.from(data['logs'] ?? []);
    });
  }

  Future<String> restartBot() async {
    return _post(ApiEndpoints.restart, {}, (data) => data['message'] ?? 'Restart initiated');
  }

  Future<String> confirmPayment(String orderId) async {
    return _post(ApiEndpoints.orderConfirm(orderId), {}, (data) => data['message'] ?? 'Confirmed');
  }

  Future<String> rejectPayment(String orderId, String reason) async {
    return _post(ApiEndpoints.orderReject(orderId), {'reason': reason}, (data) => data['message'] ?? 'Rejected');
  }

  Future<String> setTrackingCode(String orderId, String code) async {
    return _post(ApiEndpoints.orderTracking(orderId), {'code': code}, (data) => data['message'] ?? 'Tracking set');
  }

  Future<String> updateOrderStatus(String orderId, String status) async {
    return _post(ApiEndpoints.orderStatus(orderId), {'status': status}, (data) => data['message'] ?? 'Status updated');
  }
}