import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncsphere/providers/device_provider.dart';
import 'package:syncsphere/screens/devices/devices_screen.dart';
import 'package:syncsphere/services/storage_service.dart';

import '../helpers/test_data.dart';
import '../helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    initTestEnvironment();
  });

  testWidgets('shows empty state with add button', (WidgetTester tester) async {
    await pumpTestScreen(tester, const DevicesScreen(), settle: false);
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('デバイス'), findsOneWidget);
    expect(find.text('デバイスを追加してファイルを同期しましょう'), findsOneWidget);
    expect(find.text('デバイスを追加'), findsOneWidget);
  });

  testWidgets('opens add-device sheet and manual-add dialog on taps', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 1700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pump();

    await pumpTestScreen(tester, const DevicesScreen(), settle: false);
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('QRスキャン'), findsOneWidget);
    expect(find.text('手動追加'), findsOneWidget);

    final Finder manualAddInSheet = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.text('手動追加'),
    );
    final Finder manualAddInkWell = find.ancestor(
      of: manualAddInSheet,
      matching: find.byType(InkWell),
    );
    final InkWell manualAddCard = tester.widget<InkWell>(
      manualAddInkWell.first,
    );
    manualAddCard.onTap?.call();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('IPアドレス'), findsOneWidget);
    expect(find.text('ポート'), findsOneWidget);
  });

  testWidgets('shows online and offline sections with device data', (
    WidgetTester tester,
  ) async {
    final DeviceProvider deviceProvider = DeviceProvider(StorageService());
    deviceProvider.setDevices(createTestDeviceList());

    await pumpTestScreen(
      tester,
      const DevicesScreen(),
      deviceProvider: deviceProvider,
      settle: false,
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('オンライン'), findsOneWidget);
    expect(find.text('オフライン'), findsOneWidget);
    expect(find.text('オフィス PC'), findsOneWidget);
    expect(find.text('自宅 PC'), findsOneWidget);
  });

  testWidgets('scrolls list when many devices are available', (
    WidgetTester tester,
  ) async {
    final DeviceProvider deviceProvider = DeviceProvider(StorageService());
    final List devices = List.generate(15, (int i) {
      return createTestDeviceInfo(
        id: 'device-$i',
        name: 'デバイス $i',
        isOnline: i.isEven,
      );
    });
    deviceProvider.setDevices(devices.cast());

    await pumpTestScreen(
      tester,
      const DevicesScreen(),
      deviceProvider: deviceProvider,
      settle: false,
    );
    await tester.pump(const Duration(seconds: 1));

    await tester.scrollUntilVisible(
      find.text('デバイス 14'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('デバイス 14'), findsOneWidget);
  });

  testWidgets('reacts to provider state changes after initial pump', (
    WidgetTester tester,
  ) async {
    final TestProviders providers = await pumpTestScreen(
      tester,
      const DevicesScreen(),
      settle: false,
    );
    await tester.pump(const Duration(seconds: 1));

    providers.deviceProvider.addOrUpdateDevice(
      createTestDeviceInfo(id: 'new-device', name: '新規デバイス', isOnline: true),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('オンライン'), findsOneWidget);
    expect(find.text('新規デバイス'), findsOneWidget);
  });
}
