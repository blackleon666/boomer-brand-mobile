import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:boomer_brand_app/main.dart';
import 'package:boomer_brand_app/presentation/providers/app_provider.dart';
import 'package:boomer_brand_app/presentation/screens/login_screen.dart';
import 'package:boomer_brand_app/theme/app_theme.dart';

void main() {
  group('BoomerApp Tests', () {
    testWidgets('App starts and shows login screen', (WidgetTester tester) async {
      await tester.pumpWidget(const BoomerApp());
      await tester.pumpAndSettle();
      
      expect(find.text('BOOMER BRAND'), findsOneWidget);
      expect(find.text('ADMIN PANEL'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Login screen has token input field', (WidgetTester tester) async {
      await tester.pumpWidget(const BoomerApp());
      await tester.pumpAndSettle();
      
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Admin Token'), findsOneWidget);
    });

    testWidgets('Login button is present', (WidgetTester tester) async {
      await tester.pumpWidget(const BoomerApp());
      await tester.pumpAndSettle();
      
      expect(find.text('Giriş Yap'), findsOneWidget);
    });

    testWidgets('Token field is obscured', (WidgetTester tester) async {
      await tester.pumpWidget(const BoomerApp());
      await tester.pumpAndSettle();
      
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);
    });
  });

  group('Theme Tests', () {
    test('AppTheme has correct primary color', () {
      expect(AppColors.primary, equals(const Color(0xFF6366F1)));
    });

    test('AppTheme has correct background color', () {
      expect(AppColors.bgDark, equals(const Color(0xFF0F0F14)));
    });

    test('AppTheme has correct success color', () {
      expect(AppColors.success, equals(const Color(0xFF10B981)));
    });

    test('AppTheme has correct error color', () {
      expect(AppColors.error, equals(const Color(0xFFEF4444)));
    });

    test('Dark theme is configured correctly', () {
      final theme = AppTheme.darkTheme;
      expect(theme.brightness, equals(Brightness.dark));
      expect(theme.useMaterial3, isTrue);
    });
  });
}