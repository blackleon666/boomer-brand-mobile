import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class LogViewer extends StatelessWidget {
  final List<String> logs;

  const LogViewer({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(
        color: const Color(0xFF050505),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.all(12),
      child: logs.isEmpty
          ? Center(
              child: Text(
                'Log bulunamadı',
                style: GoogleFonts.inter(color: AppTheme.textSecondary),
              ),
            )
          : ListView.builder(
              itemCount: logs.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final log = logs[index];
                Color color = AppTheme.textSecondary;
                if (log.contains('ERROR') || log.contains('HATA')) {
                  color = AppTheme.error;
                } else if (log.contains('INFO') || log.contains('BAŞARILI')) {
                  color = AppTheme.success;
                } else if (log.contains('Bot') || log.contains('BOT')) {
                  color = AppTheme.gold;
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    log,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: color,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
    );
  }
}
