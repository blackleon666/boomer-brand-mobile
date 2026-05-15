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

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic> _stats = {};
  List<String> _logs = [];
  bool _isLoading = true;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final health = await ApiService.checkHealth();
      final stats = await ApiService.getStats();
      final logs = await ApiService.getLogs();
      setState(() {
        _isOnline = health;
        _stats = stats;
        _logs = logs;
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
          : RefreshIndicator(
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
}
