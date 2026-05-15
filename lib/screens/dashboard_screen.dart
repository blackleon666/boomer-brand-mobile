import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/log_viewer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> _stats = {};
  List<String> _logs = [];
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _feedbacks = [];
  bool _isLoading = true;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ApiService.checkHealth(),
        ApiService.getStats(),
        ApiService.getLogs(),
        ApiService.getOrders().catchError((_) => <Map<String, dynamic>>[]),
        ApiService.getProducts().catchError((_) => <Map<String, dynamic>>[]),
        ApiService.getFeedbacks().catchError((_) => <Map<String, dynamic>>[]),
      ]);
      setState(() {
        _isOnline = results[0] as bool;
        _stats = results[1] as Map<String, dynamic>;
        _logs = List<String>.from(results[2] as List);
        _orders = results[3] as List<Map<String, dynamic>>;
        _products = results[4] as List<Map<String, dynamic>>;
        _feedbacks = results[5] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _restartBot() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Botu Yeniden Başlat'),
        content: const Text('Bot yeniden başlatılacak. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Evet', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.restartBot();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bot yeniden başlatılıyor...'),
              backgroundColor: AppTheme.goldDark,
            ),
          );
          Future.delayed(const Duration(seconds: 5), _loadData);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: $e'), backgroundColor: AppTheme.error),
          );
        }
      }
    }
  }

  String _formatUptime(double seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    return '${h}s ${m}d';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BOOMER BRAND'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.gold,
          labelColor: AppTheme.gold,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Genel'),
            Tab(icon: Icon(Icons.shopping_cart), text: 'Siparişler'),
            Tab(icon: Icon(Icons.inventory), text: 'Ürünler'),
            Tab(icon: Icon(Icons.feedback), text: 'Geri Bildirim'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isOnline ? Icons.circle : Icons.circle_outlined,
                color: _isOnline ? AppTheme.success : AppTheme.error, size: 12),
            onPressed: null,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.gold))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDashboardTab(),
                _buildOrdersTab(),
                _buildProductsTab(),
                _buildFeedbacksTab(),
              ],
            ));
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.gold,
      child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Stats Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      StatCard(
                        label: 'Kullanıcılar',
                        value: _stats['users']?.toString() ?? '0',
                        icon: Icons.people_outline,
                      ),
                      StatCard(
                        label: 'Ürünler',
                        value: _stats['products']?.toString() ?? '0',
                        icon: Icons.inventory_2_outlined,
                      ),
                      StatCard(
                        label: 'Siparişler',
                        value: _stats['orders']?.toString() ?? '0',
                        icon: Icons.shopping_bag_outlined,
                      ),
                      StatCard(
                        label: 'Şikayetler',
                        value: _stats['complaints']?.toString() ?? '0',
                        icon: Icons.report_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // System Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sistem Bilgileri',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _infoRow('Uptime', _formatUptime(_stats['uptime']?.toDouble() ?? 0)),
                          _infoRow('Durum', _isOnline ? 'Çalışıyor' : 'Çevrimdışı',
                              valueColor: _isOnline ? AppTheme.success : AppTheme.error),
                          _infoRow('Port', '10000'),
                          _infoRow('Veritabanı', 'SQLite'),
                          _infoRow('Hosting', 'Lokal'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Control Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _restartBot,
                          icon: const Icon(Icons.restart_alt),
                          label: const Text('Botu Yeniden Başlat'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _loadData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Yenile'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Logs
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sistem Logları',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          LogViewer(logs: _logs),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    if (_orders.isEmpty) {
      return const Center(
        child: Text('Sipariş bulunmuyor', style: TextStyle(color: AppTheme.textSecondary)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        final statusColor = _getStatusColor(order['status'] ?? 'pending_payment');
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('#${order['order_id']}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppTheme.gold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                      child: Text(_getStatusText(order['status'] ?? 'pending_payment'), style: TextStyle(color: statusColor, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Ürün: ${order['product_name'] ?? 'Bilinmiyor'}', style: const TextStyle(color: AppTheme.textPrimary)),
                Text('Tutar: ${order['price'] ?? 0} TL', style: const TextStyle(color: AppTheme.textSecondary)),
                if (order['tracking_code'] != null) Text('Kargo: ${order['tracking_code']}', style: const TextStyle(color: AppTheme.textSecondary)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (order['status'] == 'pending_payment') ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _confirmOrder(order['order_id']),
                          child: const Text('Onayla'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _rejectOrder(order['order_id']),
                          style: OutlinedButton.styleFrom(foregroundColor: AppTheme.error),
                          child: const Text('Reddet'),
                        ),
                      ),
                    ] else if (order['status'] == 'paid') ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showTrackingDialog(order['order_id']),
                          child: const Text('Kargo Ekle'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductsTab() {
    if (_products.isEmpty) {
      return const Center(
        child: Text('Ürün bulunmuyor', style: TextStyle(color: AppTheme.textSecondary)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.inventory_2, color: AppTheme.gold),
            title: Text(product['model'] ?? 'Bilinmiyor', style: const TextStyle(color: AppTheme.textPrimary)),
            subtitle: Text('Fiyat: ${product['price']} TL', style: const TextStyle(color: AppTheme.textSecondary)),
            trailing: product['is_campaign'] == 1
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.gold.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                    child: const Text('KAMPANYALI', style: TextStyle(color: AppTheme.gold, fontSize: 10)),
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildFeedbacksTab() {
    if (_feedbacks.isEmpty) {
      return const Center(
        child: Text('Geri bildirim yok', style: TextStyle(color: AppTheme.textSecondary)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _feedbacks.length,
      itemBuilder: (context, index) {
        final feedback = _feedbacks[index];
        final isComplaint = feedback['type'] == 'sikayet';
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: isComplaint ? AppTheme.error.withValues(alpha: 0.1) : AppTheme.gold.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(isComplaint ? Icons.warning : Icons.lightbulb, color: isComplaint ? AppTheme.error : AppTheme.gold, size: 20),
                    const SizedBox(width: 8),
                    Text(isComplaint ? 'ŞİKAYET' : 'ÖNERİ', style: TextStyle(color: isComplaint ? AppTheme.error : AppTheme.gold, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(feedback['message'] ?? '', style: const TextStyle(color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                Text('Kullanıcı: @${feedback['username'] ?? feedback['user_id']}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'paid': return AppTheme.success;
      case 'shipped': return AppTheme.gold;
      case 'delivered': return AppTheme.success;
      case 'payment_rejected': return AppTheme.error;
      default: return AppTheme.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending_payment': return 'Ödeme Bekliyor';
      case 'paid': return 'Ödendi';
      case 'shipped': return 'Kargoda';
      case 'delivered': return 'Teslim';
      case 'payment_rejected': return 'Reddedildi';
      default: return 'Bilinmiyor';
    }
  }

  Future<void> _confirmOrder(String orderId) async {
    try {
      await ApiService.confirmPayment(orderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sipariş $orderId onaylandı'), backgroundColor: AppTheme.success));
        _loadData();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: AppTheme.error));
    }
  }

  Future<void> _rejectOrder(String orderId) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Sipariş Reddi'),
        content: TextField(
          decoration: const InputDecoration(hintText: 'Red sebebini girin'),
          onChanged: (v) => reason = v,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          TextButton(onPressed: () => Navigator.pop(context, reason ?? 'Reddedildi'), child: const Text('Reddet', style: TextStyle(color: AppTheme.error))),
        ],
      ),
    );
    if (reason != null) {
      try {
        await ApiService.rejectPayment(orderId, reason);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sipariş $orderId reddedildi'), backgroundColor: AppTheme.error));
          _loadData();
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: AppTheme.error));
      }
    }
  }

  Future<void> _showTrackingDialog(String orderId) async {
    final code = await showDialog<String>(
      context: context,
      builder: (context) {
        String trackingCode = '';
        return AlertDialog(
          backgroundColor: AppTheme.bgCard,
          title: const Text('Kargo Takip Kodu'),
          content: TextField(
            decoration: const InputDecoration(hintText: 'Kargo takip kodunu girin'),
            onChanged: (v) => trackingCode = v,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
            TextButton(onPressed: () => Navigator.pop(context, trackingCode), child: const Text('Ekle')),
          ],
        );
      },
    );
    if (code != null && code.isNotEmpty) {
      try {
        await ApiService.setTrackingCode(orderId, code);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kargo kodu eklendi'), backgroundColor: AppTheme.success));
          _loadData();
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: AppTheme.error));
      }
    }
  }
}
