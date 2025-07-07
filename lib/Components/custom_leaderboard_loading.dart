// components/leaderboard_loading.dart
import 'package:flutter/material.dart';

class LeaderboardLoadingList extends StatefulWidget {
  final int itemCount;

  const LeaderboardLoadingList({
    Key? key,
    this.itemCount = 10,
  }) : super(key: key);

  @override
  _LeaderboardLoadingListState createState() => _LeaderboardLoadingListState();
}

class _LeaderboardLoadingListState extends State<LeaderboardLoadingList>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the skeleton items
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Slide animation for items appearing
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _pulseController.repeat(reverse: true);
    _slideController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final padding = isTablet ? 16.0 : 8.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Column(
        children: [
          ...List.generate(widget.itemCount, (index) {
            return SlideTransition(
              position: _slideAnimation,
              child: LeaderboardLoadingCard(
                index: index,
                pulseAnimation: _pulseAnimation,
              ),
            );
          }),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class LeaderboardLoadingCard extends StatelessWidget {
  final int index;
  final Animation<double> pulseAnimation;

  const LeaderboardLoadingCard({
    Key? key,
    required this.index,
    required this.pulseAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final cardPadding = isTablet ? 16.0 : 12.0;
    final avatarSize = isTablet ? 60.0 : 50.0;
    final rankSize = isTablet ? 32.0 : 28.0;
    final iconSize = isTablet ? 36.0 : 32.0;
    final fontSize = isTablet ? 18.0 : 16.0;

    // Simulate rank for top 3 styling
    final simulatedRank = index + 1;
    final isTop3 = simulatedRank <= 3;

    Color getRankColor() {
      switch (simulatedRank) {
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

    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Card(
            elevation: isTop3 ? 8 : 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isTop3
                  ? BorderSide(
                      color: getRankColor().withValues(alpha: 0.3),
                      width: 2,
                    )
                  : BorderSide.none,
            ),
            child: Container(
              decoration: isTop3
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          getRankColor().withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    )
                  : null,
              child: Padding(
                padding: EdgeInsets.all(cardPadding),
                child: Row(
                  children: [
                    // Rank Number
                    SizedBox(width: 4),
                    Container(
                      width: rankSize,
                      height: rankSize,
                      decoration: BoxDecoration(
                        color: _getSkeletonColor(context, pulseAnimation.value),
                        borderRadius: BorderRadius.circular(rankSize / 2),
                      ),
                    ),
                    SizedBox(width: 12),

                    // Crown Icon placeholder (only for top 3)
                    if (isTop3) ...[
                      Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          color:
                              _getSkeletonColor(context, pulseAnimation.value),
                          borderRadius: BorderRadius.circular(iconSize / 2),
                        ),
                      ),
                      SizedBox(width: 12),
                    ],

                    // Content placeholder
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Username placeholder
                          Container(
                            height: fontSize + 2,
                            width: double.infinity * 0.6,
                            decoration: BoxDecoration(
                              color: _getSkeletonColor(
                                  context, pulseAnimation.value),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          SizedBox(height: 4),

                          // Points placeholder
                          Container(
                            height: fontSize + 2,
                            width: double.infinity * 0.4,
                            decoration: BoxDecoration(
                              color: _getSkeletonColor(
                                  context, pulseAnimation.value),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Avatar placeholder (on the right)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: avatarSize,
                          height: avatarSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getSkeletonColor(
                                context, pulseAnimation.value),
                            border: isTop3
                                ? Border.all(
                                    color:
                                        getRankColor().withValues(alpha: 0.3),
                                    width: 2,
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getSkeletonColor(BuildContext context, double opacity) {
    final baseColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade700
        : Colors.grey.shade300;

    return baseColor.withValues(alpha: opacity);
  }
}
