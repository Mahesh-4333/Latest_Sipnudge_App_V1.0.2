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
import 'package:hydrify/screens/widgets/chart_widgets/column_chart_widget.dart';
import 'package:hydrify/screens/widgets/chart_widgets/tool_tip_widget.dart';

class FlAreaChartWidget extends StatefulWidget {
  final FilterInterval interval;
  final DateTime currentDate;
  final List<BottleData> bottleData;

  const FlAreaChartWidget({
    super.key,
    required this.interval,
    required this.currentDate,
    required this.bottleData,
  });

  @override
  State<FlAreaChartWidget> createState() => _FlAreaChartWidgetState();
}

class _FlAreaChartWidgetState extends State<FlAreaChartWidget> {
  late List<ChartData> chartData;
  Offset? tappedIndexOffset;
  ChartData? tooltipData;
  int? tappedIndex;
  TouchLineBarSpot? _touchedSpot;
  Offset? _tooltipPos; // in chart-content coordinates
  final ScrollController _scrollController = ScrollController();
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
  void didUpdateWidget(covariant FlAreaChartWidget oldWidget) {
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
    double pointWidth = 50.w;
    final chartWidth = pointWidth * chartData.length;

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
                        child: Container(
                          width: chartWidth,
                          padding: EdgeInsets.only(
                              left: AppDimensions.dim9.w,
                              top: AppDimensions.dim9.h),
                          child: LineChart(
                            LineChartData(
                              minY: 0,
                              maxY: 100,
                              gridData: FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    reservedSize: 25,
                                    showTitles: true,
                                    getTitlesWidget: (value, _) {
                                      int index = value.toInt();
                                      if (index < 0 ||
                                          index >= chartData.length) {
                                        return const SizedBox();
                                      }
                                      return Padding(
                                        padding: EdgeInsets.only(
                                            top: AppDimensions.dim11.h),
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
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: List.generate(
                                    chartData.length,
                                    (i) => FlSpot(
                                      i.toDouble(),
                                      chartData[i].completionPercent,
                                    ),
                                  ),
                                  isCurved: true,
                                  color: AppColors.areaChartLineColor,
                                  barWidth: AppDimensions.dim3.w,
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        AppColors.blueGradient.withOpacity(.6),
                                        AppColors.blueGradient.withOpacity(.1),
                                      ],
                                    ),
                                  ),
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) {
                                      return FlDotCirclePainter(
                                        radius: AppDimensions.dim4.h,
                                        color: AppColors.white,
                                        strokeWidth: AppDimensions.dim4.h,
                                        strokeColor:
                                            AppColors.areaChartLineColor,
                                      );
                                    },
                                  ),
                                ),
                              ],
                              lineTouchData: LineTouchData(
                                enabled: true,
                                touchTooltipData: LineTouchTooltipData(
                                  getTooltipColor: (_) => Colors.transparent,
                                  getTooltipItems: (_) => [],
                                ),
                                touchCallback: (event, response) {
                                  if (event.isInterestedForInteractions &&
                                      response != null &&
                                      (response.lineBarSpots?.isNotEmpty ??
                                          false)) {
                                    final s = response.lineBarSpots!.first;
                                    setState(() {
                                      _touchedSpot = s;
                                      _tooltipPos = _spotToPixel(
                                        s,
                                        chartWidth: chartWidth,
                                        chartHeight: AppDimensions.dim262.h,
                                        minX: 0,
                                        maxX: (chartData.length - 1).toDouble(),
                                        minY: 0,
                                        maxY: 100,
                                        leftReserved:
                                            0, // we disabled leftTitles
                                        rightReserved: 0,
                                        topReserved: 0,
                                        bottomReserved: 30,
                                      );
                                    });
                                  } else {
                                    setState(() {
                                      _touchedSpot = null;
                                      _tooltipPos = null;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_tooltipPos != null)
              Positioned(
                left: _tooltipPos!.dx - _scrollController.offset + 46.w,
                top: _tooltipPos!.dy,
                child: FractionalTranslation(
                  translation: const Offset(-0.5, 0.0),
                  child: CustomChartToolTip(
                    isPercent: false,
                    percent: num.parse(
                      ((tooltipData?.completionVolume ?? 0)).toStringAsFixed(1),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Offset _spotToPixel(
    TouchLineBarSpot s, {
    required double chartWidth,
    required double chartHeight,
    required double minX,
    required double maxX,
    required double minY,
    required double maxY,
    required double leftReserved,
    required double rightReserved,
    required double topReserved,
    required double bottomReserved,
  }) {
    final innerW = chartWidth - leftReserved - rightReserved;
    final innerH = chartHeight - topReserved - bottomReserved;

    final dx = leftReserved + ((s.x - minX) / (maxX - minX)) * innerW;
    final dy = topReserved + (1 - (s.y - minY) / (maxY - minY)) * innerH;

    return Offset(dx, dy);
  }
}
