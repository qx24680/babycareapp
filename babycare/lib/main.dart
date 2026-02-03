import 'package:flutter/cupertino.dart';
import 'core/theme/app_theme.dart';
import 'screens/login_screen.dart';

// await dotenv.load(fileName: ".env");
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
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
