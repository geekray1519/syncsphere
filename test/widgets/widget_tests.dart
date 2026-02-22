import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncsphere/models/sync_job.dart';
import 'package:syncsphere/widgets/progress_indicator_widget.dart';
import 'package:syncsphere/widgets/sync_mode_selector.dart';
import 'package:syncsphere/widgets/connection_type_selector.dart';

import '../helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    initTestEnvironment();
  });

  group('ProgressIndicatorWidget', () {
    testWidgets('renders bar at 50% without percentage label', (
      WidgetTester tester,
    ) async {
      final TestProviders providers = await createTestProviders();
      await tester.pumpWidget(
        buildTestApp(
          providers,
          const Scaffold(
            body: ProgressIndicatorWidget(progress: 0.5),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      // No percentage text when showPercentage is false (default)
      expect(find.text('50%'), findsNothing);
    });

    testWidgets('shows percentage label when showPercentage is true', (
      WidgetTester tester,
    ) async {
      final TestProviders providers = await createTestProviders();
      await tester.pumpWidget(
        buildTestApp(
          providers,
          const Scaffold(
            body: ProgressIndicatorWidget(
              progress: 0.75,
              showPercentage: true,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('clamps progress to 0-100 range', (
      WidgetTester tester,
    ) async {
      final TestProviders providers = await createTestProviders();
      await tester.pumpWidget(
        buildTestApp(
          providers,
          const Scaffold(
            body: ProgressIndicatorWidget(
              progress: 1.5,
              showPercentage: true,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('100%'), findsOneWidget);
    });
  });

  group('SyncModeSelector', () {
    testWidgets('renders all 4 sync mode segments', (
      WidgetTester tester,
    ) async {
      SyncMode? selectedMode;

      final TestProviders providers = await createTestProviders();
      await tester.pumpWidget(
        buildTestApp(
          providers,
          Scaffold(
            body: SyncModeSelector(
              selectedMode: SyncMode.mirror,
              onSelected: (mode) => selectedMode = mode,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('ミラーリング'), findsOneWidget);
      expect(find.text('双方向同期'), findsOneWidget);
      expect(find.text('更新のみ'), findsOneWidget);
      expect(find.text('カスタム'), findsOneWidget);
      expect(selectedMode, isNull);
    });

    testWidgets('shows description for selected mode', (
      WidgetTester tester,
    ) async {
      final TestProviders providers = await createTestProviders();
      await tester.pumpWidget(
        buildTestApp(
          providers,
          Scaffold(
            body: SyncModeSelector(
              selectedMode: SyncMode.mirror,
              onSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(
        find.text('元フォルダと全く同じ状態にします。不要なファイルは削除されます。'),
        findsOneWidget,
      );
    });

    testWidgets('tapping segment calls onSelected', (
      WidgetTester tester,
    ) async {
      SyncMode? selectedMode;

      final TestProviders providers = await createTestProviders();
      await tester.pumpWidget(
        buildTestApp(
          providers,
          Scaffold(
            body: SyncModeSelector(
              selectedMode: SyncMode.mirror,
              onSelected: (mode) => selectedMode = mode,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('双方向同期'));
      await tester.pump(const Duration(seconds: 1));

      expect(selectedMode, SyncMode.twoWay);
    });
  });

  group('ConnectionTypeSelector', () {
    testWidgets('renders all 5 connection type chips', (
      WidgetTester tester,
    ) async {
      final TestProviders providers = await createTestProviders();
      await tester.pumpWidget(
        buildTestApp(
          providers,
          Scaffold(
            body: ConnectionTypeSelector(
              selectedType: ConnectionType.local,
              onSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('ローカル'), findsOneWidget);
      expect(find.text('LAN / Wi-Fi'), findsOneWidget);
      expect(find.text('SFTP'), findsOneWidget);
      expect(find.text('FTP'), findsOneWidget);
      expect(find.text('P2P'), findsOneWidget);
    });

    testWidgets('tapping chip calls onSelected', (
      WidgetTester tester,
    ) async {
      ConnectionType? selectedType;

      final TestProviders providers = await createTestProviders();
      await tester.pumpWidget(
        buildTestApp(
          providers,
          Scaffold(
            body: ConnectionTypeSelector(
              selectedType: ConnectionType.local,
              onSelected: (type) => selectedType = type,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('SFTP'));
      await tester.pump(const Duration(seconds: 1));

      expect(selectedType, ConnectionType.sftp);
    });
  });
}
