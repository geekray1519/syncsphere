import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncsphere/providers/sync_provider.dart';
import 'package:syncsphere/screens/shell/app_shell.dart';

import '../helpers/test_data.dart';
import '../helpers/test_helpers.dart';

void _expectAdaptiveNavigationVisible() {
  final int navCount =
      find.byType(NavigationBar).evaluate().length +
      find.byType(NavigationRail).evaluate().length;
  expect(navCount, greaterThan(0));
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    initTestEnvironment();
  });

  testWidgets('shows mobile navigation bar and dashboard empty state', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pump();

    await pumpTestScreen(tester, const AppShell(), settle: false);
    await tester.pump(const Duration(seconds: 1));

    _expectAdaptiveNavigationVisible();
    expect(find.text('SyncSphere'), findsOneWidget);
    expect(find.text('フォルダを追加して同期を始めましょう'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('switches tabs on mobile navigation tap', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pump();

    await pumpTestScreen(tester, const AppShell(), settle: false);
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byIcon(Icons.folder_outlined));
    await tester.pump();
    expect(find.text('フォルダ'), findsWidgets);

    await tester.tap(find.byIcon(Icons.dashboard_outlined));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('フォルダを追加して同期を始めましょう'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('shows navigation rail on desktop width', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pump();

    await pumpTestScreen(tester, const AppShell(), settle: false);
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('SyncSphere'), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('keeps dashboard content after tab changes', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pump();

    final SyncProvider syncProvider = SyncProvider();
    syncProvider.addJob(createTestSyncJob(name: '維持されるジョブ'));

    await pumpTestScreen(
      tester,
      const AppShell(),
      syncProvider: syncProvider,
      settle: false,
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('維持されるジョブ'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.folder_outlined));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.dashboard_outlined));
    await tester.pump();

    expect(find.text('維持されるジョブ'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('allows scrolling dashboard list inside shell', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pump();

    final SyncProvider syncProvider = SyncProvider();
    for (final job in createTestSyncJobs(5)) {
      syncProvider.addJob(job);
    }

    await pumpTestScreen(
      tester,
      const AppShell(),
      syncProvider: syncProvider,
      settle: false,
    );
    await tester.pump(const Duration(seconds: 1));

    await tester.drag(find.byType(ListView).first, const Offset(0, -300));
    await tester.pump();

    _expectAdaptiveNavigationVisible();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
