import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ubuntu_simulate/features/operating_system/data/os_state_data.dart';
import 'package:ubuntu_simulate/features/operating_system/data/vfs.dart';
import 'package:ubuntu_simulate/features/operating_system/ui/widgets/os_scope.dart';
import '../widgets/cmatrix_widget.dart';

enum _TerminalMode { normal, nano, cmatrix }

class TerminalLine {
  final String path;
  final String command;
  final List<String> output;
  TerminalLine({required this.path, required this.command, this.output = const []});
}

class TerminalView extends StatefulWidget {
  const TerminalView({super.key});

  @override
  State<TerminalView> createState() => _TerminalViewState();
}

class _TerminalViewState extends State<TerminalView> {
  final List<TerminalLine> _lines = [];
  final List<String> _systemMessages = [
    'Welcome to Ubuntu 22.04.3 LTS (GNU/Linux 6.5.0 x86_64)',
    'Type "help" for available commands.',
    '',
  ];

  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _focus = FocusNode();
  final _keyboardFocus = FocusNode();

  _TerminalMode _mode = _TerminalMode.normal;
  String _nanoFileName = '';
  final _nanoTextCtrl = TextEditingController();

  final List<String> _cmdHistory = [];
  int _historyIdx = -1;

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    _focus.dispose();
    _nanoTextCtrl.dispose();
    super.dispose();
  }

  String _getPromptPath(OsStateData data) {
    final path = data.currentDir.path;
    final home = data.vfs.visitor.path;
    return path.startsWith(home) ? path.replaceFirst(home, '~') : path;
  }

  void _submit(String input) {
    final data = OsScope.dataOf(context);
    final controller = OsScope.of(context);
    final cmd = input.trim();

    if (cmd.isNotEmpty) {
      _cmdHistory.add(cmd);
      _historyIdx = _cmdHistory.length;
    }

    if (cmd == 'clear') {
      setState(() {
        _lines.clear();
        _systemMessages.clear();
      });
    } else {
      final out = _run(cmd, data, controller);
      setState(() {
        _lines.add(TerminalLine(
          path: _getPromptPath(data),
          command: input,
          output: out,
        ));
      });
    }

    _ctrl.clear();
    _scrollToBottom();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focus.requestFocus();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleHistoryNavigation(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    if (_cmdHistory.isEmpty) return;

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_historyIdx > 0) {
        setState(() {
          _historyIdx--;
          _ctrl.text = _cmdHistory[_historyIdx];
          _ctrl.selection = TextSelection.fromPosition(TextPosition(offset: _ctrl.text.length));
        });
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_historyIdx < _cmdHistory.length - 1) {
        setState(() {
          _historyIdx++;
          _ctrl.text = _cmdHistory[_historyIdx];
          _ctrl.selection = TextSelection.fromPosition(TextPosition(offset: _ctrl.text.length));
        });
      } else {
        setState(() {
          _historyIdx = _cmdHistory.length;
          _ctrl.clear();
        });
      }
    }
  }

  List<String> _run(String cmdStr, OsStateData data, OsController controller) {
    final trimmed = cmdStr.trim();
    if (trimmed.isEmpty) return [];
    
    final parts = trimmed.split(RegExp(r'\s+'));
    final cmd = parts[0];
    final args = parts.length > 1 ? parts.sublist(1) : <String>[];

    switch (cmd) {
      case 'help': return ['Available: ls, cd, pwd, cat, nano, touch, mkdir, rm, neofetch, cmatrix, apt, clear'];
      case 'pwd': return [data.currentDir.path];
      case 'ls': return [data.currentDir.children.map((n) => n is VfsFolder ? '${n.name}/' : n.name).join('  ')];
      case 'cd':
        final target = args.isEmpty ? '~' : args[0];
        final node = data.vfs.resolvePath(target, data.currentDir);
        if (node is VfsFolder) {
          controller.setCurrentDir(node);
          return [];
        }
        return ['bash: cd: $target: No such directory'];
      case 'neofetch': return ['OS: Ubuntu 22.04.3 LTS', 'Kernel: 6.5.0-generic', 'Shell: bash', 'Terminal: Yaru'];
      case 'cmatrix': 
        if (!data.installedPackages.contains('cmatrix')) return ['Command not found. Try: apt install cmatrix'];
        setState(() => _mode = _TerminalMode.cmatrix); return [];
      case 'nano':
        if (args.isEmpty) return ['nano: filename required'];
        final filename = args[0];
        final node = data.vfs.resolvePath(filename, data.currentDir);
        _nanoFileName = filename;
        _nanoTextCtrl.text = node is VfsFile ? node.content : '';
        setState(() => _mode = _TerminalMode.nano); return [];
      case 'apt':
        if (args.isNotEmpty && args[0] == 'install' && args.length > 1) {
          controller.installPackage(args[1]);
          return ['Reading package lists...', 'Setting up ${args[1]}... Done.'];
        }
        return ['apt: command not recognized'];
      default: return ['bash: $cmd: command not found'];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_mode == _TerminalMode.cmatrix) return CMatrixWidget(onExit: () => setState(() => _mode = _TerminalMode.normal));
    if (_mode == _TerminalMode.nano) return _buildNano();

    final data = OsScope.dataOf(context);

    return GestureDetector(
      onTap: () => _focus.requestFocus(),
      child: Container(
        color: const Color(0xFF300A24),
        padding: const EdgeInsets.all(8),
        child: ListView(
          controller: _scroll,
          children: [
            ..._systemMessages.map((m) => Text(m, style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 13))),
            ..._lines.map((line) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PromptRow(path: line.path, command: line.command, readOnly: true),
                ...line.output.map((out) => Text(out, style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 13))),
              ],
            )),
            KeyboardListener(
              focusNode: _keyboardFocus,
              onKeyEvent: _handleHistoryNavigation,
              child: _PromptRow(
                path: _getPromptPath(data),
                controller: _ctrl,
                focusNode: _focus,
                onSubmitted: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNano() {
    return Container(
      color: const Color(0xFF0C0A0C),
      child: Column(
        children: [
          Container(color: Colors.grey[300], width: double.infinity, padding: const EdgeInsets.all(4), child: Center(child: Text('Editing: $_nanoFileName', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))),
          Expanded(child: TextField(controller: _nanoTextCtrl, maxLines: null, style: const TextStyle(color: Colors.white, fontFamily: 'monospace'), autofocus: true, decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(8)))),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            TextButton(onPressed: () { OsScope.of(context).addFile(OsScope.dataOf(context).currentDir, _nanoFileName, _nanoTextCtrl.text); }, child: const Text('Save (^O)', style: TextStyle(color: Colors.white))),
            TextButton(onPressed: () => setState(() => _mode = _TerminalMode.normal), child: const Text('Exit (^X)', style: TextStyle(color: Colors.white))),
          ])
        ],
      ),
    );
  }
}

class _PromptRow extends StatelessWidget {
  const _PromptRow({required this.path, this.controller, this.focusNode, this.onSubmitted, this.command, this.readOnly = false});
  final String path;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final String? command;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final style = const TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.bold);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: style,
            children: [
              const TextSpan(text: 'visitor@portfolio', style: TextStyle(color: Color(0xFF4EAA25))),
              const TextSpan(text: ':', style: TextStyle(color: Colors.white)),
              TextSpan(text: path, style: const TextStyle(color: Color(0xFF3465A4))),
              const TextSpan(text: '\$ ', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        Expanded(
          child: readOnly 
            ? Text(command ?? '', style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 13))
            : TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
                cursorColor: Colors.white70,
                style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 13),
                decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                onSubmitted: onSubmitted,
              ),
        ),
      ],
    );
  }
}
