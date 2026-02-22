import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncsphere/models/sync_job.dart';
import 'package:syncsphere/providers/sync_provider.dart';
import 'package:syncsphere/theme/app_spacing.dart';
import 'package:syncsphere/models/sync_result.dart';
import '../../l10n/app_localizations.dart';

const bool _disableAnimationsForTest = bool.fromEnvironment('FLUTTER_TEST');

/// Folder detail — individual folder settings and sync info.
class FolderDetailScreen extends StatelessWidget {
  const FolderDetailScreen({super.key, required this.job});

  final SyncJob job;

  String _getSyncModeString(SyncMode mode, AppLocalizations l10n) {
    switch (mode) {
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

  String _getCompareModeString(CompareMode mode, AppLocalizations l10n) {
    switch (mode) {
      case CompareMode.timeAndSize:
        return l10n.compareByTime;
      case CompareMode.content:
        return l10n.compareByContent;
      case CompareMode.sizeOnly:
        return l10n.compareBySize;
    }
  }

  String _getVersioningTypeString(VersioningType type, AppLocalizations l10n) {
    switch (type) {
      case VersioningType.none:
        return l10n.versioningNone;
      case VersioningType.trashCan:
        return l10n.versioningTrashCan;
      case VersioningType.timestamped:
        return l10n.versioningTimestamp;
    }
  }

  String _filesCountText(int count, AppLocalizations l10n) => '$count ${l10n.files}';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final SyncProvider syncProvider = context.watch<SyncProvider>();

    // Try to get latest state from provider
    final SyncJob currentJob = syncProvider.getJobById(job.id) ?? job;
    
    // Attempt to retrieve latest result
    SyncResult? latestResult;
    try {
      latestResult = syncProvider.history.firstWhere((r) => r.jobId == currentJob.id);
    } catch (e) {
      latestResult = null;
    }

    final String lastSyncText = currentJob.lastSync != null
        ? DateFormat('yyyy/MM/dd HH:mm:ss').format(currentJob.lastSync!)
        : l10n.neverSynced;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentJob.name),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'edit') {
                // Edit action
              } else if (value == 'delete') {
                syncProvider.removeJob(currentJob.id);
                Navigator.pop(context);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'edit',
                child: Text(l10n.edit),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Text(
                  l10n.delete,
                  style: TextStyle(color: colorScheme.error),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Overview section
            _SectionCard(
              title: l10n.syncOverview,
              icon: Icons.info_outline_rounded,
              child: Column(
                children: <Widget>[
                  _DetailRow(
                    label: l10n.syncModeLabel,
                    value: _getSyncModeString(currentJob.syncMode, l10n),
                  ),
                  _DetailRow(
                    label: l10n.compareModeLabel,
                    value: _getCompareModeString(currentJob.compareMode, l10n),
                  ),
                  _DetailRow(
                    label: l10n.lastSync,
                    value: lastSyncText,
                  ),
                  _DetailRow(
                    label: l10n.status,
                    value: currentJob.isActive ? l10n.running : l10n.waiting,
                    valueColor: currentJob.isActive ? colorScheme.primary : null,
                  ),
                ],
              ),
            ).animate(autoPlay: !_disableAnimationsForTest).fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),
            const SizedBox(height: AppSpacing.lg),

            // Paths section
            _SectionCard(
              title: l10n.paths,
              icon: Icons.folder_shared_outlined,
              child: Column(
                children: <Widget>[
                  _DetailRow(
                    label: l10n.source,
                    value: currentJob.sourcePath,
                    valueFontFamily: 'monospace',
                    icon: Icons.upload_file_rounded,
                  ),
                  const Divider(height: AppSpacing.xl),
                  _DetailRow(
                    label: l10n.target,
                    value: currentJob.targetPath,
                    valueFontFamily: 'monospace',
                    icon: Icons.download_rounded,
                  ),
                ],
              ),
            ).animate(autoPlay: !_disableAnimationsForTest).fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),
            const SizedBox(height: AppSpacing.lg),

            // Versioning section
            _SectionCard(
              title: l10n.versioningTitle,
              icon: Icons.history_edu_rounded,
              child: _DetailRow(
                label: l10n.type,
                value: _getVersioningTypeString(currentJob.versioningType, l10n),
              ),
            ).animate(autoPlay: !_disableAnimationsForTest).fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),
            const SizedBox(height: AppSpacing.lg),

            // Last Sync Result
            if (latestResult != null)
              _SectionCard(
                title: l10n.previousResult,
                icon: Icons.check_circle_outline_rounded,
                child: Column(
                  children: <Widget>[
                    _DetailRow(
                      label: l10n.copied,
                      value: _filesCountText(latestResult.filesCopied, l10n),
                    ),
                    _DetailRow(
                      label: l10n.deleted,
                      value: _filesCountText(latestResult.filesDeleted, l10n),
                    ),
                    _DetailRow(
                      label: l10n.skipped,
                      value: _filesCountText(latestResult.filesSkipped, l10n),
                    ),
                    _DetailRow(
                      label: l10n.conflicts,
                      value: '${latestResult.conflicts}',
                      valueColor: latestResult.conflicts > 0 ? colorScheme.error : null,
                    ),
                  ],
                ),
              ).animate(autoPlay: !_disableAnimationsForTest).fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),

            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Start comparison only
                  },
                  icon: const Icon(Icons.compare_arrows_rounded),
                  label: Text(l10n.compareFiles),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (currentJob.isActive) {
                      syncProvider.stopSync(currentJob.id);
                    } else {
                      syncProvider.startSync(currentJob.id);
                    }
                  },
                  icon: Icon(
                    currentJob.isActive ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  ),
                  label: Text(currentJob.isActive ? l10n.stopSyncButton : l10n.startSyncButton),
                ),
              ),
            ],
          ).animate(autoPlay: !_disableAnimationsForTest).fadeIn(duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, color: colorScheme.primary, size: AppSpacing.iconMd),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.valueFontFamily,
    this.icon,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final String? valueFontFamily;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: AppSpacing.iconSm, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.sm),
          ],
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: valueColor ?? colorScheme.onSurface,
                fontFamily: valueFontFamily,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
