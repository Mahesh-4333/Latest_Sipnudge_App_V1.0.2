import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hydrify/constants/app_colors.dart';
import 'package:hydrify/constants/app_dimensions.dart';
import 'package:hydrify/constants/app_font_styles.dart';
import 'package:hydrify/constants/app_strings.dart';
import 'package:hydrify/cubit/user_info/user_info_cubit.dart';
import 'package:hydrify/helpers/data_verification_helper.dart';
import 'package:hydrify/helpers/shared_pref_helper.dart';

class GreetingWidget extends StatefulWidget {
  const GreetingWidget({super.key});

  @override
  State<GreetingWidget> createState() => _GreetingWidgetState();
}

class _GreetingWidgetState extends State<GreetingWidget> {
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final userEmail = await SharedPrefsHelper.getUserEmail();
    final name = DataVerifcationHelper.extractNameFromEmail(userEmail!);
    setState(() {
      _userName = name;
    });
  }

  String _getGreeting(UserInfoState userInfo) {
    final now = DateTime.now();

    DateTime? wakeup;
    if (userInfo.wakeupHour != null && userInfo.wakeupMinute != null) {
      final hour = (userInfo.wakeupPeriod == "PM" && userInfo.wakeupHour! < 12)
          ? userInfo.wakeupHour! + 12
          : userInfo.wakeupHour!;
      wakeup = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        userInfo.wakeupMinute ?? 0,
      );
    }

    DateTime? bedtime;
    if (userInfo.bedtimeHour != null && userInfo.bedtimeMinute != null) {
      final hour =
          (userInfo.bedtimePeriod == "PM" && userInfo.bedtimeHour! < 12)
              ? userInfo.bedtimeHour! + 12
              : userInfo.bedtimeHour!;
      bedtime = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        userInfo.bedtimeMinute ?? 0,
      );
    }

    if (wakeup != null &&
        now.isAfter(wakeup.subtract(const Duration(hours: 1))) &&
        now.isBefore(wakeup.add(const Duration(hours: 1)))) {
      return AppStrings.goodMorning;
    }

    if (bedtime != null &&
        now.isAfter(bedtime.subtract(const Duration(hours: 1))) &&
        now.isBefore(bedtime.add(const Duration(hours: 1)))) {
      return AppStrings.goodNight;
    }

    // Fallback to default greeting
    final hourNow = now.hour;
    if (hourNow < 12) {
      return AppStrings.goodMorning;
    } else if (hourNow < 17) {
      return AppStrings.goodAfternoon;
    } else if (hourNow < 21) {
      return AppStrings.goodEvening;
    } else {
      return AppStrings.goodNight;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userName == null) {
      return const SizedBox(); // loader or shimmer
    }

    return BlocBuilder<UserInfoCubit, UserInfoState>(
      builder: (context, userInfo) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(userInfo),
              style: TextStyle(
                fontSize: AppFontStyles.fontSize_14,
                fontFamily: AppFontStyles.museoModernoFontFamily,
                color: AppColors.white,
                fontVariations: [AppFontStyles.semiBoldFontVariation],
              ),
            ),
            SizedBox(height: AppDimensions.dim4.h),
            Text(
              _userName!,
              style: TextStyle(
                color: Colors.white,
                fontSize: AppFontStyles.fontSize_20,
                fontFamily: AppFontStyles.museoModernoFontFamily,
                fontVariations: [AppFontStyles.boldFontVariation],
              ),
            ),
          ],
        );
      },
    );
  }
}
