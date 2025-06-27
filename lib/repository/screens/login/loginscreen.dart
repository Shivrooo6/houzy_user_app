import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:houzy/const.dart';
import 'package:houzy/repository/screens/bottomnav/bottomnavscreen.dart';
import 'package:houzy/repository/widgets/uihelper.dart';
import 'package:houzy/screens/userauth/firebaseauthservices.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoading = false;
  bool isLoginMode = true;

  Future<void> _handleGoogleAuth() async {
    setState(() => _isLoading = true);

    try {
      final user = await _authService.signInWithGoogle();
      print("User: $user");

      if (user == null) {
        _showMessage("Google Sign-In failed");
        return;
      }

      final userData = {
        "name": user.displayName ?? "No Name",
        "email": user.email ?? "",
        "firebaseUid": user.uid,
        "profileImage": user.photoURL ?? "",
      };

      final String url = isLoginMode
          ? "$apiUrl_backendregisterapi/user/login"
          : "$apiUrl_backendregisterapi/user/register";

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userData),
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavScreen()),
        );
      } else if (response.statusCode == 404 && isLoginMode) {
        _showMessage("You are not registered, please sign up first.");
      } else if (response.statusCode == 400 && !isLoginMode) {
        _showMessage("You are already registered, please log in.");
      } else {
        final errorMsg = jsonDecode(response.body)['message'] ?? "Something went wrong";
        _showMessage("Error: $errorMsg");
      }
    } catch (e) {
      _showMessage("Error: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 350,
                    height: 80,
                    child: UiHelper.CustomImage(img: "houzylogoimage.png"),
                  ),
                  const Positioned(
                    top: -2,
                    left: 12,
                    child: Icon(Icons.star, color: Color(0xFFFE600E), size: 18),
                  ),
                  const Positioned(
                    top: -3,
                    right: 20,
                    child: Icon(Icons.star, color: Color(0xFFFE600E), size: 20),
                  ),
                  const Positioned(
                    bottom: 0,
                    left: 0,
                    child: Icon(Icons.star, color: Color(0xFFFE600E), size: 16),
                  ),
                  const Positioned(
                    bottom: 0,
                    right: 10,
                    child: Icon(Icons.star, color: Color(0xFFFE600E), size: 14),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              UiHelper.CustomText(
                text: "Professional House Cleaning Service",
                color: const Color(0xFFFE600E),
                fontweight: FontWeight.bold,
                fontsize: 10,
                fontfamily: "bold",
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() => isLoginMode = true),
                    child: const Text("Sign In"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLoginMode ? const Color(0xFFFE600E) : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => setState(() => isLoginMode = false),
                    child: const Text("Sign Up"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !isLoginMode ? const Color(0xFFFE600E) : Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 48),
                child: SizedBox(
                  width: 450,
                  height: 350,
                  child: UiHelper.CustomImage(img: "loginsvg.png"),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleAuth,
                  icon: SizedBox(
                    width: 24,
                    height: 24,
                    child: Image.asset('assets/images/googleicon.png'),
                  ),
                  label: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          isLoginMode ? "Login with Google" : "Register with Google",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text.rich(
                TextSpan(
                  text: 'By continuing, you agree to our ',
                  style: const TextStyle(fontSize: 12),
                  children: [
                    TextSpan(
                      text: 'T&C',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const TextSpan(text: ' policy.'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
