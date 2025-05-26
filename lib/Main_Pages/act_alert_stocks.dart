import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:optionxi/Components/custom_searchbar.dart';
import 'package:optionxi/DataModels/sample_stock_symbols.dart';
import 'package:optionxi/Helpers/constants.dart';
import 'package:optionxi/Main_Pages/act_search_stocks_alerts.dart';
import 'dart:async';
import 'package:timeago/timeago.dart' as timeago;
import 'package:supabase_flutter/supabase_flutter.dart';

// Alert Model class
class AlertModel {
  final int id;
  final String date;
  final String description;
  final String? symbol;
  final String? sentiment;
  final String createdAt;
  final String updatedAt;

  AlertModel({
    required this.id,
    required this.date,
    required this.description,
    this.symbol,
    this.sentiment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      description: json['description'] ?? '',
      symbol: json['symbol'],
      sentiment: json['sentiment'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

// Constants
const int pageSize = 20;

enum SentimentFilter { all, bullish, bearish }

class StockAlertsPage extends StatefulWidget {
  final String? stockname;
  const StockAlertsPage(this.stockname, {Key? key}) : super(key: key);

  @override
  _StockAlertsPageState createState() => _StockAlertsPageState();
}

class _StockAlertsPageState extends State<StockAlertsPage>
    with SingleTickerProviderStateMixin {
  // Supabase client
  final supabase = Supabase.instance.client;

  // Controllers
  late AnimationController _controller;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // State variables
  List<AlertModel> _alerts = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _totalCount = 0;
  String _selectedStock = 'all';
  DateTime? _selectedDate;
  SentimentFilter _currentFilter = SentimentFilter.all;
  bool _isSearchFocused = false;
  String _displayStockName = '';
  String _searchQuery = '';
  RealtimeChannel? _channel;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _controller.forward();

    // Initialize with the stock passed in constructor if any
    if (widget.stockname != null &&
        widget.stockname!.isNotEmpty &&
        widget.stockname != "all") {
      _selectedStock = widget.stockname!;

      // Find the display name for the selected stock
      if (totalStocks.containsKey(widget.stockname)) {
        setState(() {
          _displayStockName = totalStocks[widget.stockname]
                  ?['full_stock_name'] ??
              widget.stockname!;
        });
      } else {
        setState(() {
          _displayStockName = widget.stockname!;
        });
      }
    } else {
      // If stockname is null or empty or "all", show all stocks
      _selectedStock = 'all';
      _displayStockName = '';
    }

    _fetchAlerts();
    _subscribeToAlerts();

    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
        if (_isSearchFocused && _searchQuery.isEmpty) {
          _searchQuery = '';
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    // Properly unsubscribe and dispose of the channel
    _channel?.unsubscribe().then((_) {
      _channel = null;
    });
    super.dispose();
  }

// Helper method to apply filters to a query
  PostgrestFilterBuilder<PostgrestList> _applyFilters(
      PostgrestFilterBuilder<PostgrestList> query) {
    // Apply sentiment filter
    if (_currentFilter == SentimentFilter.bullish) {
      query = query.eq('sentiment', 'bullish');
    } else if (_currentFilter == SentimentFilter.bearish) {
      query = query.eq('sentiment', 'bearish');
    }

    // Apply stock filter
    if (_selectedStock != 'all') {
      query = query.eq('symbol', _selectedStock);
    }

    // Apply date filter
    if (_selectedDate != null) {
      final startDate = DateTime(
          _selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
      final endDate = startDate
          .add(const Duration(days: 1))
          .subtract(const Duration(milliseconds: 1));

      query = query
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());
    }

    return query;
  }

  Future<void> _fetchAlerts() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final from = (_currentPage - 1) * pageSize;
      final to = from + pageSize - 1;

      // Start building the query
      var query = supabase.from('live_scanner').select();

      // Apply all filters to the query
      query = _applyFilters(query);

      // Order and paginate results
      final response =
          await query.order('created_at', ascending: false).range(from, to);

      // Get total count with the same filters applied
      var countQuery = supabase.from('live_scanner').select('id');
      countQuery = _applyFilters(countQuery);
      final countResponse = await countQuery;
      final count = countResponse.length;

      // Process the response data
      final data =
          (response as List).map((item) => AlertModel.fromJson(item)).toList();

      if (mounted) {
        setState(() {
          _alerts = data;
          _totalCount = count;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _subscribeToAlerts() {
    _channel?.unsubscribe(); // Unsubscribe from any previous channel

    final channel = supabase.channel('live_scanner_changes_filtered');

    PostgresChangeFilter? activeSubscriptionFilter;
    if (_selectedStock != 'all') {
      activeSubscriptionFilter = PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'symbol',
        value: _selectedStock,
      );
    } else if (_currentFilter != SentimentFilter.all) {
      activeSubscriptionFilter = PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'sentiment',
        value:
            _currentFilter == SentimentFilter.bullish ? 'bullish' : 'bearish',
      );
    }

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'live_scanner',
      filter: activeSubscriptionFilter,
      callback: (payload) {
        // Check if widget is still mounted before updating state
        if (mounted) {
          print(
              "Realtime event received (potentially filtered): ${payload.eventType}");
          _fetchAlerts();
        }
      },
    );

    channel.subscribe(
      (status, [error]) {
        if (status == RealtimeSubscribeStatus.subscribed) {
          print('Successfully subscribed to filtered channel!');
        } else if (status == RealtimeSubscribeStatus.timedOut) {
          print('Subscription timed out');
        } else if (error != null) {
          print('Error subscribing to channel: $error');
        }
      },
    );

    _channel = channel;
  }

  void _handleFilterChange(SentimentFilter filter) {
    setState(() {
      _currentFilter = filter;
      _currentPage = 1;
    });
    _fetchAlerts();
    _subscribeToAlerts(); // Re-subscribe with new filters
  }

  void _handleClearStock() {
    setState(() {
      _selectedStock = 'all';
      _displayStockName = '';
      _searchQuery = '';
      _currentPage = 1;
    });
    _fetchAlerts();
    _subscribeToAlerts(); // Re-subscribe
  }

  void _handleDateChange(DateTime? date) {
    setState(() {
      _selectedDate = date;
      _currentPage = 1;
    });
    _fetchAlerts();
    _subscribeToAlerts(); // Re-subscribe
  }

  void _handlePageChange(int page) {
    setState(() {
      _currentPage = page;
    });
    _fetchAlerts();
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 20, 0, 8),
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
                  "Stock Alerts",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Text(
            //   "Stay updated with the latest market insights",
            //   style: TextStyle(
            //     color: Theme.of(context).textTheme.titleSmall?.color,
            //     fontSize: 16,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return ModernSearchBar();
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      child: Column(
        children: [
          // Show search bar when no stock is selected, otherwise show the selected stock chip
          if (_selectedStock == 'all')
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StockSearchPageAlerts()),
                );
              },
              child: AbsorbPointer(
                child: Container(
                    margin: EdgeInsets.only(bottom: 16),
                    child: _buildSearchBar()),
              ),
            )
          else if (_displayStockName.isNotEmpty)
            Container(
              margin: EdgeInsets.only(bottom: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text(_displayStockName),
                    deleteIcon: Icon(Icons.close, size: 18),
                    onDeleted: _handleClearStock,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    side: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.5),
                    ),
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
          // Date Picker
          Container(
            margin: EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null && picked != _selectedDate) {
                  _handleDateChange(picked);
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? 'Pick a date'
                            : DateFormat('MMMM d, yyyy').format(_selectedDate!),
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (_selectedDate != null)
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => _handleDateChange(null),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Sentiment Filter Buttons
          Container(
            margin: EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleFilterChange(SentimentFilter.all),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentFilter == SentimentFilter.all
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).cardColor,
                      foregroundColor: _currentFilter == SentimentFilter.all
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyLarge?.color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('All'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _handleFilterChange(SentimentFilter.bullish),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentFilter == SentimentFilter.bullish
                          ? Colors.green[600]
                          : Theme.of(context).cardColor,
                      foregroundColor: _currentFilter == SentimentFilter.bullish
                          ? Colors.white
                          : Colors.green[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Bullish'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _handleFilterChange(SentimentFilter.bearish),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentFilter == SentimentFilter.bearish
                          ? Colors.red[600]
                          : Theme.of(context).cardColor,
                      foregroundColor: _currentFilter == SentimentFilter.bearish
                          ? Colors.white
                          : Colors.red[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Bearish'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(AlertModel alert, int index) {
    // Determine styles based on sentiment
    final isBullish = alert.sentiment == 'bullish';
    final Color borderColor =
        isBullish ? Colors.green.shade200 : Colors.red.shade200;
    final Color bgColor = isBullish ? Colors.green.shade50 : Colors.red.shade50;
    final Color tagColor =
        isBullish ? Colors.green.shade700 : Colors.red.shade700;
    final Color tagBgColor =
        isBullish ? Colors.green.shade100 : Colors.red.shade100;

    final DateTime alertDatetime = DateTime.parse(alert.createdAt).toLocal();

    // Get full stock name if available
    String displaySymbol = alert.symbol ?? 'Market Alert';

    if (alert.symbol != null && totalStocks.containsKey(alert.symbol)) {
      displaySymbol =
          totalStocks[alert.symbol]?['full_stock_name'] ?? alert.symbol!;
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(20 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).cardColor
              : bgColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              // Navigate to alert details page
              if (alert.symbol != null) {
                String? fullKey;

                // Find the full key (like "NSE:20MICRONS-EQ") that contains the symbol
                totalStocks.forEach((key, value) {
                  if (key.contains(alert.symbol!)) {
                    fullKey = key;
                  }
                });

                if (fullKey != null) {
                  print("Navigate to alert details for $fullKey");
                  Get.toNamed('/stocks/${fullKey!.toUpperCase()}');
                } else {
                  print(
                      "Stock symbol ${alert.symbol} not found in totalStocks.");
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stock Logo
                  CachedNetworkImage(
                    height: 48,
                    width: 48,
                    imageUrl: Constants.OptionXiS3Loc +
                        alert.symbol.toString() +
                        ".png",
                    fit: BoxFit.cover,
                    placeholder: (context, url) => ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.asset(
                        'assets/images/option_xi_w.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    errorWidget: (context, url, error) => ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.asset(
                        'assets/images/option_xi_w.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Container(
                  //   width: 60,
                  //   height: 60,
                  //   decoration: BoxDecoration(
                  //     color: Theme.of(context).cardColor,
                  //     borderRadius: BorderRadius.circular(12),
                  //     border: Border.all(
                  //       color: Theme.of(context).dividerColor,
                  //       width: 1,
                  //     ),
                  //   ),
                  //   child: Center(
                  //     child: Text(
                  //       stockInitials,
                  //       style: TextStyle(
                  //         fontWeight: FontWeight.bold,
                  //         fontSize: 18,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  SizedBox(width: 16),
                  // Alert Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Sentiment Tag
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                displaySymbol,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (alert.sentiment != null)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: tagBgColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  alert.sentiment!.toUpperCase(),
                                  style: TextStyle(
                                    color: tagColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 8),
                        // Description
                        Text(
                          alert.description,
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                            fontSize: 14,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 12),
                        // Time Info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  timeago.format(alertDatetime),
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              DateFormat('h:mm a').format(alertDatetime),
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    final int totalPages = (_totalCount / pageSize).ceil();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Button
          ElevatedButton(
            onPressed: _currentPage > 1 && !_isLoading
                ? () => _handlePageChange(_currentPage - 1)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).cardColor,
              foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Text('Previous'),
          ),

          // Page Indicator
          Text(
            'Page $_currentPage of ${totalPages > 0 ? totalPages : 1}',
            style: TextStyle(
              fontWeight: FontWeight.w100,
            ),
          ),

          // Next Button
          ElevatedButton(
            onPressed: _currentPage < totalPages && !_isLoading
                ? () => _handlePageChange(_currentPage + 1)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).cardColor,
              foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Text('Next'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          SizedBox(height: 16),
          Text(
            'No alerts found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try again sometime later or adjust your filters',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

// Replace the _buildLoadingState() method with this simplified version
  Widget _buildLoadingState() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildSkeletonItem();
      },
    );
  }

// Simplified skeleton item
  Widget _buildSkeletonItem() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          // Avatar skeleton
          _buildShimmer(48, 48, 24),
          SizedBox(width: 16),
          // Content skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(
                  children: [
                    Expanded(child: _buildShimmer(20, null, 4)),
                    SizedBox(width: 12),
                    _buildShimmer(24, 60, 12), // Tag
                  ],
                ),
                SizedBox(height: 12),
                // Description lines
                _buildShimmer(14, null, 4),
                SizedBox(height: 6),
                _buildShimmer(14, 200, 4),
                SizedBox(height: 16),
                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildShimmer(12, 80, 4),
                    _buildShimmer(12, 50, 4),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Simple shimmer container
  Widget _buildShimmer(double height, double? width, double radius) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]?.withValues(alpha: 0.3)
            : Colors.grey[300]?.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Filters
            _buildFilters(),

            // Error State
            if (_error != null)
              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .error
                      .withValues(alpha: 0.1),
                  border:
                      Border.all(color: Theme.of(context).colorScheme.error),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Error',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
              ),

            // Alerts List
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _alerts.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _alerts.length,
                          itemBuilder: (context, index) {
                            return _buildAlertItem(_alerts[index], index);
                          },
                        ),
            ),

            // Pagination
            if (!_isLoading && _alerts.isNotEmpty) _buildPagination(),
          ],
        ),
      ),
    );
  }
}
