import 'package:flutter/cupertino.dart';
import '../core/theme/app_theme.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    // Validation
    if (_fullNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showErrorDialog('Please fill in all required fields');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.register(
      email: _emailController.text,
      password: _passwordController.text,
      fullName: _fullNameController.text,
      phoneNumber: _phoneController.text.isEmpty
          ? null
          : _phoneController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      _showSuccessDialog();
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

  void _showSuccessDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Success'),
        content: const Text('Account created successfully! Please login.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to login
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.primary,
        middle: const Text('Create Account'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(CupertinoIcons.back),
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: AppSpacing.lg),

                  // Full Name Field
                  _buildInputField(
                    controller: _fullNameController,
                    placeholder: 'Full Name',
                    keyboardType: TextInputType.name,
                    prefix: const Icon(
                      CupertinoIcons.person,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

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

                  // Phone Number Field (Optional)
                  _buildInputField(
                    controller: _phoneController,
                    placeholder: 'Phone Number (Optional)',
                    keyboardType: TextInputType.phone,
                    prefix: const Icon(
                      CupertinoIcons.phone,
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
                  const SizedBox(height: AppSpacing.md),

                  // Confirm Password Field
                  _buildInputField(
                    controller: _confirmPasswordController,
                    placeholder: 'Confirm Password',
                    obscureText: _obscureConfirmPassword,
                    prefix: const Icon(
                      CupertinoIcons.lock,
                      color: AppColors.primary,
                    ),
                    suffix: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(
                          () => _obscureConfirmPassword = !_obscureConfirmPassword,
                        );
                      },
                      child: Icon(
                        _obscureConfirmPassword
                            ? CupertinoIcons.eye
                            : CupertinoIcons.eye_slash,
                        color: AppColors.text.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Password Requirements
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Text(
                      'Password must be at least 6 characters',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.text.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Sign Up Button
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
                          onPressed: _handleSignup,
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                  const SizedBox(height: AppSpacing.xl),

                  // Terms and Privacy
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Text(
                      'By creating an account, you agree to our Terms of Service and Privacy Policy',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.text.withValues(alpha: 0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ]),
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
