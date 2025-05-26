// import 'dart:ui';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// /// A highly modern, aesthetically pleasing dialog with contemporary design elements
// void showCustomDialogUpdate({
//   required BuildContext context,
//   required String title,
//   required String description,
//   required String confirmButtonText,
//   String? cancelButtonText,
//   VoidCallback? onConfirm,
//   VoidCallback? onCancel,
//   bool isDismissible = true,
//   String? svgAssetPath,
//   Widget? customIllustration,
//   Color? accentColor,
//   Color? backgroundColor,
//   DialogStyle style = DialogStyle.rounded,
// }) {
//   // Haptic feedback for dialog appearance
//   HapticFeedback.mediumImpact();

//   final theme = Theme.of(context);
//   final colorScheme = theme.colorScheme;

//   // Default values
//   final effectiveAccentColor = accentColor ?? colorScheme.primary;
//   final effectiveBackgroundColor = backgroundColor ?? colorScheme.surface;

//   showGeneralDialog(
//     context: context,
//     barrierLabel: "Dialog Barrier",
//     barrierDismissible: isDismissible,
//     barrierColor: Colors.black.withValues(alpha:0.65),
//     transitionDuration: const Duration(milliseconds: 400),
//     pageBuilder: (_, __, ___) {
//       return WillPopScope(
//         onWillPop: () => Future.value(isDismissible),
//         child: Center(
//           child: Container(
//             margin: const EdgeInsets.symmetric(horizontal: 24),
//             constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
//             child: Material(
//               color: Colors.transparent,
//               child: TweenAnimationBuilder<double>(
//                 tween: Tween(begin: 0.0, end: 1.0),
//                 duration: const Duration(milliseconds: 300),
//                 curve: Curves.easeOutCubic,
//                 builder: (context, value, child) {
//                   return Transform.scale(
//                     scale: 0.8 + (0.2 * value),
//                     child: Opacity(opacity: value, child: child),
//                   );
//                 },
//                 child: _buildDialogCard(
//                   context,
//                   theme,
//                   colorScheme,
//                   title,
//                   description,
//                   confirmButtonText,
//                   cancelButtonText,
//                   onConfirm,
//                   onCancel,
//                   svgAssetPath,
//                   customIllustration,
//                   effectiveAccentColor,
//                   effectiveBackgroundColor,
//                   style,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );
//     },
//     transitionBuilder: (context, animation, secondaryAnimation, child) {
//       final curvedAnimation = CurvedAnimation(
//         parent: animation,
//         curve: Curves.easeOutCubic,
//         reverseCurve: Curves.easeInCubic,
//       );

//       return FadeTransition(
//         opacity: curvedAnimation,
//         child: SlideTransition(
//           position: Tween<Offset>(
//             begin: const Offset(0, 0.1),
//             end: Offset.zero,
//           ).animate(curvedAnimation),
//           child: child,
//         ),
//       );
//     },
//   );
// }

// /// Builds the main dialog card with appropriate styling based on the selected style
// Widget _buildDialogCard(
//   BuildContext context,
//   ThemeData theme,
//   ColorScheme colorScheme,
//   String title,
//   String description,
//   String confirmButtonText,
//   String? cancelButtonText,
//   VoidCallback? onConfirm,
//   VoidCallback? onCancel,
//   String? svgAssetPath,
//   Widget? customIllustration,
//   Color accentColor,
//   Color backgroundColor,
//   DialogStyle style,
// ) {
//   final illustration = customIllustration ??
//       (svgAssetPath != null
//           ? Padding(
//               padding: const EdgeInsets.only(bottom: 20, top: 10),
//               child: SvgPicture.asset(
//                 svgAssetPath,
//                 height: 150,
//                 width: 150,
//               ),
//             )
//           : null);

//   final content = Column(
//     mainAxisSize: MainAxisSize.min,
//     crossAxisAlignment: CrossAxisAlignment.stretch,
//     children: [
//       if (illustration != null) Center(child: illustration),

//       // Title with modern styling
//       Text(
//         title,
//         style: theme.textTheme.headlineSmall?.copyWith(
//           fontWeight: FontWeight.w700,
//           color: colorScheme.onSurface,
//           letterSpacing: -0.3,
//         ),
//         textAlign: TextAlign.center,
//       ),

//       const SizedBox(height: 16),

//       // Description
//       Text(
//         description,
//         style: theme.textTheme.bodyMedium?.copyWith(
//           color: colorScheme.onSurfaceVariant,
//           height: 1.5,
//           letterSpacing: 0.1,
//         ),
//         textAlign: TextAlign.center,
//       ),

//       const SizedBox(height: 28),

//       // Action buttons
//       _buildActionButtons(
//         context,
//         confirmButtonText,
//         cancelButtonText,
//         accentColor,
//         onConfirm,
//         onCancel,
//         style,
//       ),
//     ],
//   );

//   switch (style) {
//     case DialogStyle.rounded:
//       return Card(
//         elevation: 24,
//         shadowColor: Colors.black38,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(24),
//         ),
//         color: backgroundColor,
//         surfaceTintColor: Colors.transparent,
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: content,
//         ),
//       );

