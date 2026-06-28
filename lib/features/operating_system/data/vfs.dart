abstract class VfsNode {
  VfsNode({required this.name, required this.parent});
  final String name;
  final VfsFolder? parent;

  String get path {
    if (parent == null) return name;
    if (parent!.name == '/') return '/$name';
    return '${parent!.path}/$name';
  }
}

class VfsFile extends VfsNode {
  VfsFile({required super.name, required super.parent, this.content = ''});
  String content;
}

class VfsFolder extends VfsNode {
  VfsFolder({required super.name, required super.parent});
  final List<VfsNode> children = [];

  VfsNode? find(String childName) {
    for (final child in children) {
      if (child.name == childName) return child;
    }
    return null;
  }
}

class Vfs {
  Vfs() {
    root = VfsFolder(name: '/', parent: null);
    
    // Setup /home/visitor
    final home = VfsFolder(name: 'home', parent: root);
    root.children.add(home);
    visitor = VfsFolder(name: 'visitor', parent: home);
    home.children.add(visitor);

    // visitor's folders
    desktop = VfsFolder(name: 'Desktop', parent: visitor);
    documents = VfsFolder(name: 'Documents', parent: visitor);
    downloads = VfsFolder(name: 'Downloads', parent: visitor);
    pictures = VfsFolder(name: 'Pictures', parent: visitor);
    videos = VfsFolder(name: 'Videos', parent: visitor);

    visitor.children.addAll([desktop, documents, downloads, pictures, videos]);

    // visitor's files
    visitor.children.add(VfsFile(
      name: 'README.md',
      parent: visitor,
      content: '''# Welcome to Marco's Portfolio
This is a fully simulated Ubuntu 22.04 LTS OS!
Feel free to explore Nautilus (Files), VS Code, Firefox, and the Terminal.

You can run commands like:
- cd, ls, cat, echo, touch, mkdir, rm
- nano <file> (edit files!)
- neofetch, cmatrix, cowsay, fortune
- apt install <pkg>''',
    ));
    
    visitor.children.add(VfsFile(
      name: 'contact.txt',
      parent: visitor,
      content: '''Email: marcoedomingos@gmail.com
GitHub: https://github.com/marcoedomingos
LinkedIn: https://www.linkedin.com/in/marcoedomingos/''',
    ));

    desktop.children.add(VfsFile(
      name: 'portfolio.txt',
      parent: desktop,
      content: 'Senior Software Engineer | Dart, Flutter, Kotlin, Jetpack Compose, TypeScript, NestJS, AWS',
    ));
  }

  late final VfsFolder root;
  late final VfsFolder visitor;
  late final VfsFolder desktop;
  late final VfsFolder documents;
  late final VfsFolder downloads;
  late final VfsFolder pictures;
  late final VfsFolder videos;

  VfsNode? resolvePath(String path, VfsFolder currentDir) {
    if (path.isEmpty) return currentDir;
    if (path == '/') return root;
    
    final isAbsolute = path.startsWith('/');
    final parts = path.split('/').where((s) => s.isNotEmpty && s != '.');
    VfsFolder temp = isAbsolute ? root : currentDir;

    for (final part in parts) {
      if (part == '..') {
        temp = temp.parent ?? temp;
      } else {
        final node = temp.find(part);
        if (node == null) return null;
        if (node is VfsFolder) {
          temp = node;
        } else {
          // If it's a file, it must be the last part of the path
          if (part == parts.last) {
            return node;
          }
          return null;
        }
      }
    }
    return temp;
  }
}
