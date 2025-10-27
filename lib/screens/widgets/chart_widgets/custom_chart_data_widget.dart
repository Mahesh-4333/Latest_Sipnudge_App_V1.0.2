import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hydrify/constants/app_colors.dart';
import 'package:hydrify/constants/app_dimensions.dart';
import 'package:hydrify/constants/app_font_styles.dart';
import 'package:hydrify/constants/app_strings.dart';
import 'package:hydrify/cubit/bottle/bottle_data_cubit.dart';
import 'package:hydrify/cubit/filter/filter_cubit.dart';
import 'package:hydrify/models/bottle_data.dart';
import 'package:hydrify/screens/widgets/chart_widgets/area_chart_widget.dart';
import 'package:hydrify/screens/widgets/chart_widgets/column_chart_widget.dart';

class CustomChartDataWidget extends StatefulWidget {
  const CustomChartDataWidget({super.key});

  @override
  State<CustomChartDataWidget> createState() => _CustomChartDataWidgetState();
}

class _CustomChartDataWidgetState extends State<CustomChartDataWidget> {
  bool _isColumnChartSelected = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.only(
          top: AppDimensions.defaultPadding.w,
          left: AppDimensions.defaultPadding.w,
          right: AppDimensions.defaultPadding.w,
          bottom: AppDimensions.dim30.h),
      margin: EdgeInsets.symmetric(horizontal: AppDimensions.defaultPadding.w),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: AppDimensions.radius_5,
            color: Colors.black.withOpacity(.4),
            offset: Offset(
              AppDimensions.dim5,
              AppDimensions.dim5,
            ),
          )
        ],
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0XFF9F7DA5),
              Color.fromARGB(255, 121, 101, 123),
            ]),
        borderRadius: BorderRadius.circular(
          AppDimensions.radius_10,
        ),
        color: Color(0XFF8F7395),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                _isColumnChartSelected
                    ? AppStrings.drinkCompletion
                    : "${AppStrings.drinkCompletion} (L)",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: AppFontStyles.fontSize_20,
                    fontFamily: AppFontStyles.urbanistFontFamily,
                    fontVariations: [AppFontStyles.boldFontVariation]),
              ),
              Spacer(),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radius_5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: AppDimensions.radius_5,
                      color: Colors.black.withOpacity(.4),
                      offset: Offset(
                        AppDimensions.dim2,
                        AppDimensions.dim2,
                      ),
                    )
                  ],
                  color: AppColors.white,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _isColumnChartSelected = true;
                        setState(() {});
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.dim18.w,
                            vertical: AppDimensions.dim8.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radius_5,
                          ),
                          color: _isColumnChartSelected
                              ? Color(0XFF8D19E9)
                              : AppColors.white,
                        ),
                        child: SvgPicture.asset(
                          "assets/images/bar_chart_ic.svg",
                          color: _isColumnChartSelected
                              ? null
                              : AppColors.disabledGreyColor,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _isColumnChartSelected = false;
                        setState(() {});
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.dim18.w,
                            vertical: AppDimensions.dim8.h),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radius_5,
                            ),
                            color: _isColumnChartSelected
                                ? AppColors.white
                                : Color(0XFF8D19E9)),
                        child: SvgPicture.asset(
                          "assets/images/spline_chart_ic.svg",
                          color: _isColumnChartSelected
                              ? AppColors.disabledGreyColor
                              : AppColors.white,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: AppDimensions.dim10.h,
          ),
          BlocBuilder<FilterCubit, FilterState>(
            builder: (context, filterState) {
              final filterCubit = context.read<FilterCubit>();
              DateTime startDate;
              DateTime endDate;
              if (filterState.currentInterval == FilterInterval.weekly) {
                startDate = filterState.currentDate.subtract(
                  Duration(days: filterState.currentDate.weekday % 7),
                );
                startDate =
                    DateTime(startDate.year, startDate.month, startDate.day);

                endDate = startDate.add(const Duration(days: 6));
                endDate = DateTime(
                  endDate.year,
                  endDate.month,
                  endDate.day,
                  23,
                  59,
                  59,
                  999,
                );
              } else {
                startDate = DateTime(
                  filterState.currentDate.year,
                  filterState.currentDate.month,
                  1,
                );
                endDate = DateTime(
                  filterState.currentDate.year,
                  filterState.currentDate.month + 1,
                  1,
                ).subtract(const Duration(microseconds: 1));
              }

              log("Start date is $startDate , end date is $endDate");

              return FutureBuilder<List<BottleData>>(
                future: context
                    .read<BottleDataCubit>()
                    .getHistoryForDateRange(startDate, endDate),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        AppStrings.errorLoadingData,
                        style: TextStyle(
                          color: AppColors.redColor,
                          fontSize: AppFontStyles.fontSize_18.sp,
                          fontFamily: AppFontStyles.urbanistFontFamily,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        AppStrings.noDataAvailable,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppFontStyles.fontSize_18.sp,
                          fontFamily: AppFontStyles.urbanistFontFamily,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }

                  return Visibility(
                    visible: _isColumnChartSelected,
                    replacement: FlAreaChartWidget(
                      interval: filterState.currentInterval,
                      currentDate: filterState.currentDate,
                      bottleData: snapshot.data!,
                    ),
                    child: FlColumnChartWidget(
                      interval: filterState.currentInterval,
                      currentDate: filterState.currentDate,
                      bottleData: snapshot.data!,
                    ),
                  );
                },
              );
            },
          )
        ],
      ),
    );
  }
}
