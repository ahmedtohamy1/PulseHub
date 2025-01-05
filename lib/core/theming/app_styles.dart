import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pulsehub/core/theming/app_colors.dart';
import 'package:pulsehub/core/theming/font_weight_helper.dart';

class TextStyles {
  static TextStyle font24BlackBold = TextStyle(
    fontSize: 22.sp,
    fontWeight: FontWeightHelper.bold,
    color: Colors.black,
  );

  static TextStyle font32BlueBold = TextStyle(
    fontSize: 30.sp,
    fontWeight: FontWeightHelper.bold,
    color: AppColors.mainOrange,
  );

  static TextStyle font11BlueSemiBold = TextStyle(
    fontSize: 11.sp,
    fontWeight: FontWeightHelper.semiBold,
    color: AppColors.mainOrange,
  );

  static TextStyle font11DarkBlueMedium = TextStyle(
    fontSize: 11.sp,
    fontWeight: FontWeightHelper.medium,
    color: AppColors.dark,
  );

  static TextStyle font11DarkBlueRegular = TextStyle(
    fontSize: 11.sp,
    fontWeight: FontWeightHelper.regular,
    color: AppColors.dark,
  );

  static TextStyle font24BlueBold = TextStyle(
    fontSize: 22.sp,
    fontWeight: FontWeightHelper.bold,
    color: AppColors.mainOrange,
  );

  static TextStyle font16WhiteSemiBold = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeightHelper.semiBold,
    color: Colors.white,
  );

  static TextStyle font11GrayRegular = TextStyle(
    fontSize: 11.sp,
    fontWeight: FontWeightHelper.regular,
    color: AppColors.gray,
  );

  static TextStyle font12GrayRegular = TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeightHelper.regular,
    color: AppColors.gray,
  );

  static TextStyle font12GrayMedium = TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeightHelper.medium,
    color: AppColors.gray,
  );

  static TextStyle font12DarkBlueRegular = TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeightHelper.regular,
    color: AppColors.dark,
  );

  static TextStyle font12BlueRegular = TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeightHelper.regular,
    color: AppColors.darkBlue,
  );

  static TextStyle font11BlueRegular = TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeightHelper.regular,
    color: AppColors.mainOrange,
  );

  static TextStyle font14GrayRegular = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeightHelper.regular,
    color: AppColors.gray,
  );

  static TextStyle font14LightGrayRegular = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeightHelper.regular,
    color: AppColors.lightGray,
  );

  static TextStyle font14DarkBlueMedium = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeightHelper.medium,
    color: AppColors.dark,
  );

  static TextStyle font14DarkBlueBold = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeightHelper.bold,
    color: AppColors.dark,
  );

  static TextStyle font16WhiteMedium = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeightHelper.medium,
    color: Colors.white,
  );

  static TextStyle font14BlueSemiBold = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeightHelper.semiBold,
    color: AppColors.darkBlue,
  );

  static TextStyle font15DarkBlueMedium = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeightHelper.medium,
    color: AppColors.dark,
  );

  static TextStyle font18DarkBlueBold = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeightHelper.bold,
    color: AppColors.dark,
  );

  static TextStyle font18DarkBlueSemiBold = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeightHelper.semiBold,
    color: AppColors.dark,
  );

  static TextStyle font18WhiteMedium = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeightHelper.medium,
    color: Colors.white,
  );
}

InputDecoration customInputDecoration(String labelText, IconData icon,
    [bool isApp = false, bool labelx = false]) {
  return InputDecoration(
    label: labelx ? Text(labelText) : null,
    filled: true,
    fillColor: isApp
        ? const Color(0xFFE0E0E0).withValues(alpha: 0.2)
        : const Color(0xFFE0E0E0), // Light gray background
    prefixIcon: Icon(icon, color: Colors.grey),
    hintText: labelText,
    hintStyle: const TextStyle(color: Colors.grey),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
  );
}

ButtonStyle customButtonStyle(
    [bool isApp = false, Color clr = const Color(0xFF4CAF50)]) {
  return ElevatedButton.styleFrom(
    backgroundColor: isApp ? null : clr, // Green color
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30), // Rounded edges
    ),
    padding: EdgeInsets.symmetric(vertical: 30.h),
  );
}

ButtonStyle outlineButtonStyle([bool isApp = false]) {
  return OutlinedButton.styleFrom(
    // Transparent background
    backgroundColor: Colors.white.withValues(alpha: 0),
    shadowColor: Colors.white.withValues(alpha: 0),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30), // Rounded edges
    ),
    splashFactory: NoSplash.splashFactory,
    side: const BorderSide(
      color: Color.fromARGB(255, 255, 17, 0),
      width: .5,
    ),
    padding: EdgeInsets.symmetric(vertical: 30.h),
  );
}
