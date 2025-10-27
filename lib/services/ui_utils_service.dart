import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hydrify/constants/app_colors.dart';
import 'package:hydrify/constants/app_dimensions.dart';
import 'package:hydrify/constants/app_font_styles.dart';
import 'package:hydrify/screens/widgets/animate_dots_widget.dart';
import 'package:hydrify/screens/widgets/custom_circular_loader/paint.dart';
import 'package:hydrify/screens/widgets/custom_circular_loader/widget.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class UiUtilsService {
  static bool isLoadingDisplaying = false;

  static showLoading(BuildContext context, String? text) {
    if (!isLoadingDisplaying) {
      isLoadingDisplaying = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Dialog(
              backgroundColor: AppColors.loadingDialogBacgkroundColor,
              elevation: 0,
              child: Container(
                width: AppDimensions.dim313.w,
                height: AppDimensions.dim155.h,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularGradientSpinner(
                      endColor: Color(0XFF1A181A),
                      color: Color(0XFFA77CB0),
                      spinnerDirection: SpinnerDirection.clockwise,
                      size: 50.w,
                      strokeWidth: 10,
                    ),
                    if (text != null) ...[
                      SizedBox(height: AppDimensions.dim16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            text,
                            style: TextStyle(
                                color: AppColors.white,
                                fontSize: AppFontStyles.fontSize_20.sp,
                                fontVariations: [
                                  AppFontStyles.semiBoldFontVariation,
                                ]),
                          ),
                          AnimatedDots(),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }

  static dismissLoading(BuildContext context) {
    if (isLoadingDisplaying) {
      isLoadingDisplaying = false;
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  static showToast(
      {required BuildContext context,
      required String text,
      Color textColor = Colors.black,
      Color backgroundColor = AppColors.white,
      EdgeInsetsGeometry margin = const EdgeInsets.all(AppDimensions.dim20)}) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.none,
        margin: margin,
        elevation: 12,
        padding: EdgeInsets.zero,
        duration: const Duration(
          seconds: 1,
        ),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: backgroundColor,
            width: AppDimensions.dim1,
          ),
          borderRadius: BorderRadius.circular(
            AppDimensions.dim5,
          ),
        ),
        content: Container(
          color: backgroundColor,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontVariations: [
                AppFontStyles.boldFontVariation,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoadingIndicator extends StatefulWidget {
  final String? text;

  const LoadingIndicator({super.key, this.text});

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = Tween<double>(begin: 0, end: 360).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });

    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.dim100.h,
      width: AppDimensions.dim100.w,
      child: Transform.rotate(
        angle: _animation.value * (3.14159 / 180),
        child: SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              minimum: 0,
              maximum: 100,
              showLabels: false,
              showTicks: false,
              startAngle: 270,
              endAngle: 270,
              radiusFactor: 0.7,
              axisLineStyle: const AxisLineStyle(
                thickness: 10,
                color: Colors.transparent,
              ),
              pointers: <GaugePointer>[
                RangePointer(
                  value: 120,
                  width: 10,
                  gradient: const SweepGradient(
                    colors: [
                      Color(0XFFA77CB0),
                      Color(0XFF1A181A),
                    ],
                    stops: <double>[0.0, 1],
                  ),
                  cornerStyle: CornerStyle.bothCurve,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
