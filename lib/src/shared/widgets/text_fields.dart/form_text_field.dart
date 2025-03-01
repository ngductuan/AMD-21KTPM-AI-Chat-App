import 'package:eco_chat_bot/src/constants/colors.dart';
import 'package:eco_chat_bot/src/constants/dimensions.dart';
import 'package:eco_chat_bot/src/constants/text_style.dart';
import 'package:flutter/material.dart';

class FormTextFieldCustom extends StatelessWidget {
  const FormTextFieldCustom({
    Key? key,
    required this.title,
    required this.inputType,
    this.borderColor,
  }) : super(key: key);

  final String title;
  final String inputType;
  final Color? borderColor;

  // Function to determine keyboardType based on inputType
  TextInputType _getKeyboardType(String inputType) {
    switch (inputType) {
      case 'email':
        return TextInputType.emailAddress;
      case 'password':
        return TextInputType.visiblePassword;
      // Add more cases as needed
      default:
        return TextInputType.text;
    }
  }

  String _hintText(String inputType) {
    switch (inputType) {
      case 'text':
        return 'Nguyen Van A';
      case 'email':
        return 'example@gmail.com';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: AppTextStyle(context).getDefaultStyle().fontHeader.bold,
        ),
        const SizedBox(
          height: spacing16,
        ),
        TextFormField(
          style: AppTextStyle(context).getDefaultStyle().fontHeader,
          decoration: InputDecoration(
            hintText: _hintText(inputType),
            border: const OutlineInputBorder(),
            // focusColor: Colors.red,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: borderColor ?? Colors.yellow.shade700, width: 2),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColor.shadow),
            ),
            suffixIcon: inputType == 'password'
                ? const Icon(
                    Icons.visibility,
                    color: AppColor.shadow,
                  )
                : null,
            errorStyle: AppTextStyle(context)
                .getDefaultStyle()
                .setColor(AppColor.error),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColor.error),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColor.errorFocusBorder),
            ),
          ),

          keyboardType: _getKeyboardType(inputType),
          // textInputAction: TextInputAction.done,
          obscureText: inputType == 'password' ? true : false,
          validator: (value) {
            if (value == null || value.isEmpty) {
              switch (inputType) {
                case 'email':
                  return 'Please enter your email';
                case 'password':
                  return 'Please enter your password';
                default:
                  return null;
              }
            }
            return null;
          },
          onSaved: (value) {
            print(value);
          },
        )
      ],
    );
  }
}
