import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class DojoBannerSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.bgDivider),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.goldPrimary,
          strokeWidth: 2,
        ),
      ),
    );
  }
}