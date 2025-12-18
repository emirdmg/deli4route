import 'package:deli4route/core/colors/app_colors.dart';
import 'package:flutter/material.dart';

class AppBorders {
  static final enabled = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(
      color: Colors.black54,
      width: 1.5,
    ),
  );

  static final focused = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(
      color: AppColors.activeDefaultButton,
      width: 2,
    ),
  );

  static final error = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(
      color: Colors.red,
      width: 1.5,
    ),
  );

  static final focusedError = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(
      color: Colors.redAccent,
      width: 2,
    ),
  );
}