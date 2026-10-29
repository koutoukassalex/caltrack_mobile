import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'providers/ai_chat_provider.dart';
import 'core/theme.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  runApp(const CaLtrackMobileApp());
}

class CaLtrackMobileApp extends StatelessWidget {
  const CaLtrackMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => AIChatProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
          final profile = appProvider.profile;
          final accentColor = appProvider.currentAccentColor;

          return MaterialApp(
            title: 'CaLtrack AI',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getTheme(isDark: false, accentColor: accentColor),
            darkTheme: AppTheme.getTheme(isDark: true, accentColor: accentColor),
            themeMode: profile.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: appProvider.isLoading
                ? _buildSplashScreen(context, accentColor)
                : (!profile.isOnboarded
                    ? OnboardingScreen(
                        onComplete: () {
                          // Profile is updated in provider, Consumer automatically triggers rebuild
                        },
                      )
                    : const MainNavigationScreen()),
          );
        },
      ),
    );
  }

  Widget _buildSplashScreen(BuildContext context, Color accentColor) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [accentColor, accentColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text('🎯', style: TextStyle(fontSize: 38)),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'CaLtrack AI',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Smart AI Calorie & Macro Tracking',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
