import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../theme/app_theme.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _tokenController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  void _login() {
    if (_tokenController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen admin token girin'), backgroundColor: AppColors.error));
      return;
    }
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (_tokenController.text == AppConstants.adminToken) {
        Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, anim, __) => FadeTransition(opacity: anim, child: const DashboardScreen()), transitionDuration: const Duration(milliseconds: 400)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Geçersiz token'), backgroundColor: AppColors.error));
      }
      setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.bgDark, AppColors.bgCard, AppColors.bgDark])),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 2)],
                      ),
                      child: const Icon(Icons.smart_toy_outlined, size: 44, color: Colors.white),
                    ),
                    const SizedBox(height: 32),
                    Text('BOOMER BRAND', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -1)),
                    const SizedBox(height: 8),
                    Text('ADMIN PANEL', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, letterSpacing: 3, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 56),
                    Container(
                      decoration: BoxDecoration(color: AppColors.bgElevated, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                      child: TextField(
                        controller: _tokenController,
                        obscureText: _obscureText,
                        style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Admin Token',
                          hintStyle: GoogleFonts.inter(color: AppColors.textTertiary),
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                          suffixIcon: IconButton(icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: AppColors.textSecondary), onPressed: () => setState(() => _obscureText = !_obscureText)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        ),
                        onSubmitted: (_) => _login(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                        child: _isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white))) : Text('Giriş Yap', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 40, height: 1, color: AppColors.border),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('Modern Admin', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textTertiary, letterSpacing: 1))),
                        Container(width: 40, height: 1, color: AppColors.border),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}