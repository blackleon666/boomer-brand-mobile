import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/models.dart';
import '../../theme/app_theme.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onConfirm;
  final VoidCallback? onReject;
  final VoidCallback? onAddTracking;

  const OrderCard({
    super.key,
    required this.order,
    this.onConfirm,
    this.onReject,
    this.onAddTracking,
  });

  Color get _statusColor {
    switch (order.status) {
      case 'paid': return AppTheme.success;
      case 'shipped': return AppTheme.gold;
      case 'delivered': return AppTheme.success;
      case 'payment_rejected': return AppTheme.error;
      default: return AppTheme.textSecondary;
    }
  }

  IconData get _statusIcon {
    switch (order.status) {
      case 'paid': return Icons.check_circle_outline;
      case 'shipped': return Icons.local_shipping_outlined;
      case 'delivered': return Icons.done_all;
      case 'payment_rejected': return Icons.cancel_outlined;
      default: return Icons.pending_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.receipt_long, color: AppTheme.gold, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '#${order.orderId}',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.gold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_statusIcon, color: _statusColor, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            order.statusText,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _infoRow('Ürün', order.productName ?? 'Bilinmiyor'),
                _infoRow('Beden/Renk', '${order.size ?? '-'} / ${order.color ?? '-'}'),
                _infoRow('Fiyat', '${order.price.toStringAsFixed(0)} TL'),
                if (order.trackingCode != null) _infoRow('Kargo', order.trackingCode!),
              ],
            ),
          ),
          if (order.canConfirm || order.canSetTracking)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  if (order.canConfirm) ...[
                    Expanded(
                      child: _ActionButton(
                        label: 'Onayla',
                        icon: Icons.check,
                        color: AppTheme.success,
                        onTap: onConfirm,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionButton(
                        label: 'Reddet',
                        icon: Icons.close,
                        color: AppTheme.error,
                        onTap: onReject,
                      ),
                    ),
                  ],
                  if (order.canSetTracking)
                    Expanded(
                      child: _ActionButton(
                        label: 'Kargo Ekle',
                        icon: Icons.local_shipping,
                        color: AppTheme.gold,
                        onTap: onAddTracking,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
          Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}