import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hydrify/constants/app_colors.dart';
import 'package:hydrify/constants/app_dimensions.dart';
import 'package:hydrify/constants/app_font_styles.dart';

class MenuItemTile extends StatelessWidget {
  final String title;
  final String info;
  final String iconpatharrow;
  final VoidCallback? onTap;

  const MenuItemTile({
    super.key,
    required this.title,
    required this.info,
    required this.iconpatharrow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      //onTap: () => debugPrint("Tapped $title"),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.dim16.w,
          vertical: AppDimensions.dim12.h,
        ),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppColors.white,
                fontSize: AppFontStyles.fontSize_20.sp,
                fontFamily: AppFontStyles.urbanistFontFamily,
                fontVariations: [AppFontStyles.fontWeightVariation600],
              ),
            ),
            const Spacer(),
            Text(
              info,
              style: TextStyle(
                color: AppColors.white,
                fontSize: AppFontStyles.fontSize_16.sp,
                fontFamily: AppFontStyles.urbanistFontFamily,
                fontVariations: [AppFontStyles.fontWeightVariation600],
              ),
            ),
            SizedBox(width: AppDimensions.dim20.w),
            Image.asset(
              iconpatharrow,
              width: AppDimensions.dim9.w,
              height: AppDimensions.dim16.h,
              color: AppColors.white,
            ),
            SizedBox(width: AppDimensions.dim8.w),
          ],
        ),
      ),
    );
  }
}

//=========================================================================

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:hydrify/constants/app_colors.dart';
// import 'package:hydrify/constants/app_dimensions.dart';
// import 'package:hydrify/constants/app_font_styles.dart';

// class MenuItemTile extends StatelessWidget {
//   final String title;
//   final String info;
//   final String iconpatharrow;

//   const MenuItemTile({
//     super.key,
//     required this.title,
//     required this.info,
//     required this.iconpatharrow,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () => debugPrint("Tapped $title"),
//       child: Padding(
//         padding: EdgeInsets.symmetric(
//           horizontal: AppDimensions.dim16.w,
//           vertical: AppDimensions.dim12.h,
//         ),
//         child: Row(
//           children: [
//             Text(
//               title,
//               style: TextStyle(
//                 color: AppColors.white,
//                 fontSize: AppFontStyles.fontSize_20.sp,
//                 fontFamily: AppFontStyles.urbanistFontFamily,
//                 fontVariations: [AppFontStyles.fontWeightVariation600],
//               ),
//             ),
//             const Spacer(),
//             Text(
//               info,
//               style: TextStyle(
//                 color: AppColors.white,
//                 fontSize: AppFontStyles.fontSize_16.sp,
//                 fontFamily: AppFontStyles.urbanistFontFamily,
//                 fontVariations: [AppFontStyles.fontWeightVariation600],
//               ),
//             ),
//             SizedBox(width: AppDimensions.dim20.w),
//             Image.asset(
//               iconpatharrow,
//               width: AppDimensions.dim9.w,
//               height: AppDimensions.dim16.h,
//               color: AppColors.white,
//             ),
//             SizedBox(width: AppDimensions.dim8.w),
//           ],
//         ),
//       ),
//     );
//   }
// }

//=========================================================================
