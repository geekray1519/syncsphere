import 'package:flutter/material.dart';
import 'package:syncsphere/models/sync_job.dart';
import 'package:syncsphere/theme/app_spacing.dart';

class SyncModeSelector extends StatelessWidget {
  const SyncModeSelector({
    super.key,
    required this.selectedMode,
    required this.onSelected,
  });

  final SyncMode selectedMode;
  final ValueChanged<SyncMode> onSelected;

  String _getLabel(SyncMode mode) {
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

  IconData _getIcon(SyncMode mode) {
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

  String _getDescription() {
    switch (selectedMode) {
      case SyncMode.mirror:
        return '元フォルダと全く同じ状態にします。不要なファイルは削除されます。';
      case SyncMode.twoWay:
        return '両方のフォルダの新しいファイルを互いにコピーします。';
      case SyncMode.update:
        return '元フォルダの新しいファイルだけをコピーします。削除はしません。';
      case SyncMode.custom:
        return 'ルールを自分で細かく設定します。';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SegmentedButton<SyncMode>(
          segments: SyncMode.values.map((SyncMode mode) {
            return ButtonSegment<SyncMode>(
              value: mode,
              icon: Icon(_getIcon(mode)),
              label: Text(_getLabel(mode)),
            );
          }).toList(),
          selected: <SyncMode>{selectedMode},
          onSelectionChanged: (Set<SyncMode> selection) {
            if (selection.isNotEmpty) {
              onSelected(selection.first);
            }
          },
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          _getDescription(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
