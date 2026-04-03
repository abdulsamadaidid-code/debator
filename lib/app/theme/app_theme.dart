import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData light() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F6A67),
          brightness: Brightness.light,
        ).copyWith(
          primary: const Color(0xFF0D5C58),
          secondary: const Color(0xFFCB6B36),
          tertiary: const Color(0xFF255D85),
          surface: const Color(0xFFFFFBF6),
          surfaceContainer: const Color(0xFFF8F0E6),
          surfaceContainerHighest: const Color(0xFFF0E5D8),
          outline: const Color(0xFFD8CABA),
          outlineVariant: const Color(0xFFE4D8C8),
        );

    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF7F1E7),
    );

    final bodyTextTheme = GoogleFonts.plusJakartaSansTextTheme(
      baseTheme.textTheme,
    );

    return baseTheme.copyWith(
      textTheme: bodyTextTheme.copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(
          textStyle: bodyTextTheme.displayLarge,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.4,
        ),
        displayMedium: GoogleFonts.spaceGrotesk(
          textStyle: bodyTextTheme.displayMedium,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.0,
        ),
        headlineLarge: GoogleFonts.spaceGrotesk(
          textStyle: bodyTextTheme.headlineLarge,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          textStyle: bodyTextTheme.headlineMedium,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          textStyle: bodyTextTheme.titleLarge,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        titleMedium: bodyTextTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          height: 1.18,
        ),
        titleSmall: bodyTextTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
        bodyLarge: bodyTextTheme.bodyLarge?.copyWith(
          height: 1.46,
          letterSpacing: -0.05,
        ),
        bodyMedium: bodyTextTheme.bodyMedium?.copyWith(
          height: 1.5,
          letterSpacing: -0.02,
        ),
        bodySmall: bodyTextTheme.bodySmall?.copyWith(height: 1.42),
        labelLarge: bodyTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
        labelMedium: bodyTextTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.94),
        elevation: 0,
        shadowColor: const Color(0xFF132B3A).withValues(alpha: 0.08),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.84),
          ),
        ),
      ),
      chipTheme: baseTheme.chipTheme.copyWith(
        backgroundColor: const Color(0xFFF3ECE3),
        selectedColor: colorScheme.primary.withValues(alpha: 0.12),
        side: BorderSide(color: colorScheme.outlineVariant),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        labelStyle: bodyTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.98),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: bodyTextTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          textStyle: bodyTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        height: 76,
        elevation: 0,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.62),
            size: isSelected ? 24 : 23,
          );
        }),
        indicatorColor: colorScheme.primary.withValues(alpha: 0.12),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        labelTextStyle: WidgetStatePropertyAll(
          bodyTextTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.15,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.transparent,
        useIndicator: true,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.12),
        selectedIconTheme: IconThemeData(color: colorScheme.primary),
        unselectedIconTheme: IconThemeData(
          color: colorScheme.onSurface.withValues(alpha: 0.64),
        ),
        selectedLabelTextStyle: bodyTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
        unselectedLabelTextStyle: bodyTextTheme.labelLarge?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.72),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.82),
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF13363F),
        contentTextStyle: bodyTextTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
