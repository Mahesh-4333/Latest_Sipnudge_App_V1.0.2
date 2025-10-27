import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hydrify/constants/app_colors.dart';
import 'package:hydrify/constants/app_dimensions.dart';
import 'package:hydrify/constants/app_font_styles.dart';
import 'package:hydrify/constants/app_strings.dart';
import 'package:hydrify/cubit/user_info/user_info_cubit.dart';
import 'package:hydrify/models/user_info.dart';
import 'package:hydrify/providers/user_info_provider.dart';
import 'package:hydrify/screens/user_info_daily_goal_screen.dart';
import 'package:hydrify/screens/user_lifestyle_info_input_screen.dart';
import 'package:hydrify/screens/widgets/custom_circular_loader/segmented_progress_indicator.dart';
import 'package:hydrify/screens/widgets/user_info_input_widgets/custom_cupertino_input_widget.dart';
import 'package:hydrify/screens/widgets/user_info_input_widgets/custom_radio_selection_widget.dart';
import 'package:hydrify/screens/widgets/user_info_input_widgets/next_button_widget.dart';
import 'package:provider/provider.dart';

class UserInfoAnalyzingScreen extends StatefulWidget {
  const UserInfoAnalyzingScreen({super.key, required this.goal});

  final double goal;
  @override
  State<UserInfoAnalyzingScreen> createState() =>
      _UserInfoAnalyzingScreenState();
}

class _UserInfoAnalyzingScreenState extends State<UserInfoAnalyzingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 100).animate(
      CurvedAnimation(
          parent: _controller, curve: Curves.fastEaseInToSlowEaseOut),
    );

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => UserInfoDailyGoalScreen(
                waterGoal: widget.goal,
              ),
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
        ),
        padding: EdgeInsets.only(
          top: AppDimensions.dim120.h,
          left: AppDimensions.defaultPadding.w,
          right: AppDimensions.defaultPadding.w,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppStrings.analyingYourData,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFontStyles.museoModernoFontFamily,
                color: AppColors.white,
                height: AppFontStyles.getLineHeight(
                  AppFontStyles.fontSize_24,
                  160,
                ),
                fontSize: AppFontStyles.fontSize_24,
                fontVariations: [AppFontStyles.fontWeightVariation600],
              ),
            ),
            SizedBox(height: AppDimensions.dim8.h),
            Text(
              AppStrings.pleaseWait,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFontStyles.urbanistFontFamily,
                color: Color(0XFF86DCFF),
                height: AppFontStyles.getLineHeight(
                  AppFontStyles.fontSize_18,
                  160,
                ),
                fontSize: AppFontStyles.fontSize_18,
                fontVariations: [AppFontStyles.regularFontVariation],
              ),
            ),
            SizedBox(height: AppDimensions.dim133.h),
            SegmentedProgressIndicator(
              isIndeterminate: true,
              segmentCount: 100,
              strokeWidth: 20,
              gapSize: 2,
              gradient: const SweepGradient(
                colors: [
                  Color(0Xff00000000),
                  Color(0xFFD918FF),
                ],
                startAngle: 0,
                endAngle: 2 * pi,
              ),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Text(
                    "${_animation.value.toInt()}%",
                    style: TextStyle(
                      fontFamily: AppFontStyles.museoModernoFontFamily,
                      color: AppColors.white,
                      fontSize: AppFontStyles.fontSize_72,
                      fontVariations: [
                        AppFontStyles.fontWeightVariation600,
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: AppDimensions.dim148.h),
            Text(
              AppStrings.almostThere,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFontStyles.museoModernoFontFamily,
                color: AppColors.white,
                height: AppFontStyles.getLineHeight(
                  AppFontStyles.fontSize_18,
                  160,
                ),
                fontSize: AppFontStyles.fontSize_18,
                fontVariations: [AppFontStyles.regularFontVariation],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
