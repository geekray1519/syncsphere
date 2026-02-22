import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncsphere/models/sync_job.dart';
import 'package:syncsphere/theme/app_spacing.dart';

class SyncJobCard extends StatelessWidget {
  const SyncJobCard({
    super.key,
    required this.job,
    required this.onTap,
  });

  final SyncJob job;
  final VoidCallback onTap;

  IconData _getModeIcon(SyncMode mode) {
    switch (mode) {
      case SyncMode.mirror:
        return Icons.arrow_right_alt_rounded;
      case SyncMode.twoWay:
        return Icons.sync_alt_rounded;
      case SyncMode.update:
        return Icons.keyboard_double_arrow_right_rounded;
      case SyncMode.custom:
        return Icons.settings_suggest_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final String lastSyncText = job.lastSync != null
        ? DateFormat('MM/dd HH:mm').format(job.lastSync!)
        : '未同期';

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(
          color: job.isActive ? colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: job.isActive
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Icon(
                      _getModeIcon(job.syncMode),
                      color: job.isActive
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          job.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${job.sourcePath} → ${job.targetPath}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontFamily: 'monospace',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Icon(
                        job.isActive ? Icons.sync : Icons.check_circle_outline,
                        color: job.isActive
                            ? colorScheme.primary
                            : colorScheme.outline,
                        size: AppSpacing.iconSm,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        lastSyncText,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (job.isActive)
              LinearProgressIndicator(
                backgroundColor: colorScheme.primaryContainer,
                color: colorScheme.primary,
                minHeight: 4,
              ),
          ],
        ),
      ),
    );
  }
}
