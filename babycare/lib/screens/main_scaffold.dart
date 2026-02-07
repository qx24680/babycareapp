import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'home_screen.dart';
import 'statistics_screen.dart';
import 'chat/chat_screen.dart';
import 'settings_screen.dart';

class MainScaffold extends StatefulWidget {
  final int? babyId;

  const MainScaffold({super.key, this.babyId});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      backgroundColor: AppColors.background,
      tabBar: CupertinoTabBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.9),
        activeColor: AppColors.primary,
        inactiveColor: AppColors.textLight,
        height: 50, // Slightly taller for better touch targets
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            activeIcon: Icon(CupertinoIcons.house_fill),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.graph_square),
            activeIcon: Icon(CupertinoIcons.graph_square_fill),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble_2),
            activeIcon: Icon(CupertinoIcons.chat_bubble_2_fill),
            label: 'AI Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            activeIcon: Icon(CupertinoIcons.settings_solid),
            label: 'Settings',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          navigatorKey: _navigatorKeys[index],
          builder: (context) {
            switch (index) {
              case 0:
                return HomeScreen(title: 'BabyCare', babyId: widget.babyId);
              case 1:
                return const StatisticsScreen();
              case 2:
                return const ChatScreen();
              case 3:
                return const SettingsScreen();
              default:
                return const SizedBox();
            }
          },
        );
      },
    );
  }
}
