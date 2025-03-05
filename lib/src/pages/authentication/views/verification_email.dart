import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/styles.dart';

class VerificationEmailScreen extends StatefulWidget {
  const VerificationEmailScreen({Key? key}) : super(key: key);

  @override
  State<VerificationEmailScreen> createState() =>
      _VerificationEmailScreenState();
}

class _VerificationEmailScreenState extends State<VerificationEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _handleSendCode() {
    if (!_isValidEmail(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: ColorConst.backgroundRedColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
      // Navigate to verification code screen
      // Navigator.push(...);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.backgroundWhiteColor,
      appBar: AppBar(
        backgroundColor: ColorConst.backgroundWhiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColorConst.textBlackColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.headphones, color: ColorConst.textBlackColor),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: spacing24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: spacing40),
            Text(
              'Email',
              style: GoogleFonts.poppins(
                fontSize: fontSize32,
                fontWeight: FontWeight.bold,
                color: ColorConst.textBlackColor,
              ),
            ),
            const SizedBox(height: spacing32),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Enter email',
                hintStyle: GoogleFonts.poppins(
                  color: ColorConst.textGrayColor,
                  fontSize: fontSize16,
                ),
                filled: true,
                fillColor: ColorConst.backgroundLightGrayColor2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(spacing32),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: spacing20,
                  vertical: spacing16,
                ),
              ),
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: ColorConst.textBlackColor,
              ),
            ),
            const SizedBox(height: spacing24),
            Container(
              width: double.infinity,
              height: spacing56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(spacing30),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4285F4), // Google blue
                    Color(0xFFEA4335), // Google red
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSendCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(spacing30),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: spacing20,
                        width: spacing20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              ColorConst.backgroundWhiteColor),
                        ),
                      )
                    : Text(
                        'Send Verification Code',
                        style: GoogleFonts.poppins(
                          color: ColorConst.textWhiteColor,
                          fontSize: fontSize18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
