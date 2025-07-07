import 'package:flutter/material.dart';

class StockTradingSkeleton extends StatefulWidget {
  final bool isDark;

  const StockTradingSkeleton({Key? key, required this.isDark})
      : super(key: key);

  @override
  State<StockTradingSkeleton> createState() => _StockTradingSkeletonState();
}

class _StockTradingSkeletonState extends State<StockTradingSkeleton>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _fadeController;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Shimmer animation for loading elements
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Subtle fade animation for static elements
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOutSine,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.4,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _shimmerController.repeat();
    _fadeController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_shimmerController, _fadeController]),
      builder: (context, child) {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStockInfoSkeleton(),
                    const SizedBox(height: 24),
                    _buildOrderTypeSection(),
                    const SizedBox(height: 24),
                    _buildProductTypeSection(),
                    const SizedBox(height: 24),
                    _buildQuantitySection(),
                    const SizedBox(height: 24),
                    _buildPriceTypeSection(),
                    const SizedBox(height: 20),
                    _buildPriceInputsSection(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // _buildBalanceSection(),
            // const SizedBox(height: 12),
            _buildBottomSection(),
          ],
        );
      },
    );
  }

  Widget _buildStockInfoSkeleton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: widget.isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Animated stock icon
              _buildShimmerBox(52, 52, isCircular: true),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Animated stock name
                    _buildShimmerBox(140, 18, borderRadius: 6),
                    const SizedBox(height: 8),
                    // Static segment badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        'EQ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Animated price
                  _buildShimmerBox(100, 18, borderRadius: 6),
                  const SizedBox(height: 8),
                  // Animated percentage
                  _buildShimmerBox(70, 16, borderRadius: 4),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(
            color: widget.isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          const SizedBox(height: 16),
          // OHLC with mixed static/loading
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOhlcItem('Open', true),
              _buildOhlcItem('High', false), // Static
              _buildOhlcItem('Low', false), // Static
              _buildOhlcItem('Prev Close', true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOhlcItem(String label, bool isAnimated) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: widget.isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        if (isAnimated)
          _buildShimmerBox(55, 16, borderRadius: 4)
        else
          AnimatedOpacity(
            opacity: _fadeAnimation.value,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: 55,
              height: 16,
              decoration: BoxDecoration(
                color:
                    widget.isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOrderTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Static section title
        Text(
          'Order Type',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: widget.isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        // Static BUY/SELL buttons
        Container(
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  widget.isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    'BUY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade600,
                    ),
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color:
                    widget.isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'SELL',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: widget.isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Type',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: widget.isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Static selected chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'INTRADAY',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Static unselected chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: widget.isDark ? const Color(0xFF1A1A1A) : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: widget.isDark
                      ? Colors.grey.shade700
                      : Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'NORMAL',
                    style: TextStyle(
                      color: widget.isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: Colors.orange.shade600,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: widget.isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  widget.isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.format_list_numbered_rounded,
                color:
                    widget.isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                size: 20,
              ),
              const SizedBox(width: 12),
              // Animated quantity placeholder
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: _buildShimmerBox(80, 16, borderRadius: 4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Type',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: widget.isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _buildPriceChip('MKT', true, false),
            _buildPriceChip('LIMIT', false, true),
            _buildPriceChip('SL', false, true),
            _buildPriceChip('SLM', false, true),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceChip(String label, bool isSelected, bool isLocked) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.blue.shade600
            : (widget.isDark ? const Color(0xFF1A1A1A) : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? Colors.blue.shade600
              : (widget.isDark ? Colors.grey.shade700 : Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (widget.isDark
                      ? Colors.grey.shade400
                      : Colors.grey.shade600),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          if (isLocked) ...[
            const SizedBox(width: 6),
            Icon(
              Icons.lock_outline,
              size: 14,
              color: Colors.orange.shade600,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceInputsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.currency_rupee_rounded,
            color: widget.isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            'Market Price',
            style: TextStyle(
              color:
                  widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: _buildShimmerBox(60, 16, borderRadius: 4),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.green.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Available Balance',
              style: TextStyle(
                fontSize: 16,
                color:
                    widget.isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            _buildShimmerBox(100, 20, borderRadius: 6),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1A1A1A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: widget.isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Margin Required',
                style: TextStyle(
                  fontSize: 16,
                  color: widget.isDark
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              _buildShimmerBox(80, 18, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'BUY',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox(double width, double height,
      {double borderRadius = 8, bool isCircular = false}) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: isCircular
                ? BorderRadius.circular(width / 2)
                : BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: widget.isDark
                  ? [
                      const Color(0xFF2A2A2A),
                      const Color(0xFF3A3A3A),
                      const Color(0xFF2A2A2A),
                    ]
                  : [
                      Colors.grey.shade300,
                      Colors.grey.shade200,
                      Colors.grey.shade300,
                    ],
              stops: const [0.0, 0.5, 1.0],
              transform: GradientRotation(_shimmerAnimation.value),
            ),
          ),
        );
      },
    );
  }
}
