import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class TraderProfilePage extends StatefulWidget {
  const TraderProfilePage({Key? key}) : super(key: key);

  @override
  State<TraderProfilePage> createState() => _TraderProfilePageState();
}

class _TraderProfilePageState extends State<TraderProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final subtitleColor =
        theme.textTheme.titleSmall?.color ?? Colors.grey[400]!;

    return Scaffold(
      body: DefaultTabController(
        length: 4,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 100,
                floating: false,
                pinned: true,
                backgroundColor: backgroundColor,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/733b5da9-efe6-4697-a4f9-9e9d4975f828/de8g75a-a128f1ac-ec63-4485-b913-3b0f00fb9b63.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcLzczM2I1ZGE5LWVmZTYtNDY5Ny1hNGY5LTllOWQ0OTc1ZjgyOFwvZGU4Zzc1YS1hMTI4ZjFhYy1lYzYzLTQ0ODUtYjkxMy0zYjBmMDBmYjliNjMuanBnIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.fPT4Y-EkXONFPgkECDHazkxjlCs1ipyyO1XE_K7aRCM',
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              backgroundColor.withValues(alpha: 0.9),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _buildProfileHeader(),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: primaryColor,
                    unselectedLabelColor: subtitleColor,
                    indicatorColor: primaryColor,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    tabs: const [
                      Tab(text: 'Profile'),
                      Tab(text: 'Ideas'),
                      Tab(text: 'Trades'),
                      Tab(text: 'Analytics'),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _ProfileTab(),
              _TradeIdeasTab(),
              _LatestTradesTab(),
              _AnalyticsTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final textColor = theme.colorScheme.onBackground;
    final subtitleColor = theme.textTheme.titleSmall?.color;

    return Container(
      padding: const EdgeInsets.all(24),
      color: theme.scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryColor, width: 3),
                  image: const DecorationImage(
                    image: NetworkImage(
                        'https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/733b5da9-efe6-4697-a4f9-9e9d4975f828/de8g75a-a128f1ac-ec63-4485-b913-3b0f00fb9b63.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcLzczM2I1ZGE5LWVmZTYtNDY5Ny1hNGY5LTllOWQ0OTc1ZjgyOFwvZGU4Zzc1YS1hMTI4ZjFhYy1lYzYzLTQ0ODUtYjkxMy0zYjBmMDBmYjliNjMuanBnIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.fPT4Y-EkXONFPgkECDHazkxjlCs1ipyyO1XE_K7aRCM'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alex Trading Pro',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@alextrader',
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              _buildFollowButton(),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Professional crypto trader with 5 years of experience. Specializing in technical analysis and swing trading.',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: textColor.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 24),
          _buildStats(),
        ],
      ),
    );
  }

  Widget _buildFollowButton() {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            isFollowing = !isFollowing;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isFollowing ? theme.colorScheme.surface : primaryColor,
          foregroundColor: isFollowing
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          isFollowing ? 'Following' : 'Follow',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildStats() {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Win Rate', '76%'),
          _buildVerticalDivider(),
          _buildStatItem('Followers', '12.4K'),
          _buildVerticalDivider(),
          _buildStatItem('Posts', '1.2K'),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Theme.of(context).dividerColor,
    );
  }

  Widget _buildStatItem(String label, String value) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onBackground;
    final subtitleColor = theme.textTheme.titleSmall?.color;

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: subtitleColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSection(
          'Trading Style',
          'Swing Trader focusing on technical analysis and market psychology',
          Icons.show_chart,
        ),
        _buildSection(
          'Experience',
          '5+ years in crypto trading',
          Icons.timeline,
        ),
        _buildSection(
          'Preferred Markets',
          'BTC, ETH, Major Altcoins',
          Icons.currency_bitcoin,
        ),
        _buildSection(
          'Risk Management',
          'Uses strict stop losses and position sizing based on market volatility',
          Icons.security,
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Builder(builder: (context) {
      final theme = Theme.of(context);
      final primaryColor = theme.colorScheme.primary;
      final cardColor = theme.cardColor;
      final textColor = theme.colorScheme.onBackground;

      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: textColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _TradeIdeasTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        final theme = Theme.of(context);
        final primaryColor = theme.colorScheme.primary;
        final cardColor = theme.cardColor;
        final textColor = theme.colorScheme.onBackground;
        final subtitleColor =
            theme.textTheme.titleSmall?.color ?? Colors.grey[400]!;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'BTC/USD',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '2h ago',
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Long Opportunity',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Looking for a potential breakout above the 200-day moving average. Key resistance levels to watch at \$48,500.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: textColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    _buildInteractionButton(
                      Icons.thumb_up_outlined,
                      '124',
                      () {},
                    ),
                    const SizedBox(width: 24),
                    _buildInteractionButton(
                      Icons.comment_outlined,
                      '38',
                      () {},
                    ),
                    const SizedBox(width: 24),
                    _buildInteractionButton(
                      Icons.share_outlined,
                      'Share',
                      () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInteractionButton(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Builder(builder: (context) {
      final subtitleColor =
          Theme.of(context).textTheme.titleSmall?.color ?? Colors.grey[400]!;

      return InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: subtitleColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: subtitleColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _LatestTradesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        final theme = Theme.of(context);
        final cardColor = theme.cardColor;
        final textColor = theme.colorScheme.onBackground;
        final subtitleColor =
            theme.textTheme.titleSmall?.color ?? Colors.grey[400]!;

        final bool isProfitable = index % 2 == 0;
        final profitColor = isProfitable ? Colors.green : Colors.red;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: profitColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'CLOSED',
                            style: TextStyle(
                              color: profitColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'BTC/USD',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          isProfitable ? '+12.5%' : '-5.2%',
                          style: TextStyle(
                            color: profitColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildTradeDetail(
                              context, 'Entry', '\$45,230', Icons.login),
                          _buildTradeDetail(
                              context, 'Exit', '\$50,883', Icons.logout),
                          _buildTradeDetail(
                              context, 'Duration', '3d 5h', Icons.access_time),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: subtitleColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Swing Trade',
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '2 days ago',
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTradeDetail(
      BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final textColor = theme.colorScheme.onBackground;
    final subtitleColor =
        theme.textTheme.titleSmall?.color ?? Colors.grey[400]!;

    return Column(
      children: [
        Icon(
          icon,
          color: primaryColor,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: subtitleColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildAnalyticsCard(
          context,
          'Performance Overview',
          Column(
            children: [
              _buildMetricRow(context, 'Total Trades', '156'),
              _buildMetricRow(context, 'Win Rate', '76%'),
              _buildMetricRow(context, 'Avg. Return', '8.4%'),
              _buildMetricRow(context, 'Best Trade', '+45.2%'),
              const SizedBox(height: 20),
              SizedBox(
                height: 300,
                child: _buildPerformanceChart(context),
              ),
            ],
          ),
          Icons.analytics,
        ),
        const SizedBox(height: 20),
        _buildAnalyticsCard(
          context,
          'Trade Distribution',
          Column(
            children: [
              _buildMetricRow(context, 'Crypto', '65%'),
              _buildMetricRow(context, 'Forex', '25%'),
              _buildMetricRow(context, 'Stocks', '10%'),
              const SizedBox(height: 20),
              SizedBox(
                height: 300,
                child: _buildDistributionChart(),
              ),
            ],
          ),
          Icons.pie_chart,
        ),
        const SizedBox(height: 20),
        _buildAnalyticsCard(
          context,
          'Monthly Returns',
          SizedBox(
            height: 300,
            child: _buildMonthlyReturnsChart(),
          ),
          Icons.bar_chart,
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(
      BuildContext context, String title, Widget content, IconData icon) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final cardColor = theme.cardColor;
    final textColor = theme.colorScheme.onBackground;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onBackground;
    final subtitleColor =
        theme.textTheme.titleSmall?.color ?? Colors.grey[400]!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: subtitleColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart(BuildContext context) {
    final List<PerformanceData> performanceData = [
      PerformanceData(DateTime(2024, 1), 1000),
      PerformanceData(DateTime(2024, 2), 1250),
      PerformanceData(DateTime(2024, 3), 1180),
      PerformanceData(DateTime(2024, 4), 1400),
      PerformanceData(DateTime(2024, 5), 1680),
      PerformanceData(DateTime(2024, 6), 1580),
    ];

    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      backgroundColor: Colors.transparent,
      primaryXAxis: DateTimeAxis(
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 1, color: Colors.grey),
        labelStyle: const TextStyle(color: Colors.grey),
        // title: AxisTitle(
        //   text: 'Time Period',
        //   textStyle: const TextStyle(color: Colors.grey),
        // ),
      ),
      primaryYAxis: NumericAxis(
        majorGridLines: MajorGridLines(
          width: 1,
          color: Colors.grey.withValues(alpha: 0.2),
          dashArray: const [5, 5],
        ),
        axisLine: const AxisLine(width: 1, color: Colors.grey),
        labelStyle: const TextStyle(color: Colors.grey),
        // title: AxisTitle(
        //   text: 'Portfolio Value (\$)',
        //   textStyle: const TextStyle(color: Colors.grey),
        // ),
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        color: const Color(0xFF333333),
        textStyle: const TextStyle(color: Colors.white),
      ),
      zoomPanBehavior: ZoomPanBehavior(
        enablePinching: true,
        enablePanning: true,
        enableDoubleTapZooming: true,
      ),
      series: <CartesianSeries>[
        SplineAreaSeries<PerformanceData, DateTime>(
          dataSource: performanceData,
          xValueMapper: (PerformanceData data, _) => data.date,
          yValueMapper: (PerformanceData data, _) => data.value,
          gradient: LinearGradient(
            colors: [
              const Color(0xFF2196F3).withValues(alpha: 0.4),
              const Color(0xFF2196F3).withValues(alpha: 0.1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderWidth: 3,
          borderColor: const Color(0xFF2196F3),
          animationDuration: 1500,
        ),
      ],
    );
  }

  Widget _buildDistributionChart() {
    final List<TradeDistribution> distributionData = [
      TradeDistribution('Crypto', 65, const Color(0xFF2196F3)),
      TradeDistribution('Forex', 25, const Color(0xFF4CAF50)),
      TradeDistribution('Stocks', 10, const Color(0xFFFFA726)),
    ];

    return SfCircularChart(
      backgroundColor: Colors.transparent,
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        textStyle: const TextStyle(color: Colors.grey),
        overflowMode: LegendItemOverflowMode.wrap,
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        color: const Color(0xFF333333),
        textStyle: const TextStyle(color: Colors.white),
      ),
      series: <CircularSeries>[
        DoughnutSeries<TradeDistribution, String>(
          dataSource: distributionData,
          xValueMapper: (TradeDistribution data, _) => data.category,
          yValueMapper: (TradeDistribution data, _) => data.percentage,
          pointColorMapper: (TradeDistribution data, _) => data.color,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
            textStyle: TextStyle(color: Colors.white),
          ),
          enableTooltip: true,
          animationDuration: 1500,
          innerRadius: '60%',
          radius: '80%',
        ),
      ],
    );
  }

  Widget _buildMonthlyReturnsChart() {
    final List<MonthlyReturn> monthlyData = [
      MonthlyReturn('Jan', 5.2),
      MonthlyReturn('Feb', -2.1),
      MonthlyReturn('Mar', 7.8),
      MonthlyReturn('Apr', 3.4),
      MonthlyReturn('May', -1.5),
      MonthlyReturn('Jun', 6.2),
    ];

    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      backgroundColor: Colors.transparent,
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 1, color: Colors.grey),
        labelStyle: const TextStyle(color: Colors.grey),
      ),
      primaryYAxis: NumericAxis(
        majorGridLines: MajorGridLines(
          width: 1,
          color: Colors.grey.withValues(alpha: 0.2),
          dashArray: const [5, 5],
        ),
        axisLine: const AxisLine(width: 1, color: Colors.grey),
        labelStyle: const TextStyle(color: Colors.grey),
        title: AxisTitle(
          text: 'Return (%)',
          textStyle: const TextStyle(color: Colors.grey),
        ),
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        color: const Color(0xFF333333),
        textStyle: const TextStyle(color: Colors.white),
      ),
      series: <CartesianSeries>[
        ColumnSeries<MonthlyReturn, String>(
          dataSource: monthlyData,
          xValueMapper: (MonthlyReturn data, _) => data.month,
          yValueMapper: (MonthlyReturn data, _) => data.return_,
          pointColorMapper: (MonthlyReturn data, _) => data.return_ >= 0
              ? const Color(0xFF4CAF50)
              : const Color(0xFFF44336),
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.outer,
            textStyle: TextStyle(color: Colors.white),
          ),
          borderRadius: BorderRadius.circular(4),
          animationDuration: 1500,
          width: 0.6,
        ),
      ],
    );
  }
}

// Data models remain the same
class PerformanceData {
  final DateTime date;
  final double value;

  PerformanceData(this.date, this.value);
}

class TradeDistribution {
  final String category;
  final double percentage;
  final Color color;

  TradeDistribution(this.category, this.percentage, this.color);
}

class MonthlyReturn {
  final String month;
  final double return_;

  MonthlyReturn(this.month, this.return_);
}
