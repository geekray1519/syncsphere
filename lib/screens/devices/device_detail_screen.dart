import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';

import '../../models/device_info.dart';
import '../../providers/device_provider.dart';
import '../../providers/sync_provider.dart';
import '../../theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';

class DeviceDetailScreen extends StatelessWidget {
  const DeviceDetailScreen({super.key, required this.device});

  final DeviceInfo device;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(device.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            onSelected: (value) {
              if (value == 'remove') {
                _confirmRemoveDevice(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: theme.colorScheme.error),
                    const Gap(AppSpacing.sm),
                    Text(
                      l10n.removeDevice,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding, vertical: AppSpacing.xl),
        children: [
          _SettingsSection(
            title: l10n.connectionInfo,
            children: [
              _SettingsEntry(
                label: l10n.status,
                valueWidget: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Semantics(
                      label: l10n.deviceStatusSemantics(
                        device.isOnline ? l10n.deviceOnline : l10n.deviceOffline,
                      ),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: device.isOnline
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                        ),
                      ),
                    ),
                    const Gap(AppSpacing.xs),
                    Text(
                      device.isOnline ? l10n.deviceOnline : l10n.deviceOffline,
                      style: TextStyle(
                        color: device.isOnline
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              _SettingsEntry(
                label: l10n.ipAddress,
                valueText: device.address,
              ),
              const Divider(height: 1),
              _SettingsEntry(
                label: l10n.port,
                valueText: device.port.toString(),
              ),
              const Divider(height: 1),
              _SettingsEntry(
                label: l10n.connectionType,
                valueText: device.connectionType.name.toUpperCase(),
              ),
            ],
          ),
          const Gap(AppSpacing.xxl),
          _SettingsSection(
            title: l10n.sharedFolders,
            children: [
              Consumer<SyncProvider>(
                builder: (context, syncProvider, child) {
                  final sharedJobs = syncProvider.jobs.where((j) {
                    return j.targetPath.contains(device.address) ||
                           j.sourcePath.contains(device.address) ||
                           j.targetPath.contains(device.id) ||
                           j.sourcePath.contains(device.id);
                  }).toList();

                  if (sharedJobs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Center(
                        child: Text(l10n.noSharedFolders),
                      ),
                    );
                  }

                  return Column(
                    children: sharedJobs.map((job) {
                      return ListTile(
                        leading: Icon(Icons.folder_shared, color: theme.colorScheme.primary),
                        title: Text(job.name),
                        subtitle: Text(
                          job.targetPath,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/folder-detail',
                          arguments: job,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
          const Gap(AppSpacing.xxl),
          _SettingsSection(
            title: l10n.statistics,
            children: [
              _SettingsEntry(
                label: l10n.transferAmount,
                valueText: '0 B',
              ),
              const Divider(height: 1),
              _SettingsEntry(
                label: l10n.lastConnected,
                valueText: device.lastSeen != null
                    ? '${device.lastSeen!.year}/${device.lastSeen!.month.toString().padLeft(2, '0')}/${device.lastSeen!.day.toString().padLeft(2, '0')} ${device.lastSeen!.hour.toString().padLeft(2, '0')}:${device.lastSeen!.minute.toString().padLeft(2, '0')}'
                    : l10n.neverConnected,
              ),
            ],
          ),
          const Gap(AppSpacing.xxxl),
          OutlinedButton(
            onPressed: () => _confirmRemoveDevice(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error),
            ),
            child: Text(l10n.removeDevice, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveDevice(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeDevice),
        content: Text('${device.name} ${l10n.removeDeviceConfirm}\n${l10n.actionCannotBeUndone}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              context.read<DeviceProvider>().removeDevice(device.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
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
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingsEntry extends StatelessWidget {
  final String label;
  final String? valueText;
  final Widget? valueWidget;

  const _SettingsEntry({
    required this.label,
    this.valueText,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.cardPadding, vertical: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          if (valueWidget != null)
            valueWidget!
          else if (valueText != null)
            Text(
              valueText!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
