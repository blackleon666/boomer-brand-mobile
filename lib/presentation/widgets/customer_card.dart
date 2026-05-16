import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/models.dart' as models;
import '../../theme/app_theme.dart' show AppColors;

class CustomerCard extends StatelessWidget {
  final models.PotentialCustomer customer;
  final VoidCallback? onContact;

  const CustomerCard({
    super.key,
    required this.customer,
    this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    final isNew = !customer.isContacted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isNew 
              ? [AppColors.primary.withValues(alpha: 0.1), AppColors.primary.withValues(alpha: 0.03)]
              : [AppColors.bgCard, AppColors.bgCard],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNew ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person_add_outlined, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.fullName,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '@${customer.username ?? 'bilinmiyor'}',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isNew)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'YENİ',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _InfoRow(icon: Icons.badge_outlined, label: 'Telegram ID', value: customer.telegramId ?? '-'),
                if (customer.phone != null) _InfoRow(icon: Icons.phone_outlined, label: 'Telefon', value: customer.phone!),
                if (customer.email != null) _InfoRow(icon: Icons.email_outlined, label: 'E-posta', value: customer.email!),
                if (customer.notes != null && customer.notes!.isNotEmpty)
                  _InfoRow(icon: Icons.note_outlined, label: 'Notlar', value: customer.notes!),
                _InfoRow(icon: Icons.source_outlined, label: 'Kaynak', value: customer.source),
                if (customer.createdAt != null)
                  _InfoRow(icon: Icons.access_time, label: 'Eklenme', value: _formatDate(customer.createdAt!)),
              ],
            ),
          ),
          if (isNew)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onContact,
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('İletişime Geçildi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success.withValues(alpha: 0.15),
                    foregroundColor: AppColors.success,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}dk';
    if (diff.inHours < 24) return '${diff.inHours}s';
    if (diff.inDays < 7) return '${diff.inDays}g';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textTertiary),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}