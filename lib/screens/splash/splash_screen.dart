import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pixel_quest/widgets/permission_rationale_dialog.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../../services/splash_router.dart';
import '../../services/permission_bootstrapper.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text_styles.dart';
import '../home/home_route.dart';
import '../login/login_screen.dart';
import '../register/register_screen.dart';
import 'widgets/splash_bottom_section.dart';
import 'widgets/splash_fitted_text.dart';
import 'widgets/splash_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _checking = true;
  bool _showAuthButtons = false;

  final _router = SplashRouter.production();

  @override
  void initState() {
    super.initState();
    _decideStartDestination();

    // Request permissions AFTER the first frame renders, so the user
    // sees the Pixel Quest splash before any Android dialogs appear.
    // Guarded by needsPermissions() so already-granted permissions are
    // not re-prompted on every launch.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final needs = await PermissionBootstrapper.needsPermissions();
        if (!mounted) return; // ← guard after await
        if (!needs) return;

        // Show the branded rationale dialog BEFORE the system prompts.
        final allowed = await PermissionRationaleDialog.show(
          context: context,
          title: 'KEEP YOUR STREAK',
          description:
              'Pixel Quest needs notification and battery permissions '
              'to send reminders and keep your streak alive in the background.',
          icon: Pixel.notification,
        );
        if (!mounted) return; // ← guard after await
        if (allowed != true) return;

        await PermissionBootstrapper.requestAll();
      } catch (e) {
        debugPrint('⚠️ Permission request failed: $e');
      }
    });
  }

  Future<void> _decideStartDestination() async {
    final results = await Future.wait([
      _router.resolve(),
      Future.delayed(const Duration(milliseconds: 600)),
    ]);
    final outcome = results[0] as SplashOutcome;

    if (!mounted) return;

    switch (outcome) {
      case SplashOutcome.showAuthButtons:
        setState(() {
          _checking = false;
          _showAuthButtons = true;
        });
      case SplashOutcome.goToLogin:
        _goTo(const LoginScreen());
      case SplashOutcome.goToHome:
        _goTo(homeRoute());
    }
  }

  void _goTo(Widget screen) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.screenPaddingH,
          ),
          child: Column(
            children: [
              const Spacer(flex: 3),
              const SplashLogo(),
              const SizedBox(height: AppSizes.xl),
              const SplashFittedText(
                text: 'PIXEL QUEST',
                style: AppTextStyles.display,
              ),
              const SizedBox(height: AppSizes.md),
              const SplashFittedText(
                text: 'SMALL HABITS BIG ADVENTURES',
                style: AppTextStyles.subheading,
              ),
              const Spacer(flex: 4),
              SplashBottomSection(
                checking: _checking,
                showAuthButtons: _showAuthButtons,
                onLogin: () => _goTo(const LoginScreen()),
                onRegister: () => _goTo(const RegisterScreen()),
              ),
              const SizedBox(height: AppSizes.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
