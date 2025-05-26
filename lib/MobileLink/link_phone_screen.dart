import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'package:optionxi/Helpers/global_snackbar_get.dart';

class CountryCode {
  final String name;
  final String code;
  final String flag;

  CountryCode({required this.name, required this.code, required this.flag});
}

class LinkPhoneScreen extends StatefulWidget {
  const LinkPhoneScreen({Key? key}) : super(key: key);

  @override
  State<LinkPhoneScreen> createState() => _LinkPhoneScreenState();
}

class _LinkPhoneScreenState extends State<LinkPhoneScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String? _verificationId;
  bool _isOtpSent = false;
  bool _isLoading = false;
  bool _isObscured = true;
  int _remainingTime = 0;
  Timer? _timer;

  // List of common country codes
  final List<CountryCode> _countryCodes = [
    CountryCode(name: "United States", code: "+1", flag: "🇺🇸"),
    CountryCode(name: "Canada", code: "+1", flag: "🇨🇦"),
    CountryCode(name: "United Kingdom", code: "+44", flag: "🇬🇧"),
    CountryCode(name: "India", code: "+91", flag: "🇮🇳"),
    CountryCode(name: "Australia", code: "+61", flag: "🇦🇺"),
    CountryCode(name: "China", code: "+86", flag: "🇨🇳"),
    CountryCode(name: "Germany", code: "+49", flag: "🇩🇪"),
    CountryCode(name: "France", code: "+33", flag: "🇫🇷"),
    CountryCode(name: "Japan", code: "+81", flag: "🇯🇵"),
    CountryCode(name: "Brazil", code: "+55", flag: "🇧🇷"),
  ];

  CountryCode _selectedCountryCode =
      CountryCode(name: "India", code: "+91", flag: "🇮🇳");

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _remainingTime = 30;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime <= 0) {
        timer.cancel();
      } else {
        setState(() {
          _remainingTime--;
        });
      }
    });
  }

  void _sendOtp() async {
    String phone =
        "${_selectedCountryCode.code}${_phoneController.text.trim()}";
    if (_phoneController.text.trim().isEmpty) {
      GlobalSnackBarGet().showGetError("Invalid", "Enter a valid phone number");
      return;
    }

    setState(() => _isLoading = true);
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.currentUser?.linkWithCredential(credential);
        GlobalSnackBarGet()
            .showGetSucess("Linked", "Phone number linked automatically");
        Navigator.pop(context);
      },
      verificationFailed: (FirebaseAuthException e) {
        GlobalSnackBarGet()
            .showGetError("Failed", e.message ?? "Something went wrong");
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _isOtpSent = true;
        });
        _startResendTimer();
        GlobalSnackBarGet().showGetSucess("OTP Sent", "Check your messages");
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
    setState(() => _isLoading = false);
  }

  void _verifyOtp() async {
    String otp = _otpController.text.trim();
    if (otp.length != 6) {
      GlobalSnackBarGet().showGetError("Invalid", "Enter a valid 6-digit OTP");
      return;
    }

    try {
      setState(() => _isLoading = true);
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      await FirebaseAuth.instance.currentUser?.linkWithCredential(credential);
      GlobalSnackBarGet()
          .showGetSucess("Success", "Phone number linked successfully");
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked' ||
          e.code == 'credential-already-in-use') {
        // If phone number already linked or used by another account, update manually
        await update_usermobile_database(); // <- Your function
        GlobalSnackBarGet().showGetSucess(
            "Updated", "Phone number already linked. User database updated.");
        Navigator.pop(context);
      } else {
        GlobalSnackBarGet()
            .showGetError("Error", e.message ?? "Something went wrong");
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showCountryCodePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        // final isDark = theme.brightness == Brightness.dark;

        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select Country",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _countryCodes.length,
                  itemBuilder: (context, index) {
                    final country = _countryCodes[index];
                    return ListTile(
                      leading: Text(
                        country.flag,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(country.name),
                      subtitle: Text(country.code),
                      onTap: () {
                        setState(() {
                          _selectedCountryCode = country;
                        });
                        Navigator.pop(context);
                      },
                      hoverColor: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.1),
                      tileColor: Colors.transparent,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Adaptive colors based on theme
    final iconContainerColor = isDark
        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2)
        : theme.colorScheme.primaryContainer.withValues(alpha: 0.3);

    final inputFieldColor = isDark
        ? theme.colorScheme.surfaceVariant.withValues(alpha: 0.3)
        : theme.colorScheme.surfaceVariant.withValues(alpha: 0.5);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Link Phone Number",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Illustration or icon
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: iconContainerColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    !_isOtpSent ? Icons.phone_android : Icons.verified_user,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Title
              Center(
                child: Text(
                  !_isOtpSent
                      ? "Verify Your Phone Number"
                      : "Enter Verification Code",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Subtitle
              Center(
                child: Text(
                  !_isOtpSent
                      ? "We'll send a verification code to this number"
                      : "A 6-digit code has been sent to your phone",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Input fields
              _isLoading
                  ? Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            !_isOtpSent ? "Sending code..." : "Verifying...",
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : !_isOtpSent
                      ? _buildPhoneInput(theme, inputFieldColor)
                      : _buildOtpInput(theme, inputFieldColor),
              const Spacer(),
              // Button
              ElevatedButton(
                onPressed:
                    _isLoading ? null : (!_isOtpSent ? _sendOtp : _verifyOtp),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  disabledBackgroundColor: isDark
                      ? theme.colorScheme.primary.withValues(alpha: 0.3)
                      : theme.colorScheme.primary.withValues(alpha: 0.4),
                  disabledForegroundColor: isDark
                      ? theme.colorScheme.onPrimary.withValues(alpha: 0.4)
                      : theme.colorScheme.onPrimary.withValues(alpha: 0.6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  !_isOtpSent ? "Send Verification Code" : "Verify & Link",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (_isOtpSent) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() {
                                _isOtpSent = false;
                                _otpController.clear();
                                _timer?.cancel();
                              });
                            },
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        disabledForegroundColor:
                            theme.colorScheme.primary.withValues(alpha: 0.4),
                      ),
                      child: Text(
                        "Change Number",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed:
                          _remainingTime > 0 || _isLoading ? null : _sendOtp,
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        disabledForegroundColor:
                            theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      child: Text(
                        _remainingTime > 0
                            ? "Resend in ${_remainingTime}s"
                            : "Resend OTP",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInput(ThemeData theme, Color inputFieldColor) {
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark
        ? theme.colorScheme.outline.withValues(alpha: 0.2)
        : theme.colorScheme.outline.withValues(alpha: 0.3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Phone Number",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: inputFieldColor,
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Country code selector
              InkWell(
                onTap: _showCountryCodePicker,
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(16)),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: borderColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _selectedCountryCode.flag,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedCountryCode.code,
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              // Phone input
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: "Phone number",
                    hintStyle:
                        TextStyle(color: theme.colorScheme.onSurfaceVariant),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    suffixIcon: _phoneController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _phoneController.clear();
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    // Trigger a rebuild to show/hide the clear button
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpInput(ThemeData theme, Color inputFieldColor) {
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark
        ? theme.colorScheme.outline.withValues(alpha: 0.2)
        : theme.colorScheme.outline.withValues(alpha: 0.3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Verification Code",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: inputFieldColor,
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            obscureText: _isObscured,
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface,
              letterSpacing: _isObscured ? 2.0 : 0.5,
            ),
            decoration: InputDecoration(
              hintText: "Enter 6-digit code",
              hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              prefixIcon: Icon(
                Icons.lock_outline,
                color: theme.colorScheme.primary,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                "Enter the code sent to ${_selectedCountryCode.code}${_phoneController.text}",
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  update_usermobile_database() {}
}
