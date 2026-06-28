import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ubuntu_simulate/commons/styles/os_colors.dart';
import 'package:ubuntu_simulate/commons/styles/os_scale.dart';
import 'os_scope.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.scale, required this.now});
  final OsScaleTokens scale;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final data = OsScope.dataOf(context);
    return Container(
      height: scale.barHeight,
      color: OsColors.topBar,
      padding: EdgeInsets.symmetric(horizontal: scale.barPadding),
      child: Row(
        children: [
          _ActivitiesBtn(scale: scale),
          Expanded(
            child: Center(
              child: Text(
                DateFormat('EEE MMM d   HH:mm').format(now),
                style: TextStyle(
                  color: OsColors.topBarText,
                  fontSize: scale.barFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (data.wifiEnabled) ...[
                Icon(
                  Icons.network_wifi,
                  color: Colors.white,
                  size: scale.barIconSize,
                ),
                SizedBox(width: scale.barPadding * 0.5),
              ],
              if (data.bluetoothEnabled) ...[
                Icon(
                  Icons.bluetooth,
                  color: Colors.white,
                  size: scale.barIconSize,
                ),
                SizedBox(width: scale.barPadding * 0.5),
              ],
              Icon(
                Icons.volume_up,
                color: Colors.white,
                size: scale.barIconSize,
              ),
              SizedBox(width: scale.barPadding * 0.5),
              Icon(
                Icons.battery_full,
                color: Colors.white,
                size: scale.barIconSize,
              ),
              SizedBox(width: scale.barPadding * 0.8),
              _TrayMenuBtn(scale: scale),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivitiesBtn extends StatefulWidget {
  const _ActivitiesBtn({required this.scale});
  final OsScaleTokens scale;
  @override
  State<_ActivitiesBtn> createState() => _ActivitiesBtnState();
}

class _ActivitiesBtnState extends State<_ActivitiesBtn> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: EdgeInsets.symmetric(
          horizontal: widget.scale.barPadding * 0.6,
          vertical: widget.scale.barHeight * 0.06,
        ),
        decoration: BoxDecoration(
          color: _hover ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'Activities',
          style: TextStyle(
            color: Colors.white,
            fontSize: widget.scale.barFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _TrayMenuBtn extends StatefulWidget {
  const _TrayMenuBtn({required this.scale});
  final OsScaleTokens scale;
  @override
  State<_TrayMenuBtn> createState() => _TrayMenuBtnState();
}

class _TrayMenuBtnState extends State<_TrayMenuBtn> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final controller = OsScope.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 30),
        onSelected: (val) {
          if (val == 'power_off') controller.shutdown();
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'power_off',
            child: Row(
              children: [
                Icon(Icons.power_settings_new, size: 18, color: Colors.white70),
                SizedBox(width: 8),
                Text('Power Off / Log Out', style: TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: EdgeInsets.symmetric(
            horizontal: widget.scale.barPadding * 0.5,
            vertical: widget.scale.barHeight * 0.06,
          ),
          decoration: BoxDecoration(
            color: _hover ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.power_settings_new,
                color: Colors.white,
                size: widget.scale.barIconSize,
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
                size: widget.scale.barIconSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
