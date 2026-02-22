import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/premium_provider.dart';
import '../../theme/app_spacing.dart';

const bool _disableAnimationsForTest = bool.fromEnvironment('FLUTTER_TEST');

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final premiumProvider = context.watch<PremiumProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.premium),
        leading: IconButton(
          tooltip: l10n.back,
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: premiumProvider.isPremium
            ? _buildSuccessState(theme, colorScheme, l10n)
            : _buildPurchaseState(premiumProvider, theme, colorScheme, l10n),
      ),
    );
  }

  Widget _buildSuccessState(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePadding,
            vertical: AppSpacing.xxl,
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primaryContainer,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 80,
                color: colorScheme.primary,
              ),
            ).animate(autoPlay: !_disableAnimationsForTest).scale(duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.premiumActive,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.premiumThankYou,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Card(
              color: colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    _buildBenefitItem(Icons.block_rounded, l10n.noAdsComplete, theme, colorScheme),
                    const Divider(height: AppSpacing.xl),
                    _buildBenefitItem(Icons.speed_rounded, l10n.unlimitedSpeed, theme, colorScheme),
                    const Divider(height: AppSpacing.xl),
                    _buildBenefitItem(Icons.support_agent_rounded, l10n.prioritySupport, theme, colorScheme),
                  ],
                ),
              ),
            ).animate(autoPlay: !_disableAnimationsForTest).fadeIn(duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text, ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(icon, color: colorScheme.primary, size: AppSpacing.iconMd),
        const SizedBox(width: AppSpacing.md),
        Text(
          text,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseState(PremiumProvider provider, ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePadding,
            vertical: AppSpacing.xl,
          ),
          children: [
            Icon(
              Icons.workspace_premium_rounded,
              size: 80,
              color: colorScheme.primary,
            ).animate(autoPlay: !_disableAnimationsForTest).scale(duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.premiumTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              children: [
                Expanded(
                      child: _buildFreePlanCard(theme, colorScheme, l10n)
                      .animate(autoPlay: !_disableAnimationsForTest)
                      .fadeIn(delay: 200.ms, duration: 400.ms)
                      .slideY(begin: 0.1, duration: 400.ms),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                      child: _buildPremiumPlanCard(theme, colorScheme, l10n)
                      .animate(autoPlay: !_disableAnimationsForTest)
                      .fadeIn(delay: 300.ms, duration: 400.ms)
                      .slideY(begin: 0.1, duration: 400.ms),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              provider.premiumProduct?.price ?? '¥3,000 (USD \$20.00)',
              textAlign: TextAlign.center,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${l10n.oneTimePurchase} — ${l10n.noSubscription}',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            ElevatedButton(
              onPressed: provider.isPurchasePending
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      provider.purchasePremium();
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                ),
              ),
              child: provider.isPurchasePending
                  ? const CircularProgressIndicator()
                  : Text(l10n.purchasePremium),
            ).animate(autoPlay: !_disableAnimationsForTest).fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: provider.isPurchasePending ? null : () => provider.restorePurchases(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              ),
              child: Text(l10n.restorePurchases),
            ),
            if (provider.errorMessage != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildFreePlanCard(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    return Card(
      color: colorScheme.surfaceContainerHighest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Text(
              l10n.freePlan,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildFeatureRow(Icons.check_rounded, l10n.basicSync, colorScheme.onSurfaceVariant),
            const SizedBox(height: AppSpacing.md),
            _buildFeatureRow(Icons.close_rounded, l10n.noAds, colorScheme.onSurfaceVariant),
            const SizedBox(height: AppSpacing.md),
            _buildFeatureRow(Icons.close_rounded, l10n.fastSync, colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumPlanCard(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    return Card(
      color: colorScheme.primaryContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        side: BorderSide(color: colorScheme.primary, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Text(
              l10n.premiumPlan,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildFeatureRow(Icons.check_rounded, l10n.basicSync, colorScheme.onPrimaryContainer),
            const SizedBox(height: AppSpacing.md),
            _buildFeatureRow(Icons.check_rounded, l10n.noAds, colorScheme.onPrimaryContainer),
            const SizedBox(height: AppSpacing.md),
            _buildFeatureRow(Icons.check_rounded, l10n.fastSync, colorScheme.onPrimaryContainer),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: AppSpacing.iconSm, color: color),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
