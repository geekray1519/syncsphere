import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncsphere/providers/sync_provider.dart';
import 'package:syncsphere/screens/sync/sync_detail_screen.dart';
import 'package:syncsphere/services/storage_service.dart';

import '../helpers/test_data.dart';
import '../helpers/test_helpers.dart';

Future<void> _setMobileSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(400, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

void main() {
  setUpAll(() {
    initTestEnvironment();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('SyncDetailScreen', () {
    testWidgets('renders summary, folders, filter, and action bar', (
      WidgetTester tester,
    ) async {
      await _setMobileSurface(tester);

      final job = createTestSyncJob(
        id: 'detail-job-1',
        name: '写真バックアップ',
        sourcePath: '/storage/photos',
        targetPath: '/backup/photos',
        isActive: false,
      );
      final syncProvider = SyncProvider(StorageService())..addJob(job);
      final providers = await createTestProviders(syncProvider: syncProvider);

      await tester.pumpWidget(
        buildTestApp(providers, SyncDetailScreen(job: job)),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('写真バックアップ'), findsOneWidget);
      expect(find.text('概要'), findsOneWidget);
      expect(find.text('フォルダ'), findsOneWidget);
      expect(find.text('フィルタ'), findsOneWidget);
      expect(find.text('比較'), findsOneWidget);
      expect(find.text('同期開始'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -250));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('/backup/photos'), findsOneWidget);
    });

    testWidgets('shows include/exclude filters and opens popup menu', (
      WidgetTester tester,
    ) async {
      await _setMobileSurface(tester);

      final job = createTestSyncJob(
        id: 'detail-job-2',
        name: 'プロジェクト同期',
        isActive: false,
        filterInclude: const <String>['*.dart', '*.yaml'],
        filterExclude: const <String>['build/', '.dart_tool/'],
      );
      final syncProvider = SyncProvider(StorageService())..addJob(job);
      final providers = await createTestProviders(syncProvider: syncProvider);

      await tester.pumpWidget(
        buildTestApp(providers, SyncDetailScreen(job: job)),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('含める:'), findsOneWidget);
      expect(find.text('除外する:'), findsOneWidget);
      expect(find.text('*.dart'), findsOneWidget);
      expect(find.text('build/'), findsOneWidget);

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('編集'), findsOneWidget);
      expect(find.text('強制再スキャン'), findsOneWidget);
      expect(find.text('削除'), findsOneWidget);
    });

    testWidgets('start sync button updates provider state', (
      WidgetTester tester,
    ) async {
      await _setMobileSurface(tester);

      final job = createTestSyncJob(
        id: 'detail-job-3',
        name: 'ドキュメント同期',
        isActive: false,
      );
      final syncProvider = SyncProvider(StorageService())..addJob(job);
      final providers = await createTestProviders(syncProvider: syncProvider);

      await tester.pumpWidget(
        buildTestApp(providers, SyncDetailScreen(job: job)),
      );
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('同期開始'));
      await tester.pump();

      expect(syncProvider.syncState, SyncState.running);
      expect(syncProvider.getJobById(job.id)?.isActive, isTrue);
    });
  });
}
