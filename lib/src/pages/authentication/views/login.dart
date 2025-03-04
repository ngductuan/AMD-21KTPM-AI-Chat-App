import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/input_field.dart';
import '../widgets/google_signin_button.dart';
import '../../../widgets/gradient_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              decoration: BoxDecoration(
                gradient: ColorConst.backgroundPastelColor,
              ),
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

                          //Error message
                          if (_errorMessage.isNotEmpty) ...[
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
                          ] else ...[
                            SizedBox(height: 24),
                          ],

                          InputField(
                            label: 'Username',
                            controller: _usernameController,
                            hintText: 'Enter your username',
                          ),
                          const SizedBox(height: 16),

                          InputField(
                            label: 'Password',
                            controller: _passwordController,
                            hintText: 'Enter your password',
                            isPassword: true,
                          ),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
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
                          buildGradientButton(context, "Login", () {
                            setState(() {
                              if (_usernameController.text.isEmpty ||
                                  _passwordController.text.isEmpty) {
                                _errorMessage =
                                    'Username or password is incorrect!';
                              } else {
                                _errorMessage = '';
                                // Handle login logic here
                              }
                            });
                          }),
                          const SizedBox(height: 16),
                          GoogleSignInButton(),
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

                    // Terms
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 8.0),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                          children: [
                            TextSpan(text: 'By continuing, you agree to our '),
                            TextSpan(
                              text: 'User Agreement',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54),
                            ),
                            TextSpan(text: ' and\u00A0'),
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
