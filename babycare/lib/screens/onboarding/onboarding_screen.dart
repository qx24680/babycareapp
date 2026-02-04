import 'package:flutter/cupertino.dart';
import '../../core/theme/app_theme.dart';
import '../../models/onboarding_data.dart';
import 'screens/welcome_screen.dart';
import 'screens/baby_info_screen.dart';
import 'screens/tracking_setup_screen.dart';
import 'screens/today_plan_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/ai_intro_screen.dart';
import 'screens/goals_screen.dart';
import 'widgets/onboarding_progress.dart';

/// Main onboarding flow controller
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  OnboardingData _data = const OnboardingData();

  // Total screens in reduced flow
  static const int _totalScreens = 7;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _updateData(OnboardingData newData) {
    setState(() {
      _data = newData;
    });
  }

  void _nextPage() {
    if (_currentPage < _totalScreens - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _completeOnboarding() {
    // TODO: Save onboarding data to database/preferences
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // Progress indicator (hide on first screen)
            if (_currentPage > 0)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: OnboardingProgress(
                  currentStep: _currentPage,
                  totalSteps: _totalScreens,
                  onStepTap: (step) {
                    if (step < _currentPage) _goToPage(step);
                  },
                ),
              ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  // Screen 1: Welcome - What do you need help with?
                  WelcomeScreen(
                    data: _data,
                    onDataChanged: _updateData,
                    onNext: _nextPage,
                  ),

                  // Screen 2: Add Baby (Minimal)
                  BabyInfoScreen(
                    data: _data,
                    onDataChanged: _updateData,
                    onNext: _nextPage,
                    onBack: _previousPage,
                  ),

                  // Screen 3: Quick Setup - Tracking Buttons
                  TrackingSetupScreen(
                    data: _data,
                    onDataChanged: _updateData,
                    onNext: _nextPage,
                    onBack: _previousPage,
                  ),

                  // Screen 4: Today's Plan (immediate payoff)
                  TodayPlanScreen(
                    data: _data,
                    onNext: _nextPage,
                    onBack: _previousPage,
                  ),

                  // Screen 5: Reminders
                  RemindersScreen(
                    data: _data,
                    onDataChanged: _updateData,
                    onNext: _nextPage,
                    onBack: _previousPage,
                  ),

                  // Screen 6: AI Assistant + Smart Features (combined)
                  AiIntroScreen(
                    data: _data,
                    onDataChanged: _updateData,
                    onNext: _nextPage,
                    onBack: _previousPage,
                  ),

                  // Screen 7: Goals (light)
                  GoalsScreen(
                    data: _data,
                    onDataChanged: _updateData,
                    onComplete: _completeOnboarding,
                    onBack: _previousPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
