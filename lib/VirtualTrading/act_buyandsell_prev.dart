import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:optionxi/Helpers/constants.dart';
import 'package:optionxi/Helpers/lotsize_helper.dart';
import 'package:optionxi/VirtualTrading/VDialogs/order_placed_dialog.dart';
import 'package:optionxi/VirtualTrading/VDialogs/subscription_required_dialog.dart';
import 'package:optionxi/VirtualTrading/buyandsell_prev_loading.dart';
import 'package:optionxi/browser_lite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BuyandSellPagePrev extends StatefulWidget {
  final String? stockname;
  final String? segment;
  final bool tosell;

  const BuyandSellPagePrev(this.stockname, this.segment, this.tosell,
      {Key? key})
      : super(key: key);

  @override
  _BuyandSellPagePrevState createState() => _BuyandSellPagePrevState();
}

class _BuyandSellPagePrevState extends State<BuyandSellPagePrev> {
  final _formKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController();
  final _limitController = TextEditingController();
  final _slController = TextEditingController();
  final _triggerController = TextEditingController();

  // State Variables
  late String _orderType;
  String _priceType = 'MKT'; // MKT, LIMIT, SL, SLM
  String _productType = 'INTRADAY'; // INTRADAY or NORMAL
  bool _isSubscribed = false;
  bool _isLoading = true;
  bool _isPlacingOrder = false;

  // Financial Data
  double _availableBalance = 0.0;
  double _marginRequired = 0.0;
  bool _hasShortPosition = false;
  int _shortPositionQuantity = 0;
  double _shortPositionAvgPrice = 0.0;
  double _shortProfitLoss = 0.0;

  // Real-time Stock Data
  double _currentPrice = 0.0;
  double _open = 0.0;
  double _high = 0.0;
  double _low = 0.0;
  double _prevClose = 0.0;
  double _percentChange = 0.0;

  // Backend References
  late RealtimeChannel _supabaseChannel;

  @override
  void initState() {
    super.initState();
    _orderType = widget.tosell ? 'SELL' : 'BUY';
    // Add listener to recalculate margin when quantity changes
    _qtyController.addListener(_calculateMargin);
    _initializeData();
  }

  // Fetches initial data required for the page
  // Improved _initializeData method with better error handling
  Future<void> _initializeData() async {
    try {
      // First fetch initial data
      await Future.wait([
        _checkSubscription(),
        _getUserBalance(),
        _checkShortPosition(),
        _fetchInitialStockData(),
      ]);

      // Then setup real-time listener
      _setupRealtimeData();

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      // Clean up any partially initialized resources
      _cleanupOnError();

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e')),
        );
      }
    }
  }

