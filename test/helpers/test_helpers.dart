
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:syncsphere/l10n/app_localizations.dart';
import 'package:syncsphere/providers/sync_provider.dart';
import 'package:syncsphere/providers/device_provider.dart';
import 'package:syncsphere/providers/settings_provider.dart';
import 'package:syncsphere/providers/premium_provider.dart';
import 'package:syncsphere/providers/server_provider.dart';
import 'package:syncsphere/theme/app_theme.dart';

/// Container holding all providers used in test widget trees.
class TestProviders {
  TestProviders({
    required this.syncProvider,
    required this.deviceProvider,
    required this.settingsProvider,
    required this.premiumProvider,
    required this.serverProvider,
  });

  final SyncProvider syncProvider;
  final DeviceProvider deviceProvider;
  final SettingsProvider settingsProvider;
  final PremiumProvider premiumProvider;
  final ServerProvider serverProvider;
}

/// Call once in setUpAll() to initialise the test environment.
void initTestEnvironment() {
  GoogleFonts.config.allowRuntimeFetching = false;
}

/// Creates a [TestProviders] instance with sensible defaults.
///
/// SharedPreferences is mocked automatically. Override individual providers
/// to control state in specific tests.
Future<TestProviders> createTestProviders({
  SyncProvider? syncProvider,
  DeviceProvider? deviceProvider,
  PremiumProvider? premiumProvider,
  ServerProvider? serverProvider,
  Map<String, Object>? prefsValues,
}) async {
  SharedPreferences.setMockInitialValues(prefsValues ?? <String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  return TestProviders(
    syncProvider: syncProvider ?? SyncProvider(),
    deviceProvider: deviceProvider ?? DeviceProvider(),
    settingsProvider: SettingsProvider(prefs),
    premiumProvider: premiumProvider ?? PremiumProvider(),
    serverProvider: serverProvider ?? ServerProvider(),
  );
}

/// Wraps [child] in a full provider tree + localised MaterialApp.
Widget buildTestApp(TestProviders providers, Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<SyncProvider>.value(
        value: providers.syncProvider,
      ),
      ChangeNotifierProvider<DeviceProvider>.value(
        value: providers.deviceProvider,
      ),
      ChangeNotifierProvider<SettingsProvider>.value(
        value: providers.settingsProvider,
      ),
      ChangeNotifierProvider<PremiumProvider>.value(
        value: providers.premiumProvider,
      ),
      ChangeNotifierProvider<ServerProvider>.value(
        value: providers.serverProvider,
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ja'),
      theme: AppTheme.lightTheme,
      home: child,
    ),
  );
}

/// All-in-one helper: creates providers, wraps [child] in a test app,
/// pumps the widget, and waits for animations to settle.
///
/// Returns the [TestProviders] so the caller can inspect / mutate state.
Future<TestProviders> pumpTestScreen(
  WidgetTester tester,
  Widget child, {
  SyncProvider? syncProvider,
  DeviceProvider? deviceProvider,
  PremiumProvider? premiumProvider,
  ServerProvider? serverProvider,
  Map<String, Object>? prefsValues,
  bool settle = true,
}) async {
  final TestProviders providers = await createTestProviders(
    syncProvider: syncProvider,
    deviceProvider: deviceProvider,
    premiumProvider: premiumProvider,
    serverProvider: serverProvider,
    prefsValues: prefsValues,
  );

  await tester.pumpWidget(buildTestApp(providers, child));

  if (settle) {
    // Allow up to 10 s for animations. If pumpAndSettle times out
    // (e.g. repeating animations), the test should use settle=false
    // and pump manually.
    await tester.pump(const Duration(seconds: 1));
  } else {
    await tester.pump();
  }

  return providers;
}
