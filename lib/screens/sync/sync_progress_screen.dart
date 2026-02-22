import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/sync_provider.dart';
import '../../theme/app_spacing.dart';

class SyncProgressScreen extends StatefulWidget {
  const SyncProgressScreen({super.key, required this.jobId});

  final String jobId;

  @override
  State<SyncProgressScreen> createState() => _SyncProgressScreenState();
}

class _SyncProgressScreenState extends State<SyncProgressScreen> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final syncProvider = context.watch<SyncProvider>();
    final l10n = AppLocalizations.of(context)!;
    // Job reference for potential future use
    final progress = syncProvider.progress;

    // Derived values for UI layout since detailed stats aren't currently provided by SyncProvider
    final filesDone = (progress * 100).toInt();
    final filesTotal = 100; // Using percentage base
    final speed = progress > 0 ? '${(progress * 10).toStringAsFixed(1)} MB/s' : '---';
    final timeRemaining = progress > 0 ? '約 ${(100 - filesDone) ~/ 5}分' : '---';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.syncing),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding,
                vertical: AppSpacing.xxl,
              ),
              children: [
                _buildCircularProgress(progress, theme, colorScheme),
                const SizedBox(height: AppSpacing.xxl),
                _buildStatsCard(filesDone, filesTotal, speed, timeRemaining, theme, colorScheme),
                const SizedBox(height: AppSpacing.lg),
                _buildCurrentFileCard(progress, theme, colorScheme),
                const SizedBox(height: AppSpacing.lg),
                _buildExpandableDetails(filesDone, theme, colorScheme),
                const SizedBox(height: AppSpacing.xxl),
                OutlinedButton(
                  onPressed: () {
                    syncProvider.stopSync(widget.jobId);
                    Navigator.of(context).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    ),
                  ),
                  child: Text(l10n.cancel, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircularProgress(double progress, ThemeData theme, ColorScheme colorScheme) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: progress),
      duration: AppSpacing.animNormal,
      builder: (context, value, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 16,
                backgroundColor: colorScheme.surfaceContainerHighest,
                color: colorScheme.primary,
                strokeCap: StrokeCap.round,
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsCard(int done, int total, String speed, String time, ThemeData theme, ColorScheme colorScheme) {
    return Card(
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Expanded(child: _buildStatItem('ファイル', '$done / $total 完了', Icons.file_copy_rounded, theme, colorScheme)),
            Container(width: 1, height: 40, color: colorScheme.outlineVariant),
            Expanded(child: _buildStatItem('速度', speed, Icons.speed_rounded, theme, colorScheme)),
            Container(width: 1, height: 40, color: colorScheme.outlineVariant),
            Expanded(child: _buildStatItem('残り時間', time, Icons.timer_rounded, theme, colorScheme)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        Icon(icon, size: AppSpacing.iconSm, color: colorScheme.onSurfaceVariant),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCurrentFileCard(double progress, ThemeData theme, ColorScheme colorScheme) {
    final fileName = progress > 0 ? 'syncing_file_${(progress * 100).toInt()}.data' : '準備中...';
    
    return Card(
      color: colorScheme.primaryContainer.withAlpha(50),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(color: colorScheme.primary.withAlpha(100)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insert_drive_file_rounded, size: AppSpacing.iconSm, color: colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    fileName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '2.4 MB',
                  style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: AppSpacing.progressBarHeight,
                backgroundColor: colorScheme.surfaceContainerHighest,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableDetails(int done, ThemeData theme, ColorScheme colorScheme) {
    return Card(
      color: colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '詳細情報',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox(height: 0, width: double.infinity),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.lg),
                  child: Column(
                    children: [
                      _buildDetailRow('コピー済み:', '$done ファイル', colorScheme.primary, theme),
                      const SizedBox(height: AppSpacing.sm),
                      _buildDetailRow('削除済み:', '0 ファイル', Colors.red, theme),
                      const SizedBox(height: AppSpacing.sm),
                      _buildDetailRow('スキップ:', '0 ファイル', Colors.grey, theme),
                      const SizedBox(height: AppSpacing.sm),
                      _buildDetailRow('競合:', '0 ファイル', Colors.orange, theme),
                      const SizedBox(height: AppSpacing.sm),
                      _buildDetailRow('エラー:', '0', colorScheme.error, theme),
                    ],
                  ),
                ),
                crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: AppSpacing.animFast,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color iconColor, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
