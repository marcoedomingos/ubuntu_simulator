import 'package:flutter/material.dart';
import 'package:ubuntu_simulate/commons/styles/os_colors.dart';
import 'package:ubuntu_simulate/commons/styles/os_scale.dart';
import '../../data/os_entities.dart';

class Dock extends StatelessWidget {
  const Dock({
    super.key,
    required this.scale,
    required this.apps,
    required this.running,
    required this.visible,
    required this.onShowApps,
  });
  final OsScaleTokens scale;
  final List<DockApp> apps;
  final bool Function(String) running;
  final bool Function(String) visible;
  final VoidCallback onShowApps;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: scale.dockWidth,
      decoration: const BoxDecoration(
        color: OsColors.dock,
        border: Border(right: BorderSide(color: OsColors.dockBorder, width: 1)),
      ),
      child: Column(
        children: [
          SizedBox(height: scale.dockPadding),
          _UbuntuLogoBtn(size: scale.dockIconSize),
          _dockDivider(scale),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: apps
                  .map(
                    (app) => _DockIcon(
                      app: app,
                      scale: scale,
                      running: running(app.id),
                      focused: visible(app.id),
                    ),
                  )
                  .toList(),
            ),
          ),
          _dockDivider(scale),
          _AppGridBtn(size: scale.dockIconSize, onTap: onShowApps),
          SizedBox(height: scale.dockPadding),
        ],
      ),
    );
  }

  Widget _dockDivider(OsScaleTokens scale) => Padding(
    padding: EdgeInsets.symmetric(vertical: scale.dockSpacing * 0.5),
    child: Divider(
      height: 1,
      color: Colors.white.withValues(alpha: 0.12),
      indent: scale.dockWidth * 0.18,
      endIndent: scale.dockWidth * 0.18,
    ),
  );
}

class _UbuntuLogoBtn extends StatefulWidget {
  const _UbuntuLogoBtn({required this.size});
  final double size;
  @override
  State<_UbuntuLogoBtn> createState() => _UbuntuLogoBtnState();
}

class _UbuntuLogoBtnState extends State<_UbuntuLogoBtn> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _hover
              ? const Color(0xFFE95420).withValues(alpha: 0.85)
              : const Color(0xFFE95420),
          boxShadow: _hover
              ? [const BoxShadow(color: Color(0x66E95420), blurRadius: 10)]
              : [],
        ),
        child: Center(
          child: Icon(
            Icons.circle,
            color: Colors.white,
            size: widget.size * 0.45,
          ),
        ),
      ),
    );
  }
}

class _AppGridBtn extends StatefulWidget {
  const _AppGridBtn({required this.size, required this.onTap});
  final double size;
  final VoidCallback onTap;
  @override
  State<_AppGridBtn> createState() => _AppGridBtnState();
}

class _AppGridBtnState extends State<_AppGridBtn> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Show Applications',
      preferBelow: false,
      textStyle: const TextStyle(fontSize: 11, color: Colors.white),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(4),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _hover
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.transparent,
            ),
            child: Center(
              child: _NineDotGrid(
                size: widget.size * 0.52,
                color: _hover ? Colors.white : Colors.white60,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NineDotGrid extends StatelessWidget {
  const _NineDotGrid({required this.size, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final dot = size / 7;
    return SizedBox(
      width: size,
      height: size,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          3,
          (_) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              3,
              (_) => Container(
                width: dot,
                height: dot,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockIcon extends StatefulWidget {
  const _DockIcon({
    required this.app,
    required this.scale,
    required this.running,
    required this.focused,
  });
  final DockApp app;
  final OsScaleTokens scale;
  final bool running, focused;
  @override
  State<_DockIcon> createState() => _DockIconState();
}

class _DockIconState extends State<_DockIcon>
    with SingleTickerProviderStateMixin {
  bool _hover = false;
  late AnimationController _bounce;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _anim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -9.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -9.0, end: 0.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _bounce, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    return Tooltip(
      message: widget.app.label,
      preferBelow: false,
      textStyle: TextStyle(fontSize: s.tooltipFontSize, color: Colors.white),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(4),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: () {
            _bounce.forward(from: 0);
            widget.app.onLaunch?.call();
          },
          child: AnimatedBuilder(
            animation: _anim,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, _anim.value),
              child: child,
            ),
            child: SizedBox(
              width: s.dockWidth,
              height: s.dockSlotHeight,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    width: s.dockWidth * 0.92,
                    height: s.dockIconSize + s.dockSpacing * 1.6,
                    decoration: BoxDecoration(
                      color: widget.focused
                          ? Colors.white.withValues(alpha: 0.12)
                          : _hover
                          ? Colors.white.withValues(alpha: 0.07)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  if (widget.running)
                    Positioned(
                      left: 0,
                      child: Container(
                        width: 3,
                        height: widget.focused
                            ? s.dockIconSize * 0.6
                            : s.dockIconSize * 0.3,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.horizontal(
                            right: Radius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: s.dockSpacing),
                    child: widget.app.assetPath != null
                        ? Image.asset(
                            widget.app.assetPath!,
                            width: s.dockIconSize,
                            height: s.dockIconSize,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              widget.app.icon,
                              color: widget.app.color,
                              size: s.dockIconSize,
                            ),
                          )
                        : Icon(
                            widget.app.icon,
                            color: _hover || widget.focused
                                ? widget.app.color
                                : Colors.white70,
                            size: s.dockIconSize,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
