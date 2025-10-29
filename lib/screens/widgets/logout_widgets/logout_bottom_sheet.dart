// // logout_bottom_sheet.dart

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hydrify/constants/app_colors.dart';
import 'package:hydrify/constants/app_dimensions.dart';
import 'package:hydrify/constants/app_font_styles.dart';
import 'package:hydrify/constants/app_strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hydrify/screens/auth/local_auth_screen.dart';
import 'package:hydrify/services/user_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutBottomSheet extends StatelessWidget {
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  const LogoutBottomSheet({super.key, this.onConfirm, this.onCancel
      // required void Function() onCancel,
      // required Null Function() onConfirm
      });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// 🔹 Blur background
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(color: Colors.black.withOpacity(0)),
        ),

        /// 🔹 Bottom Sheet UI
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.bottomSheetGradientStart,
                  AppColors.bottomSheetGradientEnd
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radius_30.r)),
            ),
            padding: EdgeInsets.only(
                top: AppDimensions.dim15.h,
                left: AppDimensions.dim30.w,
                right: AppDimensions.dim30.w,
                bottom: AppDimensions.dim30.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.logout,
                  style: TextStyle(
                    fontSize: AppFontStyles.fontSize_24.sp,
                    color: AppColors.brightReddishPink,
                    fontFamily: AppFontStyles.urbanistFontFamily,
                    fontVariations: [AppFontStyles.boldFontVariation],
                  ),
                ),
                SizedBox(height: AppDimensions.dim48.h),
                Text(
                  AppStrings.areYouSureYouWantToLogout,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: AppFontStyles.fontSize_20.sp,
                    fontFamily: AppFontStyles.urbanistFontFamily,
                    fontVariations: [AppFontStyles.semiBoldFontVariation],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppDimensions.dim48.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.lightBluish,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radius_46.r),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: AppDimensions.dim14.h),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          AppStrings.cancel,
                          style: TextStyle(
                            color: AppColors.eerieBlack,
                            fontSize: AppFontStyles.fontSize_16.sp,
                            fontFamily: AppFontStyles.urbanistFontFamily,
                            fontVariations: [AppFontStyles.boldFontVariation],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppDimensions.dim12.h),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radius_46.r),
                            side: BorderSide(
                              color: AppColors.white,
                              width: AppDimensions.dim1.w,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          // 🔹 Logout logic
                          try {
                            // 1️⃣ Firebase logout
                            await FirebaseAuth.instance.signOut();
                            await UserManager().clear();

                            // 2️⃣ Clear local session
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.clear();

                            // 3️⃣ Close app
                            if (Platform.isIOS) {
                              // 3️⃣ Navigate to login screen (iOS compatible)
                              if (context.mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        LocalAuthScreen(), // Replace with your actual login screen
                                  ),
                                  (route) => false,
                                );
                              }
                            }
                            SystemNavigator.pop();
                          } catch (e) {
                            // Optional: show error toast
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Error logging out: ${e.toString()}'),
                              ),
                            );
                          }
                        },
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.logoutbuttongradientstart,
                                AppColors.logoutbuttongradientend
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radius_46.r),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                                vertical: AppDimensions.dim14.h),
                            child: Text(
                              AppStrings.yesLogout,
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: AppFontStyles.fontSize_16.sp,
                                fontFamily: AppFontStyles.urbanistFontFamily,
                                fontVariations: [
                                  AppFontStyles.boldFontVariation
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


//================== Logout Bottom Sheet ===================//
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:hydrify/constants/app_colors.dart';
// import 'package:hydrify/constants/app_dimensions.dart';
// import 'package:hydrify/constants/app_font_styles.dart';
// import 'package:hydrify/constants/app_strings.dart';

// class LogoutBottomSheet extends StatelessWidget {
//   final VoidCallback onConfirm;
//   final VoidCallback onCancel;

//   const LogoutBottomSheet({
//     super.key,
//     required this.onConfirm,
//     required this.onCancel,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         /// 🔹 Blur background
//         BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
//           child: Container(color: Colors.black.withOpacity(0)),
//         ),

//         /// 🔹 Bottom Sheet UI
//         Align(
//           alignment: Alignment.bottomCenter,
//           child: Container(
//             width: double.infinity,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   AppColors.bottomSheetGradientStart,
//                   AppColors.bottomSheetGradientEnd
//                 ],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//               borderRadius: BorderRadius.vertical(
//                   top: Radius.circular(AppDimensions.radius_30.r)),
//             ),
//             padding: EdgeInsets.only(
//                 top: AppDimensions.dim15.h,
//                 left: AppDimensions.dim30.w,
//                 right: AppDimensions.dim30.w,
//                 bottom: AppDimensions.dim30.h),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   AppStrings.logout,
//                   style: TextStyle(
//                     fontSize: AppFontStyles.fontSize_24.sp,
//                     color: AppColors.brightReddishPink,
//                     fontFamily: AppFontStyles.urbanistFontFamily,
//                     fontVariations: [AppFontStyles.boldFontVariation],
//                   ),
//                 ),
//                 SizedBox(height: AppDimensions.dim48.h),
//                 Text(
//                   AppStrings.areYouSureYouWantToLogout,
//                   style: TextStyle(
//                     color: AppColors.white,
//                     fontSize: AppFontStyles.fontSize_20.sp,
//                     fontFamily: AppFontStyles.urbanistFontFamily,
//                     fontVariations: [AppFontStyles.semiBoldFontVariation],
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 SizedBox(height: AppDimensions.dim48.h),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton(
//                         style: OutlinedButton.styleFrom(
//                           //side:  BorderSide(color: AppColors.lightBluish),
//                           backgroundColor: AppColors.lightBluish,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(
//                                 AppDimensions.radius_46.r),
//                           ),
//                           padding: EdgeInsets.symmetric(
//                               vertical: AppDimensions.dim14.h),
//                         ),
//                         onPressed: onCancel,
//                         child: Text(
//                           AppStrings.cancel,
//                           style: TextStyle(
//                             color: AppColors.eerieBlack,
//                             fontSize: AppFontStyles.fontSize_16.sp,
//                             fontFamily: AppFontStyles.urbanistFontFamily,
//                             fontVariations: [AppFontStyles.boldFontVariation],
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: AppDimensions.dim12.h),
//                     Expanded(
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           padding: EdgeInsets.zero, // important for gradient
//                           backgroundColor:
//                               Colors.transparent, // make button transparent
//                           shadowColor:
//                               Colors.transparent, // remove default shadow
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(
//                                 AppDimensions.radius_46.r),
//                             side: BorderSide(
//                               color: AppColors.white, // White border
//                               width: AppDimensions.dim1.w,
//                             ),
//                           ),
//                         ),
//                         onPressed: onConfirm,
//                         child: Ink(
//                           decoration: BoxDecoration(
//                             gradient: const LinearGradient(
//                               colors: [
//                                 AppColors.logoutbuttongradientstart,
//                                 // logoutbuttongradientstart
//                                 AppColors
//                                     .logoutbuttongradientend // logoutbuttongradientend
//                               ],
//                               begin: Alignment.topCenter,
//                               end: Alignment.bottomCenter,
//                             ),
//                             borderRadius: BorderRadius.circular(
//                                 AppDimensions.radius_46.r),
//                           ),
//                           child: Container(
//                             alignment: Alignment.center,
//                             padding: EdgeInsets.symmetric(
//                                 vertical: AppDimensions.dim14.h),
//                             child: Text(
//                               AppStrings.yesLogout,
//                               style: TextStyle(
//                                 color: AppColors.white,
//                                 fontSize: AppFontStyles.fontSize_16.sp,
//                                 fontFamily: AppFontStyles.urbanistFontFamily,
//                                 fontVariations: [
//                                   AppFontStyles.boldFontVariation
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }


