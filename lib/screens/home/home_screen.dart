import 'package:flutter/material.dart';
import 'package:pixel_quest/screens/home/widgets/stats/stats_screen.dart';
import 'package:provider/provider.dart';

import '../../models/quest.dart';
import '../../models/tier.dart';
import '../../theme/app_colors.dart';
import '../../utils/snackbar_helper.dart';
import '../../viewmodels/home_view_model.dart';
import '../../widgets/quest_sheet/quest_sheet.dart';
import '../login/login_screen.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/dashboard_tab.dart';
import 'widgets/delete_account_dialog.dart';
import 'widgets/logout_confirm_dialog.dart';
import 'widgets/settings_tab.dart';
import 'widgets/shop_sheet.dart';
import 'widgets/tier_up_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    // Show "streak saved" snackbar once per session if a freeze was used.
    if (vm.freezeConsumedThisSession) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        SnackbarHelper.success(
          context,
          '🧊 A streak freeze saved your streak!',
        );
        vm.acknowledgeFreezeConsumed();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (vm.syncError != null)
              MaterialBanner(
                content: const Text(
                  'Sync unavailable. Your data may be out of date.',
                ),
                leading: const Icon(Icons.cloud_off),
                actions: [
                  TextButton(
                    onPressed: () => vm.retrySync(),
                    child: const Text('RETRY'),
                  ),
                ],
              ),
            Expanded(
              child: IndexedStack(
                index: vm.tabIndex,
                children: [
                  DashboardTab(
                    level: vm.level,
                    currentXp: vm.currentXp,
                    xpToNext: vm.xpToNext,
                    streak: vm.streak,
                    totalXp: vm.totalXp,
                    availableXp: vm.availableXp,
                    streakHistory: vm.streakHistory,
                    loaded: vm.loaded,
                    quests: vm.quests,
                    onAddQuest: () => _onAddQuest(context),
                    onEditQuest: (quest) => _onEditQuest(context, quest),
                    onToggleQuest: (quest) => _onToggleQuest(context, quest),
                    onSettingsTap: () => vm.setTabIndex(2),
                    onOpenShop: () => _openShop(context),
                    suggestedQuest: vm.suggestedQuest,
                    suggestedQuestStreak: vm.suggestedQuestStreak,
                    onAcceptSuggestion: vm.acceptSuggestion,
                    onDismissSuggestion: vm.dismissSuggestion,
                  ),
                  StatsScreen(
                    level: vm.level,
                    totalXp: vm.totalXp,
                    currentStreak: vm.streak,
                    streakHistory: vm.streakHistory,
                    quests: vm.quests,
                    loaded: vm.loaded,
                  ),
                  SettingsTab(
                    username: vm.username,
                    loggingOut: vm.loggingOut,
                    deletingAccount: vm.deletingAccount,
                    onLogout: () => _logout(context),
                    onDeleteAccount: () => _deleteAccount(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        tabIndex: vm.tabIndex,
        onTabChanged: vm.setTabIndex,
      ),
    );
  }

  // ── Shop ─────────────────────────────────────────────────────────────────
  Future<void> _openShop(BuildContext context) async {
    final vm = context.read<HomeViewModel>();

    await ShopSheet.show(
      context,
      availableXp: vm.availableXp,
      streakFreezes: vm.streakFreezes,
      maxFreezes: HomeViewModel.maxFreezes,
      freezePrice: HomeViewModel.freezePrice,
      buying: vm.buyingFreeze,
      onClose: () => Navigator.pop(context),
      onBuy: () async {
        try {
          await vm.buyStreakFreeze();
          if (!context.mounted) return;
          Navigator.pop(context);
          SnackbarHelper.success(context, 'Streak freeze purchased!');
        } on FreezePurchaseException catch (e) {
          if (!context.mounted) return;
          final msg = e.reason == 'insufficient_xp'
              ? 'Not enough XP.'
              : e.reason == 'inventory_full'
              ? 'You already have ${HomeViewModel.maxFreezes}.'
              : 'Purchase failed.';
          SnackbarHelper.error(context, msg);
        } catch (_) {
          if (!context.mounted) return;
          SnackbarHelper.error(context, 'Purchase failed. Try again.');
        }
      },
    );
  }

  // ── Quest interactions ───────────────────────────────────────────────────
  Future<void> _onToggleQuest(BuildContext context, Quest quest) async {
    final vm = context.read<HomeViewModel>();
    final tierUp = await vm.toggleQuest(quest);
    if (!context.mounted) return;
    if (tierUp != null) _showTierUp(context, tierUp);
  }

  Future<void> _onAddQuest(BuildContext context) async {
    final vm = context.read<HomeViewModel>();
    final result = await showModalBottomSheet<QuestSheetResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const QuestSheet(),
    );

    if (!context.mounted || result is! QuestSaved) return;
    final tierUp = await vm.addQuest(result.quest);
    if (!context.mounted) return;
    if (tierUp != null) _showTierUp(context, tierUp);
  }

  Future<void> _onEditQuest(BuildContext context, Quest quest) async {
    final vm = context.read<HomeViewModel>();
    final result = await showModalBottomSheet<QuestSheetResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuestSheet(existing: quest),
    );

    if (!context.mounted) return;

    if (result is QuestDeleted) {
      final tierUp = await vm.deleteQuest(quest);
      if (!context.mounted) return;
      if (tierUp != null) _showTierUp(context, tierUp);
    } else if (result is QuestSaved) {
      final tierUp = await vm.editQuest(result.quest);
      if (!context.mounted) return;
      if (tierUp != null) _showTierUp(context, tierUp);
    }
  }

  // ── Tier-up ──────────────────────────────────────────────────────────────
  Future<void> _showTierUp(BuildContext context, Tier tier) async {
    final level = context.read<HomeViewModel>().level;
    if (!context.mounted) return;

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tier up',
      barrierColor: Colors.black.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, _, _) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, _, _) {
        final scale = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: scale,
            child: TierUpDialog(tier: tier, level: level),
          ),
        );
      },
    );
  }

  // ── Logout ───────────────────────────────────────────────────────────────
  Future<void> _logout(BuildContext context) async {
    final confirmed = await LogoutConfirmDialog.show(context);
    if (!context.mounted) return;
    if (confirmed != true) return;

    final vm = context.read<HomeViewModel>();
    await vm.logout();

    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // ── Delete account ───────────────────────────────────────────────────────
  Future<void> _deleteAccount(BuildContext context) async {
    final vm = context.read<HomeViewModel>();

    final confirmed = await DeleteAccountDialog.show(
      context,
      onConfirm: (password) => vm.deleteAccount(password),
    );

    if (!context.mounted) return;
    if (confirmed != true) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
