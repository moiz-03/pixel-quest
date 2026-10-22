import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/prefs.dart';
import '../../theme/app_sizes.dart';
import '../../utils/snackbar_helper.dart';
import '../../utils/validators.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/or_divider.dart';
import '../home/home_route.dart';
import '../register/register_screen.dart';
import 'widgets/login_email_field.dart';
import 'widgets/login_password_field.dart';
import 'widgets/register_button.dart';
import 'widgets/remember_forgot_row.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _passFocus = FocusNode();

  bool _obscure = true;
  bool _busy = false;
  bool _remember = true;
  bool _prefsLoaded = false;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _loadRememberPreference();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  Future<void> _loadRememberPreference() async {
    final remembered = await Prefs.rememberMe();
    if (!mounted || _prefsLoaded) return;
    setState(() {
      _remember = remembered;
      _prefsLoaded = true;
    });
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _busy = true);

    try {
      await AuthService.instance.signIn(
        email: _emailCtrl.text,
        password: _passCtrl.text,
        rememberMe: _remember,
      );
      if (!mounted) return;
      _goHome();
    } on FirebaseAuthException catch (e) {
      SnackbarHelper.error(context, AuthService.instance.messageFor(e));
    } catch (_) {
      SnackbarHelper.error(context, 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || Validators.email(email) != null) {
      SnackbarHelper.error(
        context,
        'Enter your email above to reset the password.',
      );
      return;
    }

    setState(() => _busy = true);
    try {
      await AuthService.instance.sendPasswordReset(email);
      if (!mounted) return;
      SnackbarHelper.success(context, 'Password reset link sent to $email');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      SnackbarHelper.error(context, AuthService.instance.messageFor(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => homeRoute()),
      (route) => false,
    );
  }

  void _goRegister() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.screenPaddingH,
            vertical: AppSizes.screenPaddingV,
          ),
          child: Form(
            key: _formKey,
            autovalidateMode: _submitted
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSizes.md),

                const AuthHeader(
                  title: 'WELCOME BACK',
                  subtitle: 'Continue your adventure.',
                ),

                const SizedBox(height: AppSizes.xl),

                LoginEmailField(
                  controller: _emailCtrl,
                  enabled: !_busy,
                  onSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_passFocus),
                ),

                const SizedBox(height: AppSizes.lg),

                LoginPasswordField(
                  controller: _passCtrl,
                  focusNode: _passFocus,
                  obscure: _obscure,
                  enabled: !_busy,
                  onToggleObscure: () => setState(() => _obscure = !_obscure),
                  onSubmitted: (_) => _login(),
                ),

                const SizedBox(height: AppSizes.sm),

                RememberForgotRow(
                  remember: _remember,
                  busy: _busy,
                  onRememberChanged: (v) =>
                      setState(() => _remember = v ?? false),
                  onForgotPassword: _forgotPassword,
                ),

                const SizedBox(height: AppSizes.xl),

                LoadingButton(busy: _busy, label: 'LOGIN', onPressed: _login),

                const SizedBox(height: AppSizes.lg),

                const OrDivider(),

                const SizedBox(height: AppSizes.lg),

                RegisterButton(busy: _busy, onPressed: _goRegister),

                const SizedBox(height: AppSizes.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
