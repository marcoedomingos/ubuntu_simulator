import 'dart:async';
import 'package:flutter/material.dart';

import 'package:ubuntu_simulate/features/browser/ui/pages/firefox_browser.dart';
import 'package:ubuntu_simulate/features/code_editor/ui/pages/vscode_monitor_editor.dart';
import 'package:ubuntu_simulate/features/files/ui/pages/files_view.dart';
import 'package:ubuntu_simulate/features/pixel_watch/ui/pages/pixel_watch_view.dart';
import 'package:ubuntu_simulate/features/settings/ui/pages/settings_view.dart';
import 'package:ubuntu_simulate/features/terminal/ui/pages/terminal_view.dart';
import '../widgets/app_grid_overlay.dart';
import '../widgets/context_menu.dart';
import '../widgets/dock.dart';
import '../widgets/boot_splash.dart';
import 'package:ubuntu_simulate/commons/styles/os_scale.dart';
import '../widgets/os_scope.dart';
import '../widgets/top_bar.dart';
import 'package:ubuntu_simulate/commons/widgets/ui_scale.dart';
import '../widgets/window_title_bar.dart';
import '../../data/vfs.dart';
import '../../data/os_state_data.dart';
import '../../data/os_entities.dart';

class UbuntuDesktop extends StatefulWidget {
  const UbuntuDesktop({super.key});

  @override
  State<UbuntuDesktop> createState() => UbuntuDesktopState();
}

class UbuntuDesktopState extends State<UbuntuDesktop> implements OsController {
  late Timer _clock;
  DateTime _now = DateTime.now();

  final List<WindowState> _windows = [];

  Offset? _ctxPos;
  bool _showAppGrid = false;
  Size _viewport = Size.zero;

  late OsStateData _osData;

  @override
  void initState() {
    super.initState();
    final vfs = Vfs();
    _osData = OsStateData(
      vfs: vfs,
      currentDir: vfs.visitor,
      wifiEnabled: true,
      bluetoothEnabled: true,
      wallpaperPath: 'assets/src/ubuntu_background.jpg',
      installedPackages: {'neofetch'},
      powerStatus: OsPowerStatus.off,
    );
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clock.cancel();
    super.dispose();
  }

  @override
  void changeWallpaper(String bg) {
    setState(() => _osData = _osData.copyWith(wallpaperPath: bg));
  }

  @override
  void toggleWifi() {
    setState(() => _osData = _osData.copyWith(wifiEnabled: !_osData.wifiEnabled));
  }

  @override
  void toggleBluetooth() {
    setState(() => _osData = _osData.copyWith(bluetoothEnabled: !_osData.bluetoothEnabled));
  }

  @override
  void setCurrentDir(VfsFolder dir) {
    setState(() => _osData = _osData.copyWith(currentDir: dir));
  }

  @override
  void installPackage(String pkg) {
    setState(() => _osData = _osData.copyWith(
          installedPackages: {..._osData.installedPackages, pkg},
        ));
  }

  @override
  void addFile(VfsFolder parent, String name, String content) {
    setState(() {
      final existing = parent.find(name);
      if (existing != null && existing is VfsFile) {
        existing.content = content;
      } else {
        parent.children.add(VfsFile(name: name, parent: parent, content: content));
      }
      _osData = _osData.copyWith();
    });
  }

  @override
  void addFolder(VfsFolder parent, String name) {
    setState(() {
      final existing = parent.find(name);
      if (existing == null) {
        parent.children.add(VfsFolder(name: name, parent: parent));
      }
      _osData = _osData.copyWith();
    });
  }

  @override
  void removeNode(VfsFolder parent, VfsNode node) {
    setState(() {
      parent.children.remove(node);
      _osData = _osData.copyWith();
    });
  }

