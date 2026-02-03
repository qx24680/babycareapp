import 'package:flutter/cupertino.dart';
import '../core/theme/app_theme.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      final user = result['user'];
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(
          builder: (context) => HomeScreen(
            title: 'BabyCare',
            userId: user?.id,
            babyId: 1, // TODO: Get actual baby ID from user's profile
          ),
        ),
      );
    } else {
      _showErrorDialog(result['message']);
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _navigateToSignup() {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    // Logo/Title Section
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: const Icon(
                        CupertinoIcons.heart_fill,
                        size: 80,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const Text(
                      'BabyCare',
                      style: AppTypography.h1,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Track every precious moment',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.text.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl * 1.5),

                    // Email Field
                    _buildInputField(
                      controller: _emailController,
                      placeholder: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      prefix: const Icon(
                        CupertinoIcons.mail,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Password Field
                    _buildInputField(
                      controller: _passwordController,
                      placeholder: 'Password',
                      obscureText: _obscurePassword,
                      prefix: const Icon(
                        CupertinoIcons.lock,
                        color: AppColors.primary,
                      ),
                      suffix: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                        child: Icon(
                          _obscurePassword
                              ? CupertinoIcons.eye
                              : CupertinoIcons.eye_slash,
                          color: AppColors.text.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Login Button
                    _isLoading
                        ? const Center(
                            child: CupertinoActivityIndicator(
                              radius: 14,
                              color: AppColors.primary,
                            ),
                          )
                        : CupertinoButton(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            onPressed: _handleLogin,
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                    const SizedBox(height: AppSpacing.md),

                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.text.withValues(alpha: 0.6),
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: _navigateToSignup,
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String placeholder,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? prefix,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.sm,
      ),
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        obscureText: obscureText,
        keyboardType: keyboardType,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        prefix: prefix != null
            ? Padding(
                padding: const EdgeInsets.only(left: AppSpacing.md),
                child: prefix,
              )
            : null,
        suffix: suffix != null
            ? Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: suffix,
              )
            : null,
      ),
    );
  }
}
