import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hydrify/constants/app_colors.dart';
import 'package:hydrify/constants/app_dimensions.dart';
import 'package:hydrify/helpers/shared_pref_helper.dart';
import 'package:hydrify/providers/authentication_provider.dart';
import 'package:hydrify/screens/auth/auth_options_screen.dart';
import 'package:hydrify/screens/bottom_nav_screen_new.dart';
import 'package:hydrify/screens/user_personal_info_input_screen..dart';
import 'package:provider/provider.dart';

class LocalAuthScreen extends StatefulWidget {
  const LocalAuthScreen({super.key});

  @override
  State<LocalAuthScreen> createState() => _LocalAuthScreenState();
}

class _LocalAuthScreenState extends State<LocalAuthScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(
        Duration(
          milliseconds: 500,
        ), () {
      _handleStartupAuth();
    });
  }

  Future<void> _handleStartupAuth() async {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);

    final success = await authProvider.authenticateWithBiometrics();
    final loggedInUserEmail = await SharedPrefsHelper.getUserEmail() ?? "";
    final hasUserFilledInPersonalInfo =
        await SharedPrefsHelper.isPersonalInfoSubmitted();
    final hasUserSelectedPersonalGoal = await SharedPrefsHelper.getUserGoal();

    if (!mounted) return;

    if (success) {
      Future.delayed(
          Duration(
            milliseconds: 800,
          ), () {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              if (loggedInUserEmail != null && loggedInUserEmail.isNotEmpty) {
                if (hasUserFilledInPersonalInfo == true &&
                    hasUserSelectedPersonalGoal != null) {
                  return BottomNavScreenNew();
                } else {
                  return UserInfoInputScreen();
                }
              } else {
                return AuthOptionsScreen();
              }
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.gradientStart,
              AppColors.gradientEnd,
            ],
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: AppDimensions.dim285.h,
            ),
            Image.asset(
              "assets/images/bottle_top_image.png",
              width: AppDimensions.dim275.w,
              height: AppDimensions.dim275.h,
            ),
            SizedBox(
              height: AppDimensions.dim240.h,
            ),
            SvgPicture.asset(
              "assets/images/ai_meets_hydration_image.svg",
            ),
          ],
        ),
      ),
    );
  }
}
