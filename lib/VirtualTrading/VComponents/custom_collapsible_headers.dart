// Custom delegate for collapsible stats
import 'package:flutter/material.dart';

class CollapsibleHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  CollapsibleHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = shrinkOffset / maxHeight;

    return Container(
      height: maxHeight,
      child: Opacity(
        opacity: (1 - progress).clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, -shrinkOffset * 0.5),
          child: child,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(CollapsibleHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

// Custom delegate for the persistent tab bar
class TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget tabBar;

  TabBarDelegate({required this.tabBar});

  @override
  double get minExtent => 48.0; // Height of tab bar

  @override
  double get maxExtent => 48.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(TabBarDelegate oldDelegate) {
    return false;
  }
}
