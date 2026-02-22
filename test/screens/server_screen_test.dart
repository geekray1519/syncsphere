import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncsphere/providers/server_provider.dart';
import 'package:syncsphere/screens/server/server_screen.dart';

import '../helpers/test_data.dart';
import '../helpers/test_helpers.dart';

class _FakeServerProvider extends ServerProvider {
  _FakeServerProvider({
    required bool running,
    required String? url,
    required int clients,
    String syncDir = '/tmp/syncsphere',
  }) : _running = running,
       _url = url,
       _clients = clients,
       _syncDir = syncDir;

  final bool _running;
  final String? _url;
  final int _clients;
  final String _syncDir;

  int toggleCalls = 0;

  @override
  bool get isRunning => _running;

  @override
  String? get serverUrl => _url;

  @override
  int get connectedClients => _clients;

  @override
  String get syncDir => _syncDir;

  @override
  Future<void> toggleServer(String syncDir) async {
    toggleCalls += 1;
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

  group('ServerScreen', () {
    testWidgets('renders stopped state and supports scrolling', (WidgetTester tester) async {
      await _setMobileSurface(tester);

      final fakeProvider = _FakeServerProvider(
        running: false,
        url: null,
        clients: 0,
      );

      await pumpTestScreen(
        tester,
        const ServerScreen(),
        serverProvider: fakeProvider,
        settle: false,
      );
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('PC同期'), findsOneWidget);
      expect(find.text('サーバー停止中'), findsOneWidget);
      expect(find.text('サーバーを開始'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('PCにソフトウェアのインストールは不要です'), findsOneWidget);
    });

    testWidgets('start button triggers provider toggle', (WidgetTester tester) async {
      await _setMobileSurface(tester);

      final fakeProvider = _FakeServerProvider(
        running: false,
        url: null,
        clients: 0,
      );

      await pumpTestScreen(
        tester,
        const ServerScreen(),
        serverProvider: fakeProvider,
        settle: false,
      );
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('サーバーを開始'));
      await tester.pump();

      expect(fakeProvider.toggleCalls, 1);
    });

    testWidgets('running state shows URL, instructions, and copy action', (WidgetTester tester) async {
      await _setMobileSurface(tester);

      final testDevice = createTestDeviceInfo(address: '192.168.10.20', port: 8384);
      final fakeProvider = _FakeServerProvider(
        running: true,
        url: 'http://${testDevice.address}:${testDevice.port}',
        clients: 2,
      );

      await pumpTestScreen(
        tester,
        const ServerScreen(),
        serverProvider: fakeProvider,
        settle: false,
      );
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('サーバー稼働中'), findsOneWidget);
      expect(find.textContaining(testDevice.address), findsOneWidget);
      expect(find.text('接続中のクライアント: 2'), findsOneWidget);
      expect(find.text('同じWiFiネットワークに接続してください'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('サーバーを停止'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('サーバーを停止'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.copy_rounded));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('URLをコピーしました'), findsOneWidget);
    });
  });
}
