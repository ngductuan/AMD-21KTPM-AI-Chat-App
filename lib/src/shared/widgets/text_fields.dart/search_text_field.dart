import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:flutter/material.dart';

class SearchTextFieldCustom extends StatefulWidget {
  const SearchTextFieldCustom({super.key, this.focusNode});

  final FocusNode? focusNode;
  @override
  State<SearchTextFieldCustom> createState() => _SearchTextFieldCustomState();
}

class _SearchTextFieldCustomState extends State<SearchTextFieldCustom> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: _focusNode,
      // controller: widget.controller,
      cursorColor: AppColor.mainColor2,
      // onChanged: (value) {
      //   setState(() {});
      // },
      // onSubmitted: (value) {
      //   setState(() {});
      //   // widget.onSubmitted?.call(value);
      // },
      style: AppTextStyle(context).getDefaultStyle().fontCaption,
      decoration: InputDecoration(
        // hintText: widget.hintText,
        // hintStyle: const TextStyle(height: 1),
        // errorText: widget.controller.text.length > 100
        //     ? S.current.txtSearchError
        //     : null,
        // errorMaxLines: 2,
        // errorStyle: const TextStyle(
        //   fontSize: bodySmallSize,
        //   fontWeight: bodySmallWeight,
        //   color: AppColor.error,
        // ),
        prefixIcon: const Icon(Icons.search_rounded, size: 24),
        prefixIconColor: AppColor.shadow,
        // suffixIcon: widget.controller.text.isNotEmpty
        //     ? IconButton(
        //         icon: Icon(
        //           Icons.clear_rounded,
        //           color: widget.controller.text.length > 100
        //               ? AppColor.error
        //               : highlightClear
        //                   ? AppColor.mainColor2
        //                   : AppColor.container,
        //         ),
        //         onPressed: () {
        //           widget.controller.clear();
        //           widget.onSubmitted?.call('');
        //           setState(() {});
        //           if (!_focusNode.hasFocus) {
        //             _focusNode.requestFocus();
        //           }
        //         })
        //     : null,
        suffixIcon: const Icon(Icons.clear_rounded),
        suffixIconColor: AppColor.shadow,
        contentPadding: const EdgeInsets.fromLTRB(16, 25, 16, 0),

        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius8)),
          borderSide: BorderSide(
            color: AppColor.container,
            width: enabledOutlineWidthTextField,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(radius8)),
          borderSide: BorderSide(
            color: AppColor.background
                .withOpacity(disabledOutlineOpacityOutlinedTextField),
            width: disabledOutlineWidthTextField,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius8)),
          borderSide: BorderSide(
            color: AppColor.mainColor2,
            width: focusedOutlineWidthTextField,
          ),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius8)),
          borderSide: BorderSide(
              color: AppColor.error, width: errorOutlineWidthTextField / 2),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius8)),
          borderSide: BorderSide(
            color: AppColor.error,
            width: errorOutlineWidthTextField,
          ),
        ),
      ),
    );
  }
}
