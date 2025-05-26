import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdvancedOrdersPage extends StatefulWidget {
  const AdvancedOrdersPage({Key? key}) : super(key: key);

  @override
  _AdvancedOrdersPageState createState() => _AdvancedOrdersPageState();
}

class _AdvancedOrdersPageState extends State<AdvancedOrdersPage> {
  final List<Map<String, dynamic>> orders = [
    {
      'status': 'completed',
      'stockName': 'AAPL',
      'qty': 10,
      'icon': FontAwesomeIcons.check,
      'time': DateTime.now().subtract(Duration(minutes: 30)),
      'details': 'Bought at 150',
      'profitLoss': '+5%',
      'rupees': '₹750'
    },
    {
      'status': 'pending',
      'stockName': 'TSLA',
      'qty': 5,
      'icon': FontAwesomeIcons.clock,
      'time': DateTime.now().subtract(Duration(hours: 1)),
      'details': 'Limit Order at 700',
      'profitLoss': '0%',
      'rupees': '₹0'
    },
    {
      'status': 'rejected',
      'stockName': 'GOOGL',
      'qty': 8,
      'icon': FontAwesomeIcons.ban,
      'time': DateTime.now().subtract(Duration(days: 1)),
      'details': 'Insufficient Funds',
      'profitLoss': '-2%',
      'rupees': '₹-350'
    },
    {
      'status': 'rejected',
      'stockName': 'GOOGL',
      'qty': 8,
      'icon': FontAwesomeIcons.ban,
      'time': DateTime.now().subtract(Duration(days: 1)),
      'details': 'Insufficient Funds',
      'profitLoss': '-2%',
      'rupees': '₹-350'
    },
    {
      'status': 'rejected',
      'stockName': 'GOOGL',
      'qty': 8,
      'icon': FontAwesomeIcons.ban,
      'time': DateTime.now().subtract(Duration(days: 1)),
      'details': 'Insufficient Funds',
      'profitLoss': '-2%',
      'rupees': '₹-350'
    },
    {
      'status': 'rejected',
      'stockName': 'GOOGL',
      'qty': 8,
      'icon': FontAwesomeIcons.ban,
      'time': DateTime.now().subtract(Duration(days: 1)),
      'details': 'Insufficient Funds',
      'profitLoss': '-2%',
      'rupees': '₹-350'
    },
  ];

  String _selectedStatus = 'all';

