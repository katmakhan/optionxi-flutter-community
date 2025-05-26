import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class TradingNewsPage extends StatefulWidget {
  @override
  _TradingNewsPageState createState() => _TradingNewsPageState();
}

class _TradingNewsPageState extends State<TradingNewsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<String> categories = [
    'All',
    'Nifty',
    'Stocks',
    'FnO',
    'BankNifty'
  ];
  String selectedCategory = 'All';

  final List<NewsArticle> newsArticles = [
    NewsArticle(
      title: "Bitcoin Surges Past \$50,000 Mark After ETF Approval",
      subtitle: "Major milestone reached as institutional adoption grows",
      category: "Crypto",
      author: "Sarah Johnson",
      timeAgo: DateTime.now().subtract(Duration(hours: 2)),
      imageUrl:
          "https://cdn.sanity.io/images/6raj1je8/production/3971957694356b52ce36a8fd2eb798e2010aa4b4-1024x1024.png?rect=0,224,1024,576&w=1200&h=675",
      readTime: "5 min read",
      isPremium: true,
    ),
    NewsArticle(
      title: "Fed Signals Potential Rate Changes in Coming Months",
      subtitle:
          "Market analysts predict significant impact on trading patterns",
      category: "Forex",
      author: "Michael Chen",
      timeAgo: DateTime.now().subtract(Duration(hours: 4)),
      imageUrl:
          "https://cdn.sanity.io/images/6raj1je8/production/3971957694356b52ce36a8fd2eb798e2010aa4b4-1024x1024.png?rect=0,224,1024,576&w=1200&h=675",
      readTime: "3 min read",
      isPremium: false,
    ),
    NewsArticle(
      title: "Tech Stocks Rally Amid AI Breakthroughs",
      subtitle: "Major tech companies report strong quarterly earnings",
      category: "Stocks",
      author: "Alex Rivera",
      timeAgo: DateTime.now().subtract(Duration(hours: 6)),
      imageUrl:
          "https://cdn.sanity.io/images/6raj1je8/production/3971957694356b52ce36a8fd2eb798e2010aa4b4-1024x1024.png?rect=0,224,1024,576&w=1200&h=675",
      readTime: "4 min read",
      isPremium: true,
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
    // Using Theme.of(context) to get the current theme
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            _buildCategoryFilter(theme),
            Expanded(
              child: _buildNewsList(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final textColor = theme.textTheme.bodyLarge?.color;
    final subtitleColor = theme.textTheme.titleSmall?.color;
    final borderColor = theme.dividerColor;

    return FadeTransition(
      opacity: _controller,
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: Icon(
                      Icons.navigate_before,
                      color: subtitleColor,
                    ),
                  ),
                ),
                Text(
                  "Market News",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: Icon(Icons.search, color: subtitleColor),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              "Stay updated with the latest market insights",
              style: TextStyle(
                color: subtitleColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(ThemeData theme) {
    final primaryColor = theme.colorScheme.primary;
    final borderColor = theme.dividerColor;
    final secondaryTextColor = theme.textTheme.titleSmall?.color;

    return Container(
      height: 40,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          return Container(
            margin: EdgeInsets.only(right: 12),
            child: FilterChip(
              selected: isSelected,
              label: Text(category),
              onSelected: (selected) {
                setState(() {
                  selectedCategory = category;
                });
              },
              backgroundColor: theme.cardColor,
              selectedColor: primaryColor,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : secondaryTextColor,
              ),
              side: BorderSide(
                color: isSelected ? primaryColor : borderColor,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewsList(ThemeData theme) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: newsArticles.length,
      itemBuilder: (context, index) {
        final article = newsArticles[index];
        return _buildNewsCard(article, index, theme);
      },
    );
  }

  Widget _buildNewsCard(NewsArticle article, int index, ThemeData theme) {
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;
    final borderColor = theme.dividerColor;
    final textColor = theme.textTheme.bodyLarge?.color;
    final subtitleColor = theme.textTheme.titleSmall?.color;

    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, 0.2),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            0.1 * index,
            0.1 * index + 0.6,
            curve: Curves.easeOut,
          ),
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  Image.network(
                    article.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  if (article.isPremium)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor, secondaryColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Premium',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          article.category,
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        timeago.format(article.timeAgo),
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 12,
                        ),
                      ),
                      Spacer(),
                      Text(
                        article.readTime,
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    article.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    article.subtitle,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: primaryColor,
                        child: Text(
                          article.author[0],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        article.author,
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.bookmark_border,
                          color: subtitleColor,
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.share_outlined,
                          color: subtitleColor,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewsArticle {
  final String title;
  final String subtitle;
  final String category;
  final String author;
  final DateTime timeAgo;
  final String imageUrl;
  final String readTime;
  final bool isPremium;

  NewsArticle({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.author,
    required this.timeAgo,
    required this.imageUrl,
    required this.readTime,
    required this.isPremium,
  });
}
