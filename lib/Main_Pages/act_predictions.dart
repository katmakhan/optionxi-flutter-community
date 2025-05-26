import 'package:flutter/material.dart';
import 'package:optionxi/Components/custom_user_prediction.dart';
import 'package:optionxi/Theme/theme_controller.dart';

class PredictionPage extends StatefulWidget {
  @override
  _PredictionPageState createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<String> categories = [
    'All',
    'FnO',
    'Stocks',
    'Nifty',
    'BankNIfty'
  ];
  String selectedCategory = 'All';
  final themeController = ThemeController.instance;

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
            _buildHeader(),
            _buildCategoryFilter(),
            Expanded(
              child: _buildTradingIdeaList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTradingIdeaList() {
    final List<Map<String, dynamic>> stockPredictions = [
      {
        'symbol': 'AAPL',
        'name': 'Apple Inc. Strategy',
        'description':
            'Apple Inc. is showing strong bullish momentum with increased institutional buying.',
        'winRate': '85%',
        'accentColor': Colors.green,
        'userName': 'John Doe',
        'profilePicUrl':
            'https://i.pinimg.com/736x/11/46/54/114654efd2169c3ad5992c5df959dcef.jpg',
        'time': '2 hours ago',
        'timeAgo': '2 hours ago',
        'userCategory': 'Expert',
        'movement': 1.2,
        'supportLevel': 178.50,
        'resistanceLevel': 185.30,
        'entryPoint': 180.00,
        'sentiment': 'Bullish',
      },
      {
        'symbol': 'TSLA',
        'name': 'Tesla Strategy',
        'description':
            'Tesla is under pressure due to supply chain issues. Watch for support levels.',
        'winRate': '70%',
        'accentColor': Colors.red,
        'userName': 'Jane Smith',
        'profilePicUrl':
            'https://i.pinimg.com/736x/11/46/54/114654efd2169c3ad5992c5df959dcef.jpg',
        'time': '5 hours ago',
        'timeAgo': '5 hours ago',
        'userCategory': 'Intermediate',
        'movement': -2.5,
        'supportLevel': 198.00,
        'resistanceLevel': 215.00,
        'entryPoint': 200.00,
        'sentiment': 'Bearish',
      },
      {
        'symbol': 'BTCUSD',
        'name': 'Bitcoin Strategy',
        'description':
            'Bitcoin is consolidating, forming a potential breakout pattern.',
        'winRate': '90%',
        'accentColor': Colors.blue,
        'userName': 'Alex Lee',
        'profilePicUrl':
            'https://i.pinimg.com/736x/11/46/54/114654efd2169c3ad5992c5df959dcef.jpg',
        'time': '1 day ago',
        'timeAgo': '1 day ago',
        'userCategory': 'Advanced',
        'movement': 3.8,
        'supportLevel': 62000.00,
        'resistanceLevel': 68000.00,
        'entryPoint': 63500.00,
        'sentiment': 'Bullish',
      },
    ];

    return ListView.builder(
      itemCount: stockPredictions.length,
      itemBuilder: (context, index) {
        final data = stockPredictions[index];

        return StockAnalysisCard(
          symbol: data['symbol'],
          analysis: data['description'],
          movement: data['movement'],
          supportLevel: data['supportLevel'],
          resistanceLevel: data['resistanceLevel'],
          entryPoint: data['entryPoint'],
          sentiment: data['sentiment'],
          userName: data['userName'],
          profilePicUrl: data['profilePicUrl'],
          time: data['time'],
          timeAgo: data['timeAgo'],
          userCategory: data['userCategory'],
          onTap: () {
            // Handle onTap event (e.g., navigate to details page)
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        padding: EdgeInsets.all(20),
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
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.navigate_before,
                      color: Theme.of(context).textTheme.titleSmall?.color,
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                  "Traders Predictions",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              "Stay updated with the latest market insights",
              style: TextStyle(
                color: Theme.of(context).textTheme.titleSmall?.color,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
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
              backgroundColor: Theme.of(context).cardColor,
              selectedColor: Theme.of(context).colorScheme.primary,
              checkmarkColor: Theme.of(context).colorScheme.onPrimary,
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).textTheme.titleSmall?.color,
              ),
              side: BorderSide(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).dividerColor,
              ),
            ),
          );
        },
      ),
    );
  }
}
