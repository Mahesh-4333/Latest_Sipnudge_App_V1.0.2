import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hydrify/constants/app_colors.dart';
import 'package:hydrify/constants/app_dimensions.dart';
import 'package:hydrify/constants/app_font_styles.dart';
import 'package:hydrify/constants/app_strings.dart';
import 'package:hydrify/cubit/user_info/user_info_cubit.dart';

class CustomRadioSelectionWidget extends StatelessWidget {
  const CustomRadioSelectionWidget({super.key, required this.type});

  final int type;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserInfoCubit, UserInfoState>(
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final double totalSpacing = AppDimensions.dim10.h;
            final double tileWidth = (constraints.maxWidth - totalSpacing) / 2;

            return Wrap(
              runSpacing: AppDimensions.dim10.h,
              spacing: AppDimensions.dim10.h,
              children: getRadioOptionsBasedOnType(context, state, tileWidth),
            );
          },
        );
      },
    );
  }

  List<Widget> getRadioOptionsBasedOnType(
      BuildContext context, UserInfoState state, double tileWidth) {
    final cubit = context.read<UserInfoCubit>();
    if (type == 1) {
      return [
        buildTile(
          name: AppStrings.male,
          icon: "assets/images/male_ic.svg",
          isSelected: state.gender == Gender.male,
          onTap: () {
            cubit.setGender(Gender.male);
          },
          width: tileWidth,
        ),
        buildTile(
          name: AppStrings.female,
          icon: "assets/images/female_ic.svg",
          isSelected: state.gender == Gender.female,
          onTap: () {
            cubit.setGender(Gender.female);
          },
          width: tileWidth,
        ),
        buildTile(
          name: AppStrings.preferNotToSay,
          icon: "",
          isSelected: state.gender == Gender.preferNotToSay,
          onTap: () {
            cubit.setGender(Gender.preferNotToSay);
          },
          width: tileWidth,
        )
      ];
    } else if (type == 2) {
      return [
        buildTile(
          name: AppStrings.sedentary,
          icon: "assets/images/sedentary_ic.svg",
          description: AppStrings.sedentaryDes,
          isSelected: state.activityLevel == ActivityLevel.sedentary,
          onTap: () {
            cubit.setActivityLevel(ActivityLevel.sedentary);
          },
          width: tileWidth,
        ),
        buildTile(
          name: AppStrings.lightlyActive,
          icon: "assets/images/lightly_active_ic.svg",
          description: AppStrings.lightActivityDes,
          isSelected: state.activityLevel == ActivityLevel.lightActivity,
          onTap: () {
            cubit.setActivityLevel(ActivityLevel.lightActivity);
          },
          width: tileWidth,
        ),
        buildTile(
          name: AppStrings.moderatelyActive,
          icon: "assets/images/moderately_active_ic.svg",
          description: AppStrings.midActivityDes,
          isSelected: state.activityLevel == ActivityLevel.midActive,
          onTap: () {
            cubit.setActivityLevel(ActivityLevel.midActive);
          },
          width: tileWidth,
        ),
        buildTile(
          name: AppStrings.veryActive,
          icon: "assets/images/very_active_ic.svg",
          description: AppStrings.veryActivityDes,
          isSelected: state.activityLevel == ActivityLevel.veryActive,
          onTap: () {
            cubit.setActivityLevel(ActivityLevel.veryActive);
          },
          width: tileWidth,
        )
      ];
    } else if (type == 3) {
      return [
        buildTile(
          name: AppStrings.balanced,
          icon: "assets/images/balanced_diet_ic.svg",
          isSelected: state.dietType == DietType.balanced,
          onTap: () {
            cubit.setDietType(DietType.balanced);
          },
          width: tileWidth,
        ),
        buildTile(
          name: AppStrings.veg,
          icon: "assets/images/veg_diet_ic.svg",
          isSelected: state.dietType == DietType.vegetarian,
          onTap: () {
            cubit.setDietType(DietType.vegetarian);
          },
          width: tileWidth,
        ),
        buildTile(
          name: AppStrings.processedDiet,
          icon: "assets/images/processed_diet_ic.svg",
          isSelected: state.dietType == DietType.processed,
          onTap: () {
            cubit.setDietType(DietType.processed);
          },
          width: tileWidth,
        ),
        buildTile(
          name: AppStrings.highProtein,
          icon: "assets/images/high_protein_diet_ic.svg",
          isSelected: state.dietType == DietType.highProtein,
          onTap: () {
            cubit.setDietType(DietType.highProtein);
          },
          width: tileWidth,
        )
      ];
    }
    return [];
  }

  Widget buildTile({
    required String name,
    String? description,
    required String icon,
    required bool isSelected,
    required Function() onTap,
    required double width,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: AppColors.selectedPurpleToggle,
      child: Container(
        width: width,
        height: type == 1 ? AppDimensions.dim92.h : AppDimensions.dim122.h,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.selectedPurple
              : AppColors.customRadioUnselectedFillColor,
          border: Border.all(
            color: isSelected
                ? AppColors.selectedPurpleToggle
                : AppColors.unSelectedPurpleToggle,
            width: isSelected ? AppDimensions.dim3.w : AppDimensions.dim1.w,
          ),
          borderRadius: BorderRadius.circular(
            AppDimensions.radius_15.w,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: AppDimensions.dim4,
              color: Colors.black.withOpacity(.4),
              offset: Offset(AppDimensions.dim2.w, AppDimensions.dim2.h),
            )
          ],
        ),
        padding: EdgeInsets.only(
            left: AppDimensions.dim12.w,
            top: AppDimensions.dim12.w,
            bottom: AppDimensions.dim6.h,
            right: AppDimensions.dim10.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                  fontFamily: AppFontStyles.urbanistFontFamily,
                  fontSize: AppFontStyles.fontSize_16,
                  color: AppColors.white,
                  fontVariations: [
                    AppFontStyles.semiBoldFontVariation,
                  ]),
            ),
            description != null
                ? SizedBox(
                    height: AppDimensions.dim4.h,
                  )
                : SizedBox.shrink(),
            description != null
                ? Text(
                    description,
                    style: TextStyle(
                        fontFamily: AppFontStyles.urbanistFontFamily,
                        fontSize: AppFontStyles.fontSize_14,
                        color: AppColors.white.withAlpha(
                          160,
                        ),
                        fontVariations: [
                          AppFontStyles.semiBoldFontVariation,
                        ]),
                  )
                : SizedBox.shrink(),
            description == null
                ? Spacer()
                : SizedBox(
                    height: AppDimensions.dim8.h,
                  ),
            icon != ""
                ? Container(
                    alignment: Alignment.bottomRight,
                    child: SvgPicture.asset(
                      icon,
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
