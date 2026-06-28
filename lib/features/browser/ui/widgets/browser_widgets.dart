import 'package:flutter/material.dart';
import 'package:ubuntu_simulate/commons/widgets/ui_scale.dart';

class BrowserColors {
  static const chrome = Color(0xFF2B2A33);
  static const tabBar = Color(0xFF38383D);
  static const tabActive = Color(0xFF42414D);
  static const toolbar = Color(0xFF38383D);
  static const addressBar = Color(0xFF1C1B22);
  static const border = Color(0xFF5A5A61);
  static const orange = Color(0xFFFF7139);
}

class BrowserTabStrip extends StatelessWidget {
  const BrowserTabStrip({super.key, required this.currentUrl});
  final String currentUrl;

  @override
  Widget build(BuildContext context) {
    final s = UiScale.of(context);
    String tabTitle = 'Mozilla Firefox';
    if (currentUrl.startsWith('google.com')) tabTitle = 'Google';
    if (currentUrl.startsWith('github.com')) tabTitle = 'GitHub - marcoedomingos';
    if (currentUrl.startsWith('linkedin.com')) tabTitle = 'LinkedIn Profile';
    if (currentUrl.startsWith('medium.com')) tabTitle = 'Medium Articles';

    return Container(
      height: 36 * s,
      color: BrowserColors.tabBar,
      padding: EdgeInsets.only(left: 8 * s, top: 6 * s),
      child: Row(
        children: [
          Container(
            height: 28 * s,
            padding: EdgeInsets.symmetric(horizontal: 10 * s),
            decoration: const BoxDecoration(
              color: BrowserColors.tabActive,
              borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.public, size: 13 * s, color: Colors.blueAccent),
                SizedBox(width: 6 * s),
                Text(
                  tabTitle,
                  style: TextStyle(color: Colors.white, fontSize: 11 * s),
                ),
                SizedBox(width: 8 * s),
                Icon(Icons.close, size: 14 * s, color: Colors.white70),
              ],
            ),
          ),
          SizedBox(width: 4 * s),
          Icon(Icons.add, size: 16 * s, color: Colors.white54),
        ],
      ),
    );
  }
}

class BrowserNavToolbar extends StatelessWidget {
  const BrowserNavToolbar({
    super.key,
    required this.addressCtrl,
    required this.onBack,
    required this.onForward,
    required this.onReload,
    required this.onSubmitted,
    required this.onOpenExternal,
    required this.canGoBack,
    required this.canGoForward,
  });

  final TextEditingController addressCtrl;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final VoidCallback onReload;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onOpenExternal;
  final bool canGoBack;
  final bool canGoForward;

