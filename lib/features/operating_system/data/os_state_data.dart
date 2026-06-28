import 'vfs.dart';

enum OsPowerStatus { off, booting, on, shuttingDown }

class OsStateData {
  OsStateData({
    required this.vfs,
    required this.currentDir,
    required this.wifiEnabled,
    required this.bluetoothEnabled,
    required this.wallpaperPath,
    required this.installedPackages,
    this.powerStatus = OsPowerStatus.on,
  });

  final Vfs vfs;
  final VfsFolder currentDir;
  final bool wifiEnabled;
  final bool bluetoothEnabled;
  final String wallpaperPath;
  final Set<String> installedPackages;
  final OsPowerStatus powerStatus;

  OsStateData copyWith({
    VfsFolder? currentDir,
    bool? wifiEnabled,
    bool? bluetoothEnabled,
    String? wallpaperPath,
    Set<String>? installedPackages,
    OsPowerStatus? powerStatus,
  }) {
    return OsStateData(
      vfs: vfs,
      currentDir: currentDir ?? this.currentDir,
      wifiEnabled: wifiEnabled ?? this.wifiEnabled,
      bluetoothEnabled: bluetoothEnabled ?? this.bluetoothEnabled,
      wallpaperPath: wallpaperPath ?? this.wallpaperPath,
      installedPackages: installedPackages ?? this.installedPackages,
      powerStatus: powerStatus ?? this.powerStatus,
    );
  }
}

abstract class OsController {
  void changeWallpaper(String bg);
  void toggleWifi();
  void toggleBluetooth();
  void setCurrentDir(VfsFolder dir);
  void installPackage(String pkg);
  void addFile(VfsFolder parent, String name, String content);
  void addFolder(VfsFolder parent, String name);
  void removeNode(VfsFolder parent, VfsNode node);
  void powerOn();
  void shutdown();
}
