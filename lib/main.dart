import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/notification_service.dart';
import 'providers/sync_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/run_conditions_provider.dart';
import 'providers/device_provider.dart';
import 'providers/premium_provider.dart';
import 'providers/server_provider.dart';
import 'l10n/app_localizations.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();

  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final SettingsProvider settingsProvider = SettingsProvider(preferences);

  final PremiumProvider premiumProvider = PremiumProvider();
  await premiumProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SyncProvider>(
          create: (_) => SyncProvider(),
        ),
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settingsProvider,
        ),
        ChangeNotifierProvider<RunConditionsProvider>(
          create: (_) => RunConditionsProvider(preferences),
        ),
        ChangeNotifierProvider<DeviceProvider>(
          create: (_) => DeviceProvider(),
        ),
        ChangeNotifierProvider<PremiumProvider>.value(
          value: premiumProvider,
        ),
        ChangeNotifierProvider<ServerProvider>(
          create: (_) => ServerProvider(),
        ),
      ],
      child: SyncSphereApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
      ),
    ),
  );
}
