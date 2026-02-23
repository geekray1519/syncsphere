import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:syncsphere/models/sync_job.dart';
import 'package:syncsphere/providers/device_provider.dart';
import 'package:syncsphere/providers/sync_provider.dart';
import 'package:syncsphere/theme/app_spacing.dart';
import 'package:syncsphere/theme/app_theme.dart';
import 'package:syncsphere/widgets/ad_banner_widget.dart';
import 'package:syncsphere/widgets/empty_state_widget.dart';
import 'package:syncsphere/widgets/sync_job_card.dart';

import '../../l10n/app_localizations.dart';
import '../shell/app_shell.dart';

const bool _disableAnimationsForTest = bool.fromEnvironment('FLUTTER_TEST');

/// Dashboard — main overview screen (tab 0 in AppShell).
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _formatRelativeTime(DateTime? dateTime, AppLocalizations l10n) {
    if (dateTime == null) {
      return l10n.neverSynced;
    }

    final Duration difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes <= 0) {
      return l10n.justNow;
    }
    if (difference.inHours < 1) {
      return l10n.minutesAgo(difference.inMinutes);
    }
    return l10n.hoursAgo(difference.inHours);
  }

  Widget? _buildSyncStatusBanner(
    BuildContext context,
    SyncProvider syncProvider,
    AppLocalizations l10n,
  ) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    switch (syncProvider.syncState) {
      case SyncState.running:
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  l10n.syncingStatus,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      case SyncState.error:
        final String message = syncProvider.lastSyncError?.trim() ?? '';
        final String displayMessage = message.isEmpty
            ? l10n.syncErrorStatus
            : '${l10n.syncErrorStatus}: $message';
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.error_outline_rounded,
                color: colorScheme.onErrorContainer,
                size: AppSpacing.iconSm,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  displayMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      case SyncState.completed:
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: colorScheme.success.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.check_circle_outline_rounded,
                color: colorScheme.success,
                size: AppSpacing.iconSm,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  l10n.syncCompletedStatus,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: l10n.close,
                visualDensity: VisualDensity.compact,
                onPressed: syncProvider.resetSyncState,
                icon: const Icon(Icons.close_rounded),
                color: colorScheme.success,
              ),
            ],
          ),
        );
      case SyncState.idle:
      case SyncState.paused:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final SyncProvider syncProvider = context.watch<SyncProvider>();
    final DeviceProvider deviceProvider = context.watch<DeviceProvider>();

    final int totalFolders = syncProvider.jobs.length;
    final int connectedDevices = deviceProvider.connectedDevices.length;
    final int activeSyncs = syncProvider.jobs.where((SyncJob job) => job.isActive).length;
    final Widget? syncStatusBanner = _buildSyncStatusBanner(
      context,
      syncProvider,
      l10n,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('SyncSphere'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future<void>.delayed(const Duration(milliseconds: 500));
              },
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
                          semanticsLabel: l10n.summaryCardSemantics(
                            l10n.tabFolders,
                            totalFolders.toString(),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _SummaryCard(
                          title: l10n.tabDevices,
                          value: connectedDevices.toString(),
                          icon: Icons.devices_rounded,
                          color: theme.colorScheme.secondary,
                          semanticsLabel: l10n.summaryCardSemantics(
                            l10n.tabDevices,
                            connectedDevices.toString(),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _SummaryCard(
                          title: l10n.activeSyncs,
                          value: activeSyncs.toString(),
                          icon: Icons.sync_rounded,
                          color: theme.colorScheme.tertiary,
                          semanticsLabel: l10n.summaryCardSemantics(
                            l10n.activeSyncs,
                            activeSyncs.toString(),
                          ),
                        ),
                      ),
                    ],
                  ).animate(autoPlay: !_disableAnimationsForTest).fadeIn(duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),
                  if (syncStatusBanner != null) ...<Widget>[
                    const SizedBox(height: AppSpacing.xl),
                    syncStatusBanner,
                  ],
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
                        onPressed: () => AppShellController.of(context)?.switchToTab(2),
                      ),
                    ],
                  ).animate(autoPlay: !_disableAnimationsForTest).fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),
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
                      actionLabel: l10n.quickActionAddFolder,
                      onAction: () => Navigator.pushNamed(context, '/wizard'),
                    )
                  else
                    ...syncProvider.jobs.take(5).toList().asMap().entries.map((entry) {
                      final int index = entry.key;
                      final SyncJob job = entry.value;
                      return SyncJobCard(
                        job: job,
                        lastSyncText:
                            '${l10n.lastSyncPrefix}: ${_formatRelativeTime(job.lastSync, l10n)}',
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/folder-detail',
                          arguments: job,
                        ),
                      ).animate(autoPlay: !_disableAnimationsForTest).fadeIn(delay: (100 * index).ms).slideY(begin: 0.1);
                    }),
                ],
              ),
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
    required this.semanticsLabel,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Semantics(
      label: semanticsLabel,
      child: Card(
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
      ),
    );
  }
}
