import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/device_info.dart';
import '../../models/sync_enums.dart';
import '../../providers/device_provider.dart';
import '../../theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  Future<void> _refreshDevices(BuildContext context) async {
    // Simulate LAN discovery
    await Future<void>.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.tabDevices, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Consumer<DeviceProvider>(
        builder: (context, provider, child) {
          final devices = provider.devices;

          if (devices.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => _refreshDevices(context),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.xxl),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.devices_outlined,
                              size: AppSpacing.iconHero,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                          const Gap(AppSpacing.xl),
                          Text(
                            'デバイスを追加してファイルを同期しましょう',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.2),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final onlineDevices = devices.where((d) => d.isOnline).toList();
          final offlineDevices = devices.where((d) => !d.isOnline).toList();

          return RefreshIndicator(
            onRefresh: () => _refreshDevices(context),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if (onlineDevices.isNotEmpty) ...[
                  const _SectionHeader(
                    title: 'オンライン',
                    color: Colors.green,
                  ),
                  const Gap(AppSpacing.sm),
                  ...onlineDevices.map((d) => _DeviceCard(device: d)),
                  const Gap(AppSpacing.lg),
                ],
                if (offlineDevices.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'オフライン',
                    color: theme.colorScheme.outline,
                  ),
                  const Gap(AppSpacing.sm),
                  ...offlineDevices.map((d) => _DeviceCard(device: d)),
                ],
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDeviceSheet(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.addDevice),
      ).animate().scale(delay: 300.ms, duration: 300.ms, curve: Curves.easeOutBack),
    );
  }

  void _showAddDeviceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _AddDeviceSheet(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const Gap(AppSpacing.md),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final DeviceInfo device;

  const _DeviceCard({required this.device});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOnline = device.isOnline;
    final badgeColor = isOnline ? Colors.green : theme.colorScheme.outline;

    final String lastSeenText = device.lastSeen != null
        ? '${device.lastSeen!.year}/${device.lastSeen!.month.toString().padLeft(2, '0')}/${device.lastSeen!.day.toString().padLeft(2, '0')} ${device.lastSeen!.hour.toString().padLeft(2, '0')}:${device.lastSeen!.minute.toString().padLeft(2, '0')}'
        : '未接続';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/device-detail', arguments: device);
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Row(
            children: [
              Badge(
                backgroundColor: badgeColor,
                smallSize: 12,
                child: CircleAvatar(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    _getPlatformIcon(device.platform),
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const Gap(AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(2),
                    Text(
                      '${device.address}:${device.port}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      device.connectionType.name.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Gap(4),
                  Text(
                    lastSeenText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'android':
        return Icons.android;
      case 'ios':
        return Icons.phone_iphone;
      case 'windows':
        return Icons.desktop_windows;
      case 'macos':
        return Icons.desktop_mac;
      case 'linux':
        return Icons.computer;
      case 'web':
        return Icons.web;
      default:
        return Icons.device_unknown;
    }
  }
}

class _AddDeviceSheet extends StatelessWidget {
  const _AddDeviceSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.pagePadding,
        right: AppSpacing.pagePadding,
        top: AppSpacing.xl,
        bottom: AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.addDevice,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const Gap(AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _AddOptionCard(
                  icon: Icons.qr_code_scanner,
                  label: 'QRスキャン',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              const Gap(AppSpacing.md),
              Expanded(
                child: _AddOptionCard(
                  icon: Icons.edit,
                  label: l10n.manualAdd,
                  onTap: () {
                    Navigator.pop(context);
                    _showManualAddDialog(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showManualAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _ManualAddDialog(),
    );
  }
}

class _AddOptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AddOptionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: AppSpacing.iconLg, color: theme.colorScheme.primary),
              const Gap(AppSpacing.sm),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManualAddDialog extends StatefulWidget {
  const _ManualAddDialog();

  @override
  State<_ManualAddDialog> createState() => _ManualAddDialogState();
}

class _ManualAddDialogState extends State<_ManualAddDialog> {
  final _addressController = TextEditingController();
  final _portController = TextEditingController(text: '22000');

  @override
  void dispose() {
    _addressController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.manualAdd),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'IPアドレス',
              hintText: '192.168.1.100',
            ),
            keyboardType: TextInputType.url,
          ),
          const Gap(AppSpacing.md),
          TextField(
            controller: _portController,
            decoration: const InputDecoration(
              labelText: 'ポート',
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (_addressController.text.isNotEmpty && _portController.text.isNotEmpty) {
              final newDevice = DeviceInfo(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: 'Unknown Device',
                address: _addressController.text,
                port: int.tryParse(_portController.text) ?? 22000,
                connectionType: ConnectionType.lan,
                isOnline: true,
                platform: 'unknown',
              );
              context.read<DeviceProvider>().addOrUpdateDevice(newDevice);
              Navigator.pop(context);
            }
          },
          child: Text(l10n.addDevice),
        ),
      ],
    );
  }
}