  @override
  Widget build(BuildContext context) {
    final s = UiScale.of(context);
    return Container(
      height: 44 * s,
      color: BrowserColors.toolbar,
      padding: EdgeInsets.symmetric(horizontal: 8 * s),
      child: Row(
        children: [
          _navBtn(Icons.arrow_back, canGoBack ? onBack : () {}, s, enabled: canGoBack),
          _navBtn(Icons.arrow_forward, canGoForward ? onForward : () {}, s, enabled: canGoForward),
          _navBtn(Icons.refresh, onReload, s),
          SizedBox(width: 8 * s),
          Expanded(
            child: Container(
              height: 30 * s,
              padding: EdgeInsets.symmetric(horizontal: 10 * s),
              decoration: BoxDecoration(
                color: BrowserColors.addressBar,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: BrowserColors.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock, size: 14 * s, color: Colors.green.shade400),
                  SizedBox(width: 8 * s),
                  Expanded(
                    child: TextField(
                      controller: addressCtrl,
                      style: TextStyle(color: Colors.white, fontSize: 12 * s),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: onSubmitted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8 * s),
          _navBtn(Icons.open_in_new, onOpenExternal, s, tooltip: 'Open Externally'),
          SizedBox(width: 4 * s),
          Container(
            width: 28 * s,
            height: 28 * s,
            decoration: BoxDecoration(
              color: BrowserColors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.public, color: BrowserColors.orange, size: 18 * s),
          ),
        ],
      ),
    );
  }

  Widget _navBtn(IconData icon, VoidCallback onTap, double s, {String? tooltip, bool enabled = true}) {
    return IconButton(
      onPressed: enabled ? onTap : null,
      icon: Icon(icon, size: 18 * s, color: enabled ? Colors.white.withValues(alpha: 0.85) : Colors.white24),
      tooltip: tooltip,
      padding: EdgeInsets.all(6 * s),
      constraints: BoxConstraints(minWidth: 32 * s, minHeight: 32 * s),
    );
  }
}

class GoogleHomePage extends StatelessWidget {
  const GoogleHomePage({super.key, required this.onSearch, required this.s});
  final ValueChanged<String> onSearch;
  final double s;

  @override
  Widget build(BuildContext context) {
    final searchCtrl = TextEditingController();
    return Container(
      color: Colors.white,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24 * s),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Google',
                style: TextStyle(
                  fontSize: 50 * s,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1.5,
                  shadows: const [Shadow(color: Colors.black12, offset: Offset(2, 2), blurRadius: 4)],
                ),
              ),
              SizedBox(height: 24 * s),
              Container(
                width: 450 * s,
                height: 40 * s,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 2))
                  ],
                  border: Border.all(color: Colors.black12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 14 * s),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey, size: 18 * s),
                    SizedBox(width: 8 * s),
                    Expanded(
                      child: TextField(
                        controller: searchCtrl,
                        style: TextStyle(color: Colors.black, fontSize: 13 * s),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search Google or type a URL',
                          isDense: true,
                        ),
                        onSubmitted: onSearch,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18 * s),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => onSearch(searchCtrl.text),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF8F9FA), foregroundColor: Colors.black87),
                    child: Text('Google Search', style: TextStyle(fontSize: 12 * s)),
                  ),
                  SizedBox(width: 8 * s),
                  ElevatedButton(
                    onPressed: () => onSearch('marco edomingos resume'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF8F9FA), foregroundColor: Colors.black87),
                    child: Text('I’m Feeling Lucky', style: TextStyle(fontSize: 12 * s)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GoogleSearchResults extends StatelessWidget {
  const GoogleSearchResults({super.key, required this.query, required this.onLinkClick, required this.s});
  final String query;
  final ValueChanged<String> onLinkClick;
  final double s;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'G',
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 22 * s),
              ),
              SizedBox(width: 12 * s),
              Text(
                query,
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 14 * s),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: ListView(
              children: [
                _buildResultCard(
                  'Marco Domingos - Senior Software Engineer - LinkedIn',
                  'linkedin.com',
                  'Accomplished B.Sc. Computer Engineering graduate and Senior Developer specializing in Flutter cross-platform runtime pipelines, Native Android SDK, and secure scalable NodeJS backend engines.',
                  () => onLinkClick('linkedin.com'),
                  s,
                ),
                _buildResultCard(
                  'marcoedomingos (Marco Domingos) · GitHub',
                  'github.com',
                  'Browse github repositories including pixel-art portfolio, pixel_watch watchface app logic, clean architecture frameworks, offline-first native applications, and deployment scripts.',
                  () => onLinkClick('github.com'),
                  s,
                ),
                _buildResultCard(
                  'Marco Domingos – Medium Blog Articles',
                  'medium.com',
                  'Read technical logs covering Dart records series, scroll physics settings for Windows, custom MethodChannel testing suites, and Android SDK 33 storage permission workarounds.',
                  () => onLinkClick('medium.com'),
                  s,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(String title, String cite, String desc, VoidCallback onTap, double s) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(cite, style: TextStyle(color: Colors.grey.shade600, fontSize: 11 * s)),
          GestureDetector(
            onTap: onTap,
            child: Text(
              title,
              style: TextStyle(color: const Color(0xFF1A0DAB), fontSize: 15 * s, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
            ),
          ),
          SizedBox(height: 3 * s),
          Text(desc, style: TextStyle(color: Colors.black87, fontSize: 12 * s, height: 1.4)),
        ],
      ),
    );
  }
}

