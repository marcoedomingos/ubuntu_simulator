import 'package:ubuntu_simulate/features/monitor/ui/widgets/monitor_frame_painter.dart';
import 'package:ubuntu_simulate/commons/widgets/ui_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum _MonitorSourceFile { monitor, painter }

/// VS Code window showing the desk [Monitor] widget source and [Painter] code
/// with a live CustomPainter preview of the monitor bezel.
class VsCodeMonitorEditor extends StatefulWidget {
  const VsCodeMonitorEditor({super.key});

  @override
  State<VsCodeMonitorEditor> createState() => _VsCodeMonitorEditorState();
}

class _VsCodeMonitorEditorState extends State<VsCodeMonitorEditor> {
  static const _monitorAsset = 'assets/code/monitor.dart';
  static const _painterAsset = 'assets/code/monitor_frame_painter.dart';

  late final Future<Map<_MonitorSourceFile, String>> _sourcesFuture;
  final _scrollController = ScrollController();
  _MonitorSourceFile _openFile = _MonitorSourceFile.monitor;
  Map<_MonitorSourceFile, String>? _sources;
  bool _didInitialScroll = false;

  @override
  void initState() {
    super.initState();
    _sourcesFuture = _loadSources();
  }

  Future<Map<_MonitorSourceFile, String>> _loadSources() async {
    final results = await Future.wait([
      rootBundle.loadString(_monitorAsset),
      rootBundle.loadString(_painterAsset),
    ]);
    return {
      _MonitorSourceFile.monitor: results[0],
      _MonitorSourceFile.painter: results[1],
    };
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _open(_MonitorSourceFile file) {
    if (_openFile == file) return;
    setState(() => _openFile = file);
    final source = _sources?[file];
    if (source != null) _scrollToAnchor(source);
  }

  void _scrollToAnchor(String source) {
    if (source.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final anchor = _openFile == _MonitorSourceFile.monitor
          ? 'class Monitor'
          : 'class Painter';
      final lineIndex = source.indexOf(anchor);
      if (lineIndex < 0) return;
      final line = source.substring(0, lineIndex).split('\n').length - 1;
      _scrollController.jumpTo(line * 19.0);
    });
  }

  void _maybeInitialScroll(String source) {
    if (_didInitialScroll || source.isEmpty) return;
    _didInitialScroll = true;
    _scrollToAnchor(source);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _VsCode.bg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _ActivityBar(),
          _ExplorerSidebar(
            openFile: _openFile,
            onOpen: _open,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _EditorTabBar(
                  openFile: _openFile,
                  onOpen: _open,
                ),
                Expanded(
                  child: FutureBuilder<Map<_MonitorSourceFile, String>>(
                    future: _sourcesFuture,
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: _VsCode.accent,
                            strokeWidth: 2,
                          ),
                        );
                      }
                      final sources = snap.data ?? {};
                      _sources = sources;
                      final source =
                          sources[_openFile] ?? sources.values.firstOrNull ?? '';
                      _maybeInitialScroll(source);
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 58,
                            child: _CodeEditorPane(
                              source: source,
                              scrollController: _scrollController,
                            ),
                          ),
                          const VerticalDivider(
                            width: 1,
                            thickness: 1,
                            color: _VsCode.border,
                          ),
                          const Expanded(flex: 42, child: _PreviewPane()),
                        ],
                      );
                    },
                  ),
                ),
                _StatusBar(openFile: _openFile),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VsCode {
  static const bg = Color(0xFF1E1E1E);
  static const sidebar = Color(0xFF252526);
  static const activityBar = Color(0xFF333333);
  static const tabActive = Color(0xFF1E1E1E);
  static const tabInactive = Color(0xFF2D2D2D);
  static const border = Color(0xFF474747);
  static const accent = Color(0xFF007ACC);
  static const keyword = Color(0xFF569CD6);
  static const type = Color(0xFF4EC9B0);
  static const string = Color(0xFFCE9178);
  static const comment = Color(0xFF6A9955);
  static const number = Color(0xFFB5CEA8);
  static const text = Color(0xFFD4D4D4);
  static const muted = Color(0xFF858585);
  static const gutter = Color(0xFF858585);
}

class _ActivityBar extends StatelessWidget {
  const _ActivityBar();

  @override
  Widget build(BuildContext context) {
    final s = UiScale.of(context);
    final sz = 48 * s;
    return Container(
      width: sz,
      color: _VsCode.activityBar,
      padding: EdgeInsets.symmetric(vertical: 8 * s),
      child: Column(
        children: [
          _barIcon(Icons.copy_all_outlined, s, active: true),
          _barIcon(Icons.search, s),
          _barIcon(Icons.play_circle_outline, s),
          _barIcon(Icons.extension_outlined, s),
          const Spacer(),
          _barIcon(Icons.settings_outlined, s),
        ],
      ),
    );
  }

