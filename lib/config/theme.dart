import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FGColors {
  // Primary (matching web gradient: red-500 to orange-600)
  static const primary = Color(0xFFEF4444);
  static const primaryDark = Color(0xFFDC2626);
  static const orange = Color(0xFFF97316);
  static const orangeDark = Color(0xFFEA580C);

  // Backgrounds
  static const bg = Color(0xFFF4F6F9); // Lighter, modern super-app gray background
  static const surface = Colors.white;
  static const border = Color(0xFFF3F4F6); // Lighter border

  // Text
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);

  // Status colors
  static const pending = Color(0xFFEAB308);
  static const verified = Color(0xFF3B82F6);
  static const dispatched = Color(0xFF8B5CF6);
  static const arrived = Color(0xFF6366F1);
  static const completed = Color(0xFF22C55E);
  static const rejected = Color(0xFFEF4444);

  // Category colors
  static const fire = Color(0xFFEF4444);
  static const flood = Color(0xFF3B82F6);
  static const wind = Color(0xFF6B7280);
  static const infrastructure = Color(0xFF78350F);
  static const pollution = Color(0xFF10B981);

  static Color statusColor(String status) {
    switch (status) {
      case 'pending':
        return pending;
      case 'verified':
        return verified;
      case 'dispatched':
        return dispatched;
      case 'arrived':
        return arrived;
      case 'completed':
        return completed;
      case 'false_report':
        return rejected;
      default:
        return textTertiary;
    }
  }

  static String statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'verified':
        return 'Terverifikasi';
      case 'dispatched':
        return 'Dikirim';
      case 'arrived':
        return 'Tiba di Lokasi';
      case 'completed':
        return 'Selesai';
      case 'false_report':
        return 'Laporan Palsu';
      default:
        return status;
    }
  }
}

class FGTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: FGColors.primary,
        scaffoldBackgroundColor: FGColors.bg,
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: FGColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: FGColors.textPrimary,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // Softer corners
            ),
            textStyle: GoogleFonts.poppins(
              fontSize: 16, // A bit bigger and bolder
              fontWeight: FontWeight.w600,
            ),
            elevation: 0, // Flat design mostly until specified
            shadowColor: Colors.transparent,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: FGColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: FGColors.primary),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.04), // soft shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // gojek style cards
          ),
          color: Colors.white,
          margin: EdgeInsets.zero,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: FGColors.primary,
          unselectedItemColor: FGColors.textTertiary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      );

  // Gradient matching web's from-red-500 to-orange-600
  static const primaryGradient = LinearGradient(
    colors: [FGColors.primary, FGColors.orange],
  );

  static const primaryGradientVertical = LinearGradient(
    colors: [FGColors.primary, FGColors.orange],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Custom modern shadow
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
}
