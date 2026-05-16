import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../data/models/models.dart' as models;
import '../providers/app_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/order_card.dart';
import '../widgets/feedback_card.dart';
import '../widgets/log_viewer.dart';
import '../widgets/customer_card.dart';

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
    _tabController = TabController(length: 5, vsync: this);
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
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.smart_toy_outlined, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(
              'BOOMER BRAND',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined, size: 20), text: 'Genel'),
            Tab(icon: Icon(Icons.shopping_bag_outlined, size: 20), text: 'Sipariş'),
            Tab(icon: Icon(Icons.inventory_2_outlined, size: 20), text: 'Ürünler'),
            Tab(icon: Icon(Icons.feedback_outlined, size: 20), text: 'Geri Bildirim'),
            Tab(icon: Icon(Icons.people_outline, size: 20), text: 'Müşteriler'),
          ],
        ),
        actions: [
          Consumer<AppProvider>(
            builder: (context, provider, _) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: provider.isOnline ? AppColors.success : AppColors.error,
                      boxShadow: [
                        BoxShadow(
                          color: (provider.isOnline ? AppColors.success : AppColors.error).withValues(alpha: 0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppColors.textSecondary, size: 20),
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
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _DashboardTab(provider: provider),
              _OrdersTab(provider: provider),
              _ProductsTab(provider: provider),
              _FeedbacksTab(provider: provider),
              _CustomersTab(provider: provider),
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
    final botStatus = provider.botStatus;

    return RefreshIndicator(
      onRefresh: provider.refreshData,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle(title: 'Bot Durumu'),
          const SizedBox(height: 12),
          _BotStatusCard(
            isOnline: provider.isOnline,
            botStatus: botStatus,
            onRestart: () => _showRestartDialog(context, provider),
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: 'İstatistikler'),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              StatCard(label: 'Kullanıcılar', value: stats.users.toString(), icon: Icons.people_outline, iconColor: AppColors.primary, isHighlighted: true),
              StatCard(label: 'Ürünler', value: stats.products.toString(), icon: Icons.inventory_2_outlined, iconColor: AppColors.secondary),
              StatCard(label: 'Siparişler', value: stats.orders.toString(), icon: Icons.shopping_cart_outlined, iconColor: AppColors.success),
              StatCard(label: 'Geri Bildirim', value: provider.unreadFeedbacksCount.toString(), icon: Icons.message_outlined, iconColor: AppColors.warning),
            ],
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: 'Sipariş Özeti'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: MiniStatCard(label: 'Bekleyen', value: provider.pendingOrdersCount.toString(), color: AppColors.textSecondary)),
              const SizedBox(width: 8),
              Expanded(child: MiniStatCard(label: 'Ödenen', value: provider.paidOrdersCount.toString(), color: AppColors.success)),
              const SizedBox(width: 8),
              Expanded(child: MiniStatCard(label: 'Kargoda', value: provider.shippedOrdersCount.toString(), color: AppColors.warning)),
              const SizedBox(width: 8),
              Expanded(child: MiniStatCard(label: 'Yeni Müşteri', value: provider.newCustomersCount.toString(), color: AppColors.primary)),
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
        backgroundColor: AppColors.bgCard,
        title: Text('Botu Yeniden Başlat', style: GoogleFonts.inter(color: AppColors.textPrimary)),
        content: const Text('Bot yeniden başlatılacak. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.restartBot();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Bot yeniden başlatılıyor...' : 'Hata oluştu'),
                    backgroundColor: success ? AppColors.primary : AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Evet', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _BotStatusCard extends StatelessWidget {
  final bool isOnline;
  final models.BotStatus botStatus;
  final VoidCallback onRestart;

  const _BotStatusCard({
    required this.isOnline,
    required this.botStatus,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isOnline
              ? [AppColors.success.withValues(alpha: 0.15), AppColors.success.withValues(alpha: 0.05)]
              : [AppColors.error.withValues(alpha: 0.15), AppColors.error.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (isOnline ? AppColors.success : AppColors.error).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isOnline ? AppColors.success : AppColors.error).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isOnline ? Icons.check_circle : Icons.error_outline,
                  color: isOnline ? AppColors.success : AppColors.error,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOnline ? 'Bot Aktif' : 'Bot Çevrimdışı',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOnline ? 'Çalışıyor • ${botStatus.uptimeFormatted}' : 'Yeniden başlatılması gerekebilir',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRestart,
                icon: const Icon(Icons.restart_alt),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.bgElevated,
                  foregroundColor: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (isOnline) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                _StatusItem(icon: Icons.people, label: 'Kullanıcı', value: botStatus.totalUsers.toString()),
                _StatusItem(icon: Icons.message, label: 'Mesaj', value: botStatus.totalMessages.toString()),
                _StatusItem(icon: Icons.timer, label: 'Uptime', value: botStatus.uptimeFormatted),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatusItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppColors.textTertiary),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textTertiary)),
          ],
        ),
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
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.orders.length,
        itemBuilder: (context, index) => OrderCard(
          order: provider.orders[index],
          onConfirm: () => _confirmOrder(context, provider.orders[index].orderId),
          onReject: () => _rejectOrder(context, provider.orders[index].orderId),
          onAddTracking: () => _showTrackingDialog(context, provider.orders[index].orderId),
        ),
      ),
    );
  }

  void _confirmOrder(BuildContext context, String orderId) async {
    final success = await provider.confirmOrder(orderId);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Sipariş onaylandı' : 'Hata oluştu'), backgroundColor: success ? AppColors.success : AppColors.error));
    }
  }

  void _rejectOrder(BuildContext context, String orderId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: Text('Sipariş Reddi', style: GoogleFonts.inter(color: AppColors.textPrimary)),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Red sebebini girin'), style: GoogleFonts.inter(color: AppColors.textPrimary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal', style: TextStyle(color: AppColors.textSecondary))),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.rejectOrder(orderId, controller.text.isEmpty ? 'Reddedildi' : controller.text);
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Sipariş reddedildi' : 'Hata oluştu'), backgroundColor: success ? AppColors.error : AppColors.error));
            },
            child: const Text('Reddet', style: TextStyle(color: AppColors.error)),
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
        backgroundColor: AppColors.bgCard,
        title: Text('Kargo Takip Kodu', style: GoogleFonts.inter(color: AppColors.textPrimary)),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Kargo takip kodunu girin'), style: GoogleFonts.inter(color: AppColors.textPrimary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal', style: TextStyle(color: AppColors.textSecondary))),
          TextButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;
              Navigator.pop(context);
              final success = await provider.setTracking(orderId, controller.text);
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Kargo kodu eklendi' : 'Hata oluştu'), backgroundColor: success ? AppColors.success : AppColors.error));
            },
            child: const Text('Ekle', style: TextStyle(color: AppColors.primary)),
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
          decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.inventory_2, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.displayName, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(product.isCampaign ? 'Kampanyalı' : 'Normal', style: GoogleFonts.inter(fontSize: 12, color: product.isCampaign ? AppColors.primary : AppColors.textSecondary)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${product.displayPrice.toStringAsFixed(0)} TL', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  if (product.isCampaign) ...[
                    const SizedBox(height: 4),
                    Text('${product.price.toStringAsFixed(0)} TL', style: GoogleFonts.inter(fontSize: 12, decoration: TextDecoration.lineThrough, color: AppColors.textSecondary)),
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
      itemBuilder: (context, index) => FeedbackCard(feedback: provider.feedbacks[index]),
    );
  }
}

class _CustomersTab extends StatelessWidget {
  final AppProvider provider;

  const _CustomersTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.customers.isEmpty) {
      return _EmptyState(icon: Icons.people_outline, message: 'Potansiyel müşteri yok');
    }
    return RefreshIndicator(
      onRefresh: provider.refreshData,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.customers.length,
        itemBuilder: (context, index) => CustomerCard(
          customer: provider.customers[index],
          onContact: provider.customers[index].isContacted ? null : () => _markContacted(context, provider.customers[index].id),
        ),
      ),
    );
  }

  void _markContacted(BuildContext context, int customerId) async {
    final success = await provider.markCustomerContacted(customerId);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Müşteri iletişime geçildi olarak işaretlendi' : 'Hata oluştu'), backgroundColor: success ? AppColors.success : AppColors.error));
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary));
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
          Icon(icon, color: AppColors.textTertiary.withValues(alpha: 0.3), size: 64),
          const SizedBox(height: 16),
          Text(message, style: GoogleFonts.inter(fontSize: 16, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}