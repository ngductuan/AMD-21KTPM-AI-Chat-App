import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:flutter/material.dart';

class ElevatedCustom extends StatefulWidget {
  const ElevatedCustom(
      {super.key,
      required this.title,
      this.ontap,
      this.height = spacing52,
      this.width,
      this.color,
      this.textStyle,
      this.radius = 25.0,
      this.elevation = 0});

  final String title;
  final double? height;
  final double? width;
  final Color? color;
  final TextStyle? textStyle;
  final double radius;
  final double elevation;
  final Function()? ontap;

  @override
  State<ElevatedCustom> createState() => _ElevatedCustomState();
}

class _ElevatedCustomState extends State<ElevatedCustom> {
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: widget.elevation,
      borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
      color: widget.color ?? AppColor.mainColor2,
      child: InkWell(
        onTap: widget.ontap,
        splashColor: colorsByTheme(context).rippleColor,
        borderRadius: const BorderRadius.all(Radius.circular(25)),
        child: Container(
          height: widget.height,
          width: widget.width,
          padding: const EdgeInsets.symmetric(
              vertical: padding16, horizontal: padding8),
          alignment: Alignment.center,
          child: Text(
            widget.title,
            style: widget.textStyle ??
                AppTextStyle(context)
                    .getDefaultStyle()
                    .setColor(AppColor.defaultFontLight)
                    .bold,
          ),
        ),
      ),
    );
  }
}
