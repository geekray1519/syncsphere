import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncsphere/models/sync_job.dart';
import 'package:syncsphere/widgets/sync_job_card.dart';

import '../helpers/test_data.dart';
import '../helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    initTestEnvironment();
  });

  testWidgets('renders job name and paths', (WidgetTester tester) async {
    final SyncJob job = createTestSyncJob(
      name: 'ドキュメント同期',
      sourcePath: '/source',
      targetPath: '/target',
    );
    bool tapped = false;

    final TestProviders providers = await createTestProviders();
    await tester.pumpWidget(
      buildTestApp(
        providers,
        Scaffold(body: SyncJobCard(job: job, onTap: () => tapped = true)),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('ドキュメント同期'), findsOneWidget);
    expect(find.text('/source → /target'), findsOneWidget);
    expect(tapped, isFalse);
  });

  testWidgets('onTap callback fires when card is tapped', (
    WidgetTester tester,
  ) async {
    final SyncJob job = createTestSyncJob();
    bool tapped = false;

    final TestProviders providers = await createTestProviders();
    await tester.pumpWidget(
      buildTestApp(
        providers,
        Scaffold(body: SyncJobCard(job: job, onTap: () => tapped = true)),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byType(SyncJobCard));
    expect(tapped, isTrue);
  });

  testWidgets('shows last sync date when available', (
    WidgetTester tester,
  ) async {
    final SyncJob job = createTestSyncJob(
      lastSync: DateTime(2025, 6, 15, 10, 30),
    );

    final TestProviders providers = await createTestProviders();
    await tester.pumpWidget(
      buildTestApp(
        providers,
        Scaffold(body: SyncJobCard(job: job, onTap: () {})),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('06/15 10:30'), findsOneWidget);
  });

  testWidgets('shows 未同期 when no last sync', (WidgetTester tester) async {
    final SyncJob job = createTestSyncJob(lastSync: null);

    final TestProviders providers = await createTestProviders();
    await tester.pumpWidget(
      buildTestApp(
        providers,
        Scaffold(body: SyncJobCard(job: job, onTap: () {})),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('未同期'), findsOneWidget);
  });

  testWidgets('active job shows progress indicator', (
    WidgetTester tester,
  ) async {
    final SyncJob job = createTestSyncJob(isActive: true);

    final TestProviders providers = await createTestProviders();
    await tester.pumpWidget(
      buildTestApp(
        providers,
        Scaffold(body: SyncJobCard(job: job, onTap: () {})),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('inactive job does not show progress indicator', (
    WidgetTester tester,
  ) async {
    final SyncJob job = createTestSyncJob(isActive: false);

    final TestProviders providers = await createTestProviders();
    await tester.pumpWidget(
      buildTestApp(
        providers,
        Scaffold(body: SyncJobCard(job: job, onTap: () {})),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(LinearProgressIndicator), findsNothing);
  });
}
