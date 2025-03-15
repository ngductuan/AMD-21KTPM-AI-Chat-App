import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/input_field.dart';
import '../../../widgets/google_signin_button.dart';
import '../../../widgets/gradient_button.dart';
import '../../../constants/styles.dart';
import 'dart:async';

class VerificationCodeScreen extends StatefulWidget {
  final String email;

  const VerificationCodeScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final List<String> _code = ['', '', '', '', '', ''];
  int _currentIndex = 0;
  int _resendTime = 59;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTime == 0) {
        timer.cancel();
      } else {
        setState(() {
          _resendTime--;
        });
      }
    });
  }

  void _onKeyPressed(String value) {
    if (_currentIndex < 6) {
      setState(() {
        _code[_currentIndex] = value;
        _currentIndex++;
      });
    }
  }

  void _onDelete() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _code[_currentIndex] = '';
      });
    }
  }

  Widget _buildCodeBox(int index) {
    return Container(
      width: spacing44,
      height: spacing44,
      margin: const EdgeInsets.symmetric(horizontal: spacing6),
      decoration: BoxDecoration(
        color: ColorConst.backgroundGrayColor,
        borderRadius: BorderRadius.circular(radius12),
        border: Border.all(
          color: _code[index].isNotEmpty ? Colors.blue : Colors.transparent,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          _code[index],
          style: GoogleFonts.poppins(
            fontSize: fontSize28,
            fontWeight: FontWeight.bold,
            color: ColorConst.textBlackColor,
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadButton(String number, String letters) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () => _onKeyPressed(number),
        child: Container(
          height: spacing40 + spacing24,
          decoration: BoxDecoration(
            border: Border.all(color: ColorConst.grayOverlayColor),
            borderRadius: BorderRadius.circular(radius8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                number,
                style: GoogleFonts.poppins(
                  fontSize: fontSize24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (letters.isNotEmpty)
                Text(
                  letters,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: ColorConst.textGrayColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
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
      body: Column(
        children: [
          const SizedBox(height: spacing40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: spacing24),
            child: Column(
              children: [
                Text(
                  'Verification code has been sent to',
                  style: GoogleFonts.poppins(
                    fontSize: fontSize18,
                    color: ColorConst.textBlackColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: spacing8),
                Text(
                  widget.email,
                  style: GoogleFonts.poppins(
                    fontSize: fontSize20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: spacing40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (index) => _buildCodeBox(index)),
          ),
          const SizedBox(height: spacing16),
          TextButton(
            onPressed: _resendTime == 0
                ? () {
                    setState(() {
                      _resendTime = 59;
                    });
                    startTimer();
                  }
                : null,
            child: Text(
              'Resend ${_resendTime > 0 ? '${_resendTime}s' : ''}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: ColorConst.textGrayColor,
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildKeypadButton('1', '')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildKeypadButton('2', 'ABC')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildKeypadButton('3', 'DEF')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildKeypadButton('4', 'GHI')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildKeypadButton('5', 'JKL')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildKeypadButton('6', 'MNO')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildKeypadButton('7', 'PQRS')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildKeypadButton('8', 'TUV')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildKeypadButton('9', 'WXYZ')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Spacer(),
                    Expanded(child: _buildKeypadButton('0', '')),
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: spacing80,
                          child: Material(
                            color: Colors.white,
                            child: InkWell(
                              onTap: _onDelete,
                              child: Container(
                                height: spacing60,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color:
                                          ColorConst.backgroundLightGrayColor),
                                  borderRadius: BorderRadius.circular(radius8),
                                ),
                                child: const Center(
                                  child: Icon(Icons.backspace_outlined),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
