import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:optionxi/Auth_Service/auth_service.dart';
import 'package:optionxi/Helpers/open_url.dart';
import 'package:optionxi/Main_Pages/act_news.dart';
import 'package:optionxi/Main_Pages/act_portfolio.dart';
import 'package:optionxi/Main_Pages/act_predictions.dart';
import 'package:optionxi/Main_Pages/act_traderprofile.dart';
import 'package:optionxi/Main_Pages/act_tradingideas.dart';
import 'package:optionxi/MobileLink/link_phone_screen.dart';
import 'package:optionxi/Theme/theme_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class TradingProfilePage extends StatefulWidget {
  @override
  _TradingProfilePageState createState() => _TradingProfilePageState();
}

class _TradingProfilePageState extends State<TradingProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(theme),
              // _buildProfileStats(theme),
              _buildOptionsLists(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor;

    return FadeTransition(
      opacity: _controller,
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => TraderProfilePage()),
                // );
              },
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [primaryColor, secondaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: cardColor, width: 4),
                    ),
                    child: FirebaseAuth.instance.currentUser != null &&
                            FirebaseAuth.instance.currentUser!.photoURL != null
                        ? Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [primaryColor, secondaryColor],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(60),
                            ),
                            padding: EdgeInsets.all(2),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: backgroundColor,
                              backgroundImage: NetworkImage(
                                  FirebaseAuth.instance.currentUser!.photoURL!),
                            ),
                          )
                        : Icon(Icons.person,
                            size: 60, color: theme.colorScheme.onPrimary),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.edit,
                        size: 20, color: theme.colorScheme.onPrimary),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              FirebaseAuth.instance.currentUser?.displayName ?? "OptionXi",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Professional Trader",
              style: TextStyle(
                color: theme.colorScheme.onBackground.withValues(alpha: 0.6),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStats(ThemeData theme) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(0.2, 0.4, curve: Curves.easeOut),
      )),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(
                "Total Profit", "\₹15,234", Icons.trending_up, theme),
            _buildStatItem("Win Rate", "76%", Icons.auto_graph, theme),
            _buildStatItem(
                "Total Trades", "142", Icons.currency_exchange, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, ThemeData theme) {
    final borderColor = theme.brightness == Brightness.dark
        ? Colors.grey[850]
        : Colors.grey[300];

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor!, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onBackground.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsLists(ThemeData theme) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(0.4, 0.6, curve: Curves.easeOut),
      )),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _buildSection(
            //     "Trading",
            //     [
            //       OptionItem("Portfolio Overview", Icons.account_balance_wallet,
            //           badgeText: "New", onTap: goToPortfolioPage),
            //       OptionItem("Active Positions", Icons.candlestick_chart,
            //           onTap: goToTradersPredictions),
            //       OptionItem("Trading History", Icons.history,
            //           onTap: goToTradingIdeas),
            //       OptionItem("Risk Management", Icons.shield,
            //           onTap: goToMarketNews),
            //     ],
            //     theme),
            _buildSection(
                "Account",
                [
                  OptionItem(
                    "Verification Status",
                    Icons.verified,
                    trailing: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Verified",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LinkPhoneScreen()),
                      );
                    },
                  ),
                  // OptionItem("Payment Methods", Icons.payment),
                  OptionItem(
                    "Logout",
                    Icons.key,
                    onTap: () {
                      AuthService().logOut();
                    },
                  ),
                  // OptionItem("Security Settings", Icons.security),
                ],
                theme),
            _buildSection(
                "Preferences",
                [
                  // OptionItem("Notifications", Icons.notifications_outlined),
                  OptionItem("Webview", Icons.language, onTap: () {
                    OpenHelper.open_url("https://app.optionxi.com");
                  }),
                  OptionItem(
                    "Dark Mode",
                    ThemeController.instance.isDarkMode
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    trailing: GetBuilder<ThemeController>(
                      builder: (controller) {
                        return Switch(
                          value: controller.isDarkMode,
                          onChanged: (value) => controller.toggleTheme(),
                          activeColor: theme.colorScheme.primary,
                        );
                      },
                    ),
                  ),
                  OptionItem("Customer Support", Icons.help_outline,
                      onTap: () async {
                    final Uri emailLaunchUri = Uri(
                      scheme: 'mailto',
                      path: 'optionxi24@gmail.com',
                      // Optional query parameters:
                      queryParameters: {
                        'subject': 'Your Subject',
                        'body': 'Hello, this is the body of the email.'
                      },
                    );

                    if (await canLaunchUrl(emailLaunchUri)) {
                      await launchUrl(emailLaunchUri);
                    } else {
                      print('Could not launch email client');
                    }
                  }),
                ],
                theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<OptionItem> items, ThemeData theme) {
    final borderColor = theme.brightness == Brightness.dark
        ? Colors.grey[850]
        : Colors.grey[300];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor!, width: 1),
          ),
          child: Column(
            children:
                items.map((item) => _buildOptionItem(item, theme)).toList(),
          ),
        ),
      ],
    );
  }

  void changetoLightandDarkMode() {
    final themeController = Get.find<ThemeController>();
    themeController.toggleTheme();
  }

  Widget _buildOptionItem(OptionItem item, ThemeData theme) {
    final borderColor = theme.brightness == Brightness.dark
        ? Colors.grey[850]
        : Colors.grey[300];

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: borderColor!,
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            item.icon,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            color: theme.colorScheme.onBackground,
            fontSize: 16,
          ),
        ),
        trailing: item.trailing ??
            (item.badgeText != null
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.badgeText!,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 12,
                      ),
                    ),
                  )
                : Icon(Icons.chevron_right,
                    color:
                        theme.colorScheme.onBackground.withValues(alpha: 0.6))),
        onTap: item.onTap,
      ),
    );
  }

  void goToPortfolioPage() {
    //Go to OTP entering Page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PortfolioPage()),
    );
  }

  void goToMarketNews() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => TradingNewsPage()));
  }

  void goToTradersPredictions() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => PredictionPage()));
  }

  void goToTradingIdeas() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => TradingIdeasPage()));
  }
}

class OptionItem {
  final String title;
  final IconData icon;
  final String? badgeText;
  final Widget? trailing;
  final VoidCallback? onTap;

  OptionItem(this.title, this.icon,
      {this.badgeText, this.trailing, this.onTap});
}
