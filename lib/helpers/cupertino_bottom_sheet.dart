// file: cupertino_bottom_sheet.dart (updated)
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hydrify/constants/app_colors.dart';
import 'package:hydrify/constants/app_dimensions.dart';
import 'package:hydrify/constants/app_font_styles.dart';
import 'package:hydrify/constants/app_strings.dart';

/// Returns `null` if user dismisses the sheet without pressing Done.
Future<Map<String, dynamic>?> showCupertinoPickerBottomSheet({
  required BuildContext context,
  required String title,
  required int initialValue,
  required int minValue,
  required int maxValue,
  String? suffix,
  bool hasSecondaryValue = false,
  int? secondaryInitialValue,
  int? secondaryMinValue,
  int? secondaryMaxValue,
  String? secondarySuffix,
}) async {
  int selectedValue = initialValue;
  int? selectedSecondaryValue = secondaryInitialValue;
  final completer = Completer<Map<String, dynamic>?>();

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.dim32),
                topRight: Radius.circular(AppDimensions.dim32),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.bottomSheetGradientStart,
                  AppColors.bottomSheetGradientEnd
                ],
              ),
            ),
            padding: EdgeInsets.all(AppDimensions.defaultPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Title / Done / Cancel (Cancel is implicit by swipe/outer tap)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: AppFontStyles.fontSize_24,
                          fontFamily: AppFontStyles.urbanistFontFamily,
                          color: AppColors.white,
                          fontVariations: [
                            AppFontStyles.fontWeightVariation600,
                          ]),
                    ),
                    TextButton(
                      onPressed: () {
                        final result = <String, dynamic>{
                          'primaryValue': selectedValue,
                          if (suffix != null) 'suffix': suffix,
                          if (hasSecondaryValue)
                            'secondaryValue': selectedSecondaryValue,
                          if (hasSecondaryValue && secondarySuffix != null)
                            'secondarySuffix': secondarySuffix,
                        };
                        Navigator.pop(context);
                        if (!completer.isCompleted) completer.complete(result);
                      },
                      child: Text(
                        AppStrings.done,
                        style: TextStyle(
                            fontSize: AppFontStyles.fontSize_24,
                            fontFamily: AppFontStyles.urbanistFontFamily,
                            color: AppColors.white,
                            fontVariations: [
                              AppFontStyles.fontWeightVariation600,
                            ]),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.dim20.h),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoPicker(
                          itemExtent: 40,
                          onSelectedItemChanged: (int value) {
                            setState(() {
                              selectedValue = value + minValue;
                            });
                          },
                          scrollController: FixedExtentScrollController(
                            initialItem: initialValue - minValue,
                          ),
                          children: List<Widget>.generate(
                            maxValue - minValue + 1,
                            (int index) {
                              final value = index + minValue;
                              return Center(
                                child: Text(
                                  suffix != null ? '$value $suffix' : '$value',
                                  style: const TextStyle(
                                      fontSize: 20, color: AppColors.white),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      if (hasSecondaryValue &&
                          secondaryMinValue != null &&
                          secondaryMaxValue != null)
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 40,
                            onSelectedItemChanged: (int value) {
                              setState(() {
                                selectedSecondaryValue =
                                    value + secondaryMinValue;
                              });
                            },
                            scrollController: FixedExtentScrollController(
                              initialItem:
                                  (secondaryInitialValue ?? secondaryMinValue) -
                                      secondaryMinValue,
                            ),
                            children: List<Widget>.generate(
                              secondaryMaxValue - secondaryMinValue + 1,
                              (int index) {
                                final value = index + secondaryMinValue;
                                return Center(
                                  child: Text(
                                    secondarySuffix != null
                                        ? '$value $secondarySuffix'
                                        : '$value',
                                    style: const TextStyle(
                                        fontSize: 20, color: AppColors.white),
                                  ),
                                );
                              },
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
    },
  );

  // If user dismissed without pressing Done, return null.
  if (!completer.isCompleted) {
    completer.complete(null);
  }

  return completer.future;
}
