import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/order_card.dart';
import '../widgets/feedback_card.dart';
import '../widgets/log_viewer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadAllData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgSecondary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'BOOMER BRAND',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.gold,
            letterSpacing: -0.5,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.gold,
          indicatorWeight: 3,
          labelColor: AppTheme.gold,
          unselectedLabelColor: AppTheme.textSecondary,
          labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined, size: 20), text: 'Genel'),
            Tab(icon: Icon(Icons.shopping_bag_outlined, size: 20), text: 'Siparişler'),
            Tab(icon: Icon(Icons.inventory_2_outlined, size: 20), text: 'Ürünler'),
            Tab(icon: Icon(Icons.feedback_outlined, size: 20), text: 'Geri Bildirim'),
          ],
        ),
        actions: [
          Consumer<AppProvider>(
            builder: (context, provider, _) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: provider.isOnline ? AppTheme.success : AppTheme.error,
                      boxShadow: [
                        BoxShadow(
                          color: (provider.isOnline ? AppTheme.success : AppTheme.error).withValues(alpha: 0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppTheme.textSecondary),
                    onPressed: () => provider.refreshData(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          if (provider.state == LoadingState.loading && provider.stats.users == 0) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.gold),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _DashboardTab(provider: provider),
              _OrdersTab(provider: provider),
              _ProductsTab(provider: provider),
              _FeedbacksTab(provider: provider),
            ],
          );
        },
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  final AppProvider provider;

  const _DashboardTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final stats = provider.stats;

    return RefreshIndicator(
      onRefresh: provider.refreshData,
      color: AppTheme.gold,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              StatCard(label: 'Kullanıcılar', value: stats.users.toString(), icon: Icons.people_outline, iconColor: AppTheme.gold),
              StatCard(label: 'Ürünler', value: stats.products.toString(), icon: Icons.inventory_2_outlined, iconColor: AppTheme.bronze),
              StatCard(label: 'Siparişler', value: stats.orders.toString(), icon: Icons.shopping_cart_outlined, iconColor: AppTheme.success),
              StatCard(label: 'Geri Bildirim', value: provider.unreadFeedbacksCount.toString(), icon: Icons.message_outlined, iconColor: AppTheme.error),
            ],
          ),
          const SizedBox(height: 20),
          _SectionTitle(title: 'Sipariş Durumları'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: MiniStatCard(label: 'Bekleyen', value: provider.pendingOrdersCount.toString(), color: AppTheme.textSecondary)),
              const SizedBox(width: 8),
              Expanded(child: MiniStatCard(label: 'Ödenen', value: provider.paidOrdersCount.toString(), color: AppTheme.success)),
              const SizedBox(width: 8),
              Expanded(child: MiniStatCard(label: 'Kargoda', value: provider.shippedOrdersCount.toString(), color: AppTheme.gold)),
            ],
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: 'Sistem Bilgileri'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                _InfoRow(label: 'Durum', value: provider.isOnline ? 'Çalışıyor' : 'Çevrimdışı', valueColor: provider.isOnline ? AppTheme.success : AppTheme.error),
                _InfoRow(label: 'Uptime', value: stats.uptimeFormatted),
                _InfoRow(label: 'API Port', value: '10000'),
                _InfoRow(label: 'Veritabanı', value: 'SQLite'),
                _InfoRow(label: 'Hosting', value: 'Local'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _OutlineButton(
                  label: 'Botu Yeniden Başlat',
                  icon: Icons.restart_alt,
                  onTap: () => _showRestartDialog(context, provider),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: 'Sistem Logları'),
          const SizedBox(height: 12),
          LogViewer(logs: provider.logs),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showRestartDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: Text('Botu Yeniden Başlat', style: GoogleFonts.inter(color: AppTheme.textPrimary)),
        content: const Text('Bot yeniden başlatılacak. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.restartBot();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bot yeniden başlatılıyor...'), backgroundColor: AppTheme.goldDark),
                );
              }
            },
            child: const Text('Evet', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

class _OrdersTab extends StatelessWidget {
  final AppProvider provider;

  const _OrdersTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.orders.isEmpty) {
      return _EmptyState(icon: Icons.shopping_bag_outlined, message: 'Sipariş bulunmuyor');
    }

    return RefreshIndicator(
      onRefresh: provider.refreshData,
      color: AppTheme.gold,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.orders.length,
        itemBuilder: (context, index) {
          final order = provider.orders[index];
          return OrderCard(
            order: order,
            onConfirm: () => _confirmOrder(context, order.orderId),
            onReject: () => _rejectOrder(context, order.orderId),
            onAddTracking: () => _showTrackingDialog(context, order.orderId),
          );
        },
      ),
    );
  }

  void _confirmOrder(BuildContext context, String orderId) async {
    final success = await provider.confirmOrder(orderId);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Sipariş onaylandı' : 'Hata oluştu'),
          backgroundColor: success ? AppTheme.success : AppTheme.error,
        ),
      );
    }
  }

  void _rejectOrder(BuildContext context, String orderId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: Text('Sipariş Reddi', style: GoogleFonts.inter(color: AppTheme.textPrimary)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Red sebebini girin'),
          style: GoogleFonts.inter(color: AppTheme.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.rejectOrder(orderId, controller.text.isEmpty ? 'Reddedildi' : controller.text);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Sipariş reddedildi' : 'Hata oluştu'),
                    backgroundColor: success ? AppTheme.error : AppTheme.error,
                  ),
                );
              }
            },
            child: const Text('Reddet', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }

  void _showTrackingDialog(BuildContext context, String orderId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: Text('Kargo Takip Kodu', style: GoogleFonts.inter(color: AppTheme.textPrimary)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Kargo takip kodunu girin'),
          style: GoogleFonts.inter(color: AppTheme.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;
              Navigator.pop(context);
              final success = await provider.setTracking(orderId, controller.text);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Kargo kodu eklendi' : 'Hata oluştu'),
                    backgroundColor: success ? AppTheme.success : AppTheme.error,
                  ),
                );
              }
            },
            child: const Text('Ekle', style: TextStyle(color: AppTheme.gold)),
          ),
        ],
      ),
    );
  }
}

