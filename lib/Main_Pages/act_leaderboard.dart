import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:optionxi/Theme/theme_controller.dart';

class LeaderboardPage extends StatefulWidget {
  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final ThemeController themeController = Get.find<ThemeController>();

  final List<LeaderboardEntry> leaderboardEntries = [
    LeaderboardEntry(
      rank: 1,
      username: "Madara",
      points: 12500,
      level: 42,
      imageUrl:
          "https://static1.cbrimages.com/wordpress/wp-content/uploads/2020/05/madara-uchiha-naruto-featured.jpg",
    ),
    LeaderboardEntry(
      rank: 2,
      username: "StockMaster",
      points: 11000,
      level: 42,
      imageUrl:
          "https://static1.cbrimages.com/wordpress/wp-content/uploads/2020/05/madara-uchiha-naruto-featured.jpg",
    ),
    LeaderboardEntry(
      rank: 3,
      username: "NineTails",
      points: 9800,
      level: 39,
      imageUrl:
          "https://static1.cbrimages.com/wordpress/wp-content/uploads/2020/05/madara-uchiha-naruto-featured.jpg",
    ),
    LeaderboardEntry(
      rank: 4,
      username: "Jiraiya",
      points: 8500,
      level: 35,
      imageUrl:
          "https://static1.cbrimages.com/wordpress/wp-content/uploads/2020/05/madara-uchiha-naruto-featured.jpg",
    ),
    LeaderboardEntry(
      rank: 5,
      username: "Nikhil",
      points: 7200,
      level: 33,
      imageUrl:
          "https://static1.cbrimages.com/wordpress/wp-content/uploads/2020/05/madara-uchiha-naruto-featured.jpg",
    ),
  ];

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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildLeaderboardList(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // Get responsive sizes
    final isTablet = MediaQuery.of(context).size.width > 600;
    final fontSize = isTablet ? 32.0 : 28.0;
    final descriptionSize = isTablet ? 18.0 : 16.0;
    final padding = isTablet ? 24.0 : 20.0;

    return FadeTransition(
      opacity: _controller,
      child: Container(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Theme.of(context).dividerColor, width: 1),
                    ),
                    child: Icon(Icons.navigate_before,
                        color: Theme.of(context).textTheme.titleSmall?.color),
                  ),
                ),
                SizedBox(width: 20),
                Text(
                  "Leaderboard",
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              "Where each traders are ranked according to their performance in virtual trading, this does not represent real trades.",
              style: TextStyle(
                color: Theme.of(context).textTheme.titleSmall?.color,
                fontSize: descriptionSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardList(BuildContext context) {
    // Add responsiveness for tablet/desktop
    final isTablet = MediaQuery.of(context).size.width > 600;
    final padding = isTablet ? 16.0 : 8.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: ListView.builder(
        itemCount: leaderboardEntries.length,
        itemBuilder: (context, index) {
          final entry = leaderboardEntries[index];
          return ModernLeaderboardCard(
            entry: entry,
            index: index,
            controller: _controller,
          );
        },
      ),
    );
  }
}

// Update LeaderboardCard to be theme-aware
class ModernLeaderboardCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final int index;
  final AnimationController controller;

  const ModernLeaderboardCard({
    Key? key,
    required this.entry,
    required this.index,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Staggered animation for card appearance
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          index * 0.1,
          0.1 + index * 0.1,
          curve: Curves.easeOut,
        ),
      ),
    );

    // Make card responsive
    final isTablet = MediaQuery.of(context).size.width > 600;
    final cardPadding = isTablet ? 16.0 : 12.0;
    final fontSize = isTablet ? 18.0 : 16.0;
    final rankSize = isTablet ? 32.0 : 28.0;
    final avatarSize = isTablet ? 60.0 : 50.0;

    // Color based on rank
    Color getRankColor() {
      switch (entry.rank) {
        case 1:
          return Colors.amber;
        case 2:
          return Colors.grey.shade400;
        case 3:
          return Colors.brown.shade300;
        default:
          return Theme.of(context).colorScheme.primary.withValues(alpha: 0.7);
      }
    }

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.5),
          end: Offset.zero,
        ).animate(animation),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(cardPadding),
              child: Row(
                children: [
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: getRankColor().withValues(alpha: 0.2),
                    ),
                    child: Center(
                      child: Text(
                        "${entry.rank}",
                        style: TextStyle(
                          fontSize: rankSize,
                          fontWeight: FontWeight.bold,
                          color: getRankColor(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.username,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Level ${entry.level}",
                          style: TextStyle(
                            fontSize: fontSize - 2,
                            color:
                                Theme.of(context).textTheme.titleSmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${entry.points.toStringAsFixed(0)} pts",
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Add the LeaderboardEntry model if not already defined elsewhere
class LeaderboardEntry {
  final int rank;
  final String username;
  final double points;
  final int level;
  final String imageUrl;

  LeaderboardEntry({
    required this.rank,
    required this.username,
    required this.points,
    required this.level,
    required this.imageUrl,
  });
}
