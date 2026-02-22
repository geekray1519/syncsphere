// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SyncSphere';

  @override
  String get appSubtitle => 'Smart File Synchronization';

  @override
  String get home => 'Home';

  @override
  String get syncJobs => 'Sync Jobs';

  @override
  String get devices => 'Devices';

  @override
  String get settings => 'Settings';

  @override
  String get history => 'History';

  @override
  String get welcomeTitle => 'Welcome to SyncSphere';

  @override
  String get welcomeSubtitle => 'Sync your files safely and easily';

  @override
  String get getStarted => 'Get Started';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get done => 'Done';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Retry';

  @override
  String get ok => 'OK';

  @override
  String get setupWizardTitle => 'Connection Setup Wizard';

  @override
  String get setupWizardStep1 => 'Choose Sync Mode';

  @override
  String get setupWizardStep2 => 'Select Folders';

  @override
  String get setupWizardStep3 => 'Connect Devices';

  @override
  String get setupWizardStep4 => 'Review Settings';

  @override
  String get syncModeTitle => 'Choose a Sync Mode';

  @override
  String get syncModeMirror => 'Mirror Sync';

  @override
  String get syncModeMirrorDesc =>
      'Creates an exact copy of the source folder. Files only in the target are deleted.';

  @override
  String get syncModeTwoWay => 'Two-Way Sync';

  @override
  String get syncModeTwoWayDesc =>
      'Changes on both sides are synchronized with each other.';

  @override
  String get syncModeUpdate => 'Update Sync';

  @override
  String get syncModeUpdateDesc =>
      'Copies new and updated files only. Deletions are not propagated.';

  @override
  String get syncModeCustom => 'Custom Sync';

  @override
  String get syncModeCustomDesc =>
      'Configure sync direction individually for create, update, and delete operations.';

  @override
  String get selectSourceFolder => 'Select Source Folder';

  @override
  String get selectTargetFolder => 'Select Target Folder';

  @override
  String get sourceFolder => 'Source Folder';

  @override
  String get targetFolder => 'Target Folder';

  @override
  String get browseFolder => 'Browse Folder';

  @override
  String get folderPath => 'Folder Path';

  @override
  String get noFolderSelected => 'No folder selected';

  @override
  String get connectionType => 'Connection Type';

  @override
  String get connectionLocal => 'Local / USB';

  @override
  String get connectionLocalDesc =>
      'Sync between folders on this PC or with USB drives';

  @override
  String get connectionLAN => 'LAN (Local Network)';

  @override
  String get connectionLANDesc => 'Sync with devices on the same Wi-Fi network';

  @override
  String get connectionSFTP => 'SFTP (Remote Server)';

  @override
  String get connectionSFTPDesc => 'Sync with a remote server via SSH';

  @override
  String get connectionFTP => 'FTP / FTPS';

  @override
  String get connectionFTPDesc =>
      'Sync with an FTP server (SSL/TLS encryption supported)';

  @override
  String get connectionP2P => 'P2P (Direct Device Connection)';

  @override
  String get connectionP2PDesc =>
      'Connect devices directly over the internet for sync';

  @override
  String get sftpHost => 'Hostname / IP Address';

  @override
  String get sftpPort => 'Port';

  @override
  String get sftpUsername => 'Username';

  @override
  String get sftpPassword => 'Password';

  @override
  String get sftpKeyFile => 'Private Key File';

  @override
  String get sftpRemotePath => 'Remote Path';

  @override
  String get testConnection => 'Test Connection';

  @override
  String get connectionSuccess => 'Connection successful!';

  @override
  String get connectionFailed => 'Connection failed';

  @override
  String get devicePairing => 'Device Pairing';

  @override
  String get devicePairingDesc => 'Scan QR code or enter device ID to connect';

  @override
  String get myDeviceId => 'My Device ID';

  @override
  String get scanQRCode => 'Scan QR Code';

  @override
  String get showMyQRCode => 'Show My QR Code';

  @override
  String get enterDeviceId => 'Enter Device ID';

  @override
  String get deviceIdHint => 'e.g., ABCDE-FGHIJ-KLMNO-PQRST';

  @override
  String get addDevice => 'Add Device';

  @override
  String get removeDevice => 'Remove Device';

  @override
  String get deviceName => 'Device Name';

  @override
  String get deviceStatus => 'Status';

  @override
  String get deviceOnline => 'Online';

  @override
  String get deviceOffline => 'Offline';

  @override
  String get deviceSyncing => 'Syncing';

  @override
  String get deviceConnecting => 'Connecting...';

  @override
  String get compareFiles => 'Compare Files';

  @override
  String get comparing => 'Comparing...';

  @override
  String get compareByTime => 'Compare by Time and Size';

  @override
  String get compareByContent => 'Compare by Content (byte-level)';

  @override
  String get compareBySize => 'Compare by Size Only';

  @override
  String get startSync => 'Start Sync';

  @override
  String get stopSync => 'Stop Sync';

  @override
  String get startSyncButton => 'Start Sync';

  @override
  String get stopSyncButton => 'Stop';

  @override
  String get pauseSync => 'Pause Sync';

  @override
  String get resumeSync => 'Resume Sync';

  @override
  String get syncing => 'Syncing...';

  @override
  String get syncComplete => 'Sync Complete';

  @override
  String get syncFailed => 'Sync Failed';

  @override
  String get syncProgress => 'Sync Progress';

  @override
  String get syncStats => 'Sync Statistics';

  @override
  String get filesTotal => 'Total Files';

  @override
  String get filesProcessed => 'Files Processed';

  @override
  String get filesCopied => 'Copied';

  @override
  String get filesDeleted => 'Deleted';

  @override
  String get filesSkipped => 'Skipped';

  @override
  String get filesConflict => 'Conflicts';

  @override
  String get totalSize => 'Total Size';

  @override
  String get transferSpeed => 'Transfer Speed';

  @override
  String get timeRemaining => 'Time Remaining';

  @override
  String get timeElapsed => 'Time Elapsed';

  @override
  String get filterTitle => 'Filter Settings';

  @override
  String get filterInclude => 'Include';

  @override
  String get filterExclude => 'Exclude';

  @override
  String get filterIncludeHint => 'e.g., *.jpg | *.png | Documents\\';

  @override
  String get filterExcludeHint => 'e.g., *.tmp | *.log | \$Recycle.Bin\\';

  @override
  String get versioningTitle => 'Versioning';

  @override
  String get versioningNone => 'No Versioning';

  @override
  String get versioningTrashCan => 'Trash Can';

  @override
  String get versioningTrashCanDesc =>
      'Move deleted/overwritten files to a trash folder';

  @override
  String get versioningTimestamp => 'Timestamped Copies';

  @override
  String get versioningTimestampDesc => 'Save each version with a timestamp';

  @override
  String get versioningFolder => 'Versioning Folder';

  @override
  String get versioningKeepDays => 'Keep for (days)';

  @override
  String get scheduleTitle => 'Schedule Settings';

  @override
  String get scheduleEnabled => 'Enable Schedule';

  @override
  String get scheduleInterval => 'Interval';

  @override
  String get scheduleEvery5Min => 'Every 5 minutes';

  @override
  String get scheduleEvery15Min => 'Every 15 minutes';

  @override
  String get scheduleEvery30Min => 'Every 30 minutes';

  @override
  String get scheduleEveryHour => 'Every hour';

  @override
  String get scheduleEveryDay => 'Daily';

  @override
  String get scheduleCustom => 'Custom';

  @override
  String get scheduleRealtime => 'Real-time (auto-sync on file changes)';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'Follow System';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsEnabled => 'Enable Notifications';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsLicense => 'License';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsBandwidthLimit => 'Bandwidth Limit';

  @override
  String get settingsMaxUpload => 'Max Upload Speed';

  @override
  String get settingsMaxDownload => 'Max Download Speed';

  @override
  String get settingsUnlimited => 'Unlimited';

  @override
  String get errorGeneral => 'An error occurred';

  @override
  String get errorNetworkTimeout => 'Network timeout';

  @override
  String get errorPermissionDenied => 'Permission denied';

  @override
  String get errorFolderNotFound => 'Folder not found';

  @override
  String get errorDiskFull => 'Disk full';

  @override
  String get errorFileInUse => 'File is in use';

  @override
  String get errorConnectionLost => 'Connection lost';

  @override
  String get conflictTitle => 'File Conflict';

  @override
  String get conflictDesc => 'The same file was modified on both sides';

  @override
  String get conflictKeepLeft => 'Keep source file';

  @override
  String get conflictKeepRight => 'Keep target file';

  @override
  String get conflictKeepBoth => 'Keep both (rename)';

  @override
  String get conflictKeepNewer => 'Keep newer file';

  @override
  String get onboardingTitle1 => 'Sync Files Safely';

  @override
  String get onboardingDesc1 =>
      'Easily synchronize files between local folders, USB drives, networks, and remote servers.';

  @override
  String get onboardingTitle2 => 'Three Sync Modes';

  @override
  String get onboardingDesc2 =>
      'Choose from Mirror, Two-Way, or Update modes. Custom settings also available.';

  @override
  String get onboardingTitle3 => 'Easy Connection';

  @override
  String get onboardingDesc3 =>
      'Set up device connections easily with QR code scanning and setup wizards.';

  @override
  String get onboardingTitle4 => 'Safe Backups';

  @override
  String get onboardingDesc4 =>
      'Protect your important files with versioning. Stay safe even in emergencies.';

  @override
  String get adRemoveAds => 'Remove Ads';

  @override
  String get adWatchToUnlock => 'Watch video to unlock feature';

  @override
  String get adFreeFor24h => 'Ad-free for 24 hours';

  @override
  String get noSyncJobs => 'No Sync Jobs';

  @override
  String get noSyncJobsDesc =>
      'Tap \'Create New Job\' to set up your first sync job';

  @override
  String get createNewJob => 'Create New Job';

  @override
  String get jobName => 'Job Name';

  @override
  String get jobNameHint => 'e.g., Photo Backup, Document Sync';

  @override
  String get lastSync => 'Last Sync';

  @override
  String get neverSynced => 'Never synced';

  @override
  String get helpTitle => 'Help';

  @override
  String get helpSetup => 'How to Set Up Connections';

  @override
  String get helpSyncModes => 'Sync Mode Differences';

  @override
  String get helpFilters => 'How to Use Filters';

  @override
  String get helpTroubleshooting => 'Troubleshooting';

  @override
  String get helpFAQ => 'FAQ';

  @override
  String get premiumTitle => 'SyncSphere Premium';

  @override
  String get premiumSubtitle => 'Enjoy an ad-free experience';

  @override
  String get premiumFeature1 => 'Ad-free experience';

  @override
  String get premiumFeature2 => 'Priority support';

  @override
  String get premiumFeature3 => 'Faster help from the SyncSphere team.';

  @override
  String get premiumPurchase => 'Upgrade to Premium';

  @override
  String get premiumRestore => 'Restore Purchases';

  @override
  String get premiumActive => 'You\'re a Premium member';

  @override
  String get premiumActiveDesc =>
      'All premium features are unlocked. No ads will be shown.';

  @override
  String get premiumProcessing => 'Processing...';

  @override
  String get premiumError => 'Error';

  @override
  String get premiumPrice => '\$20.00';

  @override
  String get premium => 'Premium';

  @override
  String get serverTitle => 'PC Sync';

  @override
  String get serverStart => 'Start Server';

  @override
  String get serverStop => 'Stop Server';

  @override
  String get serverRunning => 'Server Running';

  @override
  String get serverStopped => 'Server Stopped';

  @override
  String get serverUrl => 'Connection URL';

  @override
  String get serverUrlCopied => 'URL copied to clipboard';

  @override
  String get serverInstruction1 => '1. Open the URL below in your PC browser';

  @override
  String get serverInstruction2 => '2. Or scan the QR code';

  @override
  String get serverInstruction3 =>
      '3. Select a sync folder in the browser and start syncing!';

  @override
  String serverConnectedClients(int count) {
    return 'Connected clients: $count';
  }

  @override
  String get serverSyncDir => 'Sync Folder';

  @override
  String get serverChangeSyncDir => 'Change Sync Folder';

  @override
  String get serverNoClients => 'Waiting for device connections...';

  @override
  String get tabDashboard => 'Dashboard';

  @override
  String get tabFolders => 'Folders';

  @override
  String get tabDevices => 'Devices';

  @override
  String get tabSettings => 'Settings';

  @override
  String get dashboardTitle => 'SyncSphere';

  @override
  String get quickActionAddFolder => 'Add Folder';

  @override
  String get quickActionPcSync => 'PC Sync';

  @override
  String get quickActionAddDevice => 'Add Device';

  @override
  String get noFoldersTitle => 'No folders yet';

  @override
  String get noFoldersSubtitle => 'Add a folder to start syncing';

  @override
  String get noDevicesTitle => 'No devices yet';

  @override
  String get noDevicesSubtitle => 'Add a device to start syncing files';

  @override
  String get scanQrCode => 'Scan QR Code';

  @override
  String get manualAdd => 'Add Manually';

  @override
  String get connectionInfo => 'Connection Info';

  @override
  String get sharedFolders => 'Shared Folders';

  @override
  String get noSharedFolders => 'No shared folders';

  @override
  String get statistics => 'Statistics';

  @override
  String get status => 'Status';

  @override
  String get removeDeviceConfirm => 'Remove this device?';

  @override
  String get actionCannotBeUndone => 'This action cannot be undone.';

  @override
  String get settingsSync => 'Sync';

  @override
  String get settingsRunConditions => 'Run Conditions';

  @override
  String get settingsBackground => 'Background';

  @override
  String get settingsStorage => 'Storage';

  @override
  String get settingsBackup => 'Backup';

  @override
  String get settingsPremium => 'Premium';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get syncModeDefault => 'Default Sync Mode';

  @override
  String get bandwidthUpload => 'Upload Bandwidth';

  @override
  String get bandwidthDownload => 'Download Bandwidth';

  @override
  String get wifiOnlySync => 'Sync on Wi-Fi only';

  @override
  String get chargingOnlySync => 'Sync while charging only';

  @override
  String get batterySaverOff => 'Only when battery saver is off';

  @override
  String get allowedSsids => 'Allowed SSIDs';

  @override
  String get addSsid => 'Add SSID';

  @override
  String get backgroundSync => 'Background Sync';

  @override
  String get autoStartOnBoot => 'Auto start on boot';

  @override
  String get disableBatteryOptimization => 'Disable Battery Optimization';

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get permissionDenied => 'Permission denied';

  @override
  String get syncCompleteNotification => 'Sync Complete';

  @override
  String get errorNotification => 'Error notifications';

  @override
  String get newDeviceNotification => 'New device notifications';

  @override
  String get exportConfig => 'Export Config';

  @override
  String get importConfig => 'Import Config';

  @override
  String get upgradePremium => 'Upgrade to Premium';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get premiumMember => 'Premium member';

  @override
  String get freePlan => 'Free plan';

  @override
  String get premiumPlan => 'Premium plan';

  @override
  String get oneTimePurchase => 'One-time purchase';

  @override
  String get noSubscription => 'No subscription';

  @override
  String get purchasePremium => 'Purchase Premium';

  @override
  String get startServer => 'Start Server';

  @override
  String get stopServer => 'Stop Server';

  @override
  String get serverInstructions1 => 'Connect to the same Wi-Fi network';

  @override
  String get serverInstructions2 => 'Open the URL above in your PC browser';

  @override
  String get serverInstructions3 => 'Select a folder and start syncing';

  @override
  String get noInstallRequired => 'No software installation required on PC';

  @override
  String get connectedClients => 'Connected clients';

  @override
  String get syncOverview => 'Overview';

  @override
  String get syncFolders => 'Folders';

  @override
  String get syncFilters => 'Filters';

  @override
  String get forceRescan => 'Force Rescan';

  @override
  String get noFilters => 'No filters';

  @override
  String get lastSyncResult => 'Last sync result';

  @override
  String get filesComplete => 'Complete';

  @override
  String get speed => 'Speed';

  @override
  String get copied => 'Copied';

  @override
  String get deleted => 'Deleted';

  @override
  String get skipped => 'Skipped';

  @override
  String get conflicts => 'Conflicts';

  @override
  String get errors => 'Errors';

  @override
  String get duration => 'Duration';

  @override
  String get version => 'Version';

  @override
  String get licenses => 'Licenses';

  @override
  String get sourceCode => 'Source Code';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get copyUrl => 'Copy URL';

  @override
  String get urlCopied => 'URL copied to clipboard';

  @override
  String get activeSyncs => 'Active Syncs';

  @override
  String get recentSync => 'Recent Syncs';

  @override
  String get noFoldersDescription =>
      'Create folder settings and sync your files';

  @override
  String get noFoldersAction =>
      'Tap the + button in the bottom-right to add a new folder.';

  @override
  String get neverConnected => 'Never connected';

  @override
  String get ipAddress => 'IP Address';

  @override
  String get port => 'Port';

  @override
  String get transferAmount => 'Transferred';

  @override
  String get lastConnected => 'Last Connected';

  @override
  String get ssidHint => 'Enter Wi-Fi network name';

  @override
  String get premiumThankYou => 'Thank you for supporting SyncSphere!';

  @override
  String get basicSync => 'Basic sync';

  @override
  String get noAds => 'No ads';

  @override
  String get fastSync => 'Fast sync';

  @override
  String get noAdsComplete => 'Complete ad removal';

  @override
  String get unlimitedSpeed => 'Unlimited sync speed';

  @override
  String get prioritySupport => 'Priority support';

  @override
  String get syncModeLabel => 'Sync Mode';

  @override
  String get compareModeLabel => 'Compare Mode';

  @override
  String get running => 'Running';

  @override
  String get waiting => 'Idle';

  @override
  String get paths => 'Paths';

  @override
  String get source => 'Source';

  @override
  String get target => 'Target';

  @override
  String get type => 'Type';

  @override
  String get previousResult => 'Previous Result';

  @override
  String get files => 'files';

  @override
  String aboutMinutes(int min) {
    return '~$min min';
  }

  @override
  String get preparing => 'Preparing...';

  @override
  String get detailedInfo => 'Details';

  @override
  String get directPcSync => 'Direct sync with your PC';

  @override
  String get disableBatteryOptDesc =>
      'Disabling battery optimization improves background sync reliability';

  @override
  String summaryCardSemantics(String title, String value) {
    return '$title: $value';
  }

  @override
  String deviceStatusSemantics(String status) {
    return 'Device status: $status';
  }

  @override
  String syncProgressSemantics(int percent) {
    return 'Progress: $percent%';
  }

  @override
  String serverStatusSemantics(String status) {
    return 'Server status: $status';
  }
}
