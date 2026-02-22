import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncsphere/models/sync_job.dart';
import 'package:syncsphere/providers/sync_provider.dart';
import 'package:syncsphere/theme/app_spacing.dart';
import 'package:syncsphere/models/sync_result.dart';
import '../../l10n/app_localizations.dart';

/// Folder detail — individual folder settings and sync info.
class FolderDetailScreen extends StatelessWidget {
  const FolderDetailScreen({super.key, required this.job});

  final SyncJob job;

  String _getSyncModeString(SyncMode mode) {
    switch (mode) {
      case SyncMode.mirror:
        return 'ミラーリング';
      case SyncMode.twoWay:
        return '双方向同期';
      case SyncMode.update:
        return '更新のみ';
      case SyncMode.custom:
        return 'カスタム';
    }
  }

  String _getCompareModeString(CompareMode mode) {
    switch (mode) {
      case CompareMode.timeAndSize:
        return '時刻とサイズ';
      case CompareMode.content:
        return '内容';
      case CompareMode.sizeOnly:
        return 'サイズのみ';
    }
  }

  String _getVersioningTypeString(VersioningType type) {
    switch (type) {
      case VersioningType.none:
        return 'なし';
      case VersioningType.trashCan:
        return 'ごみ箱';
      case VersioningType.timestamped:
        return 'タイムスタンプ付き';
    }
  }

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
        : '未同期';

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
                child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
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
              title: '概要',
              icon: Icons.info_outline_rounded,
              child: Column(
                children: <Widget>[
                  _DetailRow(
                    label: '同期モード',
                    value: _getSyncModeString(currentJob.syncMode),
                  ),
                  _DetailRow(
                    label: '比較モード',
                    value: _getCompareModeString(currentJob.compareMode),
                  ),
                  _DetailRow(
                    label: '最終同期',
                    value: lastSyncText,
                  ),
                  _DetailRow(
                    label: 'ステータス',
                    value: currentJob.isActive ? '同期中' : '待機中',
                    valueColor: currentJob.isActive ? colorScheme.primary : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Paths section
            _SectionCard(
              title: 'パス',
              icon: Icons.folder_shared_outlined,
              child: Column(
                children: <Widget>[
                  _DetailRow(
                    label: 'ソース元',
                    value: currentJob.sourcePath,
                    valueFontFamily: 'monospace',
                    icon: Icons.upload_file_rounded,
                  ),
                  const Divider(height: AppSpacing.xl),
                  _DetailRow(
                    label: 'ターゲット',
                    value: currentJob.targetPath,
                    valueFontFamily: 'monospace',
                    icon: Icons.download_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Versioning section
            _SectionCard(
              title: 'バージョン管理',
              icon: Icons.history_edu_rounded,
              child: _DetailRow(
                label: '種類',
                value: _getVersioningTypeString(currentJob.versioningType),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Last Sync Result
            if (latestResult != null)
              _SectionCard(
                title: '前回の結果',
                icon: Icons.check_circle_outline_rounded,
                child: Column(
                  children: <Widget>[
                    _DetailRow(
                      label: 'コピー済み',
                      value: '${latestResult.filesCopied} ファイル',
                    ),
                    _DetailRow(
                      label: '削除済み',
                      value: '${latestResult.filesDeleted} ファイル',
                    ),
                    _DetailRow(
                      label: 'スキップ',
                      value: '${latestResult.filesSkipped} ファイル',
                    ),
                    _DetailRow(
                      label: '競合',
                      value: '${latestResult.conflicts}',
                      valueColor: latestResult.conflicts > 0 ? colorScheme.error : null,
                    ),
                  ],
                ),
              ),

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
                  label: Text(currentJob.isActive ? '停止' : '同期開始'),
                ),
              ),
            ],
          ),
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
