import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/sync_job.dart';
import '../../providers/sync_provider.dart';
import '../../theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';

class SyncDetailScreen extends StatelessWidget {
  const SyncDetailScreen({super.key, required this.job});

  final SyncJob job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final syncProvider = context.watch<SyncProvider>();
    final l10n = AppLocalizations.of(context)!;
    final isSyncing = job.isActive;
    final isComparing = syncProvider.isComparing(job.id);
    final lastResult = syncProvider.history.cast<dynamic>().firstWhere((r) => r.jobId == job.id, orElse: () => null) as dynamic;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(job.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              // Action logic handled elsewhere
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(l10n.edit),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'rescan',
                child: Row(
                  children: [
                    const Icon(Icons.refresh_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(l10n.forceRescan),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_rounded, size: 20, color: colorScheme.error),
                    const SizedBox(width: 8),
                    Text(l10n.delete, style: TextStyle(color: colorScheme.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.pagePadding),
                children: [
                  _buildSummaryCard(theme, colorScheme, l10n),
                  const SizedBox(height: AppSpacing.lg),
                  _buildFoldersCard(theme, colorScheme, l10n),
                  const SizedBox(height: AppSpacing.lg),
                  _buildFilterCard(theme, colorScheme, l10n),
                  if (lastResult != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _buildLastSyncResultCard(lastResult, theme, colorScheme, l10n),
                  ],
                ],
              ),
            ),
            _buildBottomActionBar(isSyncing, isComparing, syncProvider, theme, colorScheme, l10n),
          ],
        ),
      ),
    );
  }

  String _getSyncModeText(AppLocalizations l10n) {
    switch (job.syncMode) {
      case SyncMode.mirror:
        return l10n.syncModeMirror;
      case SyncMode.twoWay:
        return l10n.syncModeTwoWay;
      case SyncMode.update:
        return l10n.syncModeUpdate;
      case SyncMode.custom:
        return l10n.syncModeCustom;
    }
  }

  String _getCompareModeText(AppLocalizations l10n) {
    switch (job.compareMode) {
      case CompareMode.timeAndSize:
        return l10n.compareByTime;
      case CompareMode.content:
        return l10n.compareByContent;
      case CompareMode.sizeOnly:
        return l10n.compareBySize;
    }
  }

  String _getVersioningText(AppLocalizations l10n) {
    switch (job.versioningType) {
      case VersioningType.none:
        return l10n.versioningNone;
      case VersioningType.trashCan:
        return l10n.versioningTrashCan;
      case VersioningType.timestamped:
        return l10n.versioningTimestamp;
    }
  }

  Widget _buildSummaryCard(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    return Card(
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.syncOverview,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildDetailRow(Icons.sync_alt_rounded, l10n.syncModeLabel, _getSyncModeText(l10n), theme, colorScheme),
            const SizedBox(height: AppSpacing.sm),
            _buildDetailRow(Icons.compare_arrows_rounded, l10n.compareModeLabel, _getCompareModeText(l10n), theme, colorScheme),
            const SizedBox(height: AppSpacing.sm),
            _buildDetailRow(Icons.history_rounded, l10n.versioningTitle, _getVersioningText(l10n), theme, colorScheme),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: job.isActive ? colorScheme.primaryContainer : colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(
                    color: job.isActive ? colorScheme.primary : colorScheme.outlineVariant,
                  ),
                ),
                child: Text(
                  job.isActive ? l10n.running : l10n.waiting,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: job.isActive ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoldersCard(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    return Card(
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.syncFolders,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildFolderItem(Icons.folder_shared_rounded, l10n.source, job.sourcePath, theme, colorScheme),
            Padding(
              padding: const EdgeInsets.only(left: 18.0, top: 8.0, bottom: 8.0),
              child: Icon(Icons.arrow_downward_rounded, size: 20, color: colorScheme.onSurfaceVariant),
            ),
            _buildFolderItem(Icons.create_new_folder_rounded, l10n.target, job.targetPath, theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderItem(IconData icon, String label, String path, ThemeData theme, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colorScheme.primary, size: 28),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                path,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterCard(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    final hasFilters = job.filterInclude.isNotEmpty || job.filterExclude.isNotEmpty;

    return Card(
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.syncFilters,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (!hasFilters)
              Text(
                l10n.noFilters,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              )
            else ...[
              if (job.filterInclude.isNotEmpty) ...[
                Text('${l10n.filterInclude}:', style: theme.textTheme.labelSmall),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: job.filterInclude
                      .map((f) => Chip(
                            label: Text(f),
                            backgroundColor: colorScheme.primaryContainer.withAlpha(128),
                          ))
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              if (job.filterExclude.isNotEmpty) ...[
                Text('${l10n.filterExclude}:', style: theme.textTheme.labelSmall),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: job.filterExclude
                      .map((f) => Chip(
                            label: Text(f),
                            backgroundColor: colorScheme.errorContainer.withAlpha(128),
                          ))
                      .toList(),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLastSyncResultCard(dynamic lastResultData, ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    final result = lastResultData;
    final duration = result.duration;
    final mins = duration.inMinutes;
    final secs = duration.inSeconds % 60;

    return Card(
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.lastSyncResult,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  result.errors > 0 ? Icons.error_rounded : Icons.check_circle_rounded,
                  color: result.errors > 0 ? colorScheme.error : Colors.green,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _buildStatChip(l10n.copied, result.filesCopied.toString(), Colors.blue, colorScheme),
                _buildStatChip(l10n.deleted, result.filesDeleted.toString(), Colors.red, colorScheme),
                _buildStatChip(l10n.skipped, result.filesSkipped.toString(), Colors.grey, colorScheme),
                _buildStatChip(l10n.conflicts, result.conflicts.toString(), Colors.orange, colorScheme),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '${l10n.duration}: ${mins}m ${secs}s',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String count, Color color, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: color.withAlpha(128)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: AppSpacing.xs),
          Text(
            count,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(bool isSyncing, bool isComparing, SyncProvider provider, ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: (isSyncing || isComparing) ? null : () {
                // TODO: trigger comparison
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              ),
              child: Text(l10n.compareFiles),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isComparing ? null : () {
                if (isSyncing) {
                  provider.stopSync(job.id);
                } else {
                  provider.startSync(job.id);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                backgroundColor: isSyncing ? colorScheme.error : colorScheme.primary,
                foregroundColor: isSyncing ? colorScheme.onError : colorScheme.onPrimary,
              ),
              child: Text(isSyncing ? l10n.stopSyncButton : l10n.startSyncButton),
            ),
          ),
        ],
      ),
    );
  }
}
