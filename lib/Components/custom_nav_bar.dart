import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    // Adaptive background and border colors
    final backgroundColor =
        colorScheme.surfaceVariant.withValues(alpha: isDarkMode ? 0.2 : 1);
    final borderColor = colorScheme.outline.withValues(alpha: 0.2);

    return Container(
      height: 80,
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withValues(alpha: 0.4)
                      : Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home_rounded,
                    "Home", context),
                _buildNavItem(1, Icons.trending_up_outlined, Icons.trending_up,
                    "Trade", context),
                _buildNavItem(2, Icons.bookmark_border,
                    Icons.bookmark_border_rounded, "Watchlist", context),
                _buildNavItem(3, Icons.troubleshoot_outlined,
                    Icons.troubleshoot_rounded, "Tools", context),
                _buildNavItem(4, Icons.person_outline, Icons.person_rounded,
                    "Profile", context),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 1, end: 0, curve: Curves.easeOutQuad);
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;
    final onSurfaceColor = colorScheme.onSurface;
    final isSelected = currentIndex == index;

    // Selected background color based on theme
    final selectedBackgroundColor =
        primaryColor.withValues(alpha: isDarkMode ? 0.3 : 0.15);

    // Active and inactive colors
    final activeColor = primaryColor;
    final inactiveColor = onSurfaceColor.withValues(alpha: 0.6);

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: isSelected
              ? BoxDecoration(
                  color: selectedBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? activeColor : inactiveColor,
                size: isSelected ? 28 : 24,
              )
                  .animate(target: isSelected ? 1 : 0)
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.2, 1.2),
                  )
                  .shake(
                    hz: 2,
                    rotation: 0.1,
                  ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
