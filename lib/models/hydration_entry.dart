import 'package:flutter/material.dart';

enum HydrationStatus { completed, pending }

enum HydrationSlot {
  wakeup,
  breakfast,
  midMorning,
  lunch,
  midAfternoon,
  evening,
  afterDinner,
}

extension HydrationSlotX on HydrationSlot {
  String get label {
    switch (this) {
      case HydrationSlot.wakeup:
        return 'Wakeup Time';
      case HydrationSlot.breakfast:
        return 'Breakfast Time';
      case HydrationSlot.midMorning:
        return 'Mid-Morning';
      case HydrationSlot.lunch:
        return 'Lunch Time';
      case HydrationSlot.midAfternoon:
        return 'Mid-Afternoon';
      case HydrationSlot.evening:
        return 'Evening';
      case HydrationSlot.afterDinner:
        return 'After Dinner';
    }
  }
}

class HydrationEntry {
  final HydrationSlot slot;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int amount;
  final HydrationStatus status;
  final int waterDrank;

  HydrationEntry({
    required this.slot,
    required this.startTime,
    required this.endTime,
    required this.amount,
    this.waterDrank = 0,
    this.status = HydrationStatus.pending,
  });

  HydrationEntry copyWith({
    HydrationSlot? slot,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    int? amount,
    HydrationStatus? status,
    int? waterDrank,
  }) {
    return HydrationEntry(
      slot: slot ?? this.slot,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      waterDrank: waterDrank ?? this.waterDrank,
    );
  }

  /// Format for displaying to user: "7:30 AM - 8:30 AM"
  String get formattedRange {
    return "${_formatTime(startTime)} - ${_formatTime(endTime)}";
  }

  static String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:$minute $period";
  }
}

class TimeOfDayRange {
  final TimeOfDay start;
  final TimeOfDay end;
  TimeOfDayRange({required this.start, required this.end});
}
