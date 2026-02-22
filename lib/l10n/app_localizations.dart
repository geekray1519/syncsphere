import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ja'),
    Locale('en'),
  ];

  /// アプリケーションのタイトル
  ///
  /// In ja, this message translates to:
  /// **'SyncSphere'**
  String get appTitle;

  /// アプリのサブタイトル
  ///
  /// In ja, this message translates to:
  /// **'スマートファイル同期'**
  String get appSubtitle;

  /// No description provided for @home.
  ///
  /// In ja, this message translates to:
  /// **'ホーム'**
  String get home;

  /// No description provided for @syncJobs.
  ///
  /// In ja, this message translates to:
  /// **'同期ジョブ'**
  String get syncJobs;

  /// No description provided for @devices.
  ///
  /// In ja, this message translates to:
  /// **'デバイス'**
  String get devices;

  /// No description provided for @settings.
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get settings;

  /// No description provided for @history.
  ///
  /// In ja, this message translates to:
  /// **'履歴'**
  String get history;

  /// No description provided for @welcomeTitle.
  ///
  /// In ja, this message translates to:
  /// **'SyncSphereへようこそ'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'ファイルを安全・簡単に同期しましょう'**
  String get welcomeSubtitle;

  /// No description provided for @getStarted.
  ///
  /// In ja, this message translates to:
  /// **'はじめる'**
  String get getStarted;

  /// No description provided for @skip.
  ///
  /// In ja, this message translates to:
  /// **'スキップ'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In ja, this message translates to:
  /// **'次へ'**
  String get next;

  /// No description provided for @back.
  ///
  /// In ja, this message translates to:
  /// **'戻る'**
  String get back;

  /// No description provided for @done.
  ///
  /// In ja, this message translates to:
  /// **'完了'**
  String get done;

  /// No description provided for @cancel.
  ///
  /// In ja, this message translates to:
  /// **'キャンセル'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In ja, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In ja, this message translates to:
  /// **'削除'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In ja, this message translates to:
  /// **'編集'**
  String get edit;

  /// No description provided for @confirm.
  ///
  /// In ja, this message translates to:
  /// **'確認'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In ja, this message translates to:
  /// **'閉じる'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In ja, this message translates to:
  /// **'再試行'**
  String get retry;

  /// No description provided for @ok.
  ///
  /// In ja, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @setupWizardTitle.
  ///
  /// In ja, this message translates to:
  /// **'接続設定ウィザード'**
  String get setupWizardTitle;

  /// No description provided for @setupWizardStep1.
  ///
  /// In ja, this message translates to:
  /// **'同期モードを選択'**
  String get setupWizardStep1;

  /// No description provided for @setupWizardStep2.
  ///
  /// In ja, this message translates to:
  /// **'フォルダを選択'**
  String get setupWizardStep2;

  /// No description provided for @setupWizardStep3.
  ///
  /// In ja, this message translates to:
  /// **'デバイスを接続'**
  String get setupWizardStep3;

  /// No description provided for @setupWizardStep4.
  ///
  /// In ja, this message translates to:
  /// **'設定を確認'**
  String get setupWizardStep4;

  /// No description provided for @syncModeTitle.
  ///
  /// In ja, this message translates to:
  /// **'同期モードを選んでください'**
  String get syncModeTitle;

  /// No description provided for @syncModeMirror.
  ///
  /// In ja, this message translates to:
  /// **'ミラー同期'**
  String get syncModeMirror;

  /// No description provided for @syncModeMirrorDesc.
  ///
  /// In ja, this message translates to:
  /// **'元フォルダの内容を先フォルダに完全コピーします。先フォルダにのみ存在するファイルは削除されます。'**
  String get syncModeMirrorDesc;

  /// No description provided for @syncModeTwoWay.
  ///
  /// In ja, this message translates to:
  /// **'双方向同期'**
  String get syncModeTwoWay;

  /// No description provided for @syncModeTwoWayDesc.
  ///
  /// In ja, this message translates to:
  /// **'両方のフォルダの変更を互いに反映します。どちらのフォルダで変更しても同期されます。'**
  String get syncModeTwoWayDesc;

  /// No description provided for @syncModeUpdate.
  ///
  /// In ja, this message translates to:
  /// **'アップデート同期'**
  String get syncModeUpdate;

  /// No description provided for @syncModeUpdateDesc.
  ///
  /// In ja, this message translates to:
  /// **'新しいファイルと更新されたファイルのみをコピーします。削除は反映されません。'**
  String get syncModeUpdateDesc;

  /// No description provided for @syncModeCustom.
  ///
  /// In ja, this message translates to:
  /// **'カスタム同期'**
  String get syncModeCustom;

  /// No description provided for @syncModeCustomDesc.
  ///
  /// In ja, this message translates to:
  /// **'各操作（作成・更新・削除）の同期方向を個別に設定できます。'**
  String get syncModeCustomDesc;

  /// No description provided for @selectSourceFolder.
  ///
  /// In ja, this message translates to:
  /// **'元フォルダを選択'**
  String get selectSourceFolder;

  /// No description provided for @selectTargetFolder.
  ///
  /// In ja, this message translates to:
  /// **'先フォルダを選択'**
  String get selectTargetFolder;

  /// No description provided for @sourceFolder.
  ///
  /// In ja, this message translates to:
  /// **'元フォルダ'**
  String get sourceFolder;

  /// No description provided for @targetFolder.
  ///
  /// In ja, this message translates to:
  /// **'先フォルダ'**
  String get targetFolder;

  /// No description provided for @browseFolder.
  ///
  /// In ja, this message translates to:
  /// **'フォルダを参照'**
  String get browseFolder;

  /// No description provided for @folderPath.
  ///
  /// In ja, this message translates to:
  /// **'フォルダのパス'**
  String get folderPath;

  /// No description provided for @noFolderSelected.
  ///
  /// In ja, this message translates to:
  /// **'フォルダが選択されていません'**
  String get noFolderSelected;

  /// No description provided for @connectionType.
  ///
  /// In ja, this message translates to:
  /// **'接続方法'**
  String get connectionType;

  /// No description provided for @connectionLocal.
  ///
  /// In ja, this message translates to:
  /// **'ローカル / USB'**
  String get connectionLocal;

  /// No description provided for @connectionLocalDesc.
  ///
  /// In ja, this message translates to:
  /// **'同じPC内のフォルダ間、またはUSBドライブと同期'**
  String get connectionLocalDesc;

  /// No description provided for @connectionLAN.
  ///
  /// In ja, this message translates to:
  /// **'LAN（ローカルネットワーク）'**
  String get connectionLAN;

  /// No description provided for @connectionLANDesc.
  ///
  /// In ja, this message translates to:
  /// **'同じWi-Fiネットワーク内のデバイスと同期'**
  String get connectionLANDesc;

  /// No description provided for @connectionSFTP.
  ///
  /// In ja, this message translates to:
  /// **'SFTP（リモートサーバー）'**
  String get connectionSFTP;

  /// No description provided for @connectionSFTPDesc.
  ///
  /// In ja, this message translates to:
  /// **'SSHで接続するリモートサーバーと同期'**
  String get connectionSFTPDesc;

  /// No description provided for @connectionFTP.
  ///
  /// In ja, this message translates to:
  /// **'FTP / FTPS'**
  String get connectionFTP;

  /// No description provided for @connectionFTPDesc.
  ///
  /// In ja, this message translates to:
  /// **'FTPサーバーと同期（SSL/TLS暗号化対応）'**
  String get connectionFTPDesc;

  /// No description provided for @connectionP2P.
  ///
  /// In ja, this message translates to:
  /// **'P2P（デバイス間直接接続）'**
  String get connectionP2P;

  /// No description provided for @connectionP2PDesc.
  ///
  /// In ja, this message translates to:
  /// **'インターネット経由でデバイス間を直接接続して同期'**
  String get connectionP2PDesc;

  /// No description provided for @sftpHost.
  ///
  /// In ja, this message translates to:
  /// **'ホスト名 / IPアドレス'**
  String get sftpHost;

  /// No description provided for @sftpPort.
  ///
  /// In ja, this message translates to:
  /// **'ポート番号'**
  String get sftpPort;

  /// No description provided for @sftpUsername.
  ///
  /// In ja, this message translates to:
  /// **'ユーザー名'**
  String get sftpUsername;

  /// No description provided for @sftpPassword.
  ///
  /// In ja, this message translates to:
  /// **'パスワード'**
  String get sftpPassword;

  /// No description provided for @sftpKeyFile.
  ///
  /// In ja, this message translates to:
  /// **'秘密鍵ファイル'**
  String get sftpKeyFile;

  /// No description provided for @sftpRemotePath.
  ///
  /// In ja, this message translates to:
  /// **'リモートパス'**
  String get sftpRemotePath;

  /// No description provided for @testConnection.
  ///
  /// In ja, this message translates to:
  /// **'接続テスト'**
  String get testConnection;

  /// No description provided for @connectionSuccess.
  ///
  /// In ja, this message translates to:
  /// **'接続に成功しました！'**
  String get connectionSuccess;

  /// No description provided for @connectionFailed.
  ///
  /// In ja, this message translates to:
  /// **'接続に失敗しました'**
  String get connectionFailed;

  /// No description provided for @devicePairing.
  ///
  /// In ja, this message translates to:
  /// **'デバイスペアリング'**
  String get devicePairing;

  /// No description provided for @devicePairingDesc.
  ///
  /// In ja, this message translates to:
  /// **'QRコードをスキャンするか、デバイスIDを入力して接続'**
  String get devicePairingDesc;

  /// No description provided for @myDeviceId.
  ///
  /// In ja, this message translates to:
  /// **'このデバイスのID'**
  String get myDeviceId;

  /// No description provided for @scanQRCode.
  ///
  /// In ja, this message translates to:
  /// **'QRコードをスキャン'**
  String get scanQRCode;

  /// No description provided for @showMyQRCode.
  ///
  /// In ja, this message translates to:
  /// **'自分のQRコードを表示'**
  String get showMyQRCode;

  /// No description provided for @enterDeviceId.
  ///
  /// In ja, this message translates to:
  /// **'デバイスIDを入力'**
  String get enterDeviceId;

  /// No description provided for @deviceIdHint.
  ///
  /// In ja, this message translates to:
  /// **'例: ABCDE-FGHIJ-KLMNO-PQRST'**
  String get deviceIdHint;

  /// No description provided for @addDevice.
  ///
  /// In ja, this message translates to:
  /// **'デバイスを追加'**
  String get addDevice;

  /// No description provided for @removeDevice.
  ///
  /// In ja, this message translates to:
  /// **'デバイスを削除'**
  String get removeDevice;

  /// No description provided for @deviceName.
  ///
  /// In ja, this message translates to:
  /// **'デバイス名'**
  String get deviceName;

  /// No description provided for @deviceStatus.
  ///
  /// In ja, this message translates to:
  /// **'ステータス'**
  String get deviceStatus;

  /// No description provided for @deviceOnline.
  ///
  /// In ja, this message translates to:
  /// **'オンライン'**
  String get deviceOnline;

  /// No description provided for @deviceOffline.
  ///
  /// In ja, this message translates to:
  /// **'オフライン'**
  String get deviceOffline;

  /// No description provided for @deviceSyncing.
  ///
  /// In ja, this message translates to:
  /// **'同期中'**
  String get deviceSyncing;

  /// No description provided for @deviceConnecting.
  ///
  /// In ja, this message translates to:
  /// **'接続中...'**
  String get deviceConnecting;

  /// No description provided for @compareFiles.
  ///
  /// In ja, this message translates to:
  /// **'比較'**
  String get compareFiles;

  /// No description provided for @comparing.
  ///
  /// In ja, this message translates to:
  /// **'比較中...'**
  String get comparing;

  /// No description provided for @compareByTime.
  ///
  /// In ja, this message translates to:
  /// **'日時とサイズで比較'**
  String get compareByTime;

  /// No description provided for @compareByContent.
  ///
  /// In ja, this message translates to:
  /// **'内容（バイト単位）で比較'**
  String get compareByContent;

  /// No description provided for @compareBySize.
  ///
  /// In ja, this message translates to:
  /// **'サイズのみで比較'**
  String get compareBySize;

  /// No description provided for @startSync.
  ///
  /// In ja, this message translates to:
  /// **'同期を開始'**
  String get startSync;

  /// No description provided for @stopSync.
  ///
  /// In ja, this message translates to:
  /// **'同期を停止'**
  String get stopSync;

  /// No description provided for @startSyncButton.
  ///
  /// In ja, this message translates to:
  /// **'同期開始'**
  String get startSyncButton;

  /// No description provided for @stopSyncButton.
  ///
  /// In ja, this message translates to:
  /// **'停止'**
  String get stopSyncButton;

  /// No description provided for @pauseSync.
  ///
  /// In ja, this message translates to:
  /// **'同期を一時停止'**
  String get pauseSync;

  /// No description provided for @resumeSync.
  ///
  /// In ja, this message translates to:
  /// **'同期を再開'**
  String get resumeSync;

  /// No description provided for @syncing.
  ///
  /// In ja, this message translates to:
  /// **'同期中...'**
  String get syncing;

  /// No description provided for @syncComplete.
  ///
  /// In ja, this message translates to:
  /// **'同期が完了しました'**
  String get syncComplete;

  /// No description provided for @syncFailed.
  ///
  /// In ja, this message translates to:
  /// **'同期に失敗しました'**
  String get syncFailed;

  /// No description provided for @syncProgress.
  ///
  /// In ja, this message translates to:
  /// **'同期の進捗'**
  String get syncProgress;

  /// No description provided for @syncStats.
  ///
  /// In ja, this message translates to:
  /// **'同期統計'**
  String get syncStats;

  /// No description provided for @filesTotal.
  ///
  /// In ja, this message translates to:
  /// **'合計ファイル数'**
  String get filesTotal;

  /// No description provided for @filesProcessed.
  ///
  /// In ja, this message translates to:
  /// **'処理済みファイル数'**
  String get filesProcessed;

  /// No description provided for @filesCopied.
  ///
  /// In ja, this message translates to:
  /// **'コピー済み'**
  String get filesCopied;

  /// No description provided for @filesDeleted.
  ///
  /// In ja, this message translates to:
  /// **'削除済み'**
  String get filesDeleted;

  /// No description provided for @filesSkipped.
  ///
  /// In ja, this message translates to:
  /// **'スキップ済み'**
  String get filesSkipped;

  /// No description provided for @filesConflict.
  ///
  /// In ja, this message translates to:
  /// **'競合'**
  String get filesConflict;

  /// No description provided for @totalSize.
  ///
  /// In ja, this message translates to:
  /// **'合計サイズ'**
  String get totalSize;

  /// No description provided for @transferSpeed.
  ///
  /// In ja, this message translates to:
  /// **'転送速度'**
  String get transferSpeed;

  /// No description provided for @timeRemaining.
  ///
  /// In ja, this message translates to:
  /// **'残り時間'**
  String get timeRemaining;

  /// No description provided for @timeElapsed.
  ///
  /// In ja, this message translates to:
  /// **'経過時間'**
  String get timeElapsed;

  /// No description provided for @filterTitle.
  ///
  /// In ja, this message translates to:
  /// **'フィルタ設定'**
  String get filterTitle;

  /// No description provided for @filterInclude.
  ///
  /// In ja, this message translates to:
  /// **'含める'**
  String get filterInclude;

  /// No description provided for @filterExclude.
  ///
  /// In ja, this message translates to:
  /// **'除外する'**
  String get filterExclude;

  /// No description provided for @filterIncludeHint.
  ///
  /// In ja, this message translates to:
  /// **'例: *.jpg | *.png | Documents\\'**
  String get filterIncludeHint;

  /// No description provided for @filterExcludeHint.
  ///
  /// In ja, this message translates to:
  /// **'例: *.tmp | *.log | \$Recycle.Bin\\'**
  String get filterExcludeHint;

  /// No description provided for @versioningTitle.
  ///
  /// In ja, this message translates to:
  /// **'バージョン管理'**
  String get versioningTitle;

  /// No description provided for @versioningNone.
  ///
  /// In ja, this message translates to:
  /// **'バージョン管理なし'**
  String get versioningNone;

  /// No description provided for @versioningTrashCan.
  ///
  /// In ja, this message translates to:
  /// **'ゴミ箱方式'**
  String get versioningTrashCan;

  /// No description provided for @versioningTrashCanDesc.
  ///
  /// In ja, this message translates to:
  /// **'削除・上書きされたファイルをゴミ箱フォルダに移動'**
  String get versioningTrashCanDesc;

  /// No description provided for @versioningTimestamp.
  ///
  /// In ja, this message translates to:
  /// **'タイムスタンプ方式'**
  String get versioningTimestamp;

  /// No description provided for @versioningTimestampDesc.
  ///
  /// In ja, this message translates to:
  /// **'各バージョンに日時を付けて保存'**
  String get versioningTimestampDesc;

  /// No description provided for @versioningFolder.
  ///
  /// In ja, this message translates to:
  /// **'バージョン保存先フォルダ'**
  String get versioningFolder;

  /// No description provided for @versioningKeepDays.
  ///
  /// In ja, this message translates to:
  /// **'保持日数'**
  String get versioningKeepDays;

  /// No description provided for @scheduleTitle.
  ///
  /// In ja, this message translates to:
  /// **'スケジュール設定'**
  String get scheduleTitle;

  /// No description provided for @scheduleEnabled.
  ///
  /// In ja, this message translates to:
  /// **'スケジュールを有効にする'**
  String get scheduleEnabled;

  /// No description provided for @scheduleInterval.
  ///
  /// In ja, this message translates to:
  /// **'実行間隔'**
  String get scheduleInterval;

  /// No description provided for @scheduleEvery5Min.
  ///
  /// In ja, this message translates to:
  /// **'5分ごと'**
  String get scheduleEvery5Min;

  /// No description provided for @scheduleEvery15Min.
  ///
  /// In ja, this message translates to:
  /// **'15分ごと'**
  String get scheduleEvery15Min;

  /// No description provided for @scheduleEvery30Min.
  ///
  /// In ja, this message translates to:
  /// **'30分ごと'**
  String get scheduleEvery30Min;

  /// No description provided for @scheduleEveryHour.
  ///
  /// In ja, this message translates to:
  /// **'1時間ごと'**
  String get scheduleEveryHour;

  /// No description provided for @scheduleEveryDay.
  ///
  /// In ja, this message translates to:
  /// **'毎日'**
  String get scheduleEveryDay;

  /// No description provided for @scheduleCustom.
  ///
  /// In ja, this message translates to:
  /// **'カスタム'**
  String get scheduleCustom;

  /// No description provided for @scheduleRealtime.
  ///
  /// In ja, this message translates to:
  /// **'リアルタイム（ファイル変更時に自動同期）'**
  String get scheduleRealtime;

  /// No description provided for @settingsGeneral.
  ///
  /// In ja, this message translates to:
  /// **'一般'**
  String get settingsGeneral;

  /// No description provided for @settingsTheme.
  ///
  /// In ja, this message translates to:
  /// **'テーマ'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In ja, this message translates to:
  /// **'ライト'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In ja, this message translates to:
  /// **'ダーク'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In ja, this message translates to:
  /// **'システムに合わせる'**
  String get settingsThemeSystem;

  /// No description provided for @settingsLanguage.
  ///
  /// In ja, this message translates to:
  /// **'言語'**
  String get settingsLanguage;

  /// No description provided for @settingsNotifications.
  ///
  /// In ja, this message translates to:
  /// **'通知'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsEnabled.
  ///
  /// In ja, this message translates to:
  /// **'通知を有効にする'**
  String get settingsNotificationsEnabled;

  /// No description provided for @settingsAbout.
  ///
  /// In ja, this message translates to:
  /// **'このアプリについて'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In ja, this message translates to:
  /// **'バージョン'**
  String get settingsVersion;

  /// No description provided for @settingsLicense.
  ///
  /// In ja, this message translates to:
  /// **'ライセンス'**
  String get settingsLicense;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In ja, this message translates to:
  /// **'プライバシーポリシー'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsBandwidthLimit.
  ///
  /// In ja, this message translates to:
  /// **'帯域制限'**
  String get settingsBandwidthLimit;

  /// No description provided for @settingsMaxUpload.
  ///
  /// In ja, this message translates to:
  /// **'最大アップロード速度'**
  String get settingsMaxUpload;

  /// No description provided for @settingsMaxDownload.
  ///
  /// In ja, this message translates to:
  /// **'最大ダウンロード速度'**
  String get settingsMaxDownload;

  /// No description provided for @settingsUnlimited.
  ///
  /// In ja, this message translates to:
  /// **'無制限'**
  String get settingsUnlimited;

  /// No description provided for @errorGeneral.
  ///
  /// In ja, this message translates to:
  /// **'エラーが発生しました'**
  String get errorGeneral;

  /// No description provided for @errorNetworkTimeout.
  ///
  /// In ja, this message translates to:
  /// **'ネットワークタイムアウト'**
  String get errorNetworkTimeout;

  /// No description provided for @errorPermissionDenied.
  ///
  /// In ja, this message translates to:
  /// **'アクセス権限がありません'**
  String get errorPermissionDenied;

  /// No description provided for @errorFolderNotFound.
  ///
  /// In ja, this message translates to:
  /// **'フォルダが見つかりません'**
  String get errorFolderNotFound;

  /// No description provided for @errorDiskFull.
  ///
  /// In ja, this message translates to:
  /// **'ディスク容量が不足しています'**
  String get errorDiskFull;

  /// No description provided for @errorFileInUse.
  ///
  /// In ja, this message translates to:
  /// **'ファイルが使用中です'**
  String get errorFileInUse;

  /// No description provided for @errorConnectionLost.
  ///
  /// In ja, this message translates to:
  /// **'接続が切断されました'**
  String get errorConnectionLost;

  /// No description provided for @conflictTitle.
  ///
  /// In ja, this message translates to:
  /// **'ファイルの競合'**
  String get conflictTitle;

  /// No description provided for @conflictDesc.
  ///
  /// In ja, this message translates to:
  /// **'同じファイルが両方で変更されています'**
  String get conflictDesc;

  /// No description provided for @conflictKeepLeft.
  ///
  /// In ja, this message translates to:
  /// **'元フォルダのファイルを使用'**
  String get conflictKeepLeft;

  /// No description provided for @conflictKeepRight.
  ///
  /// In ja, this message translates to:
  /// **'先フォルダのファイルを使用'**
  String get conflictKeepRight;

  /// No description provided for @conflictKeepBoth.
  ///
  /// In ja, this message translates to:
  /// **'両方を保持（名前を変更）'**
  String get conflictKeepBoth;

  /// No description provided for @conflictKeepNewer.
  ///
  /// In ja, this message translates to:
  /// **'新しいファイルを使用'**
  String get conflictKeepNewer;

  /// No description provided for @onboardingTitle1.
  ///
  /// In ja, this message translates to:
  /// **'ファイルを安全に同期'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In ja, this message translates to:
  /// **'ローカルフォルダ、USBドライブ、ネットワーク、リモートサーバー間でファイルを簡単に同期できます。'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In ja, this message translates to:
  /// **'3つの同期モード'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In ja, this message translates to:
  /// **'ミラー・双方向・アップデートの3つのモードから選べます。カスタム設定も可能です。'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In ja, this message translates to:
  /// **'かんたん接続'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In ja, this message translates to:
  /// **'QRコードスキャンやウィザードで、デバイスの接続を簡単に設定できます。'**
  String get onboardingDesc3;

  /// No description provided for @onboardingTitle4.
  ///
  /// In ja, this message translates to:
  /// **'安心のバックアップ'**
  String get onboardingTitle4;

  /// No description provided for @onboardingDesc4.
  ///
  /// In ja, this message translates to:
  /// **'バージョン管理で大切なファイルを保護。万が一の時も安心です。'**
  String get onboardingDesc4;

  /// No description provided for @adRemoveAds.
  ///
  /// In ja, this message translates to:
  /// **'広告を非表示にする'**
  String get adRemoveAds;

  /// No description provided for @adWatchToUnlock.
  ///
  /// In ja, this message translates to:
  /// **'動画を見て機能をアンロック'**
  String get adWatchToUnlock;

  /// No description provided for @adFreeFor24h.
  ///
  /// In ja, this message translates to:
  /// **'24時間広告なし'**
  String get adFreeFor24h;

  /// No description provided for @noSyncJobs.
  ///
  /// In ja, this message translates to:
  /// **'同期ジョブがありません'**
  String get noSyncJobs;

  /// No description provided for @noSyncJobsDesc.
  ///
  /// In ja, this message translates to:
  /// **'「新しいジョブを作成」をタップして最初の同期ジョブを設定しましょう'**
  String get noSyncJobsDesc;

  /// No description provided for @createNewJob.
  ///
  /// In ja, this message translates to:
  /// **'新しいジョブを作成'**
  String get createNewJob;

  /// No description provided for @jobName.
  ///
  /// In ja, this message translates to:
  /// **'ジョブ名'**
  String get jobName;

  /// No description provided for @jobNameHint.
  ///
  /// In ja, this message translates to:
  /// **'例: 写真バックアップ、ドキュメント同期'**
  String get jobNameHint;

  /// No description provided for @lastSync.
  ///
  /// In ja, this message translates to:
  /// **'最終同期'**
  String get lastSync;

  /// No description provided for @neverSynced.
  ///
  /// In ja, this message translates to:
  /// **'未同期'**
  String get neverSynced;

  /// No description provided for @helpTitle.
  ///
  /// In ja, this message translates to:
  /// **'ヘルプ'**
  String get helpTitle;

  /// No description provided for @helpSetup.
  ///
  /// In ja, this message translates to:
  /// **'接続設定の方法'**
  String get helpSetup;

  /// No description provided for @helpSyncModes.
  ///
  /// In ja, this message translates to:
  /// **'同期モードの違い'**
  String get helpSyncModes;

  /// No description provided for @helpFilters.
  ///
  /// In ja, this message translates to:
  /// **'フィルタの使い方'**
  String get helpFilters;

  /// No description provided for @helpTroubleshooting.
  ///
  /// In ja, this message translates to:
  /// **'トラブルシューティング'**
  String get helpTroubleshooting;

  /// No description provided for @helpFAQ.
  ///
  /// In ja, this message translates to:
  /// **'よくある質問'**
  String get helpFAQ;

  /// No description provided for @premiumTitle.
  ///
  /// In ja, this message translates to:
  /// **'SyncSphere プレミアム'**
  String get premiumTitle;

  /// No description provided for @premiumSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'広告なしで快適に利用しましょう'**
  String get premiumSubtitle;

  /// No description provided for @premiumFeature1.
  ///
  /// In ja, this message translates to:
  /// **'広告なしの快適体験'**
  String get premiumFeature1;

  /// No description provided for @premiumFeature2.
  ///
  /// In ja, this message translates to:
  /// **'優先サポート'**
  String get premiumFeature2;

  /// No description provided for @premiumFeature3.
  ///
  /// In ja, this message translates to:
  /// **'SyncSphereチームからの迅速なサポート'**
  String get premiumFeature3;

  /// No description provided for @premiumPurchase.
  ///
  /// In ja, this message translates to:
  /// **'プレミアムにアップグレード'**
  String get premiumPurchase;

  /// No description provided for @premiumRestore.
  ///
  /// In ja, this message translates to:
  /// **'購入を復元'**
  String get premiumRestore;

  /// No description provided for @premiumActive.
  ///
  /// In ja, this message translates to:
  /// **'プレミアム会員です'**
  String get premiumActive;

  /// No description provided for @premiumActiveDesc.
  ///
  /// In ja, this message translates to:
  /// **'すべてのプレミアム機能をご利用いただけます。広告は表示されません。'**
  String get premiumActiveDesc;

  /// No description provided for @premiumProcessing.
  ///
  /// In ja, this message translates to:
  /// **'処理中...'**
  String get premiumProcessing;

  /// No description provided for @premiumError.
  ///
  /// In ja, this message translates to:
  /// **'エラー'**
  String get premiumError;

  /// No description provided for @premiumPrice.
  ///
  /// In ja, this message translates to:
  /// **'¥3,000'**
  String get premiumPrice;

  /// No description provided for @premium.
  ///
  /// In ja, this message translates to:
  /// **'プレミアム'**
  String get premium;

  /// No description provided for @serverTitle.
  ///
  /// In ja, this message translates to:
  /// **'PC同期'**
  String get serverTitle;

  /// No description provided for @serverStart.
  ///
  /// In ja, this message translates to:
  /// **'サーバーを開始'**
  String get serverStart;

  /// No description provided for @serverStop.
  ///
  /// In ja, this message translates to:
  /// **'サーバーを停止'**
  String get serverStop;

  /// No description provided for @serverRunning.
  ///
  /// In ja, this message translates to:
  /// **'サーバー稼働中'**
  String get serverRunning;

  /// No description provided for @serverStopped.
  ///
  /// In ja, this message translates to:
  /// **'サーバー停止中'**
  String get serverStopped;

  /// No description provided for @serverUrl.
  ///
  /// In ja, this message translates to:
  /// **'接続URL'**
  String get serverUrl;

  /// No description provided for @serverUrlCopied.
  ///
  /// In ja, this message translates to:
  /// **'URLをコピーしました'**
  String get serverUrlCopied;

  /// No description provided for @serverInstruction1.
  ///
  /// In ja, this message translates to:
  /// **'1. PCのブラウザで下のURLを開いてください'**
  String get serverInstruction1;

  /// No description provided for @serverInstruction2.
  ///
  /// In ja, this message translates to:
  /// **'2. または、QRコードをスキャンしてください'**
  String get serverInstruction2;

  /// No description provided for @serverInstruction3.
  ///
  /// In ja, this message translates to:
  /// **'3. ブラウザで同期フォルダを選択して同期開始！'**
  String get serverInstruction3;

  /// No description provided for @serverConnectedClients.
  ///
  /// In ja, this message translates to:
  /// **'接続中のクライアント: {count}'**
  String serverConnectedClients(int count);

  /// No description provided for @serverSyncDir.
  ///
  /// In ja, this message translates to:
  /// **'同期フォルダ'**
  String get serverSyncDir;

  /// No description provided for @serverChangeSyncDir.
  ///
  /// In ja, this message translates to:
  /// **'同期フォルダを変更'**
  String get serverChangeSyncDir;

  /// No description provided for @serverNoClients.
  ///
  /// In ja, this message translates to:
  /// **'デバイスの接続を待っています...'**
  String get serverNoClients;

  /// No description provided for @tabDashboard.
  ///
  /// In ja, this message translates to:
  /// **'ダッシュボード'**
  String get tabDashboard;

  /// No description provided for @tabFolders.
  ///
  /// In ja, this message translates to:
  /// **'フォルダ'**
  String get tabFolders;

  /// No description provided for @tabDevices.
  ///
  /// In ja, this message translates to:
  /// **'デバイス'**
  String get tabDevices;

  /// No description provided for @tabSettings.
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get tabSettings;

  /// No description provided for @dashboardTitle.
  ///
  /// In ja, this message translates to:
  /// **'SyncSphere'**
  String get dashboardTitle;

  /// No description provided for @quickActionAddFolder.
  ///
  /// In ja, this message translates to:
  /// **'フォルダ追加'**
  String get quickActionAddFolder;

  /// No description provided for @quickActionPcSync.
  ///
  /// In ja, this message translates to:
  /// **'PC同期'**
  String get quickActionPcSync;

  /// No description provided for @quickActionAddDevice.
  ///
  /// In ja, this message translates to:
  /// **'デバイス追加'**
  String get quickActionAddDevice;

  /// No description provided for @noFoldersTitle.
  ///
  /// In ja, this message translates to:
  /// **'フォルダがありません'**
  String get noFoldersTitle;

  /// No description provided for @noFoldersSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'フォルダを追加して同期を始めましょう'**
  String get noFoldersSubtitle;

  /// No description provided for @noDevicesTitle.
  ///
  /// In ja, this message translates to:
  /// **'デバイスがありません'**
  String get noDevicesTitle;

  /// No description provided for @noDevicesSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'デバイスを追加してファイルを同期しましょう'**
  String get noDevicesSubtitle;

  /// No description provided for @scanQrCode.
  ///
  /// In ja, this message translates to:
  /// **'QRスキャン'**
  String get scanQrCode;

  /// No description provided for @manualAdd.
  ///
  /// In ja, this message translates to:
  /// **'手動追加'**
  String get manualAdd;

  /// No description provided for @connectionInfo.
  ///
  /// In ja, this message translates to:
  /// **'接続情報'**
  String get connectionInfo;

  /// No description provided for @sharedFolders.
  ///
  /// In ja, this message translates to:
  /// **'共有フォルダ'**
  String get sharedFolders;

  /// No description provided for @noSharedFolders.
  ///
  /// In ja, this message translates to:
  /// **'共有フォルダはありません'**
  String get noSharedFolders;

  /// No description provided for @statistics.
  ///
  /// In ja, this message translates to:
  /// **'統計'**
  String get statistics;

  /// No description provided for @status.
  ///
  /// In ja, this message translates to:
  /// **'ステータス'**
  String get status;

  /// No description provided for @removeDeviceConfirm.
  ///
  /// In ja, this message translates to:
  /// **'このデバイスを削除しますか？'**
  String get removeDeviceConfirm;

  /// No description provided for @actionCannotBeUndone.
  ///
  /// In ja, this message translates to:
  /// **'この操作は取り消せません。'**
  String get actionCannotBeUndone;

  /// No description provided for @settingsSync.
  ///
  /// In ja, this message translates to:
  /// **'同期'**
  String get settingsSync;

  /// No description provided for @settingsRunConditions.
  ///
  /// In ja, this message translates to:
  /// **'実行条件'**
  String get settingsRunConditions;

  /// No description provided for @settingsBackground.
  ///
  /// In ja, this message translates to:
  /// **'バックグラウンド'**
  String get settingsBackground;

  /// No description provided for @settingsStorage.
  ///
  /// In ja, this message translates to:
  /// **'ストレージ'**
  String get settingsStorage;

  /// No description provided for @settingsBackup.
  ///
  /// In ja, this message translates to:
  /// **'バックアップ'**
  String get settingsBackup;

  /// No description provided for @settingsPremium.
  ///
  /// In ja, this message translates to:
  /// **'プレミアム'**
  String get settingsPremium;

  /// No description provided for @themeSystem.
  ///
  /// In ja, this message translates to:
  /// **'システム'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In ja, this message translates to:
  /// **'ライト'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ja, this message translates to:
  /// **'ダーク'**
  String get themeDark;

  /// No description provided for @syncModeDefault.
  ///
  /// In ja, this message translates to:
  /// **'デフォルト同期モード'**
  String get syncModeDefault;

  /// No description provided for @bandwidthUpload.
  ///
  /// In ja, this message translates to:
  /// **'アップロード帯域'**
  String get bandwidthUpload;

  /// No description provided for @bandwidthDownload.
  ///
  /// In ja, this message translates to:
  /// **'ダウンロード帯域'**
  String get bandwidthDownload;

  /// No description provided for @wifiOnlySync.
  ///
  /// In ja, this message translates to:
  /// **'WiFiのみで同期'**
  String get wifiOnlySync;

  /// No description provided for @chargingOnlySync.
  ///
  /// In ja, this message translates to:
  /// **'充電中のみで同期'**
  String get chargingOnlySync;

  /// No description provided for @batterySaverOff.
  ///
  /// In ja, this message translates to:
  /// **'省電力モードOFF時のみ'**
  String get batterySaverOff;

  /// No description provided for @allowedSsids.
  ///
  /// In ja, this message translates to:
  /// **'許可されたSSID'**
  String get allowedSsids;

  /// No description provided for @addSsid.
  ///
  /// In ja, this message translates to:
  /// **'SSIDを追加'**
  String get addSsid;

  /// No description provided for @backgroundSync.
  ///
  /// In ja, this message translates to:
  /// **'バックグラウンド同期'**
  String get backgroundSync;

  /// No description provided for @autoStartOnBoot.
  ///
  /// In ja, this message translates to:
  /// **'起動時に自動開始'**
  String get autoStartOnBoot;

  /// No description provided for @disableBatteryOptimization.
  ///
  /// In ja, this message translates to:
  /// **'バッテリー最適化を無効化'**
  String get disableBatteryOptimization;

  /// No description provided for @syncCompleteNotification.
  ///
  /// In ja, this message translates to:
  /// **'同期完了'**
  String get syncCompleteNotification;

  /// No description provided for @errorNotification.
  ///
  /// In ja, this message translates to:
  /// **'エラー通知'**
  String get errorNotification;

  /// No description provided for @newDeviceNotification.
  ///
  /// In ja, this message translates to:
  /// **'新しいデバイス検出'**
  String get newDeviceNotification;

  /// No description provided for @exportConfig.
  ///
  /// In ja, this message translates to:
  /// **'設定をエクスポート'**
  String get exportConfig;

  /// No description provided for @importConfig.
  ///
  /// In ja, this message translates to:
  /// **'設定をインポート'**
  String get importConfig;

  /// No description provided for @upgradePremium.
  ///
  /// In ja, this message translates to:
  /// **'プレミアムにアップグレード'**
  String get upgradePremium;

  /// No description provided for @restorePurchases.
  ///
  /// In ja, this message translates to:
  /// **'購入を復元'**
  String get restorePurchases;

  /// No description provided for @premiumMember.
  ///
  /// In ja, this message translates to:
  /// **'プレミアム会員です'**
  String get premiumMember;

  /// No description provided for @freePlan.
  ///
  /// In ja, this message translates to:
  /// **'無料プラン'**
  String get freePlan;

  /// No description provided for @premiumPlan.
  ///
  /// In ja, this message translates to:
  /// **'プレミアムプラン'**
  String get premiumPlan;

  /// No description provided for @oneTimePurchase.
  ///
  /// In ja, this message translates to:
  /// **'一回限りの購入'**
  String get oneTimePurchase;

  /// No description provided for @noSubscription.
  ///
  /// In ja, this message translates to:
  /// **'サブスクリプションなし'**
  String get noSubscription;

  /// No description provided for @purchasePremium.
  ///
  /// In ja, this message translates to:
  /// **'プレミアムを購入'**
  String get purchasePremium;

  /// No description provided for @startServer.
  ///
  /// In ja, this message translates to:
  /// **'サーバーを開始'**
  String get startServer;

  /// No description provided for @stopServer.
  ///
  /// In ja, this message translates to:
  /// **'サーバーを停止'**
  String get stopServer;

  /// No description provided for @serverInstructions1.
  ///
  /// In ja, this message translates to:
  /// **'同じWiFiネットワークに接続してください'**
  String get serverInstructions1;

  /// No description provided for @serverInstructions2.
  ///
  /// In ja, this message translates to:
  /// **'PCのブラウザで上記URLを開いてください'**
  String get serverInstructions2;

  /// No description provided for @serverInstructions3.
  ///
  /// In ja, this message translates to:
  /// **'フォルダを選択して同期を開始できます'**
  String get serverInstructions3;

  /// No description provided for @noInstallRequired.
  ///
  /// In ja, this message translates to:
  /// **'PCにソフトウェアのインストールは不要です'**
  String get noInstallRequired;

  /// No description provided for @connectedClients.
  ///
  /// In ja, this message translates to:
  /// **'接続中のクライアント'**
  String get connectedClients;

  /// No description provided for @syncOverview.
  ///
  /// In ja, this message translates to:
  /// **'概要'**
  String get syncOverview;

  /// No description provided for @syncFolders.
  ///
  /// In ja, this message translates to:
  /// **'フォルダ'**
  String get syncFolders;

  /// No description provided for @syncFilters.
  ///
  /// In ja, this message translates to:
  /// **'フィルタ'**
  String get syncFilters;

  /// No description provided for @forceRescan.
  ///
  /// In ja, this message translates to:
  /// **'強制再スキャン'**
  String get forceRescan;

  /// No description provided for @noFilters.
  ///
  /// In ja, this message translates to:
  /// **'フィルタなし'**
  String get noFilters;

  /// No description provided for @lastSyncResult.
  ///
  /// In ja, this message translates to:
  /// **'最後の同期結果'**
  String get lastSyncResult;

  /// No description provided for @filesComplete.
  ///
  /// In ja, this message translates to:
  /// **'完了'**
  String get filesComplete;

  /// No description provided for @speed.
  ///
  /// In ja, this message translates to:
  /// **'速度'**
  String get speed;

  /// No description provided for @copied.
  ///
  /// In ja, this message translates to:
  /// **'コピー済み'**
  String get copied;

  /// No description provided for @deleted.
  ///
  /// In ja, this message translates to:
  /// **'削除済み'**
  String get deleted;

  /// No description provided for @skipped.
  ///
  /// In ja, this message translates to:
  /// **'スキップ'**
  String get skipped;

  /// No description provided for @conflicts.
  ///
  /// In ja, this message translates to:
  /// **'競合'**
  String get conflicts;

  /// No description provided for @errors.
  ///
  /// In ja, this message translates to:
  /// **'エラー'**
  String get errors;

  /// No description provided for @duration.
  ///
  /// In ja, this message translates to:
  /// **'所要時間'**
  String get duration;

  /// No description provided for @version.
  ///
  /// In ja, this message translates to:
  /// **'バージョン'**
  String get version;

  /// No description provided for @licenses.
  ///
  /// In ja, this message translates to:
  /// **'ライセンス'**
  String get licenses;

  /// No description provided for @sourceCode.
  ///
  /// In ja, this message translates to:
  /// **'ソースコード'**
  String get sourceCode;

  /// No description provided for @privacyPolicy.
  ///
  /// In ja, this message translates to:
  /// **'プライバシーポリシー'**
  String get privacyPolicy;

  /// No description provided for @copyUrl.
  ///
  /// In ja, this message translates to:
  /// **'URLをコピー'**
  String get copyUrl;

  /// No description provided for @urlCopied.
  ///
  /// In ja, this message translates to:
  /// **'URLがクリップボードにコピーされました'**
  String get urlCopied;

  /// No description provided for @activeSyncs.
  ///
  /// In ja, this message translates to:
  /// **'同期中'**
  String get activeSyncs;

  /// No description provided for @recentSync.
  ///
  /// In ja, this message translates to:
  /// **'最近の同期'**
  String get recentSync;

  /// No description provided for @noFoldersDescription.
  ///
  /// In ja, this message translates to:
  /// **'フォルダ設定を作成し、ファイルを同期します'**
  String get noFoldersDescription;

  /// No description provided for @noFoldersAction.
  ///
  /// In ja, this message translates to:
  /// **'右下の「＋」ボタンから新しいフォルダを追加してください。'**
  String get noFoldersAction;

  /// No description provided for @neverConnected.
  ///
  /// In ja, this message translates to:
  /// **'未接続'**
  String get neverConnected;

  /// No description provided for @ipAddress.
  ///
  /// In ja, this message translates to:
  /// **'IPアドレス'**
  String get ipAddress;

  /// No description provided for @port.
  ///
  /// In ja, this message translates to:
  /// **'ポート'**
  String get port;

  /// No description provided for @transferAmount.
  ///
  /// In ja, this message translates to:
  /// **'転送量'**
  String get transferAmount;

  /// No description provided for @lastConnected.
  ///
  /// In ja, this message translates to:
  /// **'最終接続'**
  String get lastConnected;

  /// No description provided for @ssidHint.
  ///
  /// In ja, this message translates to:
  /// **'WiFiネットワーク名を入力'**
  String get ssidHint;

  /// No description provided for @premiumThankYou.
  ///
  /// In ja, this message translates to:
  /// **'SyncSphereをご支援いただきありがとうございます！'**
  String get premiumThankYou;

  /// No description provided for @basicSync.
  ///
  /// In ja, this message translates to:
  /// **'基本同期'**
  String get basicSync;

  /// No description provided for @noAds.
  ///
  /// In ja, this message translates to:
  /// **'広告なし'**
  String get noAds;

  /// No description provided for @fastSync.
  ///
  /// In ja, this message translates to:
  /// **'高速同期'**
  String get fastSync;

  /// No description provided for @noAdsComplete.
  ///
  /// In ja, this message translates to:
  /// **'広告の完全非表示'**
  String get noAdsComplete;

  /// No description provided for @unlimitedSpeed.
  ///
  /// In ja, this message translates to:
  /// **'無制限の同期速度'**
  String get unlimitedSpeed;

  /// No description provided for @prioritySupport.
  ///
  /// In ja, this message translates to:
  /// **'優先サポート'**
  String get prioritySupport;

  /// No description provided for @syncModeLabel.
  ///
  /// In ja, this message translates to:
  /// **'同期モード'**
  String get syncModeLabel;

  /// No description provided for @compareModeLabel.
  ///
  /// In ja, this message translates to:
  /// **'比較モード'**
  String get compareModeLabel;

  /// No description provided for @running.
  ///
  /// In ja, this message translates to:
  /// **'実行中'**
  String get running;

  /// No description provided for @waiting.
  ///
  /// In ja, this message translates to:
  /// **'待機中'**
  String get waiting;

  /// No description provided for @paths.
  ///
  /// In ja, this message translates to:
  /// **'パス'**
  String get paths;

  /// No description provided for @source.
  ///
  /// In ja, this message translates to:
  /// **'ソース'**
  String get source;

  /// No description provided for @target.
  ///
  /// In ja, this message translates to:
  /// **'ターゲット'**
  String get target;

  /// No description provided for @type.
  ///
  /// In ja, this message translates to:
  /// **'種類'**
  String get type;

  /// No description provided for @previousResult.
  ///
  /// In ja, this message translates to:
  /// **'前回の結果'**
  String get previousResult;

  /// No description provided for @files.
  ///
  /// In ja, this message translates to:
  /// **'ファイル'**
  String get files;

  /// No description provided for @aboutMinutes.
  ///
  /// In ja, this message translates to:
  /// **'約 {min}分'**
  String aboutMinutes(int min);

  /// No description provided for @preparing.
  ///
  /// In ja, this message translates to:
  /// **'準備中...'**
  String get preparing;

  /// No description provided for @detailedInfo.
  ///
  /// In ja, this message translates to:
  /// **'詳細情報'**
  String get detailedInfo;

  /// No description provided for @directPcSync.
  ///
  /// In ja, this message translates to:
  /// **'PCと直接接続して同期'**
  String get directPcSync;

  /// No description provided for @disableBatteryOptDesc.
  ///
  /// In ja, this message translates to:
  /// **'バッテリー最適化を無効にすると、バックグラウンド同期が安定します'**
  String get disableBatteryOptDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
