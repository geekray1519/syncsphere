import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';

import '../../providers/settings_provider.dart';
import '../../providers/premium_provider.dart';
import '../../theme/app_spacing.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Local state for mocked features
  String _defaultSyncMode = 'ミラー';
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

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('設定', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      segments: const [
                        ButtonSegment(value: ThemeMode.system, label: Text('システム')),
                        ButtonSegment(value: ThemeMode.light, label: Text('ライト')),
                        ButtonSegment(value: ThemeMode.dark, label: Text('ダーク')),
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
                      items: const [
                        DropdownMenuItem(value: 'ミラー', child: Text('ミラー')),
                        DropdownMenuItem(value: '双方向', child: Text('双方向')),
                        DropdownMenuItem(value: '更新', child: Text('更新')),
                        DropdownMenuItem(value: 'カスタム', child: Text('カスタム')),
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
                    title: const Text('WiFiのみで同期'),
                    value: _wifiOnly,
                    onChanged: (value) {
                      setState(() => _wifiOnly = value);
                      // TODO: Wire to RunConditionsProvider
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('充電中のみで同期'),
                    value: _chargingOnly,
                    onChanged: (value) {
                      setState(() => _chargingOnly = value);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('省電力モードOFF時のみ'),
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
                        const Text('許可されたSSID', style: TextStyle(fontWeight: FontWeight.w600)),
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
                              label: const Text('追加'),
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
                    title: const Text('バックグラウンド同期'),
                    value: _backgroundSync,
                    onChanged: (value) {
                      setState(() => _backgroundSync = value);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('起動時に自動開始'),
                    value: _autoStart,
                    onChanged: (value) {
                      setState(() => _autoStart = value);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('バッテリー最適化を無効化', style: TextStyle(color: Colors.blue)),
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
                    title: const Text('同期完了'),
                    value: settings.notificationsEnabled,
                    onChanged: (value) {
                      settings.setNotificationsEnabled(value);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('エラー通知'),
                    value: _errorNotifications,
                    onChanged: (value) {
                      setState(() => _errorNotifications = value);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('新しいデバイス検出'),
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
                    title: const Text('設定をエクスポート'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('設定をインポート'),
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
                    title: const Text('ステータス', style: TextStyle(fontWeight: FontWeight.w600)),
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
                      title: Text('プレミアムにアップグレード', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        Navigator.pushNamed(context, '/premium');
                      },
                    ),
                  ],
                  const Divider(height: 1),
                  ListTile(
                    title: Text('購入を復元', style: TextStyle(color: theme.colorScheme.primary)),
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
                  const ListTile(
                    title: Text('バージョン'),
                    trailing: Text('1.0.0'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('ライセンス'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showLicensePage(context: context);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('ソースコード'),
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
              const Text('SSIDを追加', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                child: const Text('追加'),
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