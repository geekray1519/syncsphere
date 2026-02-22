import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncsphere/providers/sync_provider.dart';
import 'package:syncsphere/screens/sync/sync_progress_screen.dart';

import '../helpers/test_data.dart';
import '../helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    initTestEnvironment();
  });

  testWidgets('renders progress screen with zero progress', (
    WidgetTester tester,
  ) async {
    final SyncProvider syncProvider = SyncProvider();
    syncProvider.addJob(createTestSyncJob(id: 'progress-job'));

    final TestProviders providers = await createTestProviders(
      syncProvider: syncProvider,
    );
    await tester.pumpWidget(
      buildTestApp(providers, const SyncProgressScreen(jobId: 'progress-job')),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('同期中...'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('キャンセル'), findsOneWidget);
  });

  testWidgets('shows stats card with file, speed, and time labels', (
    WidgetTester tester,
  ) async {
    final SyncProvider syncProvider = SyncProvider();
    syncProvider.addJob(createTestSyncJob(id: 'stats-job'));

    final TestProviders providers = await createTestProviders(
      syncProvider: syncProvider,
    );
    await tester.pumpWidget(
      buildTestApp(providers, const SyncProgressScreen(jobId: 'stats-job')),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('ファイル'), findsOneWidget);
    expect(find.text('速度'), findsOneWidget);
    expect(find.text('残り時間'), findsOneWidget);
  });

  testWidgets('shows expandable details section', (
    WidgetTester tester,
  ) async {
    final SyncProvider syncProvider = SyncProvider();
    syncProvider.addJob(createTestSyncJob(id: 'expand-job'));

    final TestProviders providers = await createTestProviders(
      syncProvider: syncProvider,
    );
    await tester.pumpWidget(
      buildTestApp(providers, const SyncProgressScreen(jobId: 'expand-job')),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('詳細情報'), findsOneWidget);

    // Tap to expand
    await tester.tap(find.text('詳細情報'));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('コピー済み:'), findsOneWidget);
    expect(find.text('削除済み:'), findsOneWidget);
  });

  testWidgets('cancel button is present and tappable', (
    WidgetTester tester,
  ) async {
    final SyncProvider syncProvider = SyncProvider();
    syncProvider.addJob(createTestSyncJob(id: 'cancel-job'));
    syncProvider.startSync('cancel-job');

    final TestProviders providers = await createTestProviders(
      syncProvider: syncProvider,
    );
    await tester.pumpWidget(
      buildTestApp(providers, const SyncProgressScreen(jobId: 'cancel-job')),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('キャンセル'), findsOneWidget);

    // Tap cancel — it calls stopSync + Navigator.pop
    // Navigator.pop will fail because there's no route to pop to in test,
    // so we just verify the button exists and is tappable.
    await tester.tap(find.text('キャンセル'));
    await tester.pump();
  });

  testWidgets('scrolls on small screen', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 500));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final SyncProvider syncProvider = SyncProvider();
    syncProvider.addJob(createTestSyncJob(id: 'scroll-job'));

    final TestProviders providers = await createTestProviders(
      syncProvider: syncProvider,
    );
    await tester.pumpWidget(
      buildTestApp(providers, const SyncProgressScreen(jobId: 'scroll-job')),
    );
    await tester.pump(const Duration(seconds: 1));

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('キャンセル'), findsOneWidget);
  });
}
