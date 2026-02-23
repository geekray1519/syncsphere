// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'SyncSphere';

  @override
  String get appSubtitle => 'スマートファイル同期';

  @override
  String get home => 'ホーム';

  @override
  String get syncJobs => '同期ジョブ';

  @override
  String get devices => 'デバイス';

  @override
  String get settings => '設定';

  @override
  String get history => '履歴';

  @override
  String get welcomeTitle => 'SyncSphereへようこそ';

  @override
  String get welcomeSubtitle => 'ファイルを安全・簡単に同期しましょう';

  @override
  String get getStarted => 'はじめる';

  @override
  String get skip => 'スキップ';

  @override
  String get next => '次へ';

  @override
  String get back => '戻る';

  @override
  String get done => '完了';

  @override
  String get cancel => 'キャンセル';

  @override
  String get cancelButton => '中止';

  @override
  String get continueButton => '続行';

  @override
  String get save => '保存';

  @override
  String get delete => '削除';

  @override
  String get edit => '編集';

  @override
  String get confirm => '確認';

  @override
  String get close => '閉じる';

  @override
  String get retry => '再試行';

  @override
  String get ok => 'OK';

  @override
  String get setupWizardTitle => '接続設定ウィザード';

  @override
  String get setupWizardStep1 => '同期モードを選択';

  @override
  String get setupWizardStep2 => 'フォルダを選択';

  @override
  String get setupWizardStep3 => 'デバイスを接続';

  @override
  String get setupWizardStep4 => '設定を確認';

  @override
  String get syncModeTitle => '同期モードを選んでください';

  @override
  String get syncModeMirror => 'ミラー同期';

  @override
  String get syncModeMirrorDesc =>
      '元フォルダの内容を先フォルダに完全コピーします。先フォルダにのみ存在するファイルは削除されます。';

  @override
  String get syncModeTwoWay => '双方向同期';

  @override
  String get syncModeTwoWayDesc => '両方のフォルダの変更を互いに反映します。どちらのフォルダで変更しても同期されます。';

  @override
  String get syncModeUpdate => 'アップデート同期';

  @override
  String get syncModeUpdateDesc => '新しいファイルと更新されたファイルのみをコピーします。削除は反映されません。';

  @override
  String get syncModeCustom => 'カスタム同期';

  @override
  String get syncModeCustomDesc => '各操作（作成・更新・削除）の同期方向を個別に設定できます。';

  @override
  String get selectSourceFolder => '元フォルダを選択';

  @override
  String get selectTargetFolder => '先フォルダを選択';

  @override
  String get sourceFolder => '元フォルダ';

  @override
  String get targetFolder => '先フォルダ';

  @override
  String get browseFolder => 'フォルダを参照';

  @override
  String get folderPath => 'フォルダのパス';

  @override
  String get noFolderSelected => 'フォルダが選択されていません';

  @override
  String get connectionType => '接続方法';

  @override
  String get connectionLocal => 'ローカル / USB';

  @override
  String get connectionLocalDesc => '同じPC内のフォルダ間、またはUSBドライブと同期';

  @override
  String get connectionLAN => 'LAN（ローカルネットワーク）';

  @override
  String get connectionLANDesc => '同じWi-Fiネットワーク内のデバイスと同期';

  @override
  String get connectionSFTP => 'SFTP（リモートサーバー）';

  @override
  String get connectionSFTPDesc => 'SSHで接続するリモートサーバーと同期';

  @override
  String get connectionFTP => 'FTP / FTPS';

  @override
  String get connectionFTPDesc => 'FTPサーバーと同期（SSL/TLS暗号化対応）';

  @override
  String get connectionP2P => 'P2P（デバイス間直接接続）';

  @override
  String get connectionP2PDesc => 'インターネット経由でデバイス間を直接接続して同期';

  @override
  String get sftpHost => 'ホスト名 / IPアドレス';

  @override
  String get sftpPort => 'ポート番号';

  @override
  String get sftpUsername => 'ユーザー名';

  @override
  String get sftpPassword => 'パスワード';

  @override
  String get sftpKeyFile => '秘密鍵ファイル';

  @override
  String get sftpRemotePath => 'リモートパス';

  @override
  String get testConnection => '接続テスト';

  @override
  String get connectionSuccess => '接続に成功しました！';

  @override
  String get connectionFailed => '接続に失敗しました';

  @override
  String get devicePairing => 'デバイスペアリング';

  @override
  String get devicePairingDesc => 'QRコードをスキャンするか、デバイスIDを入力して接続';

  @override
  String get myDeviceId => 'このデバイスのID';

  @override
  String get scanQRCode => 'QRコードをスキャン';

  @override
  String get showMyQRCode => '自分のQRコードを表示';

  @override
  String get enterDeviceId => 'デバイスIDを入力';

  @override
  String get deviceIdHint => '例: ABCDE-FGHIJ-KLMNO-PQRST';

  @override
  String get addDevice => 'デバイスを追加';

  @override
  String get removeDevice => 'デバイスを削除';

  @override
  String get deviceName => 'デバイス名';

  @override
  String get deviceStatus => 'ステータス';

  @override
  String get deviceOnline => 'オンライン';

  @override
  String get deviceOffline => 'オフライン';

  @override
  String get deviceSyncing => '同期中';

  @override
  String get deviceConnecting => '接続中...';

  @override
  String get compareFiles => '比較';

  @override
  String get comparing => '比較中...';

  @override
  String get compareByTime => '日時とサイズで比較';

  @override
  String get compareByContent => '内容（バイト単位）で比較';

  @override
  String get compareBySize => 'サイズのみで比較';

  @override
  String get startSync => '同期を開始';

  @override
  String get stopSync => '同期を停止';

  @override
  String get startSyncButton => '同期開始';

  @override
  String get stopSyncButton => '停止';

  @override
  String get pauseSync => '同期を一時停止';

  @override
  String get resumeSync => '同期を再開';

  @override
  String get syncing => '同期中...';

  @override
  String get syncingStatus => '同期中...';

  @override
  String get syncComplete => '同期が完了しました';

  @override
  String get syncCompletedStatus => '同期完了';

  @override
  String get syncFailed => '同期に失敗しました';

  @override
  String get syncErrorStatus => '同期エラー';

  @override
  String get syncProgress => '同期の進捗';

  @override
  String get syncStats => '同期統計';

  @override
  String get filesTotal => '合計ファイル数';

  @override
  String get filesProcessed => '処理済みファイル数';

  @override
  String get filesCopied => 'コピー済み';

  @override
  String get filesDeleted => '削除済み';

  @override
  String get filesSkipped => 'スキップ済み';

  @override
  String get filesConflict => '競合';

  @override
  String get totalSize => '合計サイズ';

  @override
  String get transferSpeed => '転送速度';

  @override
  String get timeRemaining => '残り時間';

  @override
  String get timeElapsed => '経過時間';

  @override
  String get filterTitle => 'フィルタ設定';

  @override
  String get filterInclude => '含める';

  @override
  String get filterExclude => '除外する';

  @override
  String get filterIncludeHint => '例: *.jpg | *.png | Documents\\';

  @override
  String get filterExcludeHint => '例: *.tmp | *.log | \$Recycle.Bin\\';

  @override
  String get versioningTitle => 'バージョン管理';

  @override
  String get versioningNone => 'バージョン管理なし';

  @override
  String get versioningTrashCan => 'ゴミ箱方式';

  @override
  String get versioningTrashCanDesc => '削除・上書きされたファイルをゴミ箱フォルダに移動';

  @override
  String get versioningTimestamp => 'タイムスタンプ方式';

  @override
  String get versioningTimestampDesc => '各バージョンに日時を付けて保存';

  @override
  String get versioningFolder => 'バージョン保存先フォルダ';

  @override
  String get versioningKeepDays => '保持日数';

  @override
  String get scheduleTitle => 'スケジュール設定';

  @override
  String get scheduleEnabled => 'スケジュールを有効にする';

  @override
  String get scheduleInterval => '実行間隔';

  @override
  String get scheduleEvery5Min => '5分ごと';

  @override
  String get scheduleEvery15Min => '15分ごと';

  @override
  String get scheduleEvery30Min => '30分ごと';

  @override
  String get scheduleEveryHour => '1時間ごと';

  @override
  String get scheduleEveryDay => '毎日';

  @override
  String get scheduleCustom => 'カスタム';

  @override
  String get scheduleRealtime => 'リアルタイム（ファイル変更時に自動同期）';

  @override
  String get settingsGeneral => '一般';

  @override
  String get settingsTheme => 'テーマ';

  @override
  String get settingsThemeLight => 'ライト';

  @override
  String get settingsThemeDark => 'ダーク';

  @override
  String get settingsThemeSystem => 'システムに合わせる';

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsNotifications => '通知';

  @override
  String get settingsNotificationsEnabled => '通知を有効にする';

  @override
  String get settingsAbout => 'このアプリについて';

  @override
  String get settingsVersion => 'バージョン';

  @override
  String get settingsLicense => 'ライセンス';

  @override
  String get settingsPrivacyPolicy => 'プライバシーポリシー';

  @override
  String get settingsBandwidthLimit => '帯域制限';

  @override
  String get settingsMaxUpload => '最大アップロード速度';

  @override
  String get settingsMaxDownload => '最大ダウンロード速度';

  @override
  String get settingsUnlimited => '無制限';

  @override
  String get errorGeneral => 'エラーが発生しました';

  @override
  String get errorNetworkTimeout => 'ネットワークタイムアウト';

  @override
  String get errorPermissionDenied => 'アクセス権限がありません';

  @override
  String get errorFolderNotFound => 'フォルダが見つかりません';

  @override
  String get errorDiskFull => 'ディスク容量が不足しています';

  @override
  String get errorFileInUse => 'ファイルが使用中です';

  @override
  String get errorConnectionLost => '接続が切断されました';

  @override
  String get serverStartError => 'サーバー起動エラー';

  @override
  String get serverCrashed => 'サーバーが予期せず停止しました';

  @override
  String get syncErrorTitle => '同期エラー';

  @override
  String get cancelSyncConfirmTitle => '同期を中止しますか？';

  @override
  String get cancelSyncConfirmMessage => '進行中の同期は停止します。';

  @override
  String get jobNameRequired => 'ジョブ名は必須です';

  @override
  String get folderPickerError => 'フォルダを選択できませんでした';

  @override
  String get exitWizardTitle => 'ウィザードを終了しますか？';

  @override
  String get exitWizardMessage => '入力内容は失われます';

  @override
  String get exitButton => '終了';

  @override
  String get stayButton => '続ける';

  @override
  String get conflictTitle => 'ファイルの競合';

  @override
  String get conflictDesc => '同じファイルが両方で変更されています';

  @override
  String get conflictKeepLeft => '元フォルダのファイルを使用';

  @override
  String get conflictKeepRight => '先フォルダのファイルを使用';

  @override
  String get conflictKeepBoth => '両方を保持（名前を変更）';

  @override
  String get conflictKeepNewer => '新しいファイルを使用';

  @override
  String get onboardingTitle1 => 'ファイルを安全に同期';

  @override
  String get onboardingDesc1 =>
      'ローカルフォルダ、USBドライブ、ネットワーク、リモートサーバー間でファイルを簡単に同期できます。';

  @override
  String get onboardingTitle2 => '3つの同期モード';

  @override
  String get onboardingDesc2 => 'ミラー・双方向・アップデートの3つのモードから選べます。カスタム設定も可能です。';

  @override
  String get onboardingTitle3 => 'かんたん接続';

  @override
  String get onboardingDesc3 => 'QRコードスキャンやウィザードで、デバイスの接続を簡単に設定できます。';

  @override
  String get onboardingTitle4 => '安心のバックアップ';

  @override
  String get onboardingDesc4 => 'バージョン管理で大切なファイルを保護。万が一の時も安心です。';

  @override
  String get adRemoveAds => '広告を非表示にする';

  @override
  String get adWatchToUnlock => '動画を見て機能をアンロック';

  @override
  String get adFreeFor24h => '24時間広告なし';

  @override
  String get noSyncJobs => '同期ジョブがありません';

  @override
  String get noSyncJobsDesc => '「新しいジョブを作成」をタップして最初の同期ジョブを設定しましょう';

  @override
  String get createNewJob => '新しいジョブを作成';

  @override
  String get jobName => 'ジョブ名';

  @override
  String get jobNameHint => '例: 写真バックアップ、ドキュメント同期';

  @override
  String get lastSync => '最終同期';

  @override
  String get lastSyncPrefix => '最終同期';

  @override
  String get neverSynced => '未同期';

  @override
  String minutesAgo(int count) {
    return '$count分前';
  }

  @override
  String hoursAgo(int count) {
    return '$count時間前';
  }

  @override
  String get justNow => 'たった今';

  @override
  String get helpTitle => 'ヘルプ';

  @override
  String get helpSetup => '接続設定の方法';

  @override
  String get helpSyncModes => '同期モードの違い';

  @override
  String get helpFilters => 'フィルタの使い方';

  @override
  String get helpTroubleshooting => 'トラブルシューティング';

  @override
  String get helpFAQ => 'よくある質問';

  @override
  String get premiumTitle => 'SyncSphere プレミアム';

  @override
  String get premiumSubtitle => '広告なしで快適に利用しましょう';

  @override
  String get premiumFeature1 => '広告なしの快適体験';

  @override
  String get premiumFeature2 => '優先サポート';

  @override
  String get premiumFeature3 => 'SyncSphereチームからの迅速なサポート';

  @override
  String get premiumPurchase => 'プレミアムにアップグレード';

  @override
  String get premiumRestore => '購入を復元';

  @override
  String get premiumActive => 'プレミアム会員です';

  @override
  String get premiumActiveDesc => 'すべてのプレミアム機能をご利用いただけます。広告は表示されません。';

  @override
  String get premiumProcessing => '処理中...';

  @override
  String get premiumError => 'エラー';

  @override
  String get premiumPrice => '¥3,000';

  @override
  String get premium => 'プレミアム';

  @override
  String get serverTitle => 'PC同期';

  @override
  String get serverStart => 'サーバーを開始';

  @override
  String get serverStop => 'サーバーを停止';

  @override
  String get serverRunning => 'サーバー稼働中';

  @override
  String get serverStopped => 'サーバー停止中';

  @override
  String get serverUrl => '接続URL';

  @override
  String get serverUrlCopied => 'URLをコピーしました';

  @override
  String get serverInstruction1 => '1. PCのブラウザで下のURLを開いてください';

  @override
  String get serverInstruction2 => '2. または、QRコードをスキャンしてください';

  @override
  String get serverInstruction3 => '3. ブラウザで同期フォルダを選択して同期開始！';

  @override
  String serverConnectedClients(int count) {
    return '接続中のクライアント: $count';
  }

  @override
  String get serverSyncDir => '同期フォルダ';

  @override
  String get serverChangeSyncDir => '同期フォルダを変更';

  @override
  String get serverNoClients => 'デバイスの接続を待っています...';

  @override
  String get tabDashboard => 'ダッシュボード';

  @override
  String get tabFolders => 'フォルダ';

  @override
  String get tabDevices => 'デバイス';

  @override
  String get tabSettings => '設定';

  @override
  String get dashboardTitle => 'SyncSphere';

  @override
  String get quickActionAddFolder => 'フォルダ追加';

  @override
  String get quickActionPcSync => 'PC同期';

  @override
  String get quickActionAddDevice => 'デバイス追加';

  @override
  String get noFoldersTitle => 'フォルダがありません';

  @override
  String get noFoldersSubtitle => 'フォルダを追加して同期を始めましょう';

  @override
  String get noDevicesTitle => 'デバイスがありません';

  @override
  String get noDevicesSubtitle => 'デバイスを追加してファイルを同期しましょう';

  @override
  String get scanQrCode => 'QRスキャン';

  @override
  String get manualAdd => '手動追加';

  @override
  String get connectionInfo => '接続情報';

  @override
  String get sharedFolders => '共有フォルダ';

  @override
  String get noSharedFolders => '共有フォルダはありません';

  @override
  String get statistics => '統計';

  @override
  String get status => 'ステータス';

  @override
  String get removeDeviceConfirm => 'このデバイスを削除しますか？';

  @override
  String get actionCannotBeUndone => 'この操作は取り消せません。';

  @override
  String get settingsSync => '同期';

  @override
  String get settingsRunConditions => '実行条件';

  @override
  String get settingsBackground => 'バックグラウンド';

  @override
  String get settingsStorage => 'ストレージ';

  @override
  String get settingsBackup => 'バックアップ';

  @override
  String get settingsPremium => 'プレミアム';

  @override
  String get themeSystem => 'システム';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get syncModeDefault => 'デフォルト同期モード';

  @override
  String get bandwidthUpload => 'アップロード帯域';

  @override
  String get bandwidthDownload => 'ダウンロード帯域';

  @override
  String get wifiOnlySync => 'WiFiのみで同期';

  @override
  String get chargingOnlySync => '充電中のみで同期';

  @override
  String get batterySaverOff => '省電力モードOFF時のみ';

  @override
  String get allowedSsids => '許可されたSSID';

  @override
  String get addSsid => 'SSIDを追加';

  @override
  String get backgroundSync => 'バックグラウンド同期';

  @override
  String get autoStartOnBoot => '起動時に自動開始';

  @override
  String get disableBatteryOptimization => 'バッテリー最適化を無効化';

  @override
  String get settingsSaved => '設定を保存しました';

  @override
  String get permissionDenied => '権限が拒否されました';

  @override
  String get syncCompleteNotification => '同期完了';

  @override
  String get errorNotification => 'エラー通知';

  @override
  String get newDeviceNotification => '新しいデバイス検出';

  @override
  String get exportConfig => '設定をエクスポート';

  @override
  String get importConfig => '設定をインポート';

  @override
  String get upgradePremium => 'プレミアムにアップグレード';

  @override
  String get restorePurchases => '購入を復元';

  @override
  String get premiumMember => 'プレミアム会員です';

  @override
  String get freePlan => '無料プラン';

  @override
  String get premiumPlan => 'プレミアムプラン';

  @override
  String get oneTimePurchase => '一回限りの購入';

  @override
  String get noSubscription => 'サブスクリプションなし';

  @override
  String get purchasePremium => 'プレミアムを購入';

  @override
  String get startServer => 'サーバーを開始';

  @override
  String get stopServer => 'サーバーを停止';

  @override
  String get serverInstructions1 => '同じWiFiネットワークに接続してください';

  @override
  String get serverInstructions2 => 'PCのブラウザで上記URLを開いてください';

  @override
  String get serverInstructions3 => 'フォルダを選択して同期を開始できます';

  @override
  String get noInstallRequired => 'PCにソフトウェアのインストールは不要です';

  @override
  String get connectedClients => '接続中のクライアント';

  @override
  String get syncOverview => '概要';

  @override
  String get syncFolders => 'フォルダ';

  @override
  String get syncFilters => 'フィルタ';

  @override
  String get forceRescan => '強制再スキャン';

  @override
  String get noFilters => 'フィルタなし';

  @override
  String get lastSyncResult => '最後の同期結果';

  @override
  String get filesComplete => '完了';

  @override
  String get speed => '速度';

  @override
  String get copied => 'コピー済み';

  @override
  String get deleted => '削除済み';

  @override
  String get skipped => 'スキップ';

  @override
  String get conflicts => '競合';

  @override
  String get errors => 'エラー';

  @override
  String get duration => '所要時間';

  @override
  String get version => 'バージョン';

  @override
  String get licenses => 'ライセンス';

  @override
  String get sourceCode => 'ソースコード';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get copyUrl => 'URLをコピー';

  @override
  String get shareUrl => 'URLを共有';

  @override
  String get urlCopied => 'URLがクリップボードにコピーされました';

  @override
  String get activeSyncs => '同期中';

  @override
  String get recentSync => '最近の同期';

  @override
  String get noFoldersDescription => 'フォルダ設定を作成し、ファイルを同期します';

  @override
  String get noFoldersAction => '右下の「＋」ボタンから新しいフォルダを追加してください。';

  @override
  String get neverConnected => '未接続';

  @override
  String get ipAddress => 'IPアドレス';

  @override
  String get port => 'ポート';

  @override
  String get transferAmount => '転送量';

  @override
  String get lastConnected => '最終接続';

  @override
  String get ssidHint => 'WiFiネットワーク名を入力';

  @override
  String get premiumThankYou => 'SyncSphereをご支援いただきありがとうございます！';

  @override
  String get basicSync => '基本同期';

  @override
  String get noAds => '広告なし';

  @override
  String get fastSync => '高速同期';

  @override
  String get noAdsComplete => '広告の完全非表示';

  @override
  String get unlimitedSpeed => '無制限の同期速度';

  @override
  String get prioritySupport => '優先サポート';

  @override
  String get syncModeLabel => '同期モード';

  @override
  String get compareModeLabel => '比較モード';

  @override
  String get running => '実行中';

  @override
  String get waiting => '待機中';

  @override
  String get paths => 'パス';

  @override
  String get source => 'ソース';

  @override
  String get target => 'ターゲット';

  @override
  String get type => '種類';

  @override
  String get previousResult => '前回の結果';

  @override
  String get files => 'ファイル';

  @override
  String aboutMinutes(int min) {
    return '約 $min分';
  }

  @override
  String get preparing => '準備中...';

  @override
  String get detailedInfo => '詳細情報';

  @override
  String get directPcSync => 'PCと直接接続して同期';

  @override
  String get disableBatteryOptDesc => 'バッテリー最適化を無効にすると、バックグラウンド同期が安定します';

  @override
  String summaryCardSemantics(String title, String value) {
    return '$title: $value';
  }

  @override
  String deviceStatusSemantics(String status) {
    return 'デバイス状態: $status';
  }

  @override
  String syncProgressSemantics(int percent) {
    return '進捗: $percent%';
  }

  @override
  String serverStatusSemantics(String status) {
    return 'サーバーステータス: $status';
  }
}
