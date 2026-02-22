import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncsphere/models/sync_job.dart';
import 'package:syncsphere/providers/device_provider.dart';
import 'package:syncsphere/providers/sync_provider.dart';
import 'package:syncsphere/theme/app_spacing.dart';
import 'package:syncsphere/widgets/ad_banner_widget.dart';
import 'package:syncsphere/widgets/empty_state_widget.dart';
import 'package:syncsphere/widgets/sync_job_card.dart';
import '../../l10n/app_localizations.dart';

/// Dashboard — main overview screen (tab 0 in AppShell).
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final SyncProvider syncProvider = context.watch<SyncProvider>();
    final DeviceProvider deviceProvider = context.watch<DeviceProvider>();

    final int totalFolders = syncProvider.jobs.length;
    final int connectedDevices = deviceProvider.connectedDevices.length;
    final int activeSyncs = syncProvider.jobs.where((SyncJob job) => job.isActive).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SyncSphere'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              children: <Widget>[
                // Sync status summary row
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _SummaryCard(
                        title: l10n.tabFolders,
                        value: totalFolders.toString(),
                        icon: Icons.folder_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _SummaryCard(
                        title: l10n.tabDevices,
                        value: connectedDevices.toString(),
                        icon: Icons.devices_rounded,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _SummaryCard(
                        title: l10n.activeSyncs,
                        value: activeSyncs.toString(),
                        icon: Icons.sync_rounded,
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // Quick action buttons row
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: <Widget>[
                    ActionChip(
                      avatar: const Icon(Icons.create_new_folder_rounded, size: 18),
                      label: Text(l10n.quickActionAddFolder),
                      onPressed: () => Navigator.pushNamed(context, '/wizard'),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.computer_rounded, size: 18),
                      label: Text(l10n.quickActionPcSync),
                      onPressed: () => Navigator.pushNamed(context, '/server'),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                      label: Text(l10n.quickActionAddDevice),
                      onPressed: () {
                        // Normally navigates to devices tab or scanner
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // Recent sync jobs list
                Text(
                  l10n.recentSync,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (syncProvider.jobs.isEmpty)
                  EmptyStateWidget(
                    icon: Icons.auto_awesome_motion_rounded,
                    title: l10n.noFoldersSubtitle,
                    description: l10n.noFoldersDescription,
                  )
                else
                  ...syncProvider.jobs.take(5).map((SyncJob job) {
                    return SyncJobCard(
                      job: job,
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/folder-detail',
                        arguments: job,
                      ),
                    );
                  }),
              ],
            ),
          ),
          const AdBannerWidget(),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: color, size: AppSpacing.iconMd),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
