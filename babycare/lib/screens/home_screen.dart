import 'package:flutter/cupertino.dart';
import '../core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          widget.title,
          style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
        ),
        backgroundColor: AppColors.primary,
        border: null,
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppShadows.md,
                ),
                child: Column(
                  children: [
                    Text(
                      'You have pushed the button this many times:',
                      style: AppTypography.body,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '$_counter',
                      style: AppTypography.h1.copyWith(
                        fontSize: 48,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                decoration: BoxDecoration(
                  boxShadow: AppShadows.sm,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: CupertinoButton(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  onPressed: _incrementCounter,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.add, color: AppColors.text),
                      SizedBox(width: AppSpacing.sm),
                      Text('Increment', style: AppTypography.button),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
