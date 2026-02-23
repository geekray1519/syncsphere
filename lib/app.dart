import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/settings_provider.dart';
import 'theme/app_theme.dart';
import 'screens/shell/app_shell.dart';
import 'screens/wizard/onboarding_screen.dart';
import 'screens/wizard/setup_wizard_screen.dart';
import 'screens/sync/sync_detail_screen.dart';
import 'screens/sync/sync_progress_screen.dart';
import 'screens/premium/premium_screen.dart';
import 'screens/server/server_screen.dart';
import 'screens/folders/folder_detail_screen.dart';
import 'screens/devices/device_detail_screen.dart';
import 'models/sync_job.dart';
import 'models/device_info.dart';

/// Named route constants used throughout the app.
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String onboarding = '/onboarding';
  static const String wizard = '/wizard';
  static const String syncDetail = '/sync-detail';
  static const String syncProgress = '/sync-progress';
  static const String premium = '/premium';
  static const String server = '/server';
  static const String folderDetail = '/folder-detail';
  static const String deviceDetail = '/device-detail';
}

class SyncSphereApp extends StatelessWidget {
  const SyncSphereApp({
    super.key,
    required this.supportedLocales,
    required this.localizationsDelegates,
  });

  final List<Locale> supportedLocales;
  final List<LocalizationsDelegate<dynamic>> localizationsDelegates;

  @override
  Widget build(BuildContext context) {
    final SettingsProvider settings = context.watch<SettingsProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SyncSphere',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: supportedLocales,
      localizationsDelegates: localizationsDelegates,
      initialRoute: settings.hasSeenOnboarding
          ? AppRoutes.home
          : AppRoutes.onboarding,
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case AppRoutes.home:
        return MaterialPageRoute<void>(
          builder: (_) => const AppShell(),
          settings: routeSettings,
        );

      case AppRoutes.onboarding:
        return MaterialPageRoute<void>(
          builder: (_) => const OnboardingScreen(),
          settings: routeSettings,
        );

      case AppRoutes.wizard:
        return MaterialPageRoute<void>(
          builder: (_) => const SetupWizardScreen(),
          settings: routeSettings,
        );

      case AppRoutes.syncDetail:
        final SyncJob? job = routeSettings.arguments as SyncJob?;
        if (job != null) {
          return MaterialPageRoute<void>(
            builder: (_) => SyncDetailScreen(job: job),
            settings: routeSettings,
          );
        }
        return _fallbackRoute(routeSettings);

      case AppRoutes.syncProgress:
        final String? jobId = routeSettings.arguments as String?;
        if (jobId != null) {
          return MaterialPageRoute<void>(
            builder: (_) => SyncProgressScreen(jobId: jobId),
            settings: routeSettings,
          );
        }
        return _fallbackRoute(routeSettings);

      case AppRoutes.premium:
        return MaterialPageRoute<void>(
          builder: (_) => const PremiumScreen(),
          settings: routeSettings,
        );

      case AppRoutes.server:
        return MaterialPageRoute<void>(
          builder: (_) => const ServerScreen(),
          settings: routeSettings,
        );

      case AppRoutes.folderDetail:
        final SyncJob? job = routeSettings.arguments as SyncJob?;
        if (job != null) {
          return MaterialPageRoute<void>(
            builder: (_) => FolderDetailScreen(job: job),
            settings: routeSettings,
          );
        }
        return _fallbackRoute(routeSettings);

      case AppRoutes.deviceDetail:
        final DeviceInfo? device = routeSettings.arguments as DeviceInfo?;
        if (device != null) {
          return MaterialPageRoute<void>(
            builder: (_) => DeviceDetailScreen(device: device),
            settings: routeSettings,
          );
        }
        return _fallbackRoute(routeSettings);

      default:
        return _fallbackRoute(routeSettings);
    }
  }

  MaterialPageRoute<void> _fallbackRoute(RouteSettings routeSettings) {
    return MaterialPageRoute<void>(
      builder: (_) => const AppShell(),
      settings: routeSettings,
    );
  }
}
