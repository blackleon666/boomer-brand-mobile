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
}
