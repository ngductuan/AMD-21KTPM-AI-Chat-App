import 'package:eco_chat_bot/src/widgets/gradient_loading_button.dart';
import 'package:eco_chat_bot/src/widgets/toast/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/styles.dart';
import 'verification_code.dart';

class VerificationEmailScreen extends StatefulWidget {
  const VerificationEmailScreen({Key? key}) : super(key: key);

  @override
  State<VerificationEmailScreen> createState() => _VerificationEmailScreenState();
}

class _VerificationEmailScreenState extends State<VerificationEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _handleSendCode() {
    String _email = _emailController.text.trim(); // Trim extra spaces

    if (!_isValidEmail(_email)) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('Please enter a valid email address'),
      //     backgroundColor: ColorConst.backgroundRedColor,
      //   ),
      // );
      AppToast(
        context: context,
        message: 'Please enter a valid email address',
        mode: AppToastMode.error,
      ).show(context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return; // Prevent state update if widget is disposed

      setState(() {
        _isLoading = false;
      });

      // Navigate to verification code screen with email as an argument
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationCodeScreen(
            email: _email,
          ),
        ),
      );
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
            icon: const Icon(Icons.headphones, color: ColorConst.textBlackColor),
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
            buildGradientLoadingButton(context, 'Send Verification Code', _isLoading, _handleSendCode),
          ],
        ),
      ),
    );
  }
}
