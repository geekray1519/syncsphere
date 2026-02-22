enum SyncMode { mirror, twoWay, update, custom }

enum CompareMode { timeAndSize, content, sizeOnly }

enum ConnectionType { local, lan, sftp, ftp, p2p }

enum VersioningType { none, trashCan, timestamped }

enum SyncAction {
  copyToTarget,
  copyToSource,
  deleteTarget,
  deleteSource,
  skip,
  conflict,
  equal,
}
