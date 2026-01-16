import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'screens/shell.dart';
import 'screens/splash_screen.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/orders_service.dart';
import 'services/parts_service.dart';
import 'services/seller_service.dart';
import 'services/vehicles_service.dart';
import 'state/auth_store.dart';
import 'state/cart_store.dart';

// Modern color palette
const _brandColor = Color(0xFF1A1F36);
const _accentColor = Color(0xFFFF6B35);
const _secondaryColor = Color(0xFF4A90E2);
const _backgroundColor = Color(0xFFFAFBFC);
const _surfaceColor = Color(0xFFFFFFFF);
const _successColor = Color(0xFF10B981);
const _errorColor = Color(0xFFEF4444);

void main() {
  runApp(const AutoPartsApp());
}

class AutoPartsApp extends StatelessWidget {
  const AutoPartsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>(create: (_) => ApiClient()),
        Provider<AuthService>(create: (context) => AuthService(context.read<ApiClient>())),
        Provider<PartsService>(create: (context) => PartsService(context.read<ApiClient>())),
        Provider<OrdersService>(create: (context) => OrdersService(context.read<ApiClient>())),
        Provider<SellerService>(create: (context) => SellerService(context.read<ApiClient>())),
        Provider<VehiclesService>(create: (context) => VehiclesService(context.read<ApiClient>())),
        ChangeNotifierProvider<AuthStore>(
          create: (context) => AuthStore(context.read<AuthService>()),
        ),
        ChangeNotifierProvider<CartStore>(create: (_) => CartStore()),
      ],
      child: MaterialApp(
        title: 'AutoParts Hub',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const SplashScreen(),
      ),
    );
  }
}

ThemeData _buildTheme() {
  final base = ThemeData.light(useMaterial3: true);
  final textTheme = GoogleFonts.interTextTheme(base.textTheme);
  
  final colorScheme = ColorScheme.fromSeed(
    seedColor: _accentColor,
    primary: _brandColor,
    secondary: _accentColor,
    tertiary: _secondaryColor,
    surface: _surfaceColor,
    background: _backgroundColor,
    error: _errorColor,
    brightness: Brightness.light,
  );

  return base.copyWith(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: _backgroundColor,
    textTheme: textTheme.apply(
      bodyColor: _brandColor,
      displayColor: _brandColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _surfaceColor,
      foregroundColor: _brandColor,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withOpacity(0.05),
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: _brandColor,
        fontWeight: FontWeight.w700,
        fontSize: 20,
        letterSpacing: -0.5,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _surfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _accentColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _errorColor, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: _accentColor.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ).copyWith(
        elevation: MaterialStateProperty.resolveWith<double>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) return 0;
            if (states.contains(MaterialState.disabled)) return 0;
            return 4;
          },
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: _surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade100, width: 1),
      ),
      shadowColor: Colors.black.withOpacity(0.08),
      margin: EdgeInsets.zero,
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: _surfaceColor,
      selectedColor: _accentColor.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      labelStyle: textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w500,
      ),
      side: BorderSide.none,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _surfaceColor,
      selectedItemColor: _accentColor,
      unselectedItemColor: Colors.grey.shade500,
      selectedLabelStyle: textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelStyle: textTheme.labelSmall?.copyWith(
        fontSize: 12,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedIconTheme: const IconThemeData(size: 26),
      unselectedIconTheme: IconThemeData(size: 24, color: Colors.grey.shade400),
    ),
  );
}
