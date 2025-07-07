// Broker Connect Page
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:optionxi/VirtualTrading/VDialogs/connect_broker_dialog.dart';

class BrokerConnectPage extends StatelessWidget {
  BrokerConnectPage({
    Key? key,
  }) : super(key: key);

  final List<Map<String, dynamic>> brokers = [
    {
      'name': 'Zerodha',
      'logo': Icons.trending_up,
      'color': Color(0xFF387ED1),
      'subtitle': 'India\'s largest broker'
    },
    {
      'name': 'Upstox',
      'logo': Icons.show_chart,
      'color': Color(0xFF5C6BC0),
      'subtitle': 'Advanced trading platform'
    },
    {
      'name': 'Fyers',
      'logo': Icons.analytics,
      'color': Color(0xFF26A69A),
      'subtitle': 'Technology-first broker'
    },
    {
      'name': 'Angel One',
      'logo': Icons.monetization_on,
      'color': Color(0xFFFF7043),
      'subtitle': 'Smart investment solutions'
    },
    {
      'name': 'ICICI Direct',
      'logo': Icons.account_balance,
      'color': Color(0xFF42A5F5),
      'subtitle': 'Comprehensive trading'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: isDark ? Colors.white70 : Colors.black54),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Realtime Data',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Your Broker',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Connect your existing broker account to start live trading.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              SizedBox(height: 32),
              ...brokers
                  .map((broker) => _buildBrokerCard(context, broker, isDark))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrokerCard(
      BuildContext context, Map<String, dynamic> broker, bool isDark) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Material(
        color: theme.cardColor, // Use cardColor for consistency
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            showConnectionDialog(context, broker['name']);
          },
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.08),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (broker['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    broker['logo'] as IconData,
                    color: broker['color'] as Color,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        broker['name'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              theme.colorScheme.onSurface, // Use theme colors
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        broker['subtitle'] as String,
                        style: GoogleFonts.inter(
                          color: theme.colorScheme.onSurface
                              .withOpacity(0.6), // Use theme colors
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  color: theme.colorScheme.onSurface
                      .withOpacity(0.4), // Use theme colors
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
