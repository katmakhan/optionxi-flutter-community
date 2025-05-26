import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:optionxi/Helpers/global_snackbar_get.dart';
import 'package:optionxi/Login_Signup/login.dart';
import 'package:optionxi/Login_Signup/otp.dart';
import 'package:optionxi/homepage.dart';

class SupabaseAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Determine if the user is authenticated
  Widget handleAuthState() {
    return StreamBuilder<AuthState>(
      stream: _supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final session = snapshot.data?.session;
        if (session != null) {
          // User is already authenticated, navigate to the homepage
          return Homepage();
        } else {
          // User is not authenticated, navigate to the login page
          return ModernTradingLoginPage();
        }
      },
    );
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      final bool success = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo:
            'https://supabase.optionxi.com/auth/v1/callback', // Configure this for your app
      );

      if (success) {
        GlobalSnackBarGet()
            .showGetSucess("Success", "Successfully signed in with Google");
        return true;
      }
      return false;
    } on PlatformException catch (e) {
      if (e.code == 'network_error') {
        GlobalSnackBarGet().showGetError("Network Error", "No internet found");
      } else {
        GlobalSnackBarGet().showGetError("Error", e.message ?? "Unknown error");
      }
      return false;
    } catch (e) {
      GlobalSnackBarGet().showGetError("Error", e.toString());
      return false;
    }
  }

  // Sign in with Apple
  Future<bool> signInWithApple() async {
    try {
      final bool success = await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo:
            'https://supabase.optionxi.com/auth/v1/callback', // Configure this for your app
      );

      if (success) {
        GlobalSnackBarGet()
            .showGetSucess("Success", "Successfully signed in with Apple");
        return true;
      }
      return false;
    } on PlatformException catch (e) {
      if (e.code == 'network_error') {
        GlobalSnackBarGet().showGetError("Network Error", "No internet found");
      } else {
        GlobalSnackBarGet().showGetError("Error", e.message ?? "Unknown error");
      }
      return false;
    } catch (e) {
      GlobalSnackBarGet().showGetError("Error", e.toString());
      return false;
    }
  }

  // Sign in with email and password
  Future<AuthResponse?> signInWithEmailPassword(
      String email, String password) async {
    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        GlobalSnackBarGet().showGetSucess("Success", "Successfully signed in");
        return response;
      }
      return null;
    } catch (e) {
      String errorMessage = "Sign in failed";
      if (e is AuthException) {
        errorMessage = e.message;
      }
      GlobalSnackBarGet().showGetError("Error", errorMessage);
      return null;
    }
  }

  // Sign up with email and password
  Future<AuthResponse?> signUpWithEmailPassword(
      String email, String password) async {
    try {
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        GlobalSnackBarGet().showGetSucess("Success",
            "Account created successfully. Please check your email for verification.");
        return response;
      }
      return null;
    } catch (e) {
      String errorMessage = "Sign up failed";
      if (e is AuthException) {
        errorMessage = e.message;
      }
      GlobalSnackBarGet().showGetError("Error", errorMessage);
      return null;
    }
  }

  // Sign in with mobile OTP
  Future<void> signInWithMobileOTP(
      String phoneNumber, BuildContext context) async {
    try {
      await _supabase.auth.signInWithOtp(
        phone: phoneNumber,
        shouldCreateUser: true,
      );

      GlobalSnackBarGet().showGetSucess("Success", "OTP sent to $phoneNumber");

      // Navigate to OTP verification page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OTP(phoneNumber)),
      );
    } catch (e) {
      String errorMessage = "Failed to send OTP";
      if (e is AuthException) {
        errorMessage = e.message;
      }
      GlobalSnackBarGet().showGetError("Error", errorMessage);
    }
  }

  // Verify OTP
  Future<AuthResponse?> verifyOTP(String phone, String otp) async {
    try {
      final AuthResponse response = await _supabase.auth.verifyOTP(
        type: OtpType.sms,
        token: otp,
        phone: phone,
      );

      if (response.user != null) {
        GlobalSnackBarGet().showGetSucess("Success", "Successfully logged in");
        return response;
      }
      return null;
    } catch (e) {
      String errorMessage = "Invalid OTP";
      if (e is AuthException) {
        if (e.message.contains("invalid")) {
          errorMessage = "Invalid OTP";
        } else {
          errorMessage = e.message;
        }
      }
      GlobalSnackBarGet().showGetError("Error", errorMessage);
      return null;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      GlobalSnackBarGet()
          .showGetSucess("Success", "Password reset email sent to $email");
    } catch (e) {
      String errorMessage = "Failed to send reset email";
      if (e is AuthException) {
        errorMessage = e.message;
      }
      GlobalSnackBarGet().showGetError("Error", errorMessage);
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      GlobalSnackBarGet()
          .showGetSucess("Success", "Password updated successfully");
    } catch (e) {
      String errorMessage = "Failed to update password";
      if (e is AuthException) {
        errorMessage = e.message;
      }
      GlobalSnackBarGet().showGetError("Error", errorMessage);
    }
  }

  // Update user profile
  Future<void> updateProfile({String? displayName, String? email}) async {
    try {
      final Map<String, dynamic> updates = {};
      if (displayName != null) updates['display_name'] = displayName;

      await _supabase.auth.updateUser(
        UserAttributes(
          email: email,
          data: updates,
        ),
      );

      GlobalSnackBarGet()
          .showGetSucess("Success", "Profile updated successfully");
    } catch (e) {
      String errorMessage = "Failed to update profile";
      if (e is AuthException) {
        errorMessage = e.message;
      }
      GlobalSnackBarGet().showGetError("Error", errorMessage);
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _supabase.auth.currentUser != null;
  }

  // Get current session
  Session? getCurrentSession() {
    return _supabase.auth.currentSession;
  }

  // Sign out
  Future<void> logOut() async {
    try {
      await _supabase.auth.signOut();
      GlobalSnackBarGet().showGetSucess("Success", "Successfully logged out");
    } catch (e) {
      GlobalSnackBarGet().showGetError("Error", "Failed to log out");
    }
  }
}
