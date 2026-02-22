import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncsphere/providers/premium_provider.dart';
import 'package:syncsphere/screens/premium/premium_screen.dart';

import '../helpers/test_data.dart';
import '../helpers/test_helpers.dart';

class _FakePremiumProvider extends PremiumProvider {
  _FakePremiumProvider({required bool isPremium, bool isPurchasePending = false})
    : _isPremium = isPremium,
      _isPurchasePending = isPurchasePending;

  final bool _isPremium;
  final bool _isPurchasePending;

  int purchaseCalls = 0;
  int restoreCalls = 0;

  @override
  bool get isPremium => _isPremium;

  @override
  bool get isPurchasePending => _isPurchasePending;

  @override
  Future<void> purchasePremium() async {
    purchaseCalls += 1;
  }

  @override
  Future<void> restorePurchases() async {
    restoreCalls += 1;
  }
}

Future<void> _setMobileSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(400, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

void main() {
  setUpAll(() {
    initTestEnvironment();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('PremiumScreen', () {
    testWidgets('renders purchase state for free users', (WidgetTester tester) async {
      await _setMobileSurface(tester);

      final seedJob = createTestSyncJob(name: 'seed');
      expect(seedJob.name, 'seed');

      final premiumProvider = _FakePremiumProvider(isPremium: false);
      await pumpTestScreen(
        tester,
        const PremiumScreen(),
        premiumProvider: premiumProvider,
      );

      expect(find.text('SyncSphere プレミアム'), findsOneWidget);
      expect(find.text('プレミアムを購入'), findsOneWidget);
      expect(find.text('購入を復元'), findsOneWidget);
      expect(find.text('無料プラン'), findsOneWidget);
      expect(find.text('プレミアムプラン'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -250));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('一回限りの購入 — サブスクリプションなし'), findsOneWidget);
    });

    testWidgets('renders premium success state', (WidgetTester tester) async {
      await _setMobileSurface(tester);

      await pumpTestScreen(
        tester,
        const PremiumScreen(),
        premiumProvider: _FakePremiumProvider(isPremium: true),
      );

      expect(find.text('プレミアム会員です'), findsOneWidget);
      expect(find.text('SyncSphereをご支援いただきありがとうございます！'), findsOneWidget);
      expect(find.text('広告の完全非表示'), findsOneWidget);
      expect(find.text('無制限の同期速度'), findsOneWidget);
      expect(find.text('優先サポート'), findsOneWidget);
      expect(find.text('プレミアムを購入'), findsNothing);
    });

    testWidgets('purchase and restore buttons call provider methods', (WidgetTester tester) async {
      await _setMobileSurface(tester);

      final premiumProvider = _FakePremiumProvider(isPremium: false);
      await pumpTestScreen(
        tester,
        const PremiumScreen(),
        premiumProvider: premiumProvider,
      );

      await tester.tap(find.text('プレミアムを購入'));
      await tester.pump();
      await tester.tap(find.text('購入を復元'));
      await tester.pump();

      expect(premiumProvider.purchaseCalls, 1);
      expect(premiumProvider.restoreCalls, 1);
    });
  });
}
