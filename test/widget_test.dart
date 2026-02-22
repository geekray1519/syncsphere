import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncsphere/screens/shell/app_shell.dart';

import 'helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    initTestEnvironment();
  });

  testWidgets('SyncSphere smoke test — AppShell renders', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pump();

    await pumpTestScreen(tester, const AppShell(), settle: false);
    await tester.pump(const Duration(seconds: 1));

    final int navCount =
        find.byType(NavigationBar).evaluate().length +
        find.byType(NavigationRail).evaluate().length;

    expect(find.text('SyncSphere'), findsOneWidget);
    expect(navCount, greaterThan(0));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
