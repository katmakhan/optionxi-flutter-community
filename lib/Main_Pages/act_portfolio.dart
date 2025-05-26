import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartData {
  ChartData(this.x, this.y);
  final DateTime x;
  final double y;
}

class PortfolioPage extends StatefulWidget {
  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<ChartData> chartData = [
    ChartData(DateTime(2024, 1), 3000),
    ChartData(DateTime(2024, 2), 2800),
    ChartData(DateTime(2024, 3), 3500),
    ChartData(DateTime(2024, 4), 3100),
    ChartData(DateTime(2024, 5), 4000),
    ChartData(DateTime(2024, 6), 3800),
    ChartData(DateTime(2024, 7), 4200),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final backgroundColor = Theme.of(context).colorScheme.background;
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[700];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark, surfaceColor, textColor, subtitleColor),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPortfolioOverview(
                        primaryColor, secondaryColor, onSurfaceColor),
                    SizedBox(height: 24),
                    _buildPerformanceChart(isDark, surfaceColor, primaryColor,
                        secondaryColor, textColor, subtitleColor),
                    SizedBox(height: 24),
                    _buildMetricsGrid(
                        isDark, surfaceColor, textColor, subtitleColor),
                    SizedBox(height: 24),
                    _buildPositions(
                        isDark, surfaceColor, textColor, subtitleColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      bool isDark, Color surfaceColor, Color textColor, Color? subtitleColor) {
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
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isDark ? Colors.grey[850]! : Colors.grey[300]!,
                          width: 1),
                    ),
                    child: Icon(Icons.navigate_before,
                        color: isDark ? Colors.grey[400] : Colors.grey[700]),
                  ),
                ),
                SizedBox(width: 20),
                Text(
                  "Portfolio",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              "Where each traders are ranked according to their performance in virtual trading, this does not represent real trades.",
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

  Widget _buildPortfolioOverview(
      Color primaryColor, Color secondaryColor, Color textColor) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Portfolio Value',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\₹124,532',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward, color: Colors.green, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '8.2%',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPortfolioStat('Total Investment', '\₹100,000'),
              _buildPortfolioStat('Total Returns', '\₹24,532'),
              _buildPortfolioStat('ROI', '24.53%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceChart(
      bool isDark,
      Color surfaceColor,
      Color primaryColor,
      Color secondaryColor,
      Color textColor,
      Color? subtitleColor) {
    final axisLabelColor = isDark ? Colors.white60 : Colors.black54;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance',
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24),
          Container(
            height: 200,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: DateTimeAxis(
                majorGridLines: MajorGridLines(width: 0),
                axisLine: AxisLine(width: 0),
                labelStyle: TextStyle(color: axisLabelColor),
              ),
              primaryYAxis: NumericAxis(
                majorGridLines: MajorGridLines(width: 0),
                axisLine: AxisLine(width: 0),
                labelStyle: TextStyle(color: axisLabelColor),
              ),
              series: <CartesianSeries<ChartData, DateTime>>[
                SplineAreaSeries<ChartData, DateTime>(
                  dataSource: chartData,
                  name: "Investment",
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y,
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withValues(alpha: 0.3),
                      secondaryColor.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderWidth: 3,
                  borderColor: primaryColor,
                  splineType: SplineType.natural,
                  cardinalSplineTension: 0.5,
                ),
              ],
              tooltipBehavior: TooltipBehavior(enable: true),
              backgroundColor: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(
      bool isDark, Color surfaceColor, Color textColor, Color? subtitleColor) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildMetricCard(
          'Win Rate',
          '76%',
          Icons.trending_up_rounded,
          Colors.green,
          isDark,
          surfaceColor,
          textColor,
          subtitleColor,
        ),
        _buildMetricCard(
          'Profit Factor',
          '2.4',
          Icons.assessment_rounded,
          Theme.of(context).colorScheme.primary,
          isDark,
          surfaceColor,
          textColor,
          subtitleColor,
        ),
        _buildMetricCard(
          'Sharpe Ratio',
          '1.8',
          Icons.analytics_rounded,
          Theme.of(context).colorScheme.secondary,
          isDark,
          surfaceColor,
          textColor,
          subtitleColor,
        ),
        _buildMetricCard(
          'Max Drawdown',
          '-12.3%',
          Icons.show_chart_rounded,
          Colors.orange,
          isDark,
          surfaceColor,
          textColor,
          subtitleColor,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String title,
      String value,
      IconData icon,
      Color color,
      bool isDark,
      Color surfaceColor,
      Color textColor,
      Color? subtitleColor) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: subtitleColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositions(
      bool isDark, Color surfaceColor, Color textColor, Color? subtitleColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Open Positions',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        _buildPositionCard(
          'EUR/USD',
          'Buy',
          '1.2 Lots',
          '+\₹1,234',
          '+2.3%',
          true,
          isDark,
          surfaceColor,
          textColor,
          subtitleColor,
        ),
        SizedBox(height: 12),
        _buildPositionCard(
          'GBP/JPY',
          'Sell',
          '0.8 Lots',
          '-\₹421',
          '-0.8%',
          false,
          isDark,
          surfaceColor,
          textColor,
          subtitleColor,
        ),
        SizedBox(height: 12),
        _buildPositionCard(
          'EUR/USD',
          'Buy',
          '1.2 Lots',
          '+\₹1,234',
          '+2.3%',
          true,
          isDark,
          surfaceColor,
          textColor,
          subtitleColor,
        ),
        SizedBox(height: 12),
        _buildPositionCard(
          'GBP/JPY',
          'Sell',
          '0.8 Lots',
          '-\₹421',
          '-0.8%',
          false,
          isDark,
          surfaceColor,
          textColor,
          subtitleColor,
        ),
      ],
    );
  }

  Widget _buildPositionCard(
      String pair,
      String type,
      String size,
      String profit,
      String percentage,
      bool isProfit,
      bool isDark,
      Color surfaceColor,
      Color textColor,
      Color? subtitleColor) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (type == 'Buy' ? Colors.green : Colors.red)
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              type == 'Buy' ? Icons.arrow_upward : Icons.arrow_downward,
              color: type == 'Buy' ? Colors.green : Colors.red,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pair,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '$type • $size',
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                profit,
                style: TextStyle(
                  color: isProfit ? Colors.green : Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                percentage,
                style: TextStyle(
                  color: isProfit ? Colors.green : Colors.red,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
