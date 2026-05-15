import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _tokenController = TextEditingController();
  bool _isLoading = false;

  void _login() {
    if (_tokenController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen admin token girin')),
      );
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (_tokenController.text == 'boomer-admin-2026') {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, anim, __) => FadeTransition(
              opacity: anim,
              child: const DashboardScreen(),
            ),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Geçersiz token'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
      setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.bgPrimary,
              AppTheme.bgSecondary,
              AppTheme.bgPrimary,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.gold, AppTheme.bronze],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.smart_toy_outlined,
                      size: 40,
                      color: AppTheme.bgPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'BOOMER BRAND',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [AppTheme.goldLight, AppTheme.gold, AppTheme.bronze],
                        ).createShader(const Rect.fromLTWH(0, 0, 200, 40)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Admin Paneli',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 48),
                  TextField(
                    controller: _tokenController,
                    obscureText: true,
                    style: GoogleFonts.inter(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Admin Token',
                      prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.goldDark),
                    ),
                    onSubmitted: (_) => _login(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(AppTheme.bgPrimary),
                              ),
                            )
                          : const Text('Giriş Yap'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
