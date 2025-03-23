import 'package:flutter/material.dart';

extension TimeOfDayExt on TimeOfDay {
  String formatTime() {
    String formattedHour = hour < 10 ? "0$hour" : "$hour";
    String formattedMinutes = minute < 10 ? "0$minute" : "$minute";
    return "$formattedHour:$formattedMinutes";
  }
}