  @override
  void powerOn() {
    if (_osData.powerStatus != OsPowerStatus.off) return;
    setState(() => _osData = _osData.copyWith(powerStatus: OsPowerStatus.booting));
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _osData = _osData.copyWith(powerStatus: OsPowerStatus.on));
    });
  }

  @override
  void shutdown() {
    if (_osData.powerStatus != OsPowerStatus.on) return;
    setState(() => _osData = _osData.copyWith(powerStatus: OsPowerStatus.shuttingDown));
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _osData = _osData.copyWith(powerStatus: OsPowerStatus.off));
    });
  }

  late final _apps = <DockApp>[
    DockApp(
      id: 'vscode',
      label: 'Visual Studio Code',
      icon: Icons.code,
      assetPath: 'assets/src/vs.png',
      onLaunch: () => _openOrFocus('vscode'),
    ),
    DockApp(
      id: 'terminal',
      label: 'Terminal',
      icon: Icons.terminal,
      color: const Color(0xFF4EAA25),
      onLaunch: () => _openOrFocus('terminal'),
    ),
    DockApp(
      id: 'files',
      label: 'Files',
      icon: Icons.folder_open,
      color: Colors.amber,
      onLaunch: () => _openOrFocus('files'),
    ),
    DockApp(
      id: 'firefox',
      label: 'Firefox',
      icon: Icons.language,
      assetPath: 'assets/src/firefox.png',
      color: Colors.orangeAccent,
      onLaunch: () => _openOrFocus('firefox'),
    ),
    DockApp(
      id: 'settings',
      label: 'Settings',
      icon: Icons.settings,
      color: Colors.grey,
      onLaunch: () => _openOrFocus('settings'),
    ),
    DockApp(
      id: 'pixel_watch',
      label: 'Pixel Watch',
      icon: Icons.watch_rounded,
      color: const Color(0xFF4285F4),
      designSize: const Size(320, 560),
      onLaunch: () => _openOrFocus('pixel_watch'),
    ),
  ];

  void _launchApp(DockApp app) {
    setState(() => _showAppGrid = false);
    app.onLaunch?.call();
  }

  bool _running(String id) => _windows.any((w) => w.appId == id);
  bool _visible(String id) =>
      _windows.any((w) => w.appId == id && !w.minimized);

  void _openOrFocus(String id) {
    final existing = _windows.where((w) => w.appId == id);
    if (existing.isNotEmpty) {
      setState(() {
        existing.first.minimized = false;
        _front(existing.first);
      });
      return;
    }
    final app = _apps.firstWhere((a) => a.id == id);
    final ss = _viewport;
    if (ss == Size.zero) return;
    final scale = OsScaleTokens.fromViewport(ss, dockAppCount: _apps.length);
    
    double winW, winH;
    if (app.designSize != null) {
      winH = ss.height * 0.82;
      winW = winH * app.designSize!.width / app.designSize!.height;
      if (winW > ss.width * 0.40) {
        winW = ss.width * 0.40;
        winH = winW * app.designSize!.height / app.designSize!.width;
      }
    } else {
      winW = ss.width * 0.62;
      winH = ss.height * 0.64;
    }

    final win = WindowState(
      appId: id,
      title: app.label,
      child: _contentFor(id),
      offset: Offset(
        (ss.width - scale.dockWidth - winW) / 2,
        (ss.height - scale.barHeight - winH) / 2,
      ),
      size: Size(winW, winH),
    );
    setState(() {
      _windows.add(win);
      _front(win);
    });
  }

  void _front(WindowState w) {
    if (_windows.last == w) return;
    setState(() {
      _windows.remove(w);
      _windows.add(w);
    });
  }

  Widget _contentFor(String id) => switch (id) {
    'vscode' => const VsCodeMonitorEditor(),
    'terminal' => const TerminalView(),
    'files' => const FilesView(),
    'firefox' => const FirefoxBrowser(),
    'settings' => const SettingsView(),
    'pixel_watch' => const PixelWatchView(),
    _ => const SizedBox.shrink(),
  };

  void _close(String id) =>
      setState(() => _windows.removeWhere((w) => w.appId == id));
  void _minimize(String id) {
    final w = _windows.firstWhere((e) => e.appId == id);
    setState(() => w.minimized = true);
  }

  void _toggleMax(WindowState w) {
    final ss = _viewport;
    if (ss == Size.zero) return;
    final scale = OsScaleTokens.fromViewport(ss, dockAppCount: _apps.length);
    setState(() {
      w.toggleMaximize(ss, scale.dockWidth, scale.barHeight);
    });
  }

  Widget _buildWallpaper(String path) {
    if (path.startsWith('gradient:')) {
      final type = path.replaceFirst('gradient:', '');
      List<Color> colors = [const Color(0xFF2C001E), const Color(0xFF5C0038)];
      if (type == 'jellyfish') {
        colors = [const Color(0xFF2C001E), const Color(0xFFE95420)];
      } else if (type == 'aurora') {
        colors = [const Color(0xFF001F3F), const Color(0xFF00FFCC)];
      } else if (type == 'cyber') {
        colors = [const Color(0xFF120458), const Color(0xFF3F0071), Colors.black];
      }
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2C001E),
              Color(0xFF5C0038),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OsScope(
      data: _osData,
      controller: this,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewport = Size(constraints.maxWidth, constraints.maxHeight);
          if (viewport.width <= 0 || viewport.height <= 0) {
            return const SizedBox.shrink();
          }
          _viewport = viewport;
          final scale = OsScaleTokens.fromViewport(viewport, dockAppCount: _apps.length);

          if (_osData.powerStatus == OsPowerStatus.off) {
            return GestureDetector(
              onTap: powerOn,
              child: Container(
                color: Colors.black,
                child: const Center(
                  child: Text(
                    'Click to Power On',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              ),
            );
          }

          if (_osData.powerStatus == OsPowerStatus.booting || _osData.powerStatus == OsPowerStatus.shuttingDown) {
            return BootSplash(scale: scale, isShuttingDown: _osData.powerStatus == OsPowerStatus.shuttingDown);
          }

          return UiScale(
            factor: UiScale.factorFromViewport(viewport),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                size: viewport,
                padding: EdgeInsets.zero,
                viewPadding: EdgeInsets.zero,
                viewInsets: EdgeInsets.zero,
              ),
              child: GestureDetector(
                onSecondaryTapDown: (d) =>
                    setState(() => _ctxPos = d.globalPosition),
                onTap: () => setState(() => _ctxPos = null),
                child: SizedBox.expand(
                  child: Column(
                    children: [
                      TopBar(scale: scale, now: _now),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Dock(
                              scale: scale,
                              apps: _apps,
                              running: _running,
                              visible: _visible,
                              onShowApps: () =>
                                  setState(() => _showAppGrid = !_showAppGrid),
                            ),
                            Expanded(
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: _buildWallpaper(_osData.wallpaperPath),
                                  ),
                                  ..._windows.map((w) => _buildWindow(w, scale)),
                                  if (_ctxPos != null)
                                    ContextMenu(
                                      pos: _ctxPos!,
                                      scale: scale,
                                      onDismiss: () =>
                                          setState(() => _ctxPos = null),
                                    ),
                                  if (_showAppGrid)
                                    AppGridOverlay(
                                      scale: scale,
                                      apps: _apps,
                                      onDismiss: () =>
                                          setState(() => _showAppGrid = false),
                                      onLaunch: _launchApp,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWindow(WindowState w, OsScaleTokens scale) {
    if (w.minimized) return const SizedBox.shrink();
    return Positioned(
      left: w.offset.dx,
      top: w.offset.dy,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _front(w)),
        onPanUpdate: w.maximized
            ? null
            : (d) => setState(() {
                _front(w);
                w.offset += d.delta;
              }),
        child: Material(
          color: Colors.transparent,
          elevation: 20,
          shadowColor: Colors.black87,
          borderRadius: BorderRadius.circular(w.maximized ? 0 : 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(w.maximized ? 0 : 10),
            child: SizedBox(
              width: w.size.width,
              height: w.size.height,
              child: Column(
                children: [
                  WindowTitleBar(
                    title: w.title,
                    scale: scale,
                    maximized: w.maximized,
                    onClose: () => _close(w.appId),
                    onMinimize: () => _minimize(w.appId),
                    onMaximize: () => _toggleMax(w),
                  ),
                  Expanded(child: w.child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
