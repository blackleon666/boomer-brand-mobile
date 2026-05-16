import 'package:flutter_test/flutter_test.dart';
import 'package:boomer_brand_app/core/constants/app_constants.dart';

void main() {
  group('AppConstants Tests', () {
    test('App name is correct', () {
      expect(AppConstants.appName, equals('Boomer Brand'));
    });

    test('Admin token is correct', () {
      expect(AppConstants.adminToken, equals('boomer-admin-2026'));
    });

    test('Base URL is localhost:10000', () {
      expect(AppConstants.baseUrl, equals('http://localhost:10000'));
    });

    test('Timeout is 30 seconds', () {
      expect(AppConstants.timeout.inSeconds, equals(30));
    });
  });

  group('ApiEndpoints Tests', () {
    test('Health endpoint is correct', () {
      expect(ApiEndpoints.health, equals('/health'));
    });

    test('Stats endpoint is correct', () {
      expect(ApiEndpoints.stats, equals('/api/stats'));
    });

    test('Orders endpoint is correct', () {
      expect(ApiEndpoints.orders, equals('/api/orders'));
    });

    test('Products endpoint is correct', () {
      expect(ApiEndpoints.products, equals('/api/products'));
    });

    test('Feedbacks endpoint is correct', () {
      expect(ApiEndpoints.feedbacks, equals('/api/feedbacks'));
    });

    test('Logs endpoint is correct', () {
      expect(ApiEndpoints.logs, equals('/api/logs'));
    });

    test('Restart endpoint is correct', () {
      expect(ApiEndpoints.restart, equals('/api/restart'));
    });

    test('Customers endpoint is correct', () {
      expect(ApiEndpoints.customers, equals('/api/customers'));
    });

    test('BotStatus endpoint is correct', () {
      expect(ApiEndpoints.botStatus, equals('/api/bot/status'));
    });

    test('Order confirm endpoint returns correct path', () {
      expect(ApiEndpoints.orderConfirm('BB123'), equals('/api/orders/BB123/confirm'));
    });

    test('Order reject endpoint returns correct path', () {
      expect(ApiEndpoints.orderReject('BB123'), equals('/api/orders/BB123/reject'));
    });

    test('Order tracking endpoint returns correct path', () {
      expect(ApiEndpoints.orderTracking('BB123'), equals('/api/orders/BB123/tracking'));
    });

    test('Order status endpoint returns correct path', () {
      expect(ApiEndpoints.orderStatus('BB123'), equals('/api/orders/BB123/status'));
    });
  });
}