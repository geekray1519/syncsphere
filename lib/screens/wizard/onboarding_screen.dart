import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:syncsphere/l10n/app_localizations.dart';
import 'package:syncsphere/providers/settings_provider.dart';
import 'package:syncsphere/theme/app_spacing.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const MethodChannel _batterySettingsChannel = MethodChannel(
    'syncsphere/device_settings',
  );

  final PageController _pageController = PageController();
  int _currentIndex = 0;

  Future<void> _openBatteryOptimizationSettings() async {
    if (!Platform.isAndroid) {
      return;
    }

    try {
      await _batterySettingsChannel.invokeMethod<void>(
        'openBatteryOptimizationSettings',
      );
    } on MissingPluginException {
      await openAppSettings();
    } on PlatformException {
      await openAppSettings();
    }
  }

  Future<void> _completeOnboardingAndExit() async {
    await context.read<SettingsProvider>().completeOnboarding();
    if (!mounted) {
      return;
    }
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final pages = [
      _OnboardingPage(
        icon: Icons.sync_rounded,
        title: l10n.onboardingTitle1,
        description: l10n.onboardingDesc1,
      ),
      _OnboardingPage(
        icon: Icons.security_rounded,
        title: l10n.onboardingTitle2,
        description: l10n.onboardingDesc2,
      ),
      _OnboardingPage(
        icon: Icons.compare_arrows_rounded,
        title: l10n.onboardingTitle3,
        description: l10n.onboardingDesc3,
      ),
      _OnboardingPage(
        icon: Icons.speed_rounded,
        title: l10n.onboardingTitle4,
        description: l10n.onboardingDesc4,
        actionLabel: l10n.disableBatteryOptimization,
        actionDescription: l10n.disableBatteryOptDesc,
        onActionPressed: _openBatteryOptimizationSettings,
      ),
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.lg,
                  right: AppSpacing.lg,
                ),
                child: TextButton(
                  onPressed: _completeOnboardingAndExit,
                  child: Text(
                    l10n.skip,
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return pages[index];
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxxl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      pages.length,
                      (index) => AnimatedContainer(
                        duration: AppSpacing.animNormal,
                        margin: const EdgeInsets.only(right: AppSpacing.sm),
                        height: AppSpacing.sm,
                        width: _currentIndex == index
                            ? AppSpacing.xxl
                            : AppSpacing.sm,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(AppSpacing.xs),
                        ),
                      ),
                    ),
                  ),
                  FilledButton(
                        onPressed: () {
                          if (_currentIndex == pages.length - 1) {
                            _completeOnboardingAndExit();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutCubic,
                            );
                          }
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xxl,
                            vertical: AppSpacing.lg,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusLg,
                            ),
                          ),
                        ),
                        child: Text(
                          _currentIndex == pages.length - 1
                              ? l10n.getStarted
                              : l10n.next,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                      .animate(
                        target: _currentIndex == pages.length - 1 ? 1 : 0,
                      )
                      .scale(duration: 300.ms, curve: Curves.easeOutBack),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final String? actionDescription;
  final Future<void> Function()? onActionPressed;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.actionDescription,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            <Widget>[
                  Container(
                    padding: const EdgeInsets.all(
                      AppSpacing.xxxl + AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.5,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: AppSpacing.iconHero + AppSpacing.xxl,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Gap(AppSpacing.xxxl + AppSpacing.xl),
                  Text(
                    title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(AppSpacing.xl),
                  Text(
                    description,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (actionLabel != null &&
                      onActionPressed != null) ...<Widget>[
                    const Gap(AppSpacing.xxl),
                    OutlinedButton.icon(
                      onPressed: onActionPressed,
                      icon: const Icon(Icons.battery_saver_rounded),
                      label: Text(actionLabel!),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.lg,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusLg,
                          ),
                        ),
                      ),
                    ),
                    if (actionDescription != null) ...<Widget>[
                      const Gap(AppSpacing.md),
                      Text(
                        actionDescription!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ]
                .animate(interval: 120.ms)
                .fadeIn(duration: 450.ms)
                .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic)
                .toList(),
      ),
    );
  }
}
