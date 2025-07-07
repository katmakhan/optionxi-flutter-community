import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:optionxi/Helpers/browser_lite_widget.dart';
import 'package:optionxi/Helpers/open_url.dart';

class BrowserLite_V extends StatefulWidget {
  final String url;

  const BrowserLite_V(
    this.url, {
    Key? key,
  }) : super(key: key);

  @override
  State<BrowserLite_V> createState() => _BrowserLite_VState();
}

class _BrowserLite_VState extends State<BrowserLite_V> {
  String _currentTitle = '';

  @override
  void initState() {
    super.initState();
    _currentTitle = 'Browser';
  }

  void _handleBackPress() {
    Navigator.of(context).pop();
  }

  void _openInExternalBrowser() {
    OpenHelper.open_url(widget.url);
  }

  void _copyUrl() {
    Clipboard.setData(ClipboardData(text: widget.url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('URL copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.open_in_browser),
                title: const Text('Open in External Browser'),
                onTap: () {
                  Navigator.pop(context);
                  _openInExternalBrowser();
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy URL'),
                onTap: () {
                  Navigator.pop(context);
                  _copyUrl();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: _handleBackPress,
          tooltip: 'Back',
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (widget.url.isNotEmpty)
              Text(
                Uri.parse(widget.url).host,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser, size: 22),
            onPressed: _openInExternalBrowser,
            tooltip: 'Open in External Browser',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, size: 22),
            onPressed: _showMoreOptions,
            tooltip: 'More Options',
          ),
        ],
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Browser content
            Expanded(
              child: BrowserLite_Widget(
                widget.url,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
