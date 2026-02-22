import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncsphere/providers/sync_provider.dart';
import 'package:syncsphere/screens/folders/folders_screen.dart';
import 'package:syncsphere/widgets/sync_job_card.dart';

import '../helpers/test_data.dart';
import '../helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    initTestEnvironment();
  });

  testWidgets('shows empty state when no folders exist', (
    WidgetTester tester,
  ) async {
    await pumpTestScreen(tester, const FoldersScreen(), settle: false);
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('フォルダ'), findsOneWidget);
    expect(find.text('フォルダがありません'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('renders sync job cards when folders exist', (
    WidgetTester tester,
  ) async {
    final SyncProvider syncProvider = SyncProvider();
    syncProvider.addJob(createTestSyncJob(name: 'テスト同期ジョブ'));
    syncProvider.addJob(createTestSyncJob(id: 'job-2', name: '追加ジョブ'));

    await pumpTestScreen(
      tester,
      const FoldersScreen(),
      syncProvider: syncProvider,
      settle: false,
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(SyncJobCard), findsNWidgets(2));
    expect(find.text('テスト同期ジョブ'), findsOneWidget);
    expect(find.text('追加ジョブ'), findsOneWidget);
  });

  testWidgets('supports tapping in empty state without crashing', (
    WidgetTester tester,
  ) async {
    await pumpTestScreen(tester, const FoldersScreen(), settle: false);
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('フォルダがありません'));
    await tester.pump();

    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('list scrolls with many folder jobs', (WidgetTester tester) async {
    final SyncProvider syncProvider = SyncProvider();
    for (final job in createTestSyncJobs(12)) {
      syncProvider.addJob(job);
    }

    await pumpTestScreen(
      tester,
      const FoldersScreen(),
      syncProvider: syncProvider,
      settle: false,
    );
    await tester.pump(const Duration(seconds: 1));

    await tester.scrollUntilVisible(
      find.text('ジョブ 11'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('ジョブ 11'), findsOneWidget);
  });

  testWidgets('updates from empty to populated when provider changes', (
    WidgetTester tester,
  ) async {
    final TestProviders providers = await pumpTestScreen(
      tester,
      const FoldersScreen(),
      settle: false,
    );
    await tester.pump(const Duration(seconds: 1));

    providers.syncProvider.addJob(createTestSyncJob(name: '追加されたジョブ'));
    await tester.pump();

    expect(find.text('追加されたジョブ'), findsOneWidget);
    expect(find.text('フォルダがありません'), findsNothing);
  });
}
