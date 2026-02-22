import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncsphere/providers/device_provider.dart';
import 'package:syncsphere/providers/sync_provider.dart';
import 'package:syncsphere/screens/dashboard/dashboard_screen.dart';
import 'package:syncsphere/widgets/sync_job_card.dart';

import '../helpers/test_data.dart';
import '../helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    initTestEnvironment();
  });

  testWidgets('renders summary and empty state when no jobs exist', (
    WidgetTester tester,
  ) async {
    await pumpTestScreen(tester, const DashboardScreen(), settle: false);
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('SyncSphere'), findsOneWidget);
    expect(find.text('フォルダ'), findsOneWidget);
    expect(find.text('デバイス'), findsOneWidget);
    expect(find.text('同期中'), findsOneWidget);
    expect(find.text('フォルダを追加して同期を始めましょう'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('shows recent jobs and limits list to five cards', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pump();

    final SyncProvider syncProvider = SyncProvider();
    final DeviceProvider deviceProvider = DeviceProvider();
    for (final job in createTestSyncJobs(6)) {
      syncProvider.addJob(job);
    }
    deviceProvider.setDevices(createTestDeviceList());

    await pumpTestScreen(
      tester,
      const DashboardScreen(),
      syncProvider: syncProvider,
      deviceProvider: deviceProvider,
      settle: false,
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(SyncJobCard), findsNWidgets(5));
    expect(find.text('ジョブ 0'), findsOneWidget);
    expect(find.text('ジョブ 5'), findsNothing);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('add-device action chip is tappable', (WidgetTester tester) async {
    await pumpTestScreen(tester, const DashboardScreen(), settle: false);
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('デバイス追加'));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('デバイス追加'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('scrolls dashboard content with several jobs', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final SyncProvider syncProvider = SyncProvider();
    for (final job in createTestSyncJobs(5)) {
      syncProvider.addJob(job);
    }

    await pumpTestScreen(
      tester,
      const DashboardScreen(),
      syncProvider: syncProvider,
      settle: false,
    );
    await tester.pump(const Duration(seconds: 1));

    await tester.scrollUntilVisible(
      find.text('ジョブ 4'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('ジョブ 4'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('updates from empty state when provider changes', (
    WidgetTester tester,
  ) async {
    final TestProviders providers = await pumpTestScreen(
      tester,
      const DashboardScreen(),
      settle: false,
    );
    await tester.pump(const Duration(seconds: 1));

    providers.syncProvider.addJob(createTestSyncJob(name: '動的ジョブ'));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('動的ジョブ'), findsOneWidget);
    expect(find.text('フォルダを追加して同期を始めましょう'), findsNothing);
    await tester.pump(const Duration(seconds: 1));
  });
}
