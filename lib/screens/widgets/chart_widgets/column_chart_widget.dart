import 'dart:developer';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hydrify/constants/app_colors.dart';
import 'package:hydrify/constants/app_dimensions.dart';
import 'package:hydrify/constants/app_font_styles.dart';
import 'package:hydrify/cubit/filter/filter_cubit.dart';
import 'package:hydrify/helpers/water_consumption_data_helper.dart';
import 'package:hydrify/models/bottle_data.dart';
import 'package:hydrify/models/chart_data.dart';
import 'package:hydrify/models/water_consumption_data.dart';
import 'package:hydrify/screens/widgets/chart_widgets/tool_tip_widget.dart';

class FlColumnChartWidget extends StatefulWidget {
  final FilterInterval interval;
  final DateTime currentDate;
  final List<BottleData> bottleData;

  const FlColumnChartWidget({
    super.key,
    required this.interval,
    required this.currentDate,
    required this.bottleData,
  });

  @override
  State<FlColumnChartWidget> createState() => _FlColumnChartWidgetState();
}

class _FlColumnChartWidgetState extends State<FlColumnChartWidget> {
  late List<ChartData> chartData;
  final ScrollController _scrollController = ScrollController();

  double barWidth = AppDimensions.dim35.w; // fixed bar width
  double barSpacing = 16.w; // spacing between bars

  Offset? tappedIndexOffset;
  ChartData? tooltipData;
  int? tappedIndex;

  @override
  void initState() {
    super.initState();
    _updateChartData();
  }

  void _updateChartData() {
    List<WaterConsumptionData> consumptionData;
    if (widget.interval == FilterInterval.weekly) {
      DateTime weekStart = widget.currentDate.subtract(
        Duration(days: widget.currentDate.weekday % 7),
      );
      weekStart = DateTime(weekStart.year, weekStart.month, weekStart.day);

      consumptionData = WaterConsumptionCalculator.getWeeklyData(
        widget.bottleData,
        weekStart,
      );
    } else if (widget.interval == FilterInterval.monthly) {
      consumptionData = WaterConsumptionCalculator.getMonthlyData(
        widget.bottleData,
        widget.currentDate,
      );
    } else {
      consumptionData = WaterConsumptionCalculator.getYearlyData(
        widget.bottleData,
        widget.currentDate,
      );
    }

    chartData = WaterConsumptionCalculator.formatChartData(
      consumptionData,
      widget.interval,
    );

    print(
        "DEBUG: Interval=${widget.interval}, ChartData length=${chartData.length}");
  }

  @override
  void didUpdateWidget(covariant FlColumnChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.interval != widget.interval ||
        oldWidget.currentDate != widget.currentDate ||
        oldWidget.bottleData != widget.bottleData) {
      _updateChartData();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // total width = (barWidth + spacing) * numberOfBars
    // final chartWidth = (barWidth + barSpacing) * chartData.length;
    final rawChartWidth = (barWidth + barSpacing) * chartData.length;
    final chartWidth = rawChartWidth < AppDimensions.dim365.w
        ? AppDimensions.dim365.w
        : rawChartWidth;
    print("DEBUG: chartWidth = $chartWidth, bars = ${chartData.length}");

    return Container(
      color: Colors.transparent,
      width: double.maxFinite,
      height: AppDimensions.dim320.h,
      child: SizedBox(
        width: double.maxFinite,
        height: 324.h,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              child: SizedBox(
                width: AppDimensions.dim365.w,
                height: AppDimensions.dim262.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: AppDimensions.dim40.w,
                      height: AppDimensions.dim265.h,
                      child: CustomYAxis(maxY: 100, divisions: 5),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.zero,
                        child: SizedBox(
                          width: chartWidth,
                          height: AppDimensions.dim272.h,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceBetween,
                              groupsSpace: barSpacing,
                              maxY: 100,
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipColor: (group) => Colors.red,
                                  tooltipPadding: EdgeInsets.zero,
                                  tooltipMargin: 0,
                                  getTooltipItem:
                                      (group, groupIndex, rod, rodIndex) {
                                    return BarTooltipItem(
                                      '',
                                      const TextStyle(
                                          color: Colors.transparent),
                                    );
                                  },
                                ),
                                touchCallback: (event, response) {
                                  if (event.isInterestedForInteractions &&
                                      response != null &&
                                      response.spot != null) {
                                    setState(() {
                                      tooltipData = chartData[
                                          response.spot?.touchedBarGroupIndex ??
                                              0];
                                      tappedIndex =
                                          response.spot!.touchedBarGroupIndex;
                                      tappedIndexOffset = response.spot!.offset;

                                      log("X - ${tappedIndexOffset?.dx}");
                                      log("Y - ${tappedIndexOffset?.dy}");
                                    });
                                  } else {
                                    setState(() {
                                      tappedIndex = null;
                                      tappedIndexOffset = null;
                                    });
                                  }
                                },
                              ),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, _) {
                                      int index = value.toInt();
                                      if (index < 0 ||
                                          index >= chartData.length) {
                                        return const SizedBox();
                                      }
                                      return Padding(
                                        padding: EdgeInsets.only(
                                            top: AppDimensions.dim10.h),
                                        child: Text(
                                          chartData[index].x,
                                          style: TextStyle(
                                            color: AppColors.white,
                                            fontFamily: AppFontStyles
                                                .urbanistFontFamily,
                                            fontSize: AppFontStyles.fontSize_14,
                                            fontVariations: [
                                              AppFontStyles.boldFontVariation
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: false,
                                    reservedSize: AppDimensions.dim40.w,
                                    getTitlesWidget: (value, _) => Padding(
                                      padding: EdgeInsets.only(top: 10.h),
                                      child: Text(
                                        "${value.toInt()}%",
                                        style: TextStyle(
                                          fontFamily:
                                              AppFontStyles.urbanistFontFamily,
                                          color: AppColors.white,
                                          fontSize: AppFontStyles.fontSize_14,
                                          fontVariations: [
                                            AppFontStyles.boldFontVariation
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                              ),
                              gridData: FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              barGroups:
                                  List.generate(chartData.length, (index) {
                                final isSelected = tappedIndex == index;
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: chartData[index].completionPercent,
                                      color: isSelected
                                          ? const Color(0XFF9919FF)
                                          : const Color(0XFF9919FF)
                                              .withOpacity(0.48),
                                      width: barWidth,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(
                                            AppDimensions.radius_100),
                                        topRight: Radius.circular(
                                            AppDimensions.radius_100),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (tappedIndexOffset != null && tooltipData != null)
              Positioned(
                left: (tappedIndexOffset?.dx ?? 0) -
                    _scrollController.offset +
                    15,
                top: (tappedIndexOffset?.dy ?? 0),
                child: CustomChartToolTip(
                  percent: tooltipData!.completionPercent.toInt(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CustomYAxis extends StatelessWidget {
  final double maxY;
  final int divisions;

  const CustomYAxis({
    super.key,
    this.maxY = 100,
    this.divisions = 5,
  });

  @override
  Widget build(BuildContext context) {
    final step = maxY ~/ divisions;

    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.dim20.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(divisions + 1, (i) {
          final value = maxY - (i * step);
          return Text(
            "${value.toInt()}%",
            style: TextStyle(
              fontFamily: AppFontStyles.urbanistFontFamily,
              color: AppColors.white,
              fontSize: AppFontStyles.fontSize_14,
              fontVariations: [AppFontStyles.semiBoldFontVariation],
            ),
          );
        }),
      ),
    );
  }
}
