import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncsphere/widgets/empty_state_widget.dart';

import '../helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    initTestEnvironment();
  });

  testWidgets('renders icon, title, and description', (
    WidgetTester tester,
  ) async {
    final TestProviders providers = await createTestProviders();
    await tester.pumpWidget(
      buildTestApp(
        providers,
        const Scaffold(
          body: EmptyStateWidget(
            icon: Icons.folder_off_outlined,
            title: 'フォルダがありません',
            description: 'フォルダを追加して同期を始めましょう',
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.byIcon(Icons.folder_off_outlined), findsOneWidget);
    expect(find.text('フォルダがありません'), findsOneWidget);
    expect(find.text('フォルダを追加して同期を始めましょう'), findsOneWidget);
  });

  testWidgets('shows action button when actionLabel provided', (
    WidgetTester tester,
  ) async {
    bool actionFired = false;

    final TestProviders providers = await createTestProviders();
    await tester.pumpWidget(
      buildTestApp(
        providers,
        Scaffold(
          body: EmptyStateWidget(
            icon: Icons.devices_outlined,
            title: 'デバイスなし',
            description: 'デバイスを追加してください',
            actionLabel: '追加する',
            onAction: () => actionFired = true,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('追加する'), findsOneWidget);

    await tester.tap(find.text('追加する'));
    expect(actionFired, isTrue);
  });

  testWidgets('hides action button when no actionLabel', (
    WidgetTester tester,
  ) async {
    final TestProviders providers = await createTestProviders();
    await tester.pumpWidget(
      buildTestApp(
        providers,
        const Scaffold(
          body: EmptyStateWidget(
            icon: Icons.info,
            title: 'タイトル',
            description: '説明',
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(ElevatedButton), findsNothing);
  });
}
