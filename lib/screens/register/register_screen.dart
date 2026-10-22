import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../../constants/app_urls.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/prefs.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/snackbar_helper.dart';
import '../../utils/url_helper.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/or_divider.dart';
import '../home/home_route.dart';
import '../login/login_screen.dart';
import 'widgets/login_instead_button.dart';
import 'widgets/register_confirm_field.dart';
import 'widgets/register_email_field.dart';
import 'widgets/register_password_field.dart';
import 'widgets/register_username_field.dart';
import 'widgets/terms_checkbox_row.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  final _confirmFocus = FocusNode();

  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _acceptTerms = false;
  bool _remember = true;
  bool _busy = false;
  bool _prefsLoaded = false;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => _openUrl(AppUrls.terms);
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => _openUrl(AppUrls.privacy);
    _loadRememberPreference();
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    _confirmFocus.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
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

  Future<void> _openUrl(String url) async {
    final err = await UrlHelper.openExternal(url);
    if (!mounted) return;
    if (err != null) SnackbarHelper.error(context, err);
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      SnackbarHelper.error(
        context,
        'Please accept the Terms & Privacy Policy to continue.',
      );
      return;
    }

    setState(() => _busy = true);

    try {
      await AuthService.instance.register(
        email: _emailCtrl.text,
        password: _passCtrl.text,
        username: _usernameCtrl.text.trim(),
        rememberMe: _remember,
      );
      if (!mounted) return;
      SnackbarHelper.success(
        context,
        'Account created! Welcome to Pixel Quest.',
      );
      _goHome();
    } on UsernameTakenException catch (e) {
      if (!mounted) return;
      SnackbarHelper.error(
        context,
        'Username "${e.username}" is already taken. Try another.',
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      SnackbarHelper.error(context, AuthService.instance.messageFor(e));
    } on FirebaseException catch (e) {
      if (!mounted) return;
      SnackbarHelper.error(
        context,
        AuthService.instance.messageForFirestore(e),
      );
    } catch (e, st) {
      debugPrint('🔴 Register error: $e\n$st');
      if (!mounted) return;
      SnackbarHelper.error(context, 'Something went wrong. Please try again.');
    }
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => homeRoute()),
      (route) => false,
    );
  }

  void _goLogin() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Pixel.arrowleft, size: 18),
          onPressed: _busy ? null : _goLogin,
        ),
      ),
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
                  title: 'CREATE ACCOUNT',
                  subtitle: 'Start your quest. Small habits, big adventures.',
                ),

                const SizedBox(height: AppSizes.xl),

                RegisterUsernameField(
                  controller: _usernameCtrl,
                  enabled: !_busy,
                  onSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_emailFocus),
                ),

                const SizedBox(height: AppSizes.lg),

                RegisterEmailField(
                  controller: _emailCtrl,
                  focusNode: _emailFocus,
                  enabled: !_busy,
                  onSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_passFocus),
                ),

                const SizedBox(height: AppSizes.lg),

                RegisterPasswordField(
                  controller: _passCtrl,
                  focusNode: _passFocus,
                  obscure: _obscurePass,
                  enabled: !_busy,
                  onToggleObscure: () =>
                      setState(() => _obscurePass = !_obscurePass),
                  onSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_confirmFocus),
                  showRules: true,
                ),

                const SizedBox(height: AppSizes.lg),

                RegisterConfirmField(
                  controller: _confirmCtrl,
                  focusNode: _confirmFocus,
                  obscure: _obscureConfirm,
                  enabled: !_busy,
                  onToggleObscure: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  passwordProvider: () => _passCtrl.text,
                  onSubmitted: (_) => _register(),
                ),

                const SizedBox(height: AppSizes.md),

                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _remember,
                        onChanged: _busy
                            ? null
                            : (v) => setState(() => _remember = v ?? false),
                        activeColor: AppColors.primary,
                        checkColor: AppColors.textOnPrimary,
                        side: const BorderSide(color: AppColors.textSecondary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    const Flexible(
                      child: Text(
                        'Remember me',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.lg),

                TermsCheckboxRow(
                  acceptTerms: _acceptTerms,
                  busy: _busy,
                  onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                  termsRecognizer: _termsRecognizer,
                  privacyRecognizer: _privacyRecognizer,
                ),

                const SizedBox(height: AppSizes.xl),

                LoadingButton(
                  busy: _busy,
                  label: 'REGISTER',
                  onPressed: _register,
                ),

                const SizedBox(height: AppSizes.lg),

                const OrDivider(),

                const SizedBox(height: AppSizes.lg),

                LoginInsteadButton(busy: _busy, onPressed: _goLogin),

                const SizedBox(height: AppSizes.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
