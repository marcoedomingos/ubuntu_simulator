import 'package:flutter/material.dart';
import 'package:ubuntu_simulate/commons/styles/os_scale.dart';
import '../../data/os_entities.dart';

class AppGridOverlay extends StatelessWidget {
  const AppGridOverlay({
    super.key,
    required this.scale,
    required this.apps,
    required this.onDismiss,
    required this.onLaunch,
  });

  final OsScaleTokens scale;
  final List<DockApp> apps;
  final VoidCallback onDismiss;
  final void Function(DockApp app) onLaunch;

  @override
  Widget build(BuildContext context) {
    final iconSize = scale.dockIconSize * 1.1;
    final labelSize = scale.tooltipFontSize + 0.5;
    final tileStride = iconSize * 1.85 + labelSize * 2.2;

    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.72),
        child: Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onDismiss,
              child: const SizedBox.expand(),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cols = (constraints.maxWidth / tileStride)
                      .floor()
                      .clamp(3, 8);
                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          scale.barPadding * 2,
                          scale.barPadding,
                          scale.barPadding * 2,
                          scale.barPadding * 0.5,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Applications',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: scale.barFontSize + 3,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              tooltip: 'Close',
                              onPressed: onDismiss,
                              icon: Icon(
                                Icons.close,
                                color: Colors.white70,
                                size: scale.barIconSize,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: scale.barPadding * 2,
                            vertical: scale.dockSpacing,
                          ),
                          child: Wrap(
                            spacing: scale.dockSpacing * 2,
                            runSpacing: scale.dockSpacing * 2,
                            children: apps.map((app) {
                              return SizedBox(
                                width: constraints.maxWidth / cols,
                                child: _AppGridTile(
                                  app: app,
                                  iconSize: iconSize,
                                  labelSize: labelSize,
                                  onLaunch: () => onLaunch(app),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppGridTile extends StatefulWidget {
  const _AppGridTile({
    required this.app,
    required this.iconSize,
    required this.labelSize,
    required this.onLaunch,
  });

  final DockApp app;
  final double iconSize;
  final double labelSize;
  final VoidCallback onLaunch;

  @override
  State<_AppGridTile> createState() => _AppGridTileState();
}

class _AppGridTileState extends State<_AppGridTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onLaunch,
        child: SizedBox(
          width: widget.iconSize * 1.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: widget.iconSize * 1.35,
                height: widget.iconSize * 1.35,
                decoration: BoxDecoration(
                  color: _hover
                      ? Colors.white.withValues(alpha: 0.14)
                      : Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: widget.app.assetPath != null
                      ? Image.asset(
                          widget.app.assetPath!,
                          width: widget.iconSize,
                          height: widget.iconSize,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            widget.app.icon,
                            color: widget.app.color,
                            size: widget.iconSize,
                          ),
                        )
                      : Icon(
                          widget.app.icon,
                          color: widget.app.color,
                          size: widget.iconSize,
                        ),
                ),
              ),
              SizedBox(height: widget.labelSize * 0.4),
              Text(
                widget.app.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: _hover ? 1 : 0.85),
                  fontSize: widget.labelSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