  Widget _barIcon(IconData icon, double s, {bool active = false}) {
    final sz = 48 * s;
    return Container(
      width: sz,
      height: sz,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: active ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Icon(icon, size: 22 * s, color: active ? Colors.white : _VsCode.muted),
    );
  }
}

class _ExplorerSidebar extends StatelessWidget {
  const _ExplorerSidebar({
    required this.openFile,
    required this.onOpen,
  });

  final _MonitorSourceFile openFile;
  final ValueChanged<_MonitorSourceFile> onOpen;

  @override
  Widget build(BuildContext context) {
    final s = UiScale.of(context);
    return Container(
      width: 210 * s,
      color: _VsCode.sidebar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16 * s, 12 * s, 8 * s, 6 * s),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'EXPLORER',
                    style: TextStyle(
                      color: _VsCode.muted,
                      fontSize: 11 * s,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(Icons.more_horiz, size: 16 * s, color: _VsCode.muted),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _treeRow('▼', 'PORTFOLIO', s, muted: true, indent: 0),
                _treeRow('', 'ubuntu_simulate', s, muted: true, indent: 12 * s),
                _treeRow('', 'lib/features/monitor', s, muted: true, indent: 24 * s),
                _treeRow(
                  openFile == _MonitorSourceFile.monitor ? '●' : '',
                  'monitor.dart',
                  s,
                  active: openFile == _MonitorSourceFile.monitor,
                  indent: 36 * s,
                  onTap: () => onOpen(_MonitorSourceFile.monitor),
                ),
                _treeRow(
                  openFile == _MonitorSourceFile.painter ? '●' : '',
                  'monitor_frame_painter.dart',
                  s,
                  active: openFile == _MonitorSourceFile.painter,
                  indent: 36 * s,
                  onTap: () => onOpen(_MonitorSourceFile.painter),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _treeRow(
    String prefix,
    String label,
    double s, {
    bool active = false,
    bool muted = false,
    double indent = 0,
    VoidCallback? onTap,
  }) {
    final child = Padding(
      padding: EdgeInsets.only(left: indent, top: 2 * s, bottom: 2 * s),
      child: Row(
        children: [
          if (prefix.isNotEmpty)
            Text(prefix,
                style: TextStyle(
                  color: active ? _VsCode.accent : _VsCode.muted,
                  fontSize: 10 * s,
                )),
          if (prefix.isNotEmpty) SizedBox(width: 4 * s),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: active
                    ? Colors.white
                    : muted
                        ? _VsCode.muted
                        : _VsCode.text,
                fontSize: 12 * s,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return child;
    return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: child);
  }
}

class _EditorTabBar extends StatelessWidget {
  const _EditorTabBar({
    required this.openFile,
    required this.onOpen,
  });

  final _MonitorSourceFile openFile;
  final ValueChanged<_MonitorSourceFile> onOpen;

  @override
  Widget build(BuildContext context) {
    final s = UiScale.of(context);
    return Container(
      height: 35 * s,
      color: _VsCode.tabInactive,
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _tab(
                    'monitor.dart',
                    s,
                    active: openFile == _MonitorSourceFile.monitor,
                    onTap: () => onOpen(_MonitorSourceFile.monitor),
                  ),
                  _tab(
                    'monitor_frame_painter.dart',
                    s,
                    active: openFile == _MonitorSourceFile.painter,
                    onTap: () => onOpen(_MonitorSourceFile.painter),
                  ),
                  Container(width: 1, height: 35 * s, color: _VsCode.border),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10 * s),
            child: Text(
              'CustomPainter Preview',
              style: TextStyle(color: _VsCode.muted, fontSize: 11 * s),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String label, double s, {required bool active, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 35 * s,
        padding: EdgeInsets.symmetric(horizontal: 12 * s),
        color: active ? _VsCode.tabActive : _VsCode.tabInactive,
        child: Row(
          children: [
            Icon(Icons.flutter_dash,
                size: 14 * s, color: active ? _VsCode.accent : _VsCode.muted),
            SizedBox(width: 6 * s),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : _VsCode.muted,
                fontSize: 12 * s,
              ),
            ),
            SizedBox(width: 8 * s),
            Icon(Icons.close, size: 14 * s, color: _VsCode.muted),
          ],
        ),
      ),
    );
  }
}

class _CodeEditorPane extends StatelessWidget {
  const _CodeEditorPane({
    required this.source,
    required this.scrollController,
  });

  final String source;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final s = UiScale.of(context);
    final lineH = 19 * s;
    final lines = source.split('\n');
    return ColoredBox(
      color: _VsCode.bg,
      child: Scrollbar(
        controller: scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.only(top: 8 * s, bottom: 16 * s),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 8 * s, right: 12 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < lines.length; i++)
                      SizedBox(
                        height: lineH,
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: _VsCode.gutter,
                            fontSize: 12 * s,
                            fontFamily: 'monospace',
                            height: 1.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: SelectableText.rich(
                  TextSpan(
                    children: [
                      for (final line in lines) ...[
                        ..._highlightLine(line),
                        const TextSpan(text: '\n'),
                      ],
                    ],
                  ),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12 * s,
                    height: 1.58,
                    color: _VsCode.text,
                  ),
                ),
              ),
              SizedBox(width: 12 * s),
            ],
          ),
        ),
      ),
    );
  }

  List<TextSpan> _highlightLine(String line) {
    final trimmed = line.trimLeft();
    if (trimmed.startsWith('//') || trimmed.startsWith('///')) {
      return [TextSpan(text: line, style: const TextStyle(color: _VsCode.comment))];
    }

    final spans = <TextSpan>[];
    final pattern = RegExp(
      r'(\bclass\b|\bextends\b|\bconst\b|\bfinal\b|\breturn\b|\bfor\b|\bint\b|\bfalse\b|\boverride\b|\bimport\b|\bpackage\b|\bif\b|\bbool\b)|'
      r'(CustomPainter|Canvas|Size|Color|Paint|Alignment|Offset|Rect|RRect|Radius|LinearGradient|Matrix4|BorderRadius|CustomPaint|StatelessWidget|Widget|LayoutBuilder|Stack|Positioned|OperatingSystem|SafeArea)|'
      r'(0x[0-9A-Fa-f]+|\d+\.?\d*)|'
      r"('(?:[^'\\]|\\.)*')",
    );

    var start = 0;
    for (final match in pattern.allMatches(line)) {
      if (match.start > start) {
        spans.add(TextSpan(text: line.substring(start, match.start)));
      }
      final value = match.group(0)!;
      Color color = _VsCode.text;
      if (match.group(1) != null) {
        color = _VsCode.keyword;
      } else if (match.group(2) != null) {
        color = _VsCode.type;
      } else if (match.group(3) != null) {
        color = _VsCode.number;
      } else if (match.group(4) != null) {
        color = _VsCode.string;
      }
      spans.add(TextSpan(text: value, style: TextStyle(color: color)));
      start = match.end;
    }
    if (start < line.length) {
      spans.add(TextSpan(text: line.substring(start)));
    }
    if (spans.isEmpty) spans.add(TextSpan(text: line));
    return spans;
  }
}