class _ProductsTab extends StatelessWidget {
  final AppProvider provider;

  const _ProductsTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.products.isEmpty) {
      return _EmptyState(icon: Icons.inventory_2_outlined, message: 'Ürün bulunmuyor');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.products.length,
      itemBuilder: (context, index) {
        final product = provider.products[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.inventory_2, color: AppTheme.gold),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.displayName,
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.isCampaign ? 'Kampanyalı' : 'Normal',
                      style: GoogleFonts.inter(fontSize: 12, color: product.isCampaign ? AppTheme.gold : AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${product.displayPrice.toStringAsFixed(0)} TL',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.gold),
                  ),
                  if (product.isCampaign) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${product.price.toStringAsFixed(0)} TL',
                      style: GoogleFonts.inter(fontSize: 12, decoration: TextDecoration.lineThrough, color: AppTheme.textSecondary),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FeedbacksTab extends StatelessWidget {
  final AppProvider provider;

  const _FeedbacksTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.feedbacks.isEmpty) {
      return _EmptyState(icon: Icons.feedback_outlined, message: 'Geri bildirim yok');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.feedbacks.length,
      itemBuilder: (context, index) {
        return FeedbackCard(feedback: provider.feedbacks[index]);
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
          Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: valueColor ?? AppTheme.textPrimary)),
        ],
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _OutlineButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.textSecondary, size: 20),
              const SizedBox(width: 8),
              Text(label, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.textSecondary.withValues(alpha: 0.3), size: 64),
          const SizedBox(height: 16),
          Text(message, style: GoogleFonts.inter(fontSize: 16, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}