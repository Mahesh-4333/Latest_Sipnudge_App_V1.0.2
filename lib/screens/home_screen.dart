
import 'dart:developer';
import 'dart:math' hide log;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:hydrify/constants/app_colors.dart';
import 'package:hydrify/constants/app_dimensions.dart';
import 'package:hydrify/constants/app_font_styles.dart';
import 'package:hydrify/constants/app_strings.dart';
import 'package:hydrify/cubit/ble/ble_cubit.dart';
import 'package:hydrify/cubit/bottle/bottle_data_cubit.dart';
import 'package:hydrify/cubit/hydration/hydration_cubit.dart';
import 'package:hydrify/helpers/shared_pref_helper.dart';
import 'package:hydrify/helpers/water_consumption_data_helper.dart';
import 'package:hydrify/models/hydration_entry.dart';
import 'package:hydrify/providers/weather_provider.dart';

import 'package:hydrify/screens/widgets/ble_device_selection_sheet.dart';
import 'package:hydrify/screens/widgets/custom_circular_loader/custom_circular_progress_indicator.dart';
import 'package:hydrify/screens/widgets/greeting_widget.dart';
import 'package:hydrify/screens/widgets/user_info_input_widgets/custom_beating_ble_status_indicator.dart';
import 'package:hydrify/screens/widgets/water_wave_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AnimationController _controller;
  late Animation<double> _shadowOffsetAnimation;
  bool _isPickerShown = false;

  @override
  // void initState() {
  //   super.initState();
  //   context.read<BleCubit>().start();
  // }

  // void initState() {
  //   super.initState();

  //   // Show popup before BLE starts
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     _showStartJourneyDialog(context);
  //   });
  // }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      bool hasConnectedBefore = prefs.getBool('ble_connected_once') ?? false;

      if (hasConnectedBefore) {
        // ✅ Already connected before — skip dialog, auto connect
        context.read<BleCubit>().start();
      } else {
        // 🚀 First time user — show start journey dialog
        _showStartJourneyDialog(context);
      }
    });
  }

  void _showStartJourneyDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true, // 👈 allow tap outside to close
      barrierColor: Colors.transparent, // keep transparent base
      builder: (BuildContext context) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // 🟣 Background Blur + Dismiss Area
            Positioned.fill(
              child: GestureDetector(
                onTap: () =>
                    Navigator.of(context).pop(), // 👈 tap anywhere to close
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: AppColors.white1A),
                ),
              ),
            ),

            // 🟣 Center Card (image + text)
            //GestureDetector(
            //onTap: () {}, // prevent closing when tapping on the card
            Transform.translate(
              offset: Offset(-8.w, 20.h),
              child: Container(
                width: 300.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: Color(0xFFFFD000),
                    width: 2.w,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18.5.r),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // 🖼️ Bottle image
                      Image.asset(
                        'assets/images/purple_bottle1.png',
                        width: double.infinity,
                        height: 200.h,
                        fit: BoxFit.cover,
                      ),

                      // 📝 Bottom text
                      // 📝 Text and Button Centered like in image
                      Positioned(
                        bottom: 7.h,
                        left: 0,
                        right: 0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              //child: RichText(
                              //textAlign: TextAlign.justify,
                              //text: TextSpan(
                              child: Column(
                                children: [
                                  Text(
                                    "Start your journey right fill your bottle",
                                    style: TextStyle(
                                      color: const Color(0xFF030303),
                                      fontFamily:
                                          AppFontStyles.museoModernoFontFamily,
                                      fontVariations: [
                                        AppFontStyles.boldFontVariation,
                                      ],
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  Text(
                                    "till 600ml to ensure accurate data.",
                                    style: TextStyle(
                                      color: const Color(0xFF030303),
                                      fontFamily:
                                          AppFontStyles.museoModernoFontFamily,
                                      fontVariations: [
                                        AppFontStyles.boldFontVariation,
                                      ],
                                      fontSize: 14.sp,
                                      // emphasis on key part
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 14.h),

                            // ✅ Start button
                            SizedBox(
                              width: 100.w,
                              height: 20.h,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF369FFF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.r),
                                  ),
                                ),
                                // onPressed: () {
                                //   Navigator.of(context).pop();
                                //   context.read<BleCubit>().start();
                                // },
                                onPressed: () async {
                                  Navigator.of(context).pop();

                                  // Start BLE connection
                                  context.read<BleCubit>().start();

                                  // ✅ Save flag so dialog never shows again
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setBool(
                                      'ble_connected_once', true);
                                },
                                child: Text(
                                  "Start",
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontFamily:
                                        AppFontStyles.museoModernoFontFamily,
                                    fontVariations: [
                                      AppFontStyles.boldFontVariation
                                    ],
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            //),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BleCubit, BleState>(
      listener: (context, state) async {
        if (state.status == BleStatus.scanning &&
            state.scannedDevices.isNotEmpty &&
            !_isPickerShown &&
            state.isFirstConnection) {
          _isPickerShown = true;
          log("✅ Showing picker...");

          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) {
                return Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.all(24),
                  child: Stack(
                    children: [
                      BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 3.0,
                          sigmaY: 3.0,
                        ),
                        child: Container(
                          color: Colors.white.withOpacity(0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: const BleDeviceSelectionSheet(),
                      ),
                    ],
                  ),
                );
              },
            ).then((_) {
              log("❌ Picker closed.");
              _isPickerShown = false;
            });
          });
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: AppDimensions.dim74.h,
              ),
              _buildAppBar(context),
              _buildWeatherInfo(),
              //_buildBleStatus(context),
              SizedBox(
                height: AppDimensions.dim16.h,
              ),
              BlocBuilder<HydrationCubit, HydrationState>(
                buildWhen: (p, c) =>
                    p.currentSlotConsumption != c.currentSlotConsumption ||
                    p.currentSlotPercentage != c.currentSlotPercentage ||
                    p.currentSlotEntry != c.currentSlotEntry,
                builder: (context, state) {
                  final slotName =
                      state.currentSlotEntry?.slot.label ?? "Off-Slot Time";

                  final consumption = state.currentSlotConsumption;
                  final percentage = state.currentSlotPercentage;

                  return _buildTodayStats(
                    consumption,
                    percentage,
                    slotName,
                  );
                },
              ),
              SizedBox(
                height: AppDimensions.dim9.h,
              ),
              _buildBottleWidget(context),
              SizedBox(
                height: AppDimensions.dim10.h,
              ),
              BlocBuilder<BottleDataCubit, BottleDataState>(
                buildWhen: (previous, current) =>
                    previous.volumePercent != current.volumePercent,
                builder: (context, state) {
                  return FutureBuilder(future: () {
                    DateTime now = DateTime.now();

                    DateTime startDate = DateTime(now.year, now.month, now.day);

                    DateTime endDate = startDate
                        .add(const Duration(days: 1))
                        .subtract(const Duration(milliseconds: 1));

                    return context
                        .read<BottleDataCubit>()
                        .getHistoryForDateRange(startDate, endDate);
                  }(), builder: (context, snapshot) {
                    double completionPercent = 0;
                    double waterVolumeConsumed = 0;

                    if (snapshot.hasData || snapshot.data?.isNotEmpty == true) {
                      waterVolumeConsumed =
                          WaterConsumptionCalculator.calculateDailyConsumption(
                              snapshot.data!);

                      completionPercent = WaterConsumptionCalculator
                          .calculateCompletionPercentage(waterVolumeConsumed);
                    }
                    return _buildGoalText(completionPercent);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.defaultPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GreetingWidget(),
          Column(
            children: [
              CustomBeatingBleStatusIndicator(),
              SizedBox(
                height: AppDimensions.dim5.h,
              ),
              BlocBuilder<BottleDataCubit, BottleDataState>(
                buildWhen: (previous, current) =>
                    previous.battery != current.battery,
                builder: (context, state) {
                  return CustomCircularProgressIndicator(
                      height: AppDimensions.dim60.w,
                      width: AppDimensions.dim60.w,
                      backgroundColor:
                          AppColors.bottleBatteryIndicatorBackgroundColor,
                      progressBackgroundColor: Color(0XFFDDECDC),
                      progressColor: Color(0XFF43E73E),
                      percentageValue: state.battery.toDouble(),
                      center: TweenAnimationBuilder<int>(
                        tween: IntTween(
                          begin: 0,
                          end: state.battery,
                        ),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.fastEaseInToSlowEaseOut,
                        builder: (context, value, child) {
                          return Text(
                            "$value%",
                            style: TextStyle(
                              color: AppColors.white,
                              fontFamily: AppFontStyles.museoModernoFontFamily,
                              fontSize: AppFontStyles.fontSize_12,
                              fontVariations: [
                                AppFontStyles.fontWeightVariation600,
                              ],
                            ),
                          );
                        },
                      ));
                },
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildWeatherInfo() {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        if (weatherProvider.isLoading) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Loading weather data',
                style: TextStyle(
                  fontSize: AppFontStyles.fontSize_16,
                  color: AppColors.white,
                  fontVariations: [
                    AppFontStyles.regularFontVariation,
                  ],
                ),
              ),
            ],
          );
        }

        final weatherData = weatherProvider.weatherData;
        if (weatherData == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            weatherProvider.fetchWeatherForCurrentLocation();
          });
          return const Center(child: CircularProgressIndicator());
        }

        var iconPath = weatherProvider.getWeatherIcon();
        print('=== UI Widget Debug ===');
        print('Icon path received from provider: "$iconPath"');

        if (iconPath == "assets/images/cloudy_ic.svg") {
          iconPath = "assets/images/cloudy_ic.png";
        }

        return Padding(
          padding:
              EdgeInsets.symmetric(horizontal: AppDimensions.defaultPadding),
          child: Row(
            children: [
              Column(
                children: [
                  // Wrap SvgPicture.asset with error handling
                  SizedBox(
                    height: AppDimensions.dim45.h,
                    width: AppDimensions.dim45.h, // Add width for debugging

                    child: _buildWeatherIconWidget(iconPath),
                  ),
                  SizedBox(
                      height:
                          AppDimensions.dim8.h), // Changed from width to height
                  Text(
                    '${weatherData.temperature.round()}°C / ${weatherData.humidity.round()}%',
                    style: TextStyle(
                      fontSize: AppFontStyles.fontSize_16,
                      fontFamily: AppFontStyles.poppinsFamily,
                      color: AppColors.white,
                      fontVariations: [
                        AppFontStyles.boldFontVariation,
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(width: AppDimensions.dim12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(height: 1.2.h),
                          children: [
                            TextSpan(
                              text: AppStrings.itsA,
                              style: TextStyle(
                                fontFamily:
                                    AppFontStyles.museoModernoFontFamily,
                                fontSize: AppFontStyles.fontSize_18,
                                fontVariations: [
                                  AppFontStyles.regularFontVariation,
                                ],
                              ),
                            ),
                            TextSpan(
                              text: weatherProvider.getWeatherDescription(),
                              style: TextStyle(
                                fontFamily:
                                    AppFontStyles.museoModernoFontFamily,
                                fontSize: AppFontStyles.fontSize_18,
                                fontVariations: [
                                  AppFontStyles.boldFontVariation,
                                ],
                              ),
                            ),
                            TextSpan(
                              text: AppStrings.today,
                              style: TextStyle(
                                fontFamily:
                                    AppFontStyles.museoModernoFontFamily,
                                fontSize: AppFontStyles.fontSize_18,
                                fontVariations: [
                                  AppFontStyles.regularFontVariation,
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: AppDimensions.dim5.h),
                    SizedBox(
                      width: AppDimensions.dim330.w,
                      child: Text(
                        AppStrings.waterBottleReminder,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: AppFontStyles.fontSize_14,
                          fontVariations: [
                            AppFontStyles.semiBoldFontVariation,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottleWidget(BuildContext context) {
    return SizedBox(
      height: AppDimensions.dim456.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            top: 0,
            bottom: -(AppDimensions.dim20.h),
            child: GestureDetector(
              onTap: () async {
                // await context.read<BleCubit>().forceFlushSlots();
              },
              child: Image.asset(
                'assets/images/bottle_image.png',
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
          Positioned(
            bottom: AppDimensions.dim55.h,
            left: AppDimensions.dim182.w,
            child: SizedBox(
              child: BlocBuilder<BottleDataCubit, BottleDataState>(
                  buildWhen: (previous, current) =>
                      previous.volumePercent != current.volumePercent ||
                      previous.volume != current.volume,
                  builder: (context, state) {
                    return FutureBuilder(future: () {
                      DateTime now = DateTime.now();

                      DateTime startDate =
                          DateTime(now.year, now.month, now.day);

                      DateTime endDate = startDate
                          .add(const Duration(days: 1))
                          .subtract(const Duration(milliseconds: 1));

                      return context
                          .read<BottleDataCubit>()
                          .getHistoryForDateRange(startDate, endDate);
                    }(), builder: (context, snapshot) {
                      double completionPercent = 0;
                      double waterVolumeConsumed = 0;

                      if (snapshot.hasData ||
                          snapshot.data?.isNotEmpty == true) {
                        waterVolumeConsumed = WaterConsumptionCalculator
                            .calculateDailyConsumption(snapshot.data!);

                        completionPercent = WaterConsumptionCalculator
                            .calculateCompletionPercentage(waterVolumeConsumed);
                      }

                      return CustomCircularProgressIndicator(
                        height: AppDimensions.dim70.h,
                        width: AppDimensions.dim70.w,
                        radius: AppDimensions.dim32.w,
                        lineWidth: AppDimensions.dim7.w,
                        backgroundNeedsGradient: true,
                        linearGradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          transform: GradientRotation(-10 * pi / 180),
                          colors: [
                            Color(0XFFFFFFFF),
                            Color(0XFFFFFFFF),
                            Color(0XFF48CAFF),
                            Color(0XFF48CAFF),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: AppDimensions.dim4.r,
                            spreadRadius: AppDimensions.dim1.r,
                            color: Colors.black.withOpacity(.3),
                            offset: Offset(
                                AppDimensions.dim2.w, AppDimensions.dim2.h),
                          ),
                          BoxShadow(
                            blurRadius: AppDimensions.dim4.r,
                            spreadRadius: AppDimensions.dim1.r,
                            color: Colors.black.withOpacity(.3),
                            offset: Offset(
                                -AppDimensions.dim1.w, -AppDimensions.dim1.h),
                          ),
                        ],
                        backgroundColor: Color(0XFF936FA7),
                        progressBackgroundColor: Color(0XFF9F7FB1),
                        needsInnerShadow: false,
                        percentageValue: completionPercent,
                        center: Container(
                          width: AppDimensions.dim50.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(
                                  begin: 0.0,
                                  end: waterVolumeConsumed / 1000,
                                ),
                                duration: Duration(milliseconds: 500),
                                curve: Curves.fastEaseInToSlowEaseOut,
                                builder: (context, value, child) {
                                  return Text(
                                    "${value.toStringAsFixed(1)}L",
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: AppFontStyles.fontSize_18,
                                      fontVariations: [
                                        AppFontStyles.boldFontVariation
                                      ],
                                    ),
                                  );
                                },
                              ),
                              FutureBuilder<int?>(
                                future: SharedPrefsHelper.getUserGoal(),
                                builder: (context, snapshot) {
                                  double userGoalLiters = 0.0;

                                  if (snapshot.hasData &&
                                      snapshot.data != null) {
                                    userGoalLiters = snapshot.data! / 1000.0;
                                  }

                                  return Text(
                                    "/${userGoalLiters.toStringAsFixed(1)}L",
                                    style: TextStyle(
                                      color: AppColors.secondaryMintGreen,
                                      fontSize: AppFontStyles.fontSize_10,
                                      fontVariations: [
                                        AppFontStyles.semiBoldFontVariation,
                                      ],
                                    ),
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                      );
                    });
                  }),
            ),
          ),
          Positioned(
            bottom: AppDimensions.dim195.h,
            left: AppDimensions.dim184.w,
            child: BlocBuilder<BottleDataCubit, BottleDataState>(
              buildWhen: (previous, current) =>
                  previous.volumePercent != current.volumePercent,
              builder: (context, state) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppDimensions.dim187),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: AppDimensions.dim4.r,
                        spreadRadius: AppDimensions.dim1.r,
                        color: Colors.black.withOpacity(.25),
                        offset:
                            Offset(AppDimensions.dim4.w, AppDimensions.dim4.h),
                      )
                    ],
                  ),
                  width: AppDimensions.dim65.w,
                  height: AppDimensions.dim117.h,
                  child: WaterWaveWidget(
                    orientation: Axis.horizontal,
                    fillPercent: state.volumePercent / 100,
                    speed: Duration(seconds: 3),
                    amplitude: 4,
                    waveCount: 3,
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: AppDimensions.dim238.h,
            left: AppDimensions.dim184.w,
            child: Container(
              width: AppDimensions.dim66.w,
              alignment: Alignment.center,
              child: BlocBuilder<BottleDataCubit, BottleDataState>(
                buildWhen: (previous, current) =>
                    previous.volumePercent != current.volumePercent,
                builder: (context, state) {
                  return TweenAnimationBuilder<int>(
                    tween: IntTween(
                      begin: 0,
                      end: state.volumePercent,
                    ),
                    duration: Duration(milliseconds: 500),
                    curve: Curves.fastEaseInToSlowEaseOut,
                    builder: (context, value, child) {
                      return Text(
                        "$value%",
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: AppFontStyles.fontSize_24,
                          fontVariations: [
                            AppFontStyles.semiBoldFontVariation,
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: AppDimensions.dim205.h,
            left: AppDimensions.dim192.w,
            child: Container(
              width: AppDimensions.dim50.w,
              alignment: Alignment.center,
              child: BlocBuilder<BottleDataCubit, BottleDataState>(
                buildWhen: (previous, current) =>
                    previous.volume != current.volume,
                builder: (context, state) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 0,
                      end: state.volume,
                    ),
                    duration: Duration(milliseconds: 500),
                    curve: Curves.fastEaseInToSlowEaseOut,
                    builder: (context, value, child) {
                      return Text(
                        "${value.toStringAsFixed(0)} ml",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: AppFontStyles.fontSize_10,
                          fontVariations: [
                            AppFontStyles.boldFontVariation,
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBleStatus(BuildContext context) {
    return Container(
      height: AppDimensions.dim60.h,
      alignment: Alignment.center,
      child: BlocBuilder<BleCubit, BleState>(
        builder: (context, state) {
          final connectionState = state.status;

          switch (connectionState) {
            case BleStatus.disconnected:
              return Text(
                "Bottle disconnected",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFontStyles.fontSize_12,
                  color: AppColors.redColor,
                  fontVariations: [
                    AppFontStyles.semiBoldFontVariation,
                  ],
                ),
              );

            case BleStatus.scanning:
              return Text(
                "Scanning for bottle",
                style: TextStyle(
                  fontSize: AppFontStyles.fontSize_12,
                  color: AppColors.white,
                  fontVariations: [
                    AppFontStyles.semiBoldFontVariation,
                  ],
                ),
              );

            case BleStatus.connecting:
              return Text(
                "Initiating connection",
                style: TextStyle(
                  fontSize: AppFontStyles.fontSize_12,
                  color: AppColors.white,
                  fontVariations: [
                    AppFontStyles.semiBoldFontVariation,
                  ],
                ),
              );

            case BleStatus.connected:
              return Text(
                "Bottle connected",
                style: TextStyle(
                  fontSize: AppFontStyles.fontSize_12,
                  color: AppColors.white,
                  fontVariations: [
                    AppFontStyles.semiBoldFontVariation,
                  ],
                ),
              );

            default:
              return Text(
                "Bluetooth status unknown",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFontStyles.fontSize_12,
                  color: AppColors.redColor,
                  fontVariations: [
                    AppFontStyles.semiBoldFontVariation,
                  ],
                ),
              );
          }
        },
      ),
    );
  }

  Widget _buildTodayStats(double todayConsumption,
      double todayConsumptionPercentage, String slotName) {
    return InkWell(
      onTap: () async {},
      child: Container(
        height: AppDimensions.dim80.h,
        margin: EdgeInsets.symmetric(horizontal: AppDimensions.dim20.w),
        decoration: BoxDecoration(
          color: AppColors.goalCompletionStatsPurple,
          boxShadow: [
            BoxShadow(
              blurRadius: AppDimensions.dim4.r,
              spreadRadius: 0,
              color: Colors.black.withOpacity(.25),
              offset: Offset(AppDimensions.dim2.w, AppDimensions.dim2.h),
            )
          ],
          border: GradientBoxBorder(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                const Color(0XFF3F3F3F),
              ],
            ),
            width: AppDimensions.dim1.w,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.dim90.r),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.dim16.w,
          vertical: AppDimensions.dim13.h,
        ),
        child: Row(
          children: [
            SizedBox(
              width: AppDimensions.dim28.w,
              height: AppDimensions.dim28.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 0, sigmaY: 1.3.w),
                      child: Transform.translate(
                        offset: Offset(0, AppDimensions.dim3.h),
                        child: Opacity(
                          opacity: 0.3,
                          child: SvgPicture.asset(
                            'assets/images/waterdrop_ic.svg',
                            color: Colors.black,
                            width: AppDimensions.dim28.w,
                            height: AppDimensions.dim28.h,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/images/waterdrop_ic.svg',
                    fit: BoxFit.contain,
                    width: AppDimensions.dim28.w,
                    height: AppDimensions.dim28.h,
                  ),
                ],
              ),
            ),
            Container(
              width: AppDimensions.dim70.w,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Water",
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: AppFontStyles.urbanistFontFamily,
                      color: AppColors.white,
                      fontSize: AppFontStyles.fontSize_12,
                      fontVariations: [
                        AppFontStyles.semiBoldFontVariation,
                      ],
                    ),
                  ),
                  TweenAnimationBuilder<int>(
                    tween: IntTween(
                      begin: 0,
                      end: todayConsumption.toInt(),
                    ),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.fastEaseInToSlowEaseOut,
                    builder: (context, value, child) {
                      String displayValue;

                      if (value < 1000) {
                        displayValue = "$value ml";
                      } else {
                        displayValue = "${(value / 1000).toStringAsFixed(1)} L";
                      }

                      return Text(
                        displayValue,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: AppFontStyles.urbanistFontFamily,
                          color: AppColors.white,
                          fontSize: AppFontStyles.fontSize_16,
                          fontVariations: [
                            AppFontStyles.boldFontVariation,
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              width: AppDimensions.dim25.w,
            ),
            Container(
              width: AppDimensions.dim118.w,
              height: AppDimensions.dim26.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.goalCompletionStatesMealPurple,
                border: Border.all(
                  color: AppColors.white,
                  width: AppDimensions.dim1,
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: AppDimensions.dim3.r,
                    spreadRadius: 0,
                    color: Colors.black.withOpacity(.38),
                    offset: Offset(0, 0),
                  )
                ],
                borderRadius: BorderRadius.circular(
                  AppDimensions.radius_40,
                ),
              ),
              child: Text(
                // 🔥 Displays the current slot's name dynamically
                slotName,
                overflow: TextOverflow.clip,
                maxLines: 1,
                style: TextStyle(
                  color: AppColors.white,
                  fontFamily: AppFontStyles.urbanistFontFamily,
                  fontSize: AppFontStyles.fontSize_14,
                  fontVariations: [
                    AppFontStyles.boldFontVariation,
                  ],
                ),
              ),
            ),
            SizedBox(
              width: AppDimensions.dim40.w,
            ),
            Container(
              width: AppDimensions.dim80.w,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Completed",
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: AppFontStyles.urbanistFontFamily,
                      color: AppColors.white,
                      fontSize: AppFontStyles.fontSize_12,
                      fontVariations: [
                        AppFontStyles.semiBoldFontVariation,
                      ],
                    ),
                  ),
                  TweenAnimationBuilder<int>(
                    tween: IntTween(
                      begin: 0,
                      end: todayConsumptionPercentage.toInt(),
                    ),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.fastEaseInToSlowEaseOut,
                    builder: (context, value, child) {
                      return Text(
                        "$value%",
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: AppFontStyles.urbanistFontFamily,
                          color: AppColors.white,
                          fontSize: AppFontStyles.fontSize_16,
                          fontVariations: [
                            AppFontStyles.boldFontVariation,
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalText(double todayConsumptionPercentage) {
    return SizedBox(
        width: AppDimensions.dim350.w,
        child: Text(
          AppStrings.getGoalString(todayConsumptionPercentage),
          style: TextStyle(
            fontSize: AppFontStyles.fontSize_16,
            color: AppColors.white,
            height: AppFontStyles.getLineHeight(AppFontStyles.fontSize_16, 120),
            fontVariations: [
              AppFontStyles.semiBoldFontVariation,
            ],
          ),
          textAlign: TextAlign.center,
        ));
  }

  Widget _buildWeatherIconWidget(String iconPath) {
    print('Building icon widget for: $iconPath');

    // Check if it's a PNG file
    if (iconPath.toLowerCase().endsWith('.png')) {
      print('Loading as PNG image');
      return Image.asset(
        iconPath,
        height: AppDimensions.dim45.h,
        width: AppDimensions.dim45.h,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          print('PNG Error loading: $iconPath');
          print('Error: $error');
          return Container(
            height: AppDimensions.dim45.h,
            width: AppDimensions.dim45.h,
            color: Colors.orange,
            child: Icon(Icons.warning, color: Colors.white),
          );
        },
      );
    }
    // Otherwise treat as SVG
    else {
      print('Loading as SVG image');
      return SvgPicture.asset(
        iconPath,
        height: AppDimensions.dim45.h,
        width: AppDimensions.dim45.h,
        fit: BoxFit.contain,
        placeholderBuilder: (BuildContext context) {
          print('SVG Placeholder shown for: $iconPath');
          return Container(
            height: AppDimensions.dim45.h,
            width: AppDimensions.dim45.h,
            color: Colors.grey,
            child: Icon(Icons.error, color: Colors.red),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('SVG Error loading: $iconPath');
          print('Error: $error');
          return Container(
            height: AppDimensions.dim45.h,
            width: AppDimensions.dim45.h,
            color: Colors.orange,
            child: Icon(Icons.warning, color: Colors.white),
          );
        },
      );
    }
  }
}