//     case DialogStyle.floating:
//       return Container(
//         decoration: BoxDecoration(
//           color: backgroundColor,
//           borderRadius: BorderRadius.circular(28),
//           boxShadow: [
//             BoxShadow(
//               color: accentColor.withValues(alpha:0.2),
//               blurRadius: 30,
//               spreadRadius: 5,
//             ),
//             BoxShadow(
//               color: Colors.black.withValues(alpha:0.1),
//               blurRadius: 20,
//               offset: const Offset(0, 10),
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(28.0),
//           child: content,
//         ),
//       );

//     case DialogStyle.glassmorphic:
//       return ClipRRect(
//         borderRadius: BorderRadius.circular(24),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//           child: Container(
//             decoration: BoxDecoration(
//               color: backgroundColor.withValues(alpha:0.7),
//               border: Border.all(
//                 color: Colors.white.withValues(alpha:0.2),
//                 width: 1.5,
//               ),
//               borderRadius: BorderRadius.circular(24),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(28.0),
//               child: content,
//             ),
//           ),
//         ),
//       );
//   }
// }

// /// Builds the action buttons based on the dialog style
// Widget _buildActionButtons(
//   BuildContext context,
//   String confirmText,
//   String? cancelText,
//   Color accentColor,
//   VoidCallback? onConfirm,
//   VoidCallback? onCancel,
//   DialogStyle style,
// ) {
//   // For styles that need different button layouts
//   switch (style) {
//     case DialogStyle.floating:
//     case DialogStyle.glassmorphic:
//       // Modern stacked buttons for these styles
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           _buildConfirmButton(
//             context,
//             confirmText,
//             accentColor,
//             style,
//             onConfirm,
//           ),
//           if (cancelText != null)
//             Padding(
//               padding: const EdgeInsets.only(top: 12),
//               child: TextButton(
//                 onPressed: () {
//                   if (onCancel != null) onCancel();
//                 },
//                 style: TextButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   foregroundColor: style == DialogStyle.glassmorphic
//                       ? Colors.white.withValues(alpha:0.8)
//                       : null,
//                 ),
//                 child: Text(cancelText),
//               ),
//             ),
//         ],
//       );

//     case DialogStyle.rounded:
//       // Side-by-side buttons
//       if (cancelText != null) {
//         return Row(
//           children: [
//             // Cancel button
//             Expanded(
//               child: OutlinedButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   if (onCancel != null) onCancel();
//                 },
//                 style: OutlinedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   side: BorderSide(
//                       color: Colors.grey.withValues(alpha:0.3), width: 1.5),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                 ),
//                 child: Text(cancelText),
//               ),
//             ),

//             const SizedBox(width: 16),

//             // Confirm button
//             Expanded(
//               child: _buildConfirmButton(
//                 context,
//                 confirmText,
//                 accentColor,
//                 style,
//                 onConfirm,
//               ),
//             ),
//           ],
//         );
//       } else {
//         return _buildConfirmButton(
//           context,
//           confirmText,
//           accentColor,
//           style,
//           onConfirm,
//         );
//       }
//   }
// }

// /// Helper method to create a consistent confirm button based on style
// Widget _buildConfirmButton(
//   BuildContext context,
//   String text,
//   Color accentColor,
//   DialogStyle style,
//   VoidCallback? onPressed,
// ) {
//   // Customize button based on style
//   switch (style) {
//     case DialogStyle.floating:
//       return ElevatedButton(
//         onPressed: () {
//           Navigator.of(context).pop();
//           if (onPressed != null) onPressed();
//         },
//         style: ElevatedButton.styleFrom(
//           backgroundColor: accentColor,
//           foregroundColor: Colors.white,
//           elevation: 0,
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           shadowColor: accentColor.withValues(alpha:0.5),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(text),
//             const SizedBox(width: 8),
//             const Icon(Icons.arrow_forward_rounded, size: 18),
//           ],
//         ),
//       );

//     case DialogStyle.glassmorphic:
//       return ElevatedButton(
//         onPressed: () {
//           Navigator.of(context).pop();
//           if (onPressed != null) onPressed();
//         },
//         style: ElevatedButton.styleFrom(
//           backgroundColor: accentColor.withValues(alpha:0.7),
//           foregroundColor: Colors.white,
//           elevation: 0,
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//         ),
//         child: Text(text),
//       );

//     case DialogStyle.rounded:
//       return ElevatedButton(
//         onPressed: () {
//           Navigator.of(context).pop();
//           if (onPressed != null) onPressed();
//         },
//         style: ElevatedButton.styleFrom(
//           backgroundColor: accentColor,
//           foregroundColor: Colors.white,
//           elevation: 2,
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(14),
//           ),
//         ),
//         child: Text(text),
//       );
//   }
// }

// /// Predefined dialog styles
// enum DialogStyle {
//   /// Standard rounded card with elevation
//   rounded,

//   /// Floating style with accent glow
//   floating,

//   /// Modern glassmorphic effect with blur
//   glassmorphic,
// }

// /// SVG illustration assets for common dialog scenarios
// class DialogIllustrations {
//   static const String update = 'assets/illustrations/update.svg';
//   static const String success = 'assets/illustrations/success.svg';
//   static const String error = 'assets/illustrations/error.svg';
//   static const String warning = 'assets/illustrations/warning.svg';
//   static const String info = 'assets/illustrations/info.svg';
// }
