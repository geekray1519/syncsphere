import 'package:flutter/material.dart';
import 'package:syncsphere/models/sync_job.dart';
import 'package:syncsphere/theme/app_spacing.dart';

class ConnectionTypeSelector extends StatelessWidget {
  const ConnectionTypeSelector({
    super.key,
    required this.selectedType,
    required this.onSelected,
  });

  final ConnectionType selectedType;
  final ValueChanged<ConnectionType> onSelected;

  IconData _getIcon(ConnectionType type) {
    switch (type) {
      case ConnectionType.local:
        return Icons.computer_rounded;
      case ConnectionType.lan:
        return Icons.wifi_rounded;
      case ConnectionType.sftp:
        return Icons.security_rounded;
      case ConnectionType.ftp:
        return Icons.folder_shared_rounded;
      case ConnectionType.p2p:
        return Icons.share_rounded;
    }
  }

  String _getTitle(ConnectionType type) {
    switch (type) {
      case ConnectionType.local:
        return 'ローカル';
      case ConnectionType.lan:
        return 'LAN / Wi-Fi';
      case ConnectionType.sftp:
        return 'SFTP';
      case ConnectionType.ftp:
        return 'FTP';
      case ConnectionType.p2p:
        return 'P2P';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: ConnectionType.values.map((ConnectionType type) {
        return FilterChip(
          selected: type == selectedType,
          label: Text(_getTitle(type)),
          avatar: Icon(_getIcon(type), size: AppSpacing.iconSm),
          onSelected: (bool selected) {
            if (selected) {
              onSelected(type);
            }
          },
        );
      }).toList(),
    );
  }
}
