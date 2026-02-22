import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncsphere/screens/settings/settings_screen.dart';

import '../helpers/test_helpers.dart';

Future<void> _setSettingsSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(500, 1800));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pump();
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    initTestEnvironment();
  });

  testWidgets('renders key settings sections', (WidgetTester tester) async {
    await _setSettingsSurface(tester);
    await pumpTestScreen(tester, const SettingsScreen(), settle: false);
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('設定'), findsOneWidget);
    expect(find.text('一般'), findsOneWidget);
    expect(find.text('同期'), findsOneWidget);
    expect(find.text('実行条件'), findsOneWidget);
  });

  testWidgets('scrolls down to app info section', (WidgetTester tester) async {
    await _setSettingsSurface(tester);
    await pumpTestScreen(tester, const SettingsScreen(), settle: false);
    await tester.pump(const Duration(seconds: 1));

    await tester.scrollUntilVisible(
      find.text('このアプリについて'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('このアプリについて'), findsOneWidget);
    expect(find.text('バージョン'), findsOneWidget);
  });

  testWidgets('toggles WiFi-only switch on tap', (WidgetTester tester) async {
    await _setSettingsSurface(tester);
    await pumpTestScreen(tester, const SettingsScreen(), settle: false);
    await tester.pump(const Duration(seconds: 1));

    final Finder wifiTile = find.widgetWithText(SwitchListTile, 'WiFiのみで同期');
    await tester.ensureVisible(wifiTile);

    final Finder wifiSwitchFinder = find.descendant(
      of: wifiTile,
      matching: find.byType(Switch),
    );
    final Switch beforeSwitch = tester.widget<Switch>(wifiSwitchFinder);
    expect(beforeSwitch.value, isTrue);

    await tester.tap(find.text('WiFiのみで同期'));
    await tester.pump();

    final Switch afterSwitch = tester.widget<Switch>(wifiSwitchFinder);
    expect(afterSwitch.value, isFalse);
  });

  testWidgets('sync completion notification switch updates provider state', (
    WidgetTester tester,
  ) async {
    await _setSettingsSurface(tester);
    final TestProviders providers = await pumpTestScreen(
      tester,
      const SettingsScreen(),
      settle: false,
    );
    await tester.pump(const Duration(seconds: 1));

    final Finder notificationTile = find.widgetWithText(SwitchListTile, '同期完了');
    await tester.ensureVisible(notificationTile);
    final Finder notificationSwitchFinder = find.descendant(
      of: notificationTile,
      matching: find.byType(Switch),
    );
    await tester.ensureVisible(notificationSwitchFinder);
    expect(providers.settingsProvider.notificationsEnabled, isTrue);

    final SwitchListTile tile = tester.widget<SwitchListTile>(notificationTile);
    tile.onChanged?.call(false);
    await tester.pump();

    expect(providers.settingsProvider.notificationsEnabled, isFalse);
  });

  testWidgets('removes an allowed SSID chip via delete tap', (
    WidgetTester tester,
  ) async {
    await _setSettingsSurface(tester);
    await pumpTestScreen(tester, const SettingsScreen(), settle: false);
    await tester.pump(const Duration(seconds: 1));

    await tester.scrollUntilVisible(
      find.text('MyHomeNetwork'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('MyHomeNetwork'), findsOneWidget);

    final Finder chip = find.ancestor(
      of: find.text('MyHomeNetwork'),
      matching: find.byType(Chip),
    );
    final Finder deleteIcon = find.descendant(
      of: chip,
      matching: find.byIcon(Icons.cancel),
    );
    await tester.ensureVisible(deleteIcon);
    await tester.tap(deleteIcon);
    await tester.pump();

    expect(find.text('MyHomeNetwork'), findsNothing);
  });
}
