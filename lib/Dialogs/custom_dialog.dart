import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class DialogUtils {
  static final DialogUtils _instance = DialogUtils.internal();

  DialogUtils.internal();

  factory DialogUtils() => _instance;

  static void showCustomDialog(
      BuildContext context,
      String title,
      String description,
      String okBtnText,
      String cancelBtnText,
      Function okBtnFunction) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(title),
            content: Text(description),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                    onTap: () => {okBtnFunction.call()},
                    child: Text(okBtnText)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 16, 0),
                child: InkWell(
                    onTap: () => {Navigator.pop(context)},
                    child: Text(cancelBtnText)),
              )
            ],
          );
        });
  }

  void showCustomDialogGreen(BuildContext context, String title, String descrip,
      String date, String image, Function okBtnFunction) {
    showGeneralDialog(
      context: context,
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (_, __, ___) {
        return AlertDialog(
          // backgroundColor: Colors.black.withValues(alpha:0.2),
          content: Center(
            child: Container(
              width: 260,
              height: 380,
              decoration: ShapeDecoration(
                color: const Color(0xFF1BD592),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    height: 6,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                          onTap: () => {Navigator.pop(context)},
                          child:
                              SvgPicture.asset("assets/images/closebtn.svg")),
                      const SizedBox(
                        width: 4,
                      )
                    ],
                  ),
                  SvgPicture.asset(image),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.w500,
                      height: 1,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 200,
                        height: 98,
                        decoration: const ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10)),
                          ),
                        ),
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  descrip,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF014342),
                                    fontSize: 14,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                    height: 0,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Expanded(
                                child: Text(
                                  date,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF014342),
                                    fontSize: 14,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                    height: 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => {okBtnFunction.call()},
                        child: Container(
                          width: 60,
                          height: 98,
                          decoration: const ShapeDecoration(
                            color: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(10)),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'OK',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w500,
                                height: 0,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        Tween<Offset> tween;
        if (anim.status == AnimationStatus.reverse) {
          tween = Tween(begin: const Offset(-1, 0), end: Offset.zero);
        } else {
          tween = Tween(begin: const Offset(1, 0), end: Offset.zero);
        }

        return SlideTransition(
          position: tween.animate(anim),
          child: FadeTransition(
            opacity: anim,
            child: child,
          ),
        );
      },
    );
  }

  void showCustomDialogUpdate({
    required BuildContext context,
    required String title,
    required String description,
    required String confirmButtonText,
    String? cancelButtonText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDismissible = true,
    IconData? icon,
    Color? accentColor,
  }) {
    // Haptic feedback for dialog appearance
    HapticFeedback.mediumImpact();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Use provided accent color or default to primary
    final effectiveAccentColor = accentColor ?? colorScheme.primary;

    showGeneralDialog(
      context: context,
      barrierLabel: "Dialog Barrier",
      barrierDismissible: isDismissible,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return WillPopScope(
          onWillPop: () => Future.value(isDismissible),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              constraints: const BoxConstraints(maxWidth: 400),
              child: Material(
                color: Colors.transparent,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + (0.2 * value),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: Card(
                    elevation: 8,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Dialog header with icon
                          if (icon != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: CircleAvatar(
                                backgroundColor:
                                    effectiveAccentColor.withValues(alpha: 0.1),
                                radius: 28,
                                child: Icon(
                                  icon,
                                  color: effectiveAccentColor,
                                  size: 28,
                                ),
                              ),
                            ),

                          // Title
                          Text(
                            title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 16),

                          // Description
                          Text(
                            description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 24),

                          // Buttons row or column based on whether we have cancel button
                          if (cancelButtonText != null)
                            Row(
                              children: [
                                // Cancel button
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      if (onCancel != null) onCancel();
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      side: BorderSide(
                                          color: colorScheme.outline),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(cancelButtonText),
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // Confirm button
                                Expanded(
                                  child: _buildConfirmButton(
                                    context,
                                    confirmButtonText,
                                    effectiveAccentColor,
                                    onConfirm,
                                  ),
                                ),
                              ],
                            )
                          else
                            _buildConfirmButton(
                              context,
                              confirmButtonText,
                              effectiveAccentColor,
                              onConfirm,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  /// Helper method to create a consistent confirm button
  Widget _buildConfirmButton(
    BuildContext context,
    String text,
    Color accentColor,
    VoidCallback? onPressed,
  ) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pop();
        if (onPressed != null) onPressed();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(text),
    );
  }

  static Container DialogContent(
      String title,
      String description,
      String okBtnText,
      BuildContext context,
      String cancelBtnText,
      Function acceptFunction,
      Function DeclineFunction,
      bool compulsory) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 16, left: 16),
            child: Text(title,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                    fontSize: 20,
                    color: Color(0xFF363e44),
                    fontWeight: FontWeight.w700)),
          ),
          Container(
            margin:
                const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 16),
            child: Text(description,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.none,
                    fontSize: 16,
                    color: const Color(0xFF45413C).withValues(alpha: 0.8),
                    fontWeight: FontWeight.w400)),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Visibility(
                  visible: !compulsory,
                  child: GestureDetector(
                    onTap: () => {DeclineFunction.call()},
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: Text(
                        cancelBtnText,
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            decoration: TextDecoration.none,
                            fontSize: 12,
                            color: Color(0xFFE61E26),
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => {acceptFunction.call()},
                  child: Container(
                    height: 28,
                    width: 86,
                    decoration: const BoxDecoration(
                      color: Color(0xff9E00FF),
                    ),
                    child: Center(
                      child: Text(
                        okBtnText,
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            decoration: TextDecoration.none,
                            color: Color(0xFFFFFFFF),
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
