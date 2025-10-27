import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hydrify/constants/app_colors.dart';
import 'package:hydrify/constants/app_dimensions.dart';
import 'package:hydrify/constants/app_font_styles.dart';
import 'package:hydrify/constants/app_strings.dart';
import 'package:hydrify/cubit/level/level_cubit.dart';
import 'package:hydrify/cubit/level/level_state.dart';
import 'package:hydrify/screens/levelreached.dart';
import 'package:hydrify/screens/widgets/level_widgets/concentric_circles_animation.dart';

class AchievementsBadgeScreen extends StatelessWidget {
  const AchievementsBadgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LevelCubit, LevelState>(
      builder: (context, state) {
        var currentLevel = state.currentLevel;

        return Scaffold(
          body: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0XFF2E2630),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppColors.gradientStart, Color(0XFF2E2630)],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Stack(
                        children: [
                          Positioned(child: ConcentricCirclesAnimation()),
                          Positioned(
                            left: AppDimensions.dim75.w,
                            top: AppDimensions.dim90.w,
                            child: getCurrentLevelBadge(
                              currentLevel.toString(),
                            ),
                          ),
                          Positioned(
                            top: AppDimensions.dim380.h,
                            left: 0,
                            right: 0,
                            child: getCongratulationsText(
                              currentLevel.toString(),
                            ),
                          ),
                        ],
                      )),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0x1FFFFFFF),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x1A000000),
                          offset: const Offset(0, -6),
                          blurRadius: 44,
                          spreadRadius: 0,
                        ),
                      ],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppDimensions.radius_24.r),
                        topRight: Radius.circular(AppDimensions.radius_24.r),
                      ),
                    ),
                    padding: EdgeInsets.all(AppDimensions.padding_20.h),
                    child: GridView.builder(
                      padding: EdgeInsets.only(bottom: AppDimensions.dim100.h),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.2.r,
                        mainAxisSpacing: 24.h,
                        crossAxisSpacing: 20.w,
                      ),
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        final level = index + 1;
                        final isUnlocked = level <= currentLevel;
                        return GestureDetector(
                          onTap: () {
                            if (level > currentLevel) {
                              context.read<LevelCubit>().updateLevel(level);
                              showLevelUpDialog(
                                context,
                                level,
                                '15.4L',
                              );
                            }
                          },
                          child: getLevelBadges(level.toString(), isUnlocked),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget getCurrentLevelBadge(
    String level,
  ) {
    return SizedBox(
      width: AppDimensions.dim330.w,
      height: AppDimensions.dim320.h,
      child: Stack(children: [
        Positioned(
            child: Image.asset(
          "assets/achievmentimage.png",
          width: AppDimensions.dim330.w,
          height: AppDimensions.dim320.h,
        )),
        Positioned(
          left: AppDimensions.dim95.w,
          top: AppDimensions.dim105.h,
          child: SizedBox(
            width: AppDimensions.dim100.w,
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  AppColors.aztecpurple,
                  AppColors.darkviolet,
                  AppColors.richlilac,
                  AppColors.purplemimosa,
                  // Color(0xFF8C41FD),
                  // Color(0xFF7800BD),
                  // Color(0xFFAE58E0),
                  // Color(0xFFA66CFD),
                ],
              ).createShader(
                Rect.fromLTWH(
                  0,
                  0,
                  bounds.width,
                  bounds.height,
                ),
              ),
              blendMode: BlendMode.srcIn,
              child: Transform.translate(
                offset: Offset(0, -5.h),
                child: Text(
                  level,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFontStyles.fontSize_80.sp,
                    fontVariations: [
                      FontVariation(
                        'wght',
                        AppFontStyles.boldFontVariation.value,
                      ),
                    ],
                    //fontWeight: FontWeight.w900,
                    fontFamily: AppFontStyles.poppinsFamily,
                    //color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        )
      ]),
    );
  }

  Widget getLevelBadges(String level, bool isUnlocked) {
    return SizedBox(
      height: AppDimensions.dim137.h,
      width: AppDimensions.dim115.w,
      child: Stack(children: [
        Visibility(
          visible: isUnlocked,
          replacement: Positioned(
              child: Image.asset(
            "assets/images/level_locked_image.png",
            width: AppDimensions.dim115.w,
            height: AppDimensions.dim111.h,
          )),
          child: Positioned(
              left: AppDimensions.dim7.w,
              child: Image.asset(
                "assets/achievmentimage.png",
                width: AppDimensions.dim115.w,
                height: AppDimensions.dim111.h,
              )),
        ),
        Visibility(
          visible: isUnlocked,
          child: Positioned(
            left: AppDimensions.dim43.w,
            top: AppDimensions.dim34.w,
            child: SizedBox(
              width: AppDimensions.dim30.w,
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    AppColors.aztecpurple,
                    AppColors.darkviolet,
                    AppColors.richlilac,
                    AppColors.purplemimosa,
                  ],
                ).createShader(
                  Rect.fromLTWH(
                    0,
                    0,
                    bounds.width,
                    bounds.height,
                  ),
                ),
                blendMode: BlendMode.srcIn,
                child: Transform.translate(
                  offset: Offset(0, -5.h),
                  child: Text(
                    level,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.white,
                      fontFamily: AppFontStyles.urbanistFontFamily,
                      fontVariations: [AppFontStyles.extraBoldFontVariation],
                      fontSize: AppFontStyles.fontSize_28,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          child: SizedBox(
              width: AppDimensions.dim115.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Level $level',
                    style: TextStyle(
                      color: AppColors.white,
                      fontFamily: AppFontStyles.urbanistFontFamily,
                      fontVariations: [AppFontStyles.extraBoldFontVariation],
                      fontSize: AppFontStyles.fontSize_14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppDimensions.dim2.h),
                  Text(
                    'Weekly Intake: 15.4L',
                    style: TextStyle(
                        color: Colors.white60,
                        fontFamily: AppFontStyles.urbanistFontFamily,
                        fontVariations: [AppFontStyles.semiBoldFontVariation],
                        fontSize: AppFontStyles.fontSize_10),
                    textAlign: TextAlign.center,
                  ),
                ],
              )),
        )
      ]),
    );
  }

  Widget getCongratulationsText(
    String level,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.dim20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${AppStrings.levelreach} $level !',
            style: TextStyle(
              color: AppColors.white,
              fontFamily: AppFontStyles.urbanistFontFamily,
              fontSize: AppFontStyles.fontSize_20.sp,
              fontVariations: [AppFontStyles.boldFontVariation],
            ),
          ),
          SizedBox(height: AppDimensions.dim10.h),
          Text(
            AppStrings.congratulations,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFontStyles.urbanistFontFamily,
              fontVariations: [AppFontStyles.semiBoldFontVariation],
              color: AppColors.white.withOpacity(.5),
              fontSize: AppFontStyles.fontSize_14.sp,
            ),
          ),
        ],
      ),
    );
  }
}
