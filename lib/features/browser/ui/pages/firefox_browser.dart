import 'package:ubuntu_simulate/commons/widgets/ui_scale.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as html;
import '../widgets/browser_widgets.dart';

class FirefoxBrowser extends StatefulWidget {
  const FirefoxBrowser({super.key});

  static const linkedInAsset = 'assets/src/linkedin.png';
  static const linkedInUrl = 'https://www.linkedin.com/in/marcoedomingos/';

  @override
  State<FirefoxBrowser> createState() => _FirefoxBrowserState();
}

class _FirefoxBrowserState extends State<FirefoxBrowser> {
  final List<String> _history = ['google.com'];
  int _historyIndex = 0;
  final _addressCtrl = TextEditingController(text: 'google.com');

  @override
  void initState() {
    super.initState();
    _addressCtrl.text = _history[_historyIndex];
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  void _navigateTo(String url) {
    if (url.isEmpty) return;
    String target = url.trim().toLowerCase();
    if (!target.startsWith('http://') && !target.startsWith('https://') && !target.contains('.com')) {
      // Treat as search query on google
      target = 'google.com/search?q=${Uri.encodeComponent(url)}';
    } else {
      target = target.replaceAll('https://', '').replaceAll('http://', '');
    }

    setState(() {
      // Truncate forward history if navigating new
      if (_historyIndex < _history.length - 1) {
        _history.removeRange(_historyIndex + 1, _history.length);
      }
      _history.add(target);
      _historyIndex = _history.length - 1;
      _addressCtrl.text = target;
    });
  }

  void _goBack() {
    if (_historyIndex > 0) {
      setState(() {
        _historyIndex--;
        _addressCtrl.text = _history[_historyIndex];
      });
    }
  }

  void _goForward() {
    if (_historyIndex < _history.length - 1) {
      setState(() {
        _historyIndex++;
        _addressCtrl.text = _history[_historyIndex];
      });
    }
  }

  void _reload() {
    setState(() {});
  }

  void _openExternal() {
    final currentUrl = _history[_historyIndex];
    String fullUrl = 'https://$currentUrl';
    if (currentUrl == 'linkedin.com') {
      fullUrl = FirefoxBrowser.linkedInUrl;
    } else if (currentUrl.startsWith('github.com')) {
      fullUrl = 'https://github.com/marcoedomingos';
    } else if (currentUrl.startsWith('medium.com')) {
      fullUrl = 'https://medium.com/@marcoedomingos';
    }
    html.window.open(fullUrl, '_blank');
  }

  @override
  Widget build(BuildContext context) {
    final s = UiScale.of(context);
    final currentUrl = _history[_historyIndex];

    return ColoredBox(
      color: BrowserColors.chrome,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BrowserTabStrip(currentUrl: currentUrl),
          BrowserNavToolbar(
            addressCtrl: _addressCtrl,
            onBack: _goBack,
            onForward: _goForward,
            onReload: _reload,
            onSubmitted: _navigateTo,
            onOpenExternal: _openExternal,
            canGoBack: _historyIndex > 0,
            canGoForward: _historyIndex < _history.length - 1,
          ),
          Expanded(
            child: ColoredBox(
              color: currentUrl.startsWith('google.com') ? Colors.white : const Color(0xFFF3F2EF),
              child: _buildWebContent(currentUrl, s),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebContent(String url, double s) {
    if (url.startsWith('google.com/search')) {
      final uri = Uri.parse('https://$url');
      final query = uri.queryParameters['q'] ?? 'Marco Domingos';
      return GoogleSearchResults(query: query, onLinkClick: _navigateTo, s: s);
    }
    if (url == 'google.com') {
      return GoogleHomePage(onSearch: _navigateTo, s: s);
    }
    if (url.startsWith('github.com')) {
      return GitHubProfilePage(s: s, onLinkClick: _navigateTo);
    }
    if (url.startsWith('linkedin.com')) {
      return Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          child: Image.asset(
            FirefoxBrowser.linkedInAsset,
            fit: BoxFit.fitWidth,
            width: double.infinity,
            filterQuality: FilterQuality.none,
          ),
        ),
      );
    }
    if (url.startsWith('medium.com')) {
      return MediumBlogPage(s: s, onLinkClick: _navigateTo);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.grey, size: 48 * s),
          SizedBox(height: 12 * s),
          Text(
            'Server Not Found',
            style: TextStyle(color: Colors.white70, fontSize: 16 * s, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6 * s),
          Text(
            'Firefox can’t find the server at $url.',
            style: TextStyle(color: Colors.grey, fontSize: 12 * s),
          ),
        ],
      ),
    );
  }
}
