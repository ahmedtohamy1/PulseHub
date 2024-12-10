import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pulsehub/core/theming/app_colors.dart';
import 'package:pulsehub/core/theming/app_styles.dart';
import 'package:pulsehub/core/theming/font_weight_helper.dart';

class AppTextFormField extends StatelessWidget {
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? focusedBorder;
  final InputBorder? enabledBorder;
  final TextStyle? inputTextStyle;
  final TextStyle? hintStyle;
  final String hintText;
  final bool isObscureText;
  final Widget? suffixIcon;
  final Color? backgroundColor;
  final TextEditingController? controller;
  final bool isEnabled; // updated to be required and non-nullable
  final Function(String?) validator;

  const AppTextFormField({
    super.key,
    this.contentPadding,
    this.focusedBorder,
    this.enabledBorder,
    this.inputTextStyle,
    this.hintStyle,
    required this.hintText,
    this.isObscureText = false, // default set to false
    this.suffixIcon,
    this.backgroundColor,
    this.controller,
    required this.validator,
    this.isEnabled = true, // default set to true
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: isEnabled, // use isEnabled to control editability
      controller: controller,
      decoration: InputDecoration(
        disabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: AppColors.lighterGray,
            width: 1.3,
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
        isDense: true,
        contentPadding: contentPadding ??
            EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        focusedBorder: focusedBorder ??
            OutlineInputBorder(
              borderSide: const BorderSide(
                color: AppColors.mainOrange,
                width: 1.3,
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
        enabledBorder: enabledBorder ??
            OutlineInputBorder(
              borderSide: const BorderSide(
                color: AppColors.lighterGray,
                width: 1.3,
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.3,
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.3,
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
        hintStyle: hintStyle ?? TextStyles.font14LightGrayRegular,
        hintText: hintText,
        suffixIcon: suffixIcon,
        fillColor: backgroundColor ?? AppColors.moreLightGray,
        filled: true,
      ),
      obscureText: isObscureText,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeightHelper.regular,
        color: AppColors.darkBlue,
      ),
      validator: (value) {
        return validator(value);
      },
    );
  }
}