// Cleanup method for error scenarios
  void _cleanupOnError() {
    try {
      _supabaseChannel.unsubscribe();
    } catch (e) {
      print('Error during cleanup: $e');
    }
  }

  Future<void> _fetchInitialStockData() async {
    final tableName = widget.segment == 'EQ'
        ? 'prev_nifty50_stocks'
        : 'prev_fno_bankandnifty';

    final response = await Supabase.instance.client
        .from(tableName)
        .select()
        .eq('symbol', widget.stockname!)
        .single();

    if (mounted) {
      setState(() {
        _currentPrice = (response['ltp'] ?? 0.0).toDouble();
        _open = (response['o'] ?? 0.0).toDouble();
        _high = (response['h'] ?? 0.0).toDouble();
        _low = (response['l'] ?? 0.0).toDouble();
        _prevClose = (response['pc'] ?? 0.0).toDouble();
        _percentChange = (response['pcnt'] ?? 0.0).toDouble();
      });
    }
  }

  // Checks if the user has an active subscription via Firebase
  Future<void> _checkSubscription() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final ref = FirebaseDatabase.instance.ref('subscribed/${user.uid}');
      final snapshot = await ref.get();
      if (mounted) {
        setState(() {
          _isSubscribed = snapshot.exists;
        });
      }
    }
  }

  // Fetches the user's trading balance from Supabase
  Future<void> _getUserBalance() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print("Used id:" + user.uid.toString());
      try {
        final response = await Supabase.instance.client
            .from('prev_balance')
            .select('balance')
            .eq('suid', user.uid)
            .single();
        if (mounted) {
          setState(() {
            _availableBalance = (response['balance'] ?? 0.0).toDouble();
          });
        }
      } catch (e) {
        // Handle error, e.g., show a snackbar
        print("Error fetching balance: $e");
      }
    }
  }

  // Checks if the user holds a short position for the current stock
  Future<void> _checkShortPosition() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && widget.stockname != null) {
      final response = await Supabase.instance.client
          .from('prev_short_positions')
          .select('quantity, average_price')
          .eq('suid', user.uid)
          .eq('symbol', widget.stockname!)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _hasShortPosition = response != null;
          if (_hasShortPosition && response != null) {
            _shortPositionQuantity = (response['quantity'] ?? 0) as int;
            _shortPositionAvgPrice =
                (response['average_price'] ?? 0).toDouble();
          } else {
            _shortPositionQuantity = 0;
            _shortPositionAvgPrice = 0.0;
          }
        });
      }
    }
  }

  // Subscribes to real-time stock price updates from Supabase
  void _setupRealtimeData() {
    final tableName = widget.segment == 'EQ'
        ? 'prev_nifty50_stocks'
        : 'prev_fno_bankandnifty';

    _supabaseChannel =
        Supabase.instance.client.channel('stock_${widget.stockname}');
    _supabaseChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: tableName,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'symbol',
            value: widget.stockname,
          ),
          callback: (payload) {
            final record = payload.newRecord;
            if (mounted) {
              setState(() {
                _currentPrice = (record['ltp'] ?? 0.0).toDouble();
                _open = (record['o'] ?? 0.0).toDouble();
                _high = (record['h'] ?? 0.0).toDouble();
                _low = (record['l'] ?? 0.0).toDouble();
                _prevClose = (record['pc'] ?? 0.0).toDouble();
                _percentChange = (record['pcnt'] ?? 0.0).toDouble();
                _calculateMargin();
                _calculateShortProfitLoss();
                if (_isLoading) _isLoading = false;
              });
            }
          },
        )
        .subscribe();
  }

  // Calculates the margin required for an order
  void _calculateMargin() {
    final qty = int.tryParse(_qtyController.text) ?? 0;

    int lot = 1; // Default for EQ
    if (widget.segment == "FNO") {
      if (widget.stockname.toString().toUpperCase().startsWith("BANKNIFTY")) {
        lot = 15; // Changed from 25 to 15
      } else if (widget.stockname
          .toString()
          .toUpperCase()
          .startsWith("NIFTY")) {
        lot = 15; // Changed from 25 to 15
      }
    }

    final price = _priceType == 'LIMIT'
        ? (double.tryParse(_limitController.text) ?? _currentPrice)
        : _currentPrice;

    setState(() {
      _marginRequired = price * qty * lot;
    });
  }

  // Calculates the profit or loss on the short position
  void _calculateShortProfitLoss() {
    if (_hasShortPosition) {
      setState(() {
        _shortProfitLoss =
            (_shortPositionAvgPrice - _currentPrice) * _shortPositionQuantity;
      });
    }
  }

  // Places the order by pushing it to Firebase
  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isSubscribed && (_priceType != 'MKT' || _productType == 'NORMAL')) {
      showSubscriptionRequiredDialog(context);
      return;
    }

    setState(() => _isPlacingOrder = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle not logged in case
      setState(() => _isPlacingOrder = false);
      return;
    }

    final dbRef = FirebaseDatabase.instance.ref('prev_pend_order/${user.uid}');
    final newOrderRef = dbRef.push(); // Generates a unique ID

    int lotsize = getLotSize(
      segment: widget.segment,
      stockName: widget.stockname,
    );

    final orderData = {
      'id': newOrderRef.key,
      'suid': user.uid,
      'symbol': widget.stockname,
      'quantity': (int.tryParse(_qtyController.text) ?? 0) * lotsize,
      'order_type': _priceType,
      'transaction_type': _orderType,
      // 'product_type': _productType, // Added Product Type
      'segment': widget.segment,
      'price': _priceType == 'LIMIT' || _priceType == 'SL'
          ? (double.tryParse(_limitController.text) ?? 0.0)
          : null,
      'trigger_price': _priceType == 'SL' || _priceType == 'SLM'
          ? (double.tryParse(_triggerController.text) ?? 0.0)
          : null,
      'status': 'pending',
      // 'created_at': ServerValue.timestamp, // Firebase server-side timestamp
    };

    try {
      await newOrderRef.set(orderData);
      showOrderConfiramationDialog(context, _orderType.toLowerCase());
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to place order: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isPlacingOrder = false);
      }
    }
  }

  @override
  void dispose() {
    // Remove listeners first
    _qtyController.removeListener(_calculateMargin);

    // Dispose controllers
    _qtyController.dispose();
    _limitController.dispose();
    _slController.dispose();
    _triggerController.dispose();

    // Unsubscribe from Supabase channel safely
    try {
      _supabaseChannel.unsubscribe();
    } catch (e) {
      print('Error unsubscribing from Supabase channel: $e');
    }

    super.dispose();
  }

  // Main Build Method
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0E0E0E) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          // widget.stockname ?? 'Stock Trading',
          "Place Order",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      body: _isLoading
          ? StockTradingSkeleton(isDark: isDark)
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                              onTap: () {
                                if (widget.segment == "EQ") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => BrowserLite_V(
                                            "https://in.tradingview.com/chart/?symbol=NSE%3A" +
                                                widget.stockname.toString())),
                                  );
                                }
                              },
                              child: _buildStockInfoCard(isDark)),
                          if (_hasShortPosition && _orderType == 'BUY') ...[
                            const SizedBox(height: 20),
                            _buildShortPositionInfoCard(isDark),
                          ],
                          const SizedBox(height: 20),
                          _buildOrderTypeSelection(isDark),
                          const SizedBox(height: 20),
                          // NEW: Product Type Selection
                          _buildProductTypeSelection(isDark),
                          const SizedBox(height: 20),
                          _buildQuantityInput(isDark),
                          const SizedBox(height: 20),
                          _buildPriceTypeSelection(isDark),
                          const SizedBox(height: 16),
                          if (_priceType != 'MKT') _buildPriceInputs(isDark),
                        ],
                      ),
                    ),
                  ),
                ),
                // Sticky Bottom Bar
                const SizedBox(height: 20),
                // _buildBalanceCard(isDark),
                // const SizedBox(height: 10),
                _buildBottomBar(isDark),
              ],
            ),
    );
  }

  // --- UI Builder Widgets ---

  Widget _buildStockInfoCard(bool isDark) {
    final Color gainColor = Colors.green.shade600;
    final Color lossColor = Colors.red.shade600;
    final Color changeColor = _percentChange >= 0 ? gainColor : lossColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.stockname ?? 'Unknown Stock',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Stock Icon
                  CachedNetworkImage(
                    height: 48,
                    width: 48,
                    imageUrl: Constants.OptionXiS3Loc +
                        widget.stockname.toString() +
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
                  const SizedBox(width: 12),
                  Text(
                    widget.segment ?? 'EQ',
                    style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                  // Spacer to push price and percent change to the right
                  const Spacer(),
                  // Price and Percent Change
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${_currentPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87),
                      ),
                      Text(
                        '${_percentChange >= 0 ? '▲' : '▼'} ${_percentChange.abs().toStringAsFixed(2)}%',
                        style: TextStyle(
                            fontSize: 14,
                            color: changeColor,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          // O-H-L-C Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOhlcItem('Open', _open.toStringAsFixed(2), isDark),
              _buildOhlcItem('High', _high.toStringAsFixed(2), isDark),
              _buildOhlcItem('Low', _low.toStringAsFixed(2), isDark),
              _buildOhlcItem(
                  'Prev. Close', _prevClose.toStringAsFixed(2), isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShortPositionInfoCard(bool isDark) {
    final Color pnlColor =
        _shortProfitLoss >= 0 ? Colors.green.shade600 : Colors.red.shade600;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Short Position',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quantity: $_shortPositionQuantity',
                style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[300] : Colors.grey[700]),
              ),
              Text(
                'Avg. Sell Price: ₹${_shortPositionAvgPrice.toStringAsFixed(2)}',
                style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[300] : Colors.grey[700]),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Potential P/L',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                '₹${_shortProfitLoss.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: pnlColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOhlcItem(String title, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87)),
      ],
    );
  }

  Widget _buildBalanceCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE0E0E0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            color: isDark ? Colors.blue[300] : Colors.blue[700],
          ),
          const SizedBox(width: 12),
          Text(
            'Available Balance:',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          const Spacer(),
          Text(
            '₹${_availableBalance.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTypeSelection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildSelectChip('INTRADAY', _productType, isDark, true, (type) {
              setState(() => _productType = type);
            }),
            const SizedBox(width: 12),
            _buildSelectChip('NORMAL', _productType, isDark, _isSubscribed,
                (type) {
              if (_isSubscribed) {
                setState(() => _productType = type);
              } else {
                showSubscriptionRequiredDialog(context);
              }
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderTypeSelection(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeButton('BUY', Colors.green, isDark),
          ),
          Container(
            width: 1,
            height: 35,
            color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE0E0E0),
          ),
          Expanded(
            child: _buildTypeButton('SELL', Colors.red, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String type, Color color, bool isDark) {
    final isSelected = _orderType == type;
    return GestureDetector(
      onTap: () => setState(() => _orderType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: type == 'BUY'
              ? const BorderRadius.only(
                  topLeft: Radius.circular(12), bottomLeft: Radius.circular(12))
              : const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12)),
        ),
        child: Text(
          type,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? color
                : (isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityInput(bool isDark) {
    // Calculate lot size
    int lotSize = getLotSize(
      segment: widget.segment,
      stockName: widget.stockname,
    );

    // Get current quantity
    final currentQty = int.tryParse(_qtyController.text) ?? 0;
    final totalShares = currentQty * lotSize;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _qtyController,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration(
              labelText: 'Quantity',
              prefixIcon: Icons.format_list_numbered,
              isDark: isDark),
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter quantity';
            final int? qty = int.tryParse(value);
            if (qty == null || qty <= 0) return 'Enter a valid quantity';
            if (_orderType == 'SELL' &&
                _hasShortPosition &&
                qty > _shortPositionQuantity) {
              return 'Cannot sell more than your short position';
            }
            return null;
          },
        ),

        // Add lot size info and total shares display
        if (widget.segment == "FNO") ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? const Color(0xFF2E2E2E) : Colors.grey[300]!,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lot Size: $lotSize',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                    Text(
                      'Total Shares: $totalShares',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.blue[300] : Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Note: Enter lot quantity, not individual shares. For example, if you want 75 shares, enter 5 (since 5 lots × 15 = 75 shares).',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    // fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPriceTypeSelection(bool isDark) {
    final types = ['MKT', 'LIMIT', 'SL', 'SLM'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: types.map((type) {
            final isEnabled = type == 'MKT' || _isSubscribed;
            return _buildSelectChip(type, _priceType, isDark, isEnabled,
                (selectedType) {
              if (isEnabled) {
                setState(() => _priceType = selectedType);
              } else {
                showSubscriptionRequiredDialog(context);
              }
            });
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSelectChip(String type, String currentSelection, bool isDark,
      bool isEnabled, Function(String) onTap) {
    final isSelected = currentSelection == type;
    return GestureDetector(
      onTap: () => onTap(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.blue.shade700 : Colors.blue.shade600)
              : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected
                  ? (isDark ? Colors.blue.shade600 : Colors.blue.shade500)
                  : (isDark ? const Color(0xFF2E2E2E) : Colors.grey.shade300)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              type,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : isEnabled
                        ? (isDark ? Colors.white70 : Colors.black87)
                        : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (!isEnabled)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(
                  Icons.lock,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceInputs(bool isDark) {
    return Column(
      children: [
        if (_priceType == 'LIMIT' || _priceType == 'SL')
          TextFormField(
            controller: _limitController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _inputDecoration(
                labelText: _priceType == 'LIMIT' ? 'Limit Price' : 'Price',
                prefixIcon: Icons.price_change_outlined,
                isDark: isDark),
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Price is required' : null,
          ),
        if (_priceType == 'SL' || _priceType == 'SLM') ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _triggerController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _inputDecoration(
                labelText: 'Trigger Price',
                prefixIcon: Icons.touch_app_outlined,
                isDark: isDark),
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Trigger price is required' : null,
          ),
        ],
      ],
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border(
            top: BorderSide(
                color: isDark
                    ? const Color(0xFF2E2E2E)
                    : const Color(0xFFE0E0E0))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMarginInfo(isDark),
          const SizedBox(height: 16),
          _buildPlaceOrderButton(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMarginInfo(bool isDark) {
    final label = _orderType == 'BUY' ? 'Margin Required' : 'Order Value';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        Text(
          '₹${_marginRequired.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceOrderButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isPlacingOrder ? null : _placeOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _orderType == 'BUY' ? Colors.green.shade600 : Colors.red.shade600,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _isPlacingOrder
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 3))
            : Text(
                '${_orderType.toUpperCase()}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  // Helper for consistent InputDecoration
  InputDecoration _inputDecoration(
      {required String labelText,
      required IconData prefixIcon,
      required bool isDark}) {
    final borderColor =
        isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE0E0E0);
    final focusedColor = isDark ? Colors.blue[400]! : Colors.blue[600]!;

    return InputDecoration(
      labelText: labelText,
      prefixIcon:
          Icon(prefixIcon, color: isDark ? Colors.grey[400] : Colors.grey[600]),
      filled: true,
      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: focusedColor, width: 1.5),
      ),
      labelStyle:
          TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
    );
  }
}
