import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For some icon/colors if customized, but trying to stick to Cupertino
import '../core/theme/app_theme.dart';
import 'reminders_list_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(middle: Text('Settings')),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Account Section
              CupertinoListSection.insetGrouped(
                header: const Text('Account'),
                children: [
                  CupertinoListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.person_fill,
                        color: CupertinoColors.white,
                        size: 20,
                      ),
                    ),
                    title: const Text('Profile'),
                    subtitle: const Text('Baby\'s Name'),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () {
                      _showPlaceholderAction(context, 'Edit Profile');
                    },
                  ),
                ],
              ),

              // General Section
              CupertinoListSection.insetGrouped(
                header: const Text('General'),
                children: [
                  CupertinoListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: CupertinoColors.activeOrange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        CupertinoIcons.bell_fill,
                        color: CupertinoColors.white,
                        size: 20,
                      ),
                    ),
                    title: const Text('Notifications'),
                    trailing: CupertinoSwitch(
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                    ),
                  ),
                  CupertinoListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemPurple,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        CupertinoIcons.alarm,
                        color: CupertinoColors.white,
                        size: 20,
                      ),
                    ),
                    title: const Text('Reminders'),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => const RemindersListScreen(),
                        ),
                      );
                    },
                  ),
                  CupertinoListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBlue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        CupertinoIcons.globe,
                        color: CupertinoColors.white,
                        size: 20,
                      ),
                    ),
                    title: const Text('Language'),
                    trailing: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'English',
                          style: TextStyle(
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                        CupertinoListTileChevron(),
                      ],
                    ),
                    onTap: () {
                      _showPlaceholderAction(context, 'Change Language');
                    },
                  ),
                ],
              ),

              // Support & About Section
              CupertinoListSection.insetGrouped(
                header: const Text('Support & About'),
                children: [
                  CupertinoListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGreen,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        CupertinoIcons.question_circle_fill,
                        color: CupertinoColors.white,
                        size: 20,
                      ),
                    ),
                    title: const Text('Support'),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () {
                      _showPlaceholderAction(context, 'Open Support');
                    },
                  ),
                  CupertinoListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        CupertinoIcons.doc_text_fill,
                        color: CupertinoColors.white,
                        size: 20,
                      ),
                    ),
                    title: const Text('Terms of Use'),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () {
                      _showPlaceholderAction(context, 'Open Terms of Use');
                    },
                  ),
                  CupertinoListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        CupertinoIcons.hand_raised_fill,
                        color: CupertinoColors.white,
                        size: 20,
                      ),
                    ),
                    title: const Text('Privacy Policy'),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () {
                      _showPlaceholderAction(context, 'Open Privacy Policy');
                    },
                  ),
                ],
              ),

              // Danger Zone
              CupertinoListSection.insetGrouped(
                children: [
                  CupertinoListTile(
                    title: const Text(
                      'Sign Out',
                      style: TextStyle(color: CupertinoColors.destructiveRed),
                    ),
                    onTap: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) => CupertinoAlertDialog(
                          title: const Text('Sign Out'),
                          content: const Text(
                            'Are you sure you want to sign out?',
                          ),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text('Cancel'),
                              onPressed: () => Navigator.pop(context),
                            ),
                            CupertinoDialogAction(
                              isDestructiveAction: true,
                              child: const Text('Sign Out'),
                              onPressed: () {
                                Navigator.pop(context);
                                // TODO: Implement sign out logic
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Text(
                'Version 1.0.0',
                style: AppTypography.caption.copyWith(
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlaceholderAction(BuildContext context, String actionName) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(actionName),
        content: const Text('This feature is coming soon.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
