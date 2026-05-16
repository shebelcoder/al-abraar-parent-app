import 'package:flutter/material.dart';

class AppTheme {
  static const primaryGreen = Color(0xFF166534);
  static const primaryLight = Color(0xFF22C55E);
  static const primaryDark = Color(0xFF14532D);
  static const goldAccent = Color(0xFFF59E0B);
  static const warmBackground = Color(0xFFFAF9F7);
  static const surfaceWhite = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B7280);
  static const errorRed = Color(0xFFEF4444);
  static const successGreen = Color(0xFF10B981);
  static const warningOrange = Color(0xFFF97316);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          primary: primaryGreen,
          secondary: goldAccent,
          surface: warmBackground,
        ),
        scaffoldBackgroundColor: warmBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: surfaceWhite,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
          iconTheme: IconThemeData(color: primaryGreen),
        ),
        cardTheme: CardThemeData(
          color: surfaceWhite,
          elevation: 2,
          shadowColor: Colors.black12,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceWhite,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: primaryGreen, width: 2)),
        ),
      );
}
