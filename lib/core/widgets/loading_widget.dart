/* import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gif_view/gif_view.dart';
import 'package:pulsehub/core/helpers/app_assets.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GifView.asset(
            AppAssets.loading,
            colorBlendMode: BlendMode.srcIn,
            height: 0.4.sh,
            width: 0.8.sw,
            frameRate: 30,
          ),
        ],
      ),
    );
  }
}
 */