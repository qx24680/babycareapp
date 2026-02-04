import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'BabyCare',
      theme: AppTheme.theme,
      home: const AppStartup(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Handles app startup and determines whether to show onboarding
class AppStartup extends StatefulWidget {
  const AppStartup({super.key});

  @override
  State<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<AppStartup> {
  bool? _onboardingCompleted;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('onboarding_completed') ?? false;
    setState(() {
      _onboardingCompleted = completed;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    setState(() {
      _onboardingCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking status
    if (_onboardingCompleted == null) {
      return const CupertinoPageScaffold(
        backgroundColor: AppColors.background,
        child: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }

    // Show onboarding or home screen
    if (_onboardingCompleted!) {
      return const HomeScreen(title: 'BabyCare Home');
    } else {
      return OnboardingScreen(onComplete: _completeOnboarding);
    }
  }
}
