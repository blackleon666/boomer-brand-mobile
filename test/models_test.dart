import 'package:flutter_test/flutter_test.dart';
import 'package:boomer_brand_app/data/models/models.dart';

void main() {
  group('Order Model Tests', () {
    test('Order fromJson creates order correctly', () {
      final json = {
        'order_id': 'BB12345678',
        'user_id': 12345,
        'product_id': 1,
        'product_name': 'iPhone 15 Pro',
        'size': 'M',
        'color': 'Siyah',
        'price': 45000.0,
        'status': 'pending_payment',
        'tracking_code': null,
      };

      final order = Order.fromJson(json);

      expect(order.orderId, equals('BB12345678'));
      expect(order.userId, equals(12345));
      expect(order.productId, equals(1));
      expect(order.productName, equals('iPhone 15 Pro'));
      expect(order.size, equals('M'));
      expect(order.color, equals('Siyah'));
      expect(order.price, equals(45000.0));
      expect(order.status, equals('pending_payment'));
    });

    test('Order statusText returns correct text', () {
      expect(Order(orderId: '1', userId: 1, productId: 1, price: 100, status: 'pending_payment').statusText, equals('Ödeme Bekliyor'));
      expect(Order(orderId: '1', userId: 1, productId: 1, price: 100, status: 'paid').statusText, equals('Ödendi'));
      expect(Order(orderId: '1', userId: 1, productId: 1, price: 100, status: 'shipped').statusText, equals('Kargoda'));
      expect(Order(orderId: '1', userId: 1, productId: 1, price: 100, status: 'delivered').statusText, equals('Teslim'));
      expect(Order(orderId: '1', userId: 1, productId: 1, price: 100, status: 'payment_rejected').statusText, equals('Reddedildi'));
    });

    test('Order canConfirm returns true for pending_payment', () {
      final order = Order(orderId: '1', userId: 1, productId: 1, price: 100, status: 'pending_payment');
      expect(order.canConfirm, isTrue);
    });

    test('Order canSetTracking returns true for paid', () {
      final order = Order(orderId: '1', userId: 1, productId: 1, price: 100, status: 'paid');
      expect(order.canSetTracking, isTrue);
    });
  });

  group('Product Model Tests', () {
    test('Product fromJson creates product correctly', () {
      final json = {
        'id': 1,
        'model': 'iPhone 15',
        'price': 40000.0,
        'campaign_price': 35000.0,
        'is_campaign': true,
        'color': 'Siyah',
        'sizes': 'M,L,XL',
      };

      final product = Product.fromJson(json);

      expect(product.id, equals(1));
      expect(product.model, equals('iPhone 15'));
      expect(product.price, equals(40000.0));
      expect(product.campaignPrice, equals(35000.0));
      expect(product.isCampaign, isTrue);
    });

    test('Product displayName returns model name', () {
      final product = Product(id: 1, model: 'Test Product', price: 100);
      expect(product.displayName, equals('Test Product'));
    });

    test('Product displayPrice returns campaign price if available', () {
      final product = Product(id: 1, model: 'Test', price: 100, campaignPrice: 80);
      expect(product.displayPrice, equals(80));
    });
  });

  group('Feedback Model Tests', () {
    test('Feedback fromJson creates feedback correctly', () {
      final json = {
        'id': 1,
        'user_id': 12345,
        'username': 'testuser',
        'user_telegram_id': '5832042754',
        'type': 'sikayet',
        'message': 'Ürün çok geç geldi',
        'is_read': false,
      };

      final feedback = Feedback.fromJson(json);

      expect(feedback.id, equals(1));
      expect(feedback.userId, equals(12345));
      expect(feedback.username, equals('testuser'));
      expect(feedback.userTelegramId, equals('5832042754'));
      expect(feedback.type, equals('sikayet'));
      expect(feedback.message, equals('Ürün çok geç geldi'));
    });

    test('Feedback isComplaint returns true for sikayet', () {
      final feedback = Feedback(id: 1, userId: 1, type: 'sikayet', message: 'Test');
      expect(feedback.isComplaint, isTrue);
    });

    test('Feedback isComplaint returns false for oneri', () {
      final feedback = Feedback(id: 1, userId: 1, type: 'oneri', message: 'Test');
      expect(feedback.isComplaint, isFalse);
    });
  });

  group('Stats Model Tests', () {
    test('Stats fromJson creates stats correctly', () {
      final json = {
        'users': 100,
        'products': 50,
        'orders': 75,
        'complaints': 10,
        'uptime': 3600.0,
      };

      final stats = Stats.fromJson(json);

      expect(stats.users, equals(100));
      expect(stats.products, equals(50));
      expect(stats.orders, equals(75));
      expect(stats.complaints, equals(10));
      expect(stats.uptime, equals(3600.0));
    });

    test('Stats uptimeFormatted returns correct format', () {
      final stats = Stats(uptime: 3660);
      expect(stats.uptimeFormatted, equals('1s 1d'));
    });
  });

  group('PotentialCustomer Model Tests', () {
    test('PotentialCustomer fromJson creates customer correctly', () {
      final json = {
        'id': 1,
        'user_id': 12345,
        'telegram_id': '5832042754',
        'username': 'customer1',
        'first_name': 'Ahmet',
        'last_name': 'Yılmaz',
        'phone': '+905551234567',
        'email': 'ahmet@example.com',
        'notes': 'VIP müşteri',
        'source': 'telegram',
        'is_contacted': false,
      };

      final customer = PotentialCustomer.fromJson(json);

      expect(customer.id, equals(1));
      expect(customer.telegramId, equals('5832042754'));
      expect(customer.firstName, equals('Ahmet'));
      expect(customer.lastName, equals('Yılmaz'));
      expect(customer.phone, equals('+905551234567'));
      expect(customer.email, equals('ahmet@example.com'));
      expect(customer.isContacted, isFalse);
    });

    test('PotentialCustomer fullName returns combined name', () {
      final customer = PotentialCustomer(
        id: 1,
        userId: 1,
        firstName: 'Ahmet',
        lastName: 'Yılmaz',
      );
      expect(customer.fullName, equals('Ahmet Yılmaz'));
    });
  });

  group('BotStatus Model Tests', () {
    test('BotStatus fromJson creates status correctly', () {
      final json = {
        'is_running': true,
        'uptime': 7200.0,
        'total_users': 150,
        'total_messages': 500,
        'last_activity': '2024-01-15 10:30:00',
      };

      final status = BotStatus.fromJson(json);

      expect(status.isRunning, isTrue);
      expect(status.uptime, equals(7200.0));
      expect(status.totalUsers, equals(150));
      expect(status.totalMessages, equals(500));
    });

    test('BotStatus uptimeFormatted returns correct format', () {
      final status = BotStatus(isRunning: true, uptime: 90000);
      expect(status.uptimeFormatted, equals('1g 1s'));
    });
  });
}