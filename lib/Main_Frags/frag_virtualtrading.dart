import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:optionxi/VirtualTrading/MainFrags/vt_frag_portfolio.dart';
import 'package:optionxi/VirtualTrading/MainFrags/vt_frag_watchlist.dart';
import 'package:optionxi/VirtualTrading/MainFrags/vt_frag_tradinghub.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optionxi/VirtualTrading/MainFrags/vt_frag_orders.dart';

class VirtualTradingFragment extends StatefulWidget {
  const VirtualTradingFragment({Key? key}) : super(key: key);

  @override
  State<VirtualTradingFragment> createState() => _VirtualTradingFragmentState();
}

class _VirtualTradingFragmentState extends State<VirtualTradingFragment>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentPageIndex = 0;
  bool _hasShownPopup = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    // Show popup after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showEducationalPopup();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showEducationalPopup() async {
    if (_hasShownPopup) return;

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final lastDismissedStr = prefs.getString('educationalPopupDismissedAt');

    if (lastDismissedStr != null) {
      final lastDismissed = DateTime.tryParse(lastDismissedStr);
      if (lastDismissed != null && now.difference(lastDismissed).inHours < 24) {
        return; // Don't show if it's been dismissed within the last 24 hours
      }
    }

    bool dontShowAgain = false;

    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Educational Mode',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This section displays previous day data, as required by regulatory guidelines (SEBI and NSE) for virtual trading platforms.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  height: 1.4,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'It\'s perfect for learning and practicing trading strategies in a simulated environment!',
                        style: GoogleFonts.inter(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: dontShowAgain,
                    onChanged: (val) {
                      setState(() {
                        dontShowAgain = val ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      "Don't show again for today",
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (dontShowAgain) {
                  await prefs.setString(
                      'educationalPopupDismissedAt', now.toIso8601String());
                }
                Navigator.pop(context);
                setState(() {
                  _hasShownPopup = true;
                });
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Got it!'),
            ),
          ],
        ),
      ),
    );
  }

  void _onBottomNavItemTapped(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Widget> pages = [
      FNOPage(),
      OrdersPage(),
      PortfolioFragmentPrev(),
      FragTradingHub(), // Settings page (placeholder)
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: pages[_currentPageIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.08),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentPageIndex,
          onTap: _onBottomNavItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
          backgroundColor: theme.scaffoldBackgroundColor,
          selectedLabelStyle:
              GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle:
              GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 12),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.visibility_outlined),
              activeIcon: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.visibility,
                  color: theme.colorScheme.primary,
                ),
              ),
              label: 'Watchlist',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_outlined),
              activeIcon: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.list_alt,
                  color: theme.colorScheme.primary,
                ),
              ),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.donut_small_outlined),
              activeIcon: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.donut_small,
                  color: theme.colorScheme.primary,
                ),
              ),
              label: 'Portfolio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wallet),
              activeIcon: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.wallet,
                  color: theme.colorScheme.primary,
                ),
              ),
              label: 'Trade Hub',
            ),
          ],
        ),
      ),
    );
  }
}
