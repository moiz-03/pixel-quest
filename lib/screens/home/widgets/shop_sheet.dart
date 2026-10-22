import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_sizes.dart';
import '../../../theme/app_text_styles.dart';

class ShopSheet extends StatelessWidget {
  final int availableXp;
  final int streakFreezes;
  final int maxFreezes;
  final int freezePrice;
  final bool buying;
  final VoidCallback onBuy;
  final VoidCallback onClose;

  const ShopSheet({
    super.key,
    required this.availableXp,
    required this.streakFreezes,
    required this.maxFreezes,
    required this.freezePrice,
    required this.buying,
    required this.onBuy,
    required this.onClose,
  });

  static Future<void> show(
    BuildContext context, {
    required int availableXp,
    required int streakFreezes,
    required int maxFreezes,
    required int freezePrice,
    required bool buying,
    required VoidCallback onBuy,
    required VoidCallback onClose,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShopSheet(
        availableXp: availableXp,
        streakFreezes: streakFreezes,
        maxFreezes: maxFreezes,
        freezePrice: freezePrice,
        buying: buying,
        onBuy: onBuy,
        onClose: onClose,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventoryFull = streakFreezes >= maxFreezes;
    final canAfford = availableXp >= freezePrice;
    final canBuy = !inventoryFull && canAfford && !buying;

    return RepaintBoundary(
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusXl),
          ),
          border: Border(
            top: BorderSide(color: AppColors.accentGold, width: 2),
            left: BorderSide(color: AppColors.accentGold, width: 2),
            right: BorderSide(color: AppColors.accentGold, width: 2),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.xl,
            AppSizes.md,
            AppSizes.xl,
            AppSizes.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 44,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              Row(
                children: [
                  const Icon(Pixel.coin, color: AppColors.accentGold, size: 24),
                  const SizedBox(width: AppSizes.sm),
                  const Expanded(child: Text('SHOP', style: AppTextStyles.h2)),
                  IconButton(
                    onPressed: onClose,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    icon: const Icon(
                      Pixel.close,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.md),

              // Balance
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.border, width: 1.2),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Pixel.coin,
                      color: AppColors.accentGold,
                      size: 18,
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Text(
                        'Available XP',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      '$availableXp',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.accentGold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.lg),

              // Freeze product
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.6),
                    width: 1.4,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusSm,
                            ),
                            border: Border.all(
                              color: AppColors.secondary,
                              width: 1.2,
                            ),
                          ),
                          child: const Icon(
                            Pixel.shield,
                            color: AppColors.secondary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'STREAK FREEZE',
                                style: AppTextStyles.h3.copyWith(
                                  color: AppColors.secondary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Miss a day without breaking your streak.',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.md),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'OWNED: $streakFreezes / $maxFreezes',
                            style: AppTextStyles.micro.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Pixel.coin,
                              color: AppColors.accentGold,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$freezePrice',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.accentGold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.md),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: canBuy ? onBuy : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.surfaceHigh,
                          disabledForegroundColor: AppColors.textMuted,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMd,
                            ),
                          ),
                        ),
                        child: buying
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                inventoryFull
                                    ? 'INVENTORY FULL'
                                    : !canAfford
                                    ? 'NOT ENOUGH XP'
                                    : 'BUY',
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.lg),

              Text(
                'Freezes are used automatically when you miss a day. '
                'You can hold up to $maxFreezes at once.',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
