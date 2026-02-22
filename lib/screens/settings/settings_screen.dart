import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';

import '../../providers/settings_provider.dart';
import '../../providers/premium_provider.dart';
import '../../theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Local state for mocked features
  String _defaultSyncMode = 'mirror';
  double _downloadLimit = 0.0;
  bool _wifiOnly = true;
  bool _chargingOnly = false;
  bool _powerSaveOffOnly = true;
  final List<String> _allowedSsids = ['MyHomeNetwork', 'Office_5G'];
  bool _backgroundSync = true;
  bool _autoStart = false;
  bool _errorNotifications = true;
  bool _newDeviceNotifications = true;

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
                title: '一般',
                children: [
                  _SettingsEntry(
                    label: 'テーマ',
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
                    label: '言語',
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
              ),
              const Gap(AppSpacing.xxl),

              _SettingsSection(
                title: '同期',
                children: [
                  _SettingsEntry(
                    label: 'デフォルト同期モード',
                    valueWidget: DropdownButton<String>(
                      value: _defaultSyncMode,
                      underline: const SizedBox(),
                      items: [
                        DropdownMenuItem(value: 'mirror', child: Text(l10n.syncModeMirror)),
                        DropdownMenuItem(value: 'twoWay', child: Text(l10n.syncModeTwoWay)),
                        DropdownMenuItem(value: 'update', child: Text(l10n.syncModeUpdate)),
                        DropdownMenuItem(value: 'custom', child: Text(l10n.syncModeCustom)),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _defaultSyncMode = value);
                        }
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingsEntry(
                    label: '帯域制限 (アップロード)',
                    isVertical: true,
                    valueWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          settings.bandwidthLimit == 0 ? '無制限' : '${settings.bandwidthLimit.toInt()} KB/s',
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
                    label: '帯域制限 (ダウンロード)',
                    isVertical: true,
                    valueWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _downloadLimit == 0 ? '無制限' : '${_downloadLimit.toInt()} KB/s',
                          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                        ),
                        Slider(
                          value: _downloadLimit,
                          min: 0,
                          max: 10000,
                          divisions: 100,
                          onChanged: (value) {
                            setState(() => _downloadLimit = value);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(AppSpacing.xxl),

              _SettingsSection(
                title: '実行条件',
                children: [
                  SwitchListTile(
                    title: Text(l10n.wifiOnlySync),
                    value: _wifiOnly,
                    onChanged: (value) {
                      setState(() => _wifiOnly = value);
                      // TODO: Wire to RunConditionsProvider
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(l10n.chargingOnlySync),
                    value: _chargingOnly,
                    onChanged: (value) {
                      setState(() => _chargingOnly = value);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(l10n.batterySaverOff),
                    value: _powerSaveOffOnly,
                    onChanged: (value) {
                      setState(() => _powerSaveOffOnly = value);
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
                            ..._allowedSsids.map((ssid) => Chip(
                              label: Text(ssid),
                              onDeleted: () {
                                setState(() => _allowedSsids.remove(ssid));
                              },
                            )),
                            ActionChip(
                              label: Text(l10n.addSsid),
                              avatar: const Icon(Icons.add, size: 16),
                              onPressed: () {
                                _showAddSsidSheet(context);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(AppSpacing.xxl),

              _SettingsSection(
                title: 'バックグラウンド',
                children: [
                  SwitchListTile(
                    title: Text(l10n.backgroundSync),
                    value: _backgroundSync,
                    onChanged: (value) {
                      setState(() => _backgroundSync = value);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(l10n.autoStartOnBoot),
                    value: _autoStart,
                    onChanged: (value) {
                      setState(() => _autoStart = value);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text(l10n.disableBatteryOptimization, style: const TextStyle(color: Colors.blue)),
                    onTap: () {
                      // Mock open Android battery settings
                      debugPrint('Open battery settings intent');
                    },
                  ),
                ],
              ),
              const Gap(AppSpacing.xxl),

              _SettingsSection(
                title: '通知',
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
                    value: _errorNotifications,
                    onChanged: (value) {
                      setState(() => _errorNotifications = value);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(l10n.newDeviceNotification),
                    value: _newDeviceNotifications,
                    onChanged: (value) {
                      setState(() => _newDeviceNotifications = value);
                    },
                  ),
                ],
              ),
              const Gap(AppSpacing.xxl),

              _SettingsSection(
                title: 'バックアップ',
                children: [
                  ListTile(
                    title: Text(l10n.exportConfig),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text(l10n.importConfig),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ],
              ),
              const Gap(AppSpacing.xxl),

              _SettingsSection(
                title: 'プレミアム',
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
                        premium.isPremium ? '会員' : '無料',
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
              ),
              const Gap(AppSpacing.xxl),

              _SettingsSection(
                title: 'このアプリについて',
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
                    onTap: () {},
                  ),
                ],
              ),
              const Gap(AppSpacing.xxxl),
            ],
          );
        },
      ),
    );
  }

  void _showAddSsidSheet(BuildContext context) {
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
                decoration: const InputDecoration(
                  hintText: 'WiFiネットワーク名を入力',
                ),
                autofocus: true,
              ),
              const Gap(AppSpacing.lg),
              FilledButton(
                onPressed: () {
                  if (textController.text.isNotEmpty) {
                    setState(() {
                      if (!_allowedSsids.contains(textController.text)) {
                        _allowedSsids.add(textController.text);
                      }
                    });
                    Navigator.pop(context);
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