class GitHubProfilePage extends StatelessWidget {
  const GitHubProfilePage({super.key, required this.s, required this.onLinkClick});
  final double s;
  final ValueChanged<String> onLinkClick;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D1117),
      padding: EdgeInsets.all(16 * s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column: Profile card
          Container(
            width: 180 * s,
            padding: EdgeInsets.all(8 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 36 * s,
                  backgroundColor: Colors.indigo,
                  child: Icon(Icons.person, size: 40 * s, color: Colors.white),
                ),
                SizedBox(height: 12 * s),
                Text(
                  'Marco Domingos',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16 * s),
                ),
                Text(
                  'marcoedomingos',
                  style: TextStyle(color: Colors.grey, fontSize: 12 * s),
                ),
                SizedBox(height: 12 * s),
                Text(
                  'B.Sc. Computer Engineering. Focused on Clean Architecture, Flutter pipelines, and Kotlin natively.',
                  style: TextStyle(color: Colors.white70, fontSize: 11 * s, height: 1.4),
                ),
                SizedBox(height: 16 * s),
                ElevatedButton(
                  onPressed: () => onLinkClick('linkedin.com'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF21262D), foregroundColor: Colors.white, minimumSize: Size(double.infinity, 28 * s)),
                  child: Text('LinkedIn Contact', style: TextStyle(fontSize: 10 * s)),
                ),
              ],
            ),
          ),
          // Right column: Repositories and Contribution Matrix
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 12 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Popular repositories', style: TextStyle(color: Colors.white, fontSize: 14 * s, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8 * s),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10 * s,
                    mainAxisSpacing: 10 * s,
                    childAspectRatio: 1.9,
                    children: [
                      _repoCard('my-gamed-portfolio', 'Simulated pixel-art personal portfolio containing Ubuntu & Watch interactions.', 'TypeScript', Colors.blue, s),
                      _repoCard('pixel_watch_flutter', 'Watchface state sync logic constructed on Flutter SDK runtime.', 'Dart', Colors.cyan, s),
                      _repoCard('clean-architecture-framework', 'Clean domain driven architectural templates for Native Mobile.', 'Kotlin', Colors.amber, s),
                      _repoCard('api-gateway-engine', 'High throughput API Routing pipeline supporting ORM interfaces.', 'TypeScript', Colors.blue, s),
                    ],
                  ),
                  SizedBox(height: 16 * s),
                  Text('Contributions in the last year', style: TextStyle(color: Colors.white, fontSize: 13 * s)),
                  SizedBox(height: 8 * s),
                  Container(
                    height: 80 * s,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white12),
                      borderRadius: BorderRadius.circular(6),
                      color: const Color(0xFF161B22),
                    ),
                    padding: EdgeInsets.all(8 * s),
                    child: GridView.count(
                      crossAxisCount: 24,
                      mainAxisSpacing: 2 * s,
                      crossAxisSpacing: 2 * s,
                      children: List.generate(120, (index) {
                        final val = (index * 7 + 13) % 4; // Use something deterministic since we don't have math import here
                        Color tileColor = const Color(0xFF0E4429);
                        if (val == 0) tileColor = const Color(0xFF161B22);
                        if (val == 1) tileColor = const Color(0xFF26A641);
                        if (val == 2) tileColor = const Color(0xFF39D353);
                        return Container(
                          decoration: BoxDecoration(color: tileColor, borderRadius: BorderRadius.circular(1.5)),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _repoCard(String name, String desc, String lang, Color langCol, double s) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        border: Border.all(color: const Color(0xFF30363D)),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: EdgeInsets.all(10 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: TextStyle(color: const Color(0xFF58A6FF), fontWeight: FontWeight.bold, fontSize: 12 * s)),
          Text(desc, style: TextStyle(color: Colors.grey, fontSize: 10 * s, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
          Row(
            children: [
              CircleAvatar(radius: 4 * s, backgroundColor: langCol),
              SizedBox(width: 6 * s),
              Text(lang, style: TextStyle(color: Colors.grey, fontSize: 10 * s)),
            ],
          )
        ],
      ),
    );
  }
}

class MediumBlogPage extends StatelessWidget {
  const MediumBlogPage({super.key, required this.s, required this.onLinkClick});
  final double s;
  final ValueChanged<String> onLinkClick;

  @override
  Widget build(BuildContext context) {
    final posts = [
      ('Flutter — Storage access for Android SDK 33', 'Navigating granular media permissions and privacy frameworks across modern SDK compilation boundaries.'),
      ('The Ultimate Showdown: MethodChannel vs. Platform Channels', 'An architectural deep-dive analyzing asynchronous message passing and memory models between Dart and Native systems.'),
      ('BulletProof Method Call: Unit Testing Channels', 'Strategies for mock-injecting binary messengers and ensuring reliable execution loops inside testing suites.'),
      ('No Internet? No Problem! Offline Package Cache', 'Configuring custom local repositories, cache structures, and offline dependency paths inside the toolchain.')
    ];

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Medium Blogs',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18 * s, fontFamily: 'serif'),
          ),
          SizedBox(height: 6 * s),
          Text(
            'Technical engineering logs written by Marco Domingos',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12 * s),
          ),
          const Divider(),
          Expanded(
            child: ListView.separated(
              itemCount: posts.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, idx) {
                final post = posts[idx];
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.$1,
                        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14 * s),
                      ),
                      SizedBox(height: 4 * s),
                      Text(
                        post.$2,
                        style: TextStyle(color: Colors.black54, fontSize: 11 * s, height: 1.4),
                      ),
                      SizedBox(height: 8 * s),
                      GestureDetector(
                        onTap: () => onLinkClick('linkedin.com'),
                        child: Text(
                          'Read full article ➔',
                          style: TextStyle(color: Colors.blue.shade700, fontSize: 10 * s, fontWeight: FontWeight.w500),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
