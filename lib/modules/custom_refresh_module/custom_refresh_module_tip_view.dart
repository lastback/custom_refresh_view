import 'package:custom_refresh_view/env.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 自定义empty tip view
/// ***
/// [CustomRefreshModuleTipView]
/// ***
class CustomRefreshModuleTipView extends StatelessWidget {
  final String tips;
  final HeaderState headerState;

  const CustomRefreshModuleTipView({
    super.key,
    required this.tips,
    required this.headerState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(),
      child: Container(
        width: 200.w,
        height: 200.w,
        decoration: BoxDecoration(color: Theme.of(context).focusColor, borderRadius: BorderRadius.circular(8.w)),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.refresh,
              size: 70.w,
              color: headerState == HeaderState.idle ? null : Colors.grey.shade500,
            ),
            SizedBox(height: 30.w),
            Text(
              tips,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                overflow: TextOverflow.ellipsis,
                color: headerState == HeaderState.idle ? null : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
