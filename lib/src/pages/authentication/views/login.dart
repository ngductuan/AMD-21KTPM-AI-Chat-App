import 'dart:convert';

import 'package:eco_chat_bot/src/constants/api/api_base.dart';
import 'package:eco_chat_bot/src/constants/share_preferences/local_storage_key.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/pages/authentication/views/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../widgets/input_field.dart';
import '../../../widgets/google_signin_button.dart';
import '../../../widgets/gradient_button.dart';
import 'verification_email.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final url = Uri.parse('${ApiBase.authUrl}/api/v1/auth/password/sign-in');

    final body = jsonEncode({
      'email': email,
      'password': password,
    });

    try {
      final response =
          await http.post(url, headers: ApiBase.headerAuth, body: body);
      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(LocalStorageKey.accessToken,
            responseJson[LocalStorageKey.accessToken]);
        await prefs.setString(LocalStorageKey.refreshToken,
            responseJson[LocalStorageKey.refreshToken]);
        await prefs.setString(
            LocalStorageKey.userId, responseJson[LocalStorageKey.userId]);
        await prefs.setString(LocalStorageKey.email, email);
        await prefs.setBool(
            LocalStorageKey.hasSeenWelcome, true); // Đánh dấu đã vào app

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đăng nhập thành công!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );

          await Future.delayed(const Duration(milliseconds: 800));
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home', // Hoặc HomeScreen.routeName nếu bạn đã import
            (route) => false,
          );
        }
      } else {
        setState(() {
          _errorMessage =
              responseJson['error'] ?? 'Login failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      // Chuyển hướng sau khi đăng nhập thành công
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        _errorMessage = "Google Sign-In failed. Please try again.";
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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // Logo
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

                    const SizedBox(height: 32),

                    // Form
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          Text(
                            'LOGIN',
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),

                          // Error message
                          if (_errorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                _errorMessage,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                          const SizedBox(height: 24),

                          InputField(
                            label: 'Email',
                            controller: _emailController,
                            hintText: 'Enter your email',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),

                          InputField(
                            label: 'Password',
                            controller: _passwordController,
                            hintText: 'Enter your password',
                            isPassword: true,
                            keyboardType: TextInputType.text,
                          ),

                          // Forgot Password
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

                    const SizedBox(height: 12),

                    // Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          buildGradientButton(
                              context, "Login", _signInWithEmail),
                          const SizedBox(height: 16),
                          GoogleSignInButton(
                            onPressed: _signInWithGoogle,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Sign Up
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No account yet? ',
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
                                transitionDuration:
                                    const Duration(milliseconds: 400),
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const SignUpScreen(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOut;

                                  var tween = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: curve));
                                  var offsetAnimation = animation.drive(tween);

                                  return SlideTransition(
                                      position: offsetAnimation, child: child);
                                },
                              ),
                            );
                          },
                          child: Text(
                            'Sign up',
                            style: GoogleFonts.poppins(
                              color: Colors.purple,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 36),

                    // Terms and conditions
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 14),
                              children: [
                                TextSpan(
                                    text: 'By continuing, you agree to our '),
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
          ),
        ),
      ),
    );
  }
}
