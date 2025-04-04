import 'dart:convert';
import 'package:eco_chat_bot/src/constants/api/api_base.dart';
import 'package:eco_chat_bot/src/constants/share_preferences/local_storage_key.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../widgets/input_field.dart';
import '../../../widgets/gradient_button.dart';
import 'login.dart';
import 'verification_email.dart';
import 'package:eco_chat_bot/src/pages/general/views/home.dart';
import '../../../constants/colors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields.';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Passwords do not match.';
      });
      return;
    }

    final url =
        Uri.parse('${ApiBase.authUrl}/api/v1/auth/password/sign-up');

    final body = jsonEncode({
      "email": email,
      "password": password,
      "verification_callback_url":
          ApiBase.verificationCallbackUrl,
    });

    try {
      var request = http.Request('POST', url);
      request.headers.addAll(ApiBase.headerAuth);
      request.body = body;

      http.StreamedResponse response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseJson = jsonDecode(responseBody);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(LocalStorageKey.accessToken, responseJson[LocalStorageKey.accessToken]);
        await prefs.setString(LocalStorageKey.refreshToken, responseJson[LocalStorageKey.refreshToken]);
        await prefs.setString(LocalStorageKey.userId, responseJson[LocalStorageKey.userId]);
        await prefs.setString(LocalStorageKey.email, email);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Đăng ký tài khoản thành công!',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );

          await prefs.setBool(LocalStorageKey.hasSeenWelcome, true); // Đánh dấu đã vào app
          Future.delayed(const Duration(milliseconds: 800), () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              HomeScreen.routeName,
              (route) => false,
            );
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Sign up failed: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: ColorConst.backgroundPastelColor,
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                // Logo
                                const SizedBox(height: 40),
                                Center(
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.purple.withOpacity(0.3),
                                          blurRadius: 12,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/logo/eco_chat_bot-logo.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),

                                // Sign up
                                const SizedBox(height: 30),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24.0),
                                  child: Column(
                                    children: [
                                      // SIGN UP text
                                      Text(
                                        'SIGN UP',
                                        style: GoogleFonts.poppins(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),

                                      // Error message
                                      if (_errorMessage.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            _errorMessage,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.red,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        )
                                      else
                                        const SizedBox(height: 10),

                                      // Email input
                                      InputField(
                                        label: 'Email',
                                        controller: _emailController,
                                        hintText: 'Enter your email',
                                        keyboardType:
                                            TextInputType.emailAddress,
                                      ),
                                      const SizedBox(height: 4),

                                      // Password input
                                      InputField(
                                        label: 'Password',
                                        controller: _passwordController,
                                        hintText: 'Enter your password',
                                        isPassword: true,
                                        keyboardType: TextInputType.text,
                                      ),
                                      const SizedBox(height: 4),

                                      // Confirm password input
                                      InputField(
                                        label: 'Confirm Password',
                                        controller: _confirmPasswordController,
                                        hintText: 'Re-enter your password',
                                        isPassword: true,
                                        keyboardType: TextInputType.text,
                                      ),
                                      const SizedBox(height: 2),

                                      // Forgot password
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const VerificationEmailScreen(),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'Forgot password?',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.blue[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Sign up button
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24.0),
                                  child: Column(
                                    children: [
                                      buildGradientButton(
                                          context, "Sign up", _signUp),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                ),

                                // Already have an account => Login
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Already have an account? ',
                                      style: GoogleFonts.poppins(
                                        color: Colors.black54,
                                        fontSize: 14,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            transitionDuration: const Duration(
                                                milliseconds: 400),
                                            pageBuilder: (context, animation,
                                                    secondaryAnimation) =>
                                                const LoginScreen(),
                                            transitionsBuilder: (context,
                                                animation,
                                                secondaryAnimation,
                                                child) {
                                              const begin = Offset(-1.0, 0.0);
                                              const end = Offset.zero;
                                              const curve = Curves.easeInOut;

                                              var tween = Tween(
                                                      begin: begin, end: end)
                                                  .chain(
                                                      CurveTween(curve: curve));
                                              var offsetAnimation =
                                                  animation.drive(tween);

                                              return SlideTransition(
                                                  position: offsetAnimation,
                                                  child: child);
                                            },
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Login',
                                        style: GoogleFonts.poppins(
                                          color: Colors.purple,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Terms and conditions
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0),
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: const TextSpan(
                                    style: TextStyle(
                                        color: Colors.black54, fontSize: 14),
                                    children: [
                                      TextSpan(
                                          text:
                                              'By continuing, you agree to our '),
                                      TextSpan(
                                        text: 'User Agreement',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black54),
                                      ),
                                      TextSpan(text: ' and '),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black54),
                                      ),
                                      TextSpan(text: '.'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
