import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://YOUR_DUCKDNS_DOMAIN.duckdns.org:10000';
  static const String adminToken = 'boomer-admin-2026';

  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'X-Admin-Token': adminToken,
  };

  static Future<Map<String, dynamic>> getStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/stats'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load stats');
  }

  static Future<List<String>> getLogs() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/logs'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<String>.from(data['logs'] ?? []);
    }
    throw Exception('Failed to load logs');
  }

  static Future<String> restartBot() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/restart'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['message'] ?? 'Restart initiated';
    }
    throw Exception('Failed to restart bot');
  }

  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getOrders() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/orders'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['orders'] ?? []);
    }
    throw Exception('Failed to load orders');
  }

  static Future<Map<String, dynamic>> updateOrderStatus(String orderId, String status) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/orders/$orderId/status'),
      headers: _headers,
      body: json.encode({'status': status}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to update order');
  }

  static Future<String> setTrackingCode(String orderId, String code) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/orders/$orderId/tracking'),
      headers: _headers,
      body: json.encode({'code': code}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['message'] ?? 'Tracking code set';
    }
    throw Exception('Failed to set tracking code');
  }

  static Future<List<Map<String, dynamic>>> getProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/products'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['products'] ?? []);
    }
    throw Exception('Failed to load products');
  }

  static Future<List<Map<String, dynamic>>> getFeedbacks() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/feedbacks'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['feedbacks'] ?? []);
    }
    throw Exception('Failed to load feedbacks');
  }

  static Future<String> confirmPayment(String orderId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/orders/$orderId/confirm'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['message'] ?? 'Payment confirmed';
    }
    throw Exception('Failed to confirm payment');
  }

  static Future<String> rejectPayment(String orderId, String reason) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/orders/$orderId/reject'),
      headers: _headers,
      body: json.encode({'reason': reason}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['message'] ?? 'Payment rejected';
    }
    throw Exception('Failed to reject payment');
  }
}