class _PreviewPane extends StatelessWidget {
  const _PreviewPane();

  @override
  Widget build(BuildContext context) {
    final s = UiScale.of(context);
    return ColoredBox(
      color: const Color(0xFF181818),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 28 * s,
            padding: EdgeInsets.symmetric(horizontal: 10 * s),
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _VsCode.border)),
            ),
            child: Text(
              'PREVIEW — Monitor bezel (class Painter)',
              style: TextStyle(
                color: _VsCode.muted,
                fontSize: 10 * s,
                letterSpacing: 0.6,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16 * s),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const aspect = 1 / 0.62;
                    var w = constraints.maxWidth;
                    var h = w / aspect;
                    if (h > constraints.maxHeight) {
                      h = constraints.maxHeight;
                      w = h * aspect;
                    }
                    return SizedBox(
                      width: w,
                      height: h,
                      child: CustomPaint(
                        painter: Painter(),
                        size: Size(w, h),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8 * s),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: _VsCode.border)),
            ),
            child: Text(
              'monitor.dart stacks CustomPaint + OperatingSystem inside the screen',
              textAlign: TextAlign.center,
              style: TextStyle(color: _VsCode.muted, fontSize: 10 * s),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.openFile});

  final _MonitorSourceFile openFile;

  @override
  Widget build(BuildContext context) {
    final s = UiScale.of(context);
    final fileName = openFile == _MonitorSourceFile.monitor
        ? 'monitor.dart'
        : 'monitor_frame_painter.dart';
    return Container(
      height: 22 * s,
      color: _VsCode.accent,
      padding: EdgeInsets.symmetric(horizontal: 10 * s),
      child: Row(
        children: [
          Icon(Icons.sync, size: 12 * s, color: Colors.white),
          SizedBox(width: 6 * s),
          Text('main*', style: TextStyle(color: Colors.white, fontSize: 11 * s)),
          const Spacer(),
          Text(fileName, style: TextStyle(color: Colors.white, fontSize: 11 * s)),
          SizedBox(width: 12 * s),
          Text('Dart', style: TextStyle(color: Colors.white, fontSize: 11 * s)),
          SizedBox(width: 12 * s),
          Text('UTF-8', style: TextStyle(color: Colors.white, fontSize: 11 * s)),
        ],
      ),
    );
  }
}