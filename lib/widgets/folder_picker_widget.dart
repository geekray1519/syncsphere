import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:syncsphere/theme/app_spacing.dart';

class FolderPickerWidget extends StatelessWidget {
  const FolderPickerWidget({
    super.key,
    required this.label,
    required this.currentPath,
    required this.onFolderSelected,
    this.icon = Icons.folder_open_rounded,
  });

  final String label;
  final String? currentPath;
  final ValueChanged<String> onFolderSelected;
  final IconData icon;

  Future<void> _pickFolder() async {
    final String? result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      onFolderSelected(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool hasPath = currentPath != null && currentPath!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          elevation: 0,
          color: colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            side: BorderSide(
              color: hasPath ? colorScheme.primary : colorScheme.outlineVariant,
            ),
          ),
          child: InkWell(
            onTap: _pickFolder,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    icon,
                    color: hasPath ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    size: AppSpacing.iconMd,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Text(
                      hasPath ? currentPath! : 'フォルダを選択してください',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: hasPath ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    onPressed: _pickFolder,
                    icon: const Icon(Icons.search),
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
