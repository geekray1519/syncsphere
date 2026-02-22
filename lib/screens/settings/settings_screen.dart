import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/settings_provider.dart';
import '../../providers/premium_provider.dart';
import '../../theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';

const bool _disableAnimationsForTest = bool.fromEnvironment('FLUTTER_TEST');

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.tabSettings, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Consumer2<SettingsProvider, PremiumProvider>(
        builder: (context, settings, premium, child) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding, vertical: AppSpacing.xl),
            children: [
              _SettingsSection(
                title: l10n.settingsGeneral,
                children: [
                  _SettingsEntry(
                    label: l10n.settingsTheme,
                    valueWidget: SegmentedButton<ThemeMode>(
                      segments: [
                        ButtonSegment(value: ThemeMode.system, label: Text(l10n.themeSystem)),
                        ButtonSegment(value: ThemeMode.light, label: Text(l10n.themeLight)),
                        ButtonSegment(value: ThemeMode.dark, label: Text(l10n.themeDark)),
                      ],
                      selected: {settings.themeMode},
                      onSelectionChanged: (Set<ThemeMode> selection) {
                        settings.setThemeMode(selection.first);
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingsEntry(
                    label: l10n.settingsLanguage,
                    valueWidget: SegmentedButton<Locale>(
                      segments: const [
                        ButtonSegment(value: Locale('ja'), label: Text('日本語')),
                        ButtonSegment(value: Locale('en'), label: Text('English')),
                      ],
                      selected: {settings.locale.languageCode == 'ja' ? const Locale('ja') : const Locale('en')},
                      onSelectionChanged: (Set<Locale> selection) {
                        settings.setLocale(selection.first);
                      },
                    ),
                  ),
                ],
              ).animate(autoPlay: !_disableAnimationsForTest).fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),
              const Gap(AppSpacing.xxl),

              _SettingsSection(
                title: l10n.settingsSync,
                children: [
                  _SettingsEntry(
                    label: l10n.syncModeDefault,
                    valueWidget: DropdownButton<String>(
                      value: settings.defaultSyncMode,
                      underline: const SizedBox(),
                      items: [
                        DropdownMenuItem(value: 'mirror', child: Text(l10n.syncModeMirror)),
                        DropdownMenuItem(value: 'twoWay', child: Text(l10n.syncModeTwoWay)),
                        DropdownMenuItem(value: 'update', child: Text(l10n.syncModeUpdate)),
                        DropdownMenuItem(value: 'custom', child: Text(l10n.syncModeCustom)),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          settings.setDefaultSyncMode(value);
                        }
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingsEntry(
                    label: l10n.bandwidthUpload,
                    isVertical: true,
                    valueWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          settings.bandwidthLimit == 0 ? l10n.settingsUnlimited : '${settings.bandwidthLimit.toInt()} KB/s',
                          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                        ),
                        Slider(
                          value: settings.bandwidthLimit,
                          min: 0,
                          max: 10000,
                          divisions: 100,
                          onChanged: (value) => settings.setBandwidthLimit(value),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingsEntry(
                    label: l10n.bandwidthDownload,
                    isVertical: true,
                    valueWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          settings.downloadBandwidthLimit == 0
                              ? l10n.settingsUnlimited
                              : '${settings.downloadBandwidthLimit.toInt()} KB/s',
                          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                        ),
                        Slider(
                          value: settings.downloadBandwidthLimit,
                          min: 0,
                          max: 10000,
                          divisions: 100,
                          onChanged: (value) => settings.setDownloadBandwidthLimit(value),
                        ),
                      ],
                    ),
                  ),
                ],
              ).animate(autoPlay: !_disableAnimationsForTest).fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),
              const Gap(AppSpacing.xxl),

              _SettingsSection(
                title: l10n.settingsRunConditions,
                children: [
                  SwitchListTile(
                    title: Text(l10n.wifiOnlySync),
                    value: settings.wifiOnlySync,
                    onChanged: (value) {
                      settings.setWifiOnlySync(value);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(l10n.chargingOnlySync),
                    value: settings.chargingOnlySync,
                    onChanged: (value) {
                      settings.setChargingOnlySync(value);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(l10n.batterySaverOff),
                    value: settings.powerSaveOffOnly,
                    onChanged: (value) {
                      settings.setPowerSaveOffOnly(value);
                    },
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.allowedSsids, style: const TextStyle(fontWeight: FontWeight.w600)),
                        const Gap(AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.xs,
                          children: [
                            ...settings.allowedSsids.map((ssid) => Chip(
                              label: Text(ssid),
                              onDeleted: () {
                                settings.removeSsid(ssid);
                              },
                            )),
                            ActionChip(
                              label: Text(l10n.addSsid),
                              avatar: const Icon(Icons.add, size: 16),
                              onPressed: () {
                                _showAddSsidSheet(context, settings);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ).animate(autoPlay: !_disableAnimationsForTest).fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),
              const Gap(AppSpacing.xxl),

              _SettingsSection(
                title: l10n.settingsBackground,
                children: [
                  SwitchListTile(
                    title: Text(l10n.backgroundSync),
                    value: settings.backgroundSync,
                    onChanged: (value) {
                      settings.setBackgroundSync(value);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(l10n.autoStartOnBoot),
                    value: settings.autoStartOnBoot,
                    onChanged: (value) {
                      settings.setAutoStartOnBoot(value);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text(l10n.disableBatteryOptimization, style: TextStyle(color: theme.colorScheme.primary)),
                    onTap: () async {
                      final status = await Permission.ignoreBatteryOptimizations.request();
                      if (context.mounted) {
                        _showStyledSnackBar(
                          context,
                          message: status.isGranted ? l10n.settingsSaved : l10n.permissionDenied,
                        );
                      }
                    },
                  ),
                ],
              ).animate(autoPlay: !_disableAnimationsForTest).fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),
              const Gap(AppSpacing.xxl),

              _SettingsSection(
                title: l10n.settingsNotifications,
                children: [
                  SwitchListTile(
                    title: Text(l10n.syncCompleteNotification),
                    value: settings.notificationsEnabled,
                    onChanged: (value) {
                      settings.setNotificationsEnabled(value);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(l10n.errorNotification),
                    value: settings.errorNotifications,
                    onChanged: (value) {
                      settings.setErrorNotifications(value);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(l10n.newDeviceNotification),
                    value: settings.newDeviceNotifications,
                    onChanged: (value) {
                      settings.setNewDeviceNotifications(value);
                    },
                  ),
                ],
              ).animate(autoPlay: !_disableAnimationsForTest).fadeIn(delay: 500.ms, duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),
              const Gap(AppSpacing.xxl),

              _SettingsSection(
                title: l10n.settingsBackup,
                children: [
                  ListTile(
                    title: Text(l10n.exportConfig),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _exportConfig(context, settings, l10n),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text(l10n.importConfig),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _importConfig(context, settings, l10n),
                  ),
                ],
              ).animate(autoPlay: !_disableAnimationsForTest).fadeIn(delay: 500.ms, duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),
              const Gap(AppSpacing.xxl),

              _SettingsSection(
                title: l10n.settingsPremium,
                children: [
                  ListTile(
                    leading: Icon(Icons.workspace_premium, color: theme.colorScheme.primary),
                    title: Text(l10n.status, style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: premium.isPremium ? Colors.amber.shade100 : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        premium.isPremium ? l10n.premiumMember : l10n.freePlan,
                        style: TextStyle(
                          color: premium.isPremium ? Colors.amber.shade900 : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (!premium.isPremium) ...[
                    const Divider(height: 1),
                    ListTile(
                      title: Text(l10n.upgradePremium, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        Navigator.pushNamed(context, '/premium');
                      },
                    ),
                  ],
                  const Divider(height: 1),
                  ListTile(
                    title: Text(l10n.restorePurchases, style: TextStyle(color: theme.colorScheme.primary)),
                    onTap: () {
                      premium.restorePurchases();
                    },
                  ),
                ],
              ).animate(autoPlay: !_disableAnimationsForTest).fadeIn(delay: 500.ms, duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),
              const Gap(AppSpacing.xxl),

              _SettingsSection(
                title: l10n.settingsAbout,
                children: [
                  ListTile(
                    title: Text(l10n.version),
                    trailing: Text('1.0.0'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text(l10n.licenses),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showLicensePage(context: context);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text(l10n.sourceCode),
                    trailing: const Icon(Icons.open_in_new, size: 20),
                    onTap: () => launchUrl(
                      Uri.parse('https://github.com/geekray1519/syncsphere'),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                ],
              ).animate(autoPlay: !_disableAnimationsForTest).fadeIn(delay: 500.ms, duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),
              const Gap(AppSpacing.xxxl),
            ],
          );
        },
      ),
    );
  }

  Future<void> _exportConfig(
    BuildContext context,
    SettingsProvider settings,
    AppLocalizations l10n,
  ) async {
    try {
      final Map<String, dynamic> jsonMap = settings.exportConfigToJson();
      final String prettyJson = const JsonEncoder.withIndent('  ').convert(jsonMap);
      final Directory outputDirectory = await _resolveConfigDirectory();
      await outputDirectory.create(recursive: true);

      final String timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final String filePath = p.join(outputDirectory.path, 'syncsphere_config_$timestamp.json');
      final File configFile = File(filePath);
      await configFile.writeAsString(prettyJson);

      if (context.mounted) {
        _showStyledSnackBar(
          context,
          message: '${l10n.exportConfig}: ${configFile.path}',
        );
      }
    } catch (error) {
      if (context.mounted) {
        _showStyledSnackBar(
          context,
          message: '${l10n.errorGeneral}: $error',
        );
      }
    }
  }

  Future<void> _importConfig(
    BuildContext context,
    SettingsProvider settings,
    AppLocalizations l10n,
  ) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const <String>['json'],
      );

      if (result == null) {
        return;
      }

      final String? pickedFilePath = result.files.single.path;
      if (pickedFilePath == null) {
        throw const FormatException('Selected file path is unavailable.');
      }

      final String jsonContent = await File(pickedFilePath).readAsString();
      final dynamic decoded = jsonDecode(jsonContent);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid config format.');
      }

      await settings.importConfigFromJson(decoded);

      if (context.mounted) {
        _showStyledSnackBar(
          context,
          message: '${l10n.importConfig}: ${l10n.done}',
        );
      }
    } catch (error) {
      if (context.mounted) {
        _showStyledSnackBar(
          context,
          message: '${l10n.errorGeneral}: $error',
        );
      }
    }
  }

  void _showStyledSnackBar(
    BuildContext context, {
    required String message,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<Directory> _resolveConfigDirectory() async {
    final Directory? downloadsDirectory = await getDownloadsDirectory();
    if (downloadsDirectory != null) {
      return downloadsDirectory;
    }

    final Directory? externalStorageDirectory = await getExternalStorageDirectory();
    if (externalStorageDirectory != null) {
      return externalStorageDirectory;
    }

    return getApplicationDocumentsDirectory();
  }

  void _showAddSsidSheet(BuildContext context, SettingsProvider settings) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final textController = TextEditingController();
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: AppSpacing.pagePadding,
            right: AppSpacing.pagePadding,
            top: AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.addSsid, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Gap(AppSpacing.lg),
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  hintText: l10n.ssidHint,
                ),
                autofocus: true,
              ),
              const Gap(AppSpacing.lg),
              FilledButton(
                onPressed: () async {
                  if (textController.text.isNotEmpty) {
                    await settings.addSsid(textController.text);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                child: Text(l10n.addSsid),
              ),
              const Gap(AppSpacing.xl),
            ],
          ),
        );
        },
      );
    }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.sm),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Card.filled(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingsEntry extends StatelessWidget {
  final String label;
  final Widget valueWidget;
  final bool isVertical;

  const _SettingsEntry({
    required this.label,
    required this.valueWidget,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: isVertical
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                const Gap(AppSpacing.sm),
                valueWidget,
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                valueWidget,
              ],
            ),
    );
  }
}
