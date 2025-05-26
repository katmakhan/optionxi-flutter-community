import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:optionxi/Components/custom_searchbar.dart';
import 'package:optionxi/Helpers/global_snackbar_get.dart';
import 'package:optionxi/Main_Pages/act_leaderboard.dart';
import 'package:optionxi/Main_Pages/act_search_stocks.dart';
import 'package:optionxi/Main_Pages/act_traderprofile.dart';
import 'package:optionxi/Main_Pages/act_tradingideas.dart';
import 'package:optionxi/Main_Pages/cust_top_stocks_component.dart';
import 'package:optionxi/Theme/theme_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class TradingHomeScreen extends StatefulWidget {
  @override
  _TradingHomeScreenState createState() => _TradingHomeScreenState();
}

class _TradingHomeScreenState extends State<TradingHomeScreen>
    with TickerProviderStateMixin {
  final String username =
      FirebaseAuth.instance.currentUser?.displayName ?? "OptionXi";

  late AnimationController _controller;
  late TabController _tabController;
  final ThemeController themeController = Get.put(ThemeController());

  final List<GroupData> yourGroups = [
    GroupData(
      name: "Nifty and Bank",
      memberCount: 11,
      activityCount: "110+ trades",
      color: Color(0xFF2962FF),
      isLeader: true,
    ),
    GroupData(
      name: "Nifty 50 Stocks",
      memberCount: 8,
      activityCount: "130+ trades",
      color: Color(0xFF6200EA),
      isLeader: true,
    ),
    GroupData(
      name: "Nifty 200 Stocks",
      memberCount: 8,
      activityCount: "130+ trades",
      color: Color(0xFF2962FF),
      isLeader: true,
    ),
    GroupData(
      name: "FnO Stocks",
      memberCount: 8,
      activityCount: "130+ trades",
      color: Color(0xFF6200EA),
      isLeader: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
    _tabController = TabController(length: 2, vsync: this);
    // themeController.initTheme();
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'About Signal Count',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The signal count represents the number of technical screeners that have identified this stock with a bullish/bearish trend.',
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 12),
              Text(
                'A higher signal count indicates stronger consensus across multiple technical indicators, suggesting a higher probability of price movement in the bullish/bearish direction.',
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 12),
              const Text(
                'This metric combines various technical analyses to provide a comprehensive view of market sentiment, helping you identify stocks with the strongest directional signals.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeTransition(
                      opacity: Tween<double>(begin: 0, end: 1).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Interval(0.0, 0.2, curve: Curves.easeOut),
                        ),
                      ),
                      child: _buildHeader(),
                    ),
                    const SizedBox(height: 24),
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Interval(0.1, 0.3, curve: Curves.easeOut),
                        ),
                      ),
                      child: FadeTransition(
                        opacity: Tween<double>(begin: 0, end: 1).animate(
                          CurvedAnimation(
                            parent: _controller,
                            curve: Interval(0.1, 0.3, curve: Curves.easeOut),
                          ),
                        ),
                        child: _buildTitle(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Interval(0.2, 0.4, curve: Curves.easeOut),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        StockSearchPage(false)),
                              );
                            },
                            child: AbsorbPointer(
                              child: ModernSearchBar(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // SlideTransition(
                    //   position: Tween<Offset>(
                    //     begin: Offset(0, 0.2),
                    //     end: Offset.zero,
                    //   ).animate(
                    //     CurvedAnimation(
                    //       parent: _controller,
                    //       curve: Interval(0.3, 0.5, curve: Curves.easeOut),
                    //     ),
                    //   ),
                    //   child: _buildYourGroupsSection(),
                    // ),
                    const SizedBox(height: 24),
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0, 0.8),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Interval(0.3, 0.5, curve: Curves.easeOut),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Trending Stocks",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontSize: 20,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Header
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0, 0.9),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Interval(0.3, 0.5, curve: Curves.easeOut),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Good for multi-line text alignment

                        children: [
                          Expanded(
                            child: Text(
                              'These stock selections are filtered using technical indicators and are provided for educational purposes only. They do not constitute financial advice.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: _showInfoDialog,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildStocksTabSection(),
                    const SizedBox(height: 24),
                    InkWell(
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
                        },
                        child: _buildCtaSection()),
                    const SizedBox(height: 24),
                    // SlideTransition(
                    //   position: Tween<Offset>(
                    //     begin: Offset(0, 0.2),
                    //     end: Offset.zero,
                    //   ).animate(
                    //     CurvedAnimation(
                    //       parent: _controller,
                    //       curve: Interval(0.4, 0.6, curve: Curves.easeOut),
                    //     ),
                    //   ),
                    //   child: _buildOtherGroupsSection(),
                    // ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStocksTabSection() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            tabs: const [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.trending_up, size: 20),
                    SizedBox(width: 8),
                    Text('Bullish'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.trending_down, size: 20),
                    SizedBox(width: 8),
                    Text('Bearish'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: _tabController,
          builder: (context, _) {
            return IndexedStack(
              index: _tabController.index,
              children: const [
                TopStocksHeatMap(category: 'bullish'),
                TopStocksHeatMap(category: 'bearish'),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.currency_exchange, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(
                "OptionXi",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildIconButton(Icons.notifications_outlined),
              const SizedBox(width: 8),
              Obx(() => _buildIconButton(
                    themeController.isDarkMode
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    onPressed: () => themeController.toggleTheme(),
                  )),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => TraderProfilePage()),
                  // );
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.all(2),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    backgroundImage:
                        FirebaseAuth.instance.currentUser?.photoURL != null
                            ? NetworkImage(
                                FirebaseAuth.instance.currentUser!.photoURL!)
                            : const AssetImage('assets/images/option_xi_w.png')
                                as ImageProvider,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, {VoidCallback? onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed ??
            () {
              // GlobalSnackBarGet().showGetSucess(
              //     "Comming Soon", "Please wait while our team iworks on it");
            },
        color: Theme.of(context).iconTheme.color,
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hey, $username 👋",
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Text(
          "Simple, Fast Trading\nOpen Source",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 28,
                height: 1.2,
              ),
        ),
      ],
    );
  }

  Widget _buildYourGroupsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Trading Communities",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                  ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TradingIdeasPage()));
              },
              child: Text(
                "See All",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: yourGroups.length,
            itemBuilder: (context, index) {
              return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TradingIdeasPage()));
                  },
                  child: _buildGroupCard(yourGroups[index], index));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGroupCard(GroupData group, int index) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0.2, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve:
              Interval(0.1 * index, 0.1 * index + 0.2, curve: Curves.easeOut),
        ),
      ),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [group.color, group.color.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: group.color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    group.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (group.isLeader)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.yellow, size: 16),
                    SizedBox(width: 4),
                    Text(
                      "Leader",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 72,
                  height: 24,
                  child: Stack(
                    children: [
                      for (var i = 0; i < 3; i++)
                        Positioned(
                          left: i * 20.0,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: group.color, width: 2),
                              shape: BoxShape.circle,
                            ),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.person,
                                  size: 16, color: Colors.black87),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  "+${group.memberCount}",
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                group.activityCount,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCtaSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Ready to Deploy Your Algorithm?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Get started with our professional trading infrastructure and deploy your strategies at scale.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
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
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Contact Support",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // TextButton(
              //   onPressed: () {},
              //   child: Row(
              //     children: [
              //       Text(
              //         "Learn More",
              //         style: TextStyle(
              //           color: Colors.white,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //       const SizedBox(width: 8),
              //       Icon(
              //         Icons.arrow_forward,
              //         color: Colors.white,
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOtherGroupsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Intraday Leaderboard",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                  ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LeaderboardPage()));
              },
              child: Text(
                "See All",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TraderProfilePage()),
            );
          },
          child: _buildOtherGroupItem(
            "Jibin Victor",
            "Member",
            Icons.person_4_rounded,
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TraderProfilePage()),
            );
          },
          child: _buildOtherGroupItem(
            "Madara Uchiha",
            "Elite Member",
            Icons.person_4_rounded,
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TraderProfilePage()),
            );
          },
          child: _buildOtherGroupItem(
            "Ittachi",
            "Member",
            Icons.person_4_rounded,
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TraderProfilePage()),
            );
          },
          child: _buildOtherGroupItem(
            "Izuna",
            "Member",
            Icons.person_4_rounded,
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TraderProfilePage()),
            );
          },
          child: _buildOtherGroupItem(
            "Konan",
            "Elite Member",
            Icons.person_4_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildOtherGroupItem(String name, String role, IconData icon) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon,
                color: Theme.of(context).colorScheme.onPrimary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    role,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.more_horiz,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GroupData {
  final String name;
  final int memberCount;
  final String activityCount;
  final Color color;
  final bool isLeader;

  GroupData({
    required this.name,
    required this.memberCount,
    required this.activityCount,
    required this.color,
    required this.isLeader,
  });
}