  @override
  Widget build(BuildContext context) {
    return _buildComingSoon(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor = theme.colorScheme.onBackground;
    final secondaryTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final dividerColor = theme.dividerColor;
    final cardColor = theme.cardColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(textColor),
            _buildStatusFilter(isDark),
            _buildOrdersList(
                isDark, textColor, secondaryTextColor, dividerColor, cardColor),
          ],
        ),
      ),
    );
  }

  // Build the header with title and filter button
  Widget _buildHeader(Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Trading Orders',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          IconButton(
            icon: Icon(Icons.notifications_active_rounded, color: textColor),
            onPressed: () {
              // TODO: Implement advanced filtering
            },
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoon(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Theme.of(context).colorScheme.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.hourglass_top_rounded,
              size: 80,
              color: isDark
                  ? Colors.white.withOpacity(0.5)
                  : Theme.of(context).colorScheme.primary.withOpacity(0.7),
            ),
          ).animate().fadeIn(duration: 600.ms).scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
                duration: 600.ms,
                curve: Curves.easeOutBack,
              ),
          const SizedBox(height: 32),
          Text(
            'Coming Soon!',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ).animate().fadeIn(duration: 800.ms, delay: 200.ms),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'We\'re working hard to bring you this exciting new feature. Stay tuned for updates!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: isDark
                    ? Colors.white70
                    : Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.7),
              ),
            ),
          ).animate().fadeIn(duration: 800.ms, delay: 400.ms),
          const SizedBox(height: 40),
          OutlinedButton(
            onPressed: () {
              // Action to notify user when feature is ready
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.notifications_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Notify Me',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 800.ms, delay: 600.ms).slideY(
                begin: 0.2,
                end: 0,
                duration: 600.ms,
                curve: Curves.easeOutQuart,
              ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  // Build the status filter chips
  Widget _buildStatusFilter(bool isDark) {
    final statuses = ['all', 'completed', 'pending', 'rejected'];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            statuses.map((status) => _buildStatusChip(status, isDark)).toList(),
      ),
    );
  }

  // Build a single status chip
  Widget _buildStatusChip(String status, bool isDark) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;
    bool isSelected = _selectedStatus == status;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor
              : (isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status.toUpperCase(),
          style: GoogleFonts.poppins(
            color: isSelected
                ? (isDark ? Colors.white : Colors.white)
                : (isDark ? accentColor.withValues(alpha: 0.7) : accentColor),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Build the list of orders
  Widget _buildOrdersList(bool isDark, Color textColor,
      Color? secondaryTextColor, Color dividerColor, Color cardColor) {
    final filteredOrders = _selectedStatus == 'all'
        ? orders
        : orders.where((order) => order['status'] == _selectedStatus).toList();

    return Expanded(
      child: filteredOrders.isEmpty
          ? Center(
              child: Text(
                'No orders found',
                style: GoogleFonts.poppins(
                  color: secondaryTextColor,
                  fontSize: 18,
                ),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                return _buildOrderCard(order, isDark, textColor,
                    secondaryTextColor, dividerColor, cardColor);
              },
            ),
    );
  }

  Widget _buildOrderCard(
      Map<String, dynamic> order,
      bool isDark,
      Color textColor,
      Color? secondaryTextColor,
      Color dividerColor,
      Color cardColor) {
    final bool isProfit = order['profitLoss'].startsWith('+');
    final borderColor = isDark
        ? Colors.grey.withValues(alpha: 0.1)
        : Colors.grey.withValues(alpha: 0.2);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                _buildOrderStatusBadge(order, isDark),
                const SizedBox(width: 12),
                Flexible(
                  child: Container(),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isProfit
                        ? (isDark ? Colors.green[900] : Colors.green[50])
                        : (isDark ? Colors.red[900] : Colors.red[50]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order['profitLoss'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isProfit
                          ? (isDark ? Colors.green[100] : Colors.green[700])
                          : (isDark ? Colors.red[100] : Colors.red[700]),
                    ),
                  ),
                ),
              ],
            ),

            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(
                color: dividerColor,
                height: 1,
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order['stockName'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _timeAgo(order['time']),
                  style: TextStyle(
                    fontSize: 13,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),

            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(
                color: dividerColor,
                height: 1,
              ),
            ),

            // Order Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailItem(
                  'Quantity',
                  order['qty'].toString(),
                  Icons.format_list_numbered_rounded,
                  textColor,
                  secondaryTextColor,
                ),
                _buildDetailItem(
                  'Price',
                  order['rupees'],
                  Icons.attach_money_rounded,
                  textColor,
                  secondaryTextColor,
                ),
                _buildDetailItem(
                  'Type',
                  order['details'],
                  Icons.category_rounded,
                  textColor,
                  secondaryTextColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusBadge(Map<String, dynamic> order, bool isDark) {
    final (color, backgroundColor) = _getStatusColors(order['status'], isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(order['status']),
            color: color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            order['status'].toString().toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon,
      Color textColor, Color? secondaryTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: secondaryTextColor,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );
  }

  (Color, Color) _getStatusColors(String status, bool isDark) {
    switch (status.toLowerCase()) {
      case 'completed':
        return isDark
            ? (Colors.green[400]!, Colors.green[900]!)
            : (Colors.green[700]!, Colors.green[50]!);
      case 'pending':
        return isDark
            ? (Colors.amber[400]!, Colors.amber[900]!)
            : (Colors.amber[700]!, Colors.amber[50]!);
      case 'rejected':
        return isDark
            ? (Colors.red[400]!, Colors.red[900]!)
            : (Colors.red[700]!, Colors.red[50]!);
      default:
        return isDark
            ? (Colors.blue[400]!, Colors.blue[900]!)
            : (Colors.blue[700]!, Colors.blue[50]!);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle_rounded;
      case 'pending':
        return Icons.pending_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
