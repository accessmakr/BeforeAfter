import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/comparison_provider.dart';
import 'providers/subscription_provider.dart';
import 'screens/home_screen.dart';
import 'services/admob_service.dart';
import 'utils/constants.dart';
import 'utils/error_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorHandler.install();
  AdMobService.initialize();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const BeforeAfterApp());
}

class BeforeAfterApp extends StatefulWidget {
  const BeforeAfterApp({super.key});

  @override
  State<BeforeAfterApp> createState() => _BeforeAfterAppState();
}

class _BeforeAfterAppState extends State<BeforeAfterApp> {
  late final ComparisonProvider _comparisonProvider;
  final SubscriptionProvider _subscriptionProvider = SubscriptionProvider();

  @override
  void initState() {
    super.initState();
    _comparisonProvider = ComparisonProvider(isPro: () => _subscriptionProvider.isPro);
    _subscriptionProvider.addListener(_onSubscriptionChange);
  }

  void _onSubscriptionChange() {
    _comparisonProvider.refresh();
  }

  @override
  void dispose() {
    _subscriptionProvider.removeListener(_onSubscriptionChange);
    _subscriptionProvider.dispose();
    _comparisonProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeforeAfter',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('fr'),
        Locale('de'),
        Locale('pt'),
        Locale('ar'),
        Locale('hi'),
        Locale('ja'),
        Locale('ko'),
        Locale('zh'),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return const Locale('en');
        for (final supported in supportedLocales) {
          if (supported.languageCode == locale.languageCode) {
            return supported;
          }
        }
        return const Locale('en');
      },
      theme: _lightTheme(),
      darkTheme: _darkTheme(),
      themeMode: ThemeMode.system,
      home: HomeScreen(
        comparisonProvider: _comparisonProvider,
        subscriptionProvider: _subscriptionProvider,
      ),
    );
  }

  ThemeData _lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bgPrimary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accent,
        onPrimary: AppColors.textInverse,
        secondary: AppColors.accent,
        surface: AppColors.bgSecondary,
        error: AppColors.error,
      ),
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.textInverse,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
        color: AppColors.bgSecondary,
      ),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bgPrimaryDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentDark,
        onPrimary: AppColors.textInverseDark,
        secondary: AppColors.accentDark,
        surface: AppColors.bgSecondaryDark,
        error: AppColors.errorDark,
      ),
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentDark,
          foregroundColor: AppColors.textInverseDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSecondaryDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
        color: AppColors.bgSecondaryDark,
      ),
    );
  }
}
