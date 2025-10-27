import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hydrify/constants/app_colors.dart';
import 'package:hydrify/constants/app_dimensions.dart';
import 'package:hydrify/constants/app_font_styles.dart';
import 'package:hydrify/constants/app_strings.dart';
import 'package:hydrify/screens/widgets/animated_bottom_navbar_widget.dart';
import 'package:hydrify/screens/widgets/contact_support_widget/contact_support_buttons.dart';

class ContactSupportPage extends StatelessWidget {
  const ContactSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: AppDimensions.dim1.sw,
        height: AppDimensions.dim1.sh,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              /// 🔹 Top Bar
              Padding(
                padding: EdgeInsets.only(
                  top: AppDimensions.dim40.h,
                  left: AppDimensions.dim20.w,
                  right: AppDimensions.dim20.w,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back,
                        color: AppColors.black,
                        size: AppFontStyles.fontSize_30.sp,
                      ),
                    ),
                    SizedBox(width: AppDimensions.dim60.w),
                    Text(
                      AppStrings.contactsupport,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: AppFontStyles.fontSize_24.sp,
                        fontFamily: AppFontStyles.urbanistFontFamily,
                        fontVariations: [AppFontStyles.boldFontVariation],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppDimensions.dim50.h),

              /// 🔹 Support Options
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.dim30.w,
                ),
                child: Column(
                  children: [
                    SupportButton(
                      iconPath: 'assets/customersupporticon.png',
                      label: 'Customer Support',
                      iconpatharrow: "assets/arrow.png",
                      url: "https://sipnudge.com/pages/contact",
                    ),
                    SizedBox(height: AppDimensions.dim20.h),
                    SupportButton(
                      iconPath: 'assets/websiteicon.png',
                      label: 'Website',
                      iconpatharrow: "assets/arrow.png",
                      url: "https://sipnudge.com/",
                    ),
                  ],
                ),
              ),

              const Spacer(),

              /// 🔹 Bottom Navigation
              AnimatedBottomNavBar(),
            ],
          ),
        ),
      ),
    );
  }
}
