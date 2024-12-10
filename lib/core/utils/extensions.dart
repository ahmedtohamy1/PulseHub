import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  double get height => MediaQuery.of(this).size.height;
  double get width => MediaQuery.of(this).size.width;
}

extension StringExtension on String? {
  bool isNullOrEmpty() => this == null || this == "";
}
// ahmed ! null && ahmed != ""  .. ahmed.isNullOrEmpty()

extension ListExtension<T> on List<T>? {
  bool isNullOrEmpty() => this == null || this!.isEmpty;
}
