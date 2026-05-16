class Order {
  final String orderId;
  final int userId;
  final int productId;
  final String? productName;
  final String? size;
  final String? color;
  final double price;
  final String status;
  final String? trackingCode;
  final DateTime? createdAt;

  Order({
    required this.orderId,
    required this.userId,
    required this.productId,
    this.productName,
    this.size,
    this.color,
    required this.price,
    required this.status,
    this.trackingCode,
    this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['order_id'] ?? '',
      userId: json['user_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productName: json['product_name'],
      size: json['size'],
      color: json['color'],
      price: (json['price'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending_payment',
      trackingCode: json['tracking_code'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  String get statusText {
    switch (status) {
      case 'pending_payment': return 'Ödeme Bekliyor';
      case 'paid': return 'Ödendi';
      case 'shipped': return 'Kargoda';
      case 'delivered': return 'Teslim';
      case 'payment_rejected': return 'Reddedildi';
      default: return 'Bilinmiyor';
    }
  }

  bool get canConfirm => status == 'pending_payment';
  bool get canSetTracking => status == 'paid';
}

class Product {
  final int id;
  final String? name;
  final String? model;
  final double price;
  final double? campaignPrice;
  final bool isCampaign;
  final String? color;
  final String? sizes;
  final String? description;
  final String? imageUrl;

  Product({
    required this.id,
    this.name,
    this.model,
    required this.price,
    this.campaignPrice,
    this.isCampaign = false,
    this.color,
    this.sizes,
    this.description,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'],
      model: json['model'],
      price: (json['price'] ?? 0).toDouble(),
      campaignPrice: json['campaign_price']?.toDouble(),
      isCampaign: json['is_campaign'] == 1 || json['is_campaign'] == true,
      color: json['color'],
      sizes: json['sizes'],
      description: json['description'],
      imageUrl: json['image_url'],
    );
  }

  String get displayName => model ?? name ?? 'Ürün #$id';
  double get displayPrice => campaignPrice ?? price;
}

class Feedback {
  final int id;
  final int userId;
  final String? username;
  final String? userTelegramId;
  final String type;
  final String message;
  final bool isRead;
  final DateTime? createdAt;

  Feedback({
    required this.id,
    required this.userId,
    this.username,
    this.userTelegramId,
    required this.type,
    required this.message,
    this.isRead = false,
    this.createdAt,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      username: json['username'],
      userTelegramId: json['user_telegram_id']?.toString(),
      type: json['type'] ?? 'sikayet',
      message: json['message'] ?? '',
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  bool get isComplaint => type == 'sikayet';
  
  String get displayUserId => userTelegramId ?? userId.toString();
}

class Stats {
  final int users;
  final int products;
  final int orders;
  final int complaints;
  final double uptime;
  final int totalUsers;
  final int totalOrders;
  final int pendingOrders;
  final int paidOrders;
  final int shippedOrders;
  final int newFeedback;

  Stats({
    this.users = 0,
    this.products = 0,
    this.orders = 0,
    this.complaints = 0,
    this.uptime = 0,
    this.totalUsers = 0,
    this.totalOrders = 0,
    this.pendingOrders = 0,
    this.paidOrders = 0,
    this.shippedOrders = 0,
    this.newFeedback = 0,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      users: json['users'] ?? json['total_users'] ?? 0,
      products: json['products'] ?? 0,
      orders: json['orders'] ?? json['total_orders'] ?? 0,
      complaints: json['complaints'] ?? 0,
      uptime: (json['uptime'] ?? 0).toDouble(),
      totalUsers: json['total_users'] ?? 0,
      totalOrders: json['total_orders'] ?? 0,
      pendingOrders: json['pending_orders'] ?? 0,
      paidOrders: json['paid_orders'] ?? 0,
      shippedOrders: json['shipped_orders'] ?? 0,
      newFeedback: json['new_feedback'] ?? 0,
    );
  }

  String get uptimeFormatted {
    final hours = uptime ~/ 3600;
    final minutes = (uptime % 3600) ~/ 60;
    return '${hours}s ${minutes}d';
  }
}

class PotentialCustomer {
  final int id;
  final int userId;
  final String? telegramId;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? email;
  final String? notes;
  final String source;
  final DateTime? createdAt;
  final bool isContacted;

  PotentialCustomer({
    required this.id,
    required this.userId,
    this.telegramId,
    this.username,
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.notes,
    this.source = 'telegram',
    this.createdAt,
    this.isContacted = false,
  });

  factory PotentialCustomer.fromJson(Map<String, dynamic> json) {
    return PotentialCustomer(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      telegramId: json['telegram_id']?.toString(),
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      email: json['email'],
      notes: json['notes'],
      source: json['source'] ?? 'telegram',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      isContacted: json['is_contacted'] == 1 || json['is_contacted'] == true,
    );
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return firstName ?? username ?? 'Bilinmiyor';
  }

  String get displayContact => phone ?? email ?? telegramId ?? '-';
}

class BotStatus {
  final bool isRunning;
  final double uptime;
  final int totalUsers;
  final int totalMessages;
  final String? lastActivity;
  final double? cpuUsage;
  final double? memoryUsage;

  BotStatus({
    required this.isRunning,
    this.uptime = 0,
    this.totalUsers = 0,
    this.totalMessages = 0,
    this.lastActivity,
    this.cpuUsage,
    this.memoryUsage,
  });

  factory BotStatus.fromJson(Map<String, dynamic> json) {
    return BotStatus(
      isRunning: json['is_running'] ?? true,
      uptime: (json['uptime'] ?? 0).toDouble(),
      totalUsers: json['total_users'] ?? 0,
      totalMessages: json['total_messages'] ?? 0,
      lastActivity: json['last_activity'],
      cpuUsage: json['cpu_usage']?.toDouble(),
      memoryUsage: json['memory_usage']?.toDouble(),
    );
  }

  String get uptimeFormatted {
    if (uptime == 0) return '-';
    final hours = uptime ~/ 3600;
    final minutes = (uptime % 3600) ~/ 60;
    final days = hours ~/ 24;
    if (days > 0) return '${days}g ${hours % 24}s';
    return '${hours}s ${minutes}d';
  }
}