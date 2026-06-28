import 'package:flutter/material.dart';
import 'package:ubuntu_simulate/features/operating_system/data/vfs.dart';
import 'package:ubuntu_simulate/features/operating_system/ui/widgets/os_scope.dart';
import 'package:ubuntu_simulate/commons/widgets/ui_scale.dart';
import '../widgets/files_widgets.dart';

class FilesView extends StatefulWidget {
  const FilesView({super.key});

  @override
  State<FilesView> createState() => _FilesViewState();
}

class _FilesViewState extends State<FilesView> {
  void _openFile(VfsFile file, double s) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(
            file.name,
            style: TextStyle(color: Colors.white, fontSize: 16 * s, fontFamily: 'monospace'),
          ),
          content: Container(
            width: 450 * s,
            constraints: BoxConstraints(maxHeight: 300 * s),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: EdgeInsets.all(12 * s),
            child: SingleChildScrollView(
              child: Text(
                file.content,
                style: TextStyle(color: Colors.greenAccent, fontSize: 13 * s, fontFamily: 'monospace'),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.redAccent)),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = UiScale.of(context);
    final data = OsScope.dataOf(context);
    final controller = OsScope.of(context);

    const filesBg = Color(0xFF1C1C1C);
    const filesToolbar = Color(0xFF252525);

    return Container(
      color: filesBg,
      child: Column(
        children: [
          // Nautilus Header
          Container(
            height: 38 * s,
            color: filesToolbar,
            padding: EdgeInsets.symmetric(horizontal: 8 * s),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left, color: Colors.white70, size: 20 * s),
                  onPressed: data.currentDir.parent != null
                      ? () => controller.setCurrentDir(data.currentDir.parent!)
                      : null,
                ),
                IconButton(
                  icon: Icon(Icons.arrow_upward, color: Colors.white70, size: 18 * s),
                  onPressed: data.currentDir.parent != null
                      ? () => controller.setCurrentDir(data.currentDir.parent!)
                      : null,
                ),
                SizedBox(width: 8 * s),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 3 * s),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.folder, color: Colors.white54, size: 14 * s),
                      SizedBox(width: 4 * s),
                      Text(
                        data.currentDir.name,
                        style: TextStyle(color: Colors.white70, fontSize: 12 * s),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // File Explorer Panel
          Expanded(
            child: Row(
              children: [
                // Sidebar Navigation
                Container(
                  width: 140 * s,
                  color: const Color(0xFF212121),
                  child: ListView(
                    children: [
                      FileSideItem(
                        icon: Icons.home,
                        label: 'Home',
                        scale: s,
                        selected: data.currentDir == data.vfs.visitor,
                        onTap: () => controller.setCurrentDir(data.vfs.visitor),
                      ),
                      FileSideItem(
                        icon: Icons.desktop_windows,
                        label: 'Desktop',
                        scale: s,
                        selected: data.currentDir == data.vfs.desktop,
                        onTap: () => controller.setCurrentDir(data.vfs.desktop),
                      ),
                      FileSideItem(
                        icon: Icons.folder,
                        label: 'Documents',
                        scale: s,
                        selected: data.currentDir == data.vfs.documents,
                        onTap: () => controller.setCurrentDir(data.vfs.documents),
                      ),
                      FileSideItem(
                        icon: Icons.download,
                        label: 'Downloads',
                        scale: s,
                        selected: data.currentDir == data.vfs.downloads,
                        onTap: () => controller.setCurrentDir(data.vfs.downloads),
                      ),
                    ],
                  ),
                ),

                // Folder & Files view
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.all(16 * s),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 10 * s,
                      crossAxisSpacing: 10 * s,
                    ),
                    itemCount: data.currentDir.children.length,
                    itemBuilder: (context, idx) {
                      final item = data.currentDir.children[idx];
                      final isFolder = item is VfsFolder;
                      return GestureDetector(
                        onTap: () {
                          if (isFolder) {
                            controller.setCurrentDir(item);
                          } else {
                            _openFile(item as VfsFile, s);
                          }
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isFolder ? Icons.folder : Icons.description,
                              color: isFolder ? Colors.amber : Colors.lightBlueAccent,
                              size: 42 * s,
                            ),
                            SizedBox(height: 4 * s),
                            Text(
                              item.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70, fontSize: 11 * s),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
