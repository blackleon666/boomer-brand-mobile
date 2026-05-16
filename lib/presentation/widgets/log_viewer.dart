import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart' show AppColors;

class LogViewer extends StatelessWidget {
  final List<String> logs;
  final int maxLines;

  const LogViewer({
    super.key,
    required this.logs,
    this.maxLines = 50,
  });

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.article_outlined, color: AppColors.textTertiary.withValues(alpha: 0.5), size: 40),
              const SizedBox(height: 12),
              Text(
                'Log kaydı yok',
                style: GoogleFonts.inter(color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
      );
    }

    final displayLogs = logs.length > maxLines ? logs.sublist(logs.length - maxLines) : logs;

    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: displayLogs.length,
        itemBuilder: (context, index) {
          final log = displayLogs[index];
          final isError = log.contains('ERROR') || log.contains('error') || log.contains('HATA');
          final isWarning = log.contains('WARNING') || log.contains('warning') || log.contains('UYARI');

          Color? textColor;
          if (isError) textColor = AppColors.error;
          else if (isWarning) textColor = AppColors.warning;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              log,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: textColor ?? AppColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
    );
  }
}