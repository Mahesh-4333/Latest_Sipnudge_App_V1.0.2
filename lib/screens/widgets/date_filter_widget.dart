import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hydrify/constants/app_colors.dart';
import 'package:hydrify/constants/app_dimensions.dart';
import 'package:hydrify/constants/app_font_styles.dart';
import 'package:hydrify/cubit/filter/filter_cubit.dart';

class DateFilterWidget extends StatelessWidget {
  const DateFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: AppDimensions.dim10.h,
        bottom: AppDimensions.dim10.h,
        left: AppDimensions.defaultPadding,
        right: AppDimensions.defaultPadding,
      ),
      margin: EdgeInsets.symmetric(horizontal: AppDimensions.defaultPadding.w),
      decoration: BoxDecoration(
        color: Color(0XFF907396),
        borderRadius: BorderRadius.circular(
          AppDimensions.radius_15,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(.4),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const IntervalSelector(),
          SizedBox(height: AppDimensions.dim15.h),
          const DateNavigator(),
        ],
      ),
    );
  }
}

class IntervalSelector extends StatelessWidget {
  const IntervalSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
      builder: (context, filterState) {
        return Container(
          padding: EdgeInsets.all(AppDimensions.dim2.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              AppDimensions.radius_25.w,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: FilterInterval.values.map((interval) {
              bool isSelected = filterState.currentInterval == interval;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    context.read<FilterCubit>().changeInterval(interval);
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: AppDimensions.dim12.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0XFFA964E0)
                          : Colors.transparent,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radius_25.w),
                    ),
                    child: Text(
                      interval.name[0].toUpperCase() +
                          interval.name.substring(1),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontFamily: AppFontStyles.urbanistFontFamily,
                        fontSize: AppFontStyles.fontSize_16,
                        fontVariations: [
                          AppFontStyles.boldFontVariation,
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class DateNavigator extends StatelessWidget {
  const DateNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              splashColor: AppColors.gradientEnd,
              child: const Icon(
                Icons.chevron_left,
                color: Colors.white,
              ),
              onTap: () => context.read<FilterCubit>().navigateDate(false),
            ),
            Text(
              state.getFormattedDateRange(),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: AppFontStyles.fontSize_18.sp,
                  fontFamily: AppFontStyles.urbanistFontFamily,
                  fontVariations: [
                    AppFontStyles.boldFontVariation,
                  ]),
            ),
            context.read<FilterCubit>().canNavigateForward()
                ? InkWell(
                    splashColor: AppColors.gradientEnd,
                    child: const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                    ),
                    onTap: () => context.read<FilterCubit>().navigateDate(true),
                  )
                : SizedBox(width: AppDimensions.dim48.w),
          ],
        );
      },
    );
  }
}
