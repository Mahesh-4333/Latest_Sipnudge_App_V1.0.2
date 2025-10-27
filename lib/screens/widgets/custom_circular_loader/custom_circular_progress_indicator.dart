import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hydrify/constants/app_colors.dart';
import 'package:hydrify/constants/app_dimensions.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CustomCircularProgressIndicator extends StatelessWidget {
  const CustomCircularProgressIndicator(
      {super.key,
      required this.height,
      required this.width,
      required this.backgroundColor,
      required this.progressBackgroundColor,
      required this.percentageValue,
      this.progressColor,
      this.linearGradient,
      this.center,
      this.lineWidth,
      this.boxShadow,
      this.needsInnerShadow = false,
      this.radius,
      this.backgroundNeedsGradient = false});

  final double width;
  final double height;
  final Color backgroundColor;
  final Color? progressColor;
  final Color progressBackgroundColor;
  final LinearGradient? linearGradient;
  final double percentageValue;
  final Widget? center;
  final double? radius;
  final double? lineWidth;
  final bool needsInnerShadow;
  final List<BoxShadow>? boxShadow;
  final bool backgroundNeedsGradient;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: boxShadow,
          gradient: backgroundNeedsGradient
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.circularProgressBackgroundGradientStart,
                    AppColors.cirularProgressBackgroundGradiendEnd
                  ],
                )
              : null),
      padding: EdgeInsets.all(AppDimensions.dim2.w),
      alignment: Alignment.center,
      child: Container(
        width: width - AppDimensions.dim2.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: CircularPercentIndicator(
          percent: percentageValue / 100,
          radius: radius ?? AppDimensions.dim26.r,
          lineWidth: lineWidth ?? AppDimensions.dim6.w,
          circularStrokeCap: CircularStrokeCap.round,
          backgroundColor: progressBackgroundColor,
          progressColor: progressColor,
          linearGradient: linearGradient,
          center: center,
          animation: true,
          animateFromLastPercent: true,
          animationDuration: 500,
          curve: Curves.fastEaseInToSlowEaseOut,
        ),
      ),
    );
  }
}
