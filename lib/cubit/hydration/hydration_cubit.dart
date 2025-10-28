import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrify/cubit/hydration/hydration_sync.dart';
import 'package:hydrify/helpers/database_helper.dart';
import 'package:hydrify/helpers/shared_pref_helper.dart';
import 'package:hydrify/models/hydration_entry.dart';
import 'package:hydrify/services/notification_service.dart';

part 'hydration_state.dart';

class HydrationCubit extends Cubit<HydrationState> {
  final HydrationSync ble;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  HydrationCubit({required this.ble})
      : super(HydrationState(
          entries: [],
          totalDrank: 0,
          goal: 0,
          selectedDate: DateTime.now(),
        )) {
    _init();
  }

  void _calculateCurrentSlotStatus() {
    final now = TimeOfDay.now();
    final nowMinutes = _timeOfDayToMinutes(now);

    HydrationEntry? activeEntry;
    for (final entry in state.entries) {
      final startMin = _timeOfDayToMinutes(entry.startTime);
      final endMin = _timeOfDayToMinutes(entry.endTime);

      if (startMin < endMin) {
        if (nowMinutes >= startMin && nowMinutes < endMin) {
          activeEntry = entry;
          break;
        }
      } else {
        if (nowMinutes >= startMin || nowMinutes < endMin) {
          activeEntry = entry;
          break;
        }
      }
    }

    double consumption = 0.0;
    double percentage = 0.0;

    if (activeEntry != null) {
      consumption = activeEntry.waterDrank.toDouble();

      if (activeEntry.amount > 0) {
        percentage = (consumption / activeEntry.amount) * 100.0;
        percentage = percentage.clamp(0.0, 100.0);
      }
    }

    emit(state.copyWith(
      currentSlotEntry: activeEntry,
      currentSlotConsumption: consumption,
      currentSlotPercentage: percentage,
    ));
  }

  Future<void> _init() async {
    try {
      ble.hydrationUpdates.listen((entries) {
        markCompletedByEntries(entries);
      });
      final dailyGoal = await SharedPrefsHelper.getUserGoal() ?? 0;
      log("[Cubit] Daily goal: $dailyGoal");

      final slotsFromDb = await _dbHelper.getAllSlots();
      log("[Cubit] Loaded ${slotsFromDb.length} slots from DB");
      for (var s in slotsFromDb) {
        log("  Slot: ${s.slot.label}, amount: ${s.amount}, status: ${s.status}");
      }

      int total = slotsFromDb
          .where((e) => e.status == HydrationStatus.completed)
          .fold(0, (sum, e) => sum + e.amount);

      emit(state.copyWith(
        entries: slotsFromDb,
        goal: dailyGoal,
        totalDrank: total,
      ));
      _calculateCurrentSlotStatus();
    } catch (e) {
      log("[Cubit] Failed to load hydration data: $e");
      emit(state.copyWith(errorMessage: "Failed to load hydration data."));
    }
  }

  Future<void> loadSlotsFromDb() async {
    try {
      final slotsFromDb = await _dbHelper.getAllSlots();
      log("[Cubit] _loadSlotsFromDb: Loaded ${slotsFromDb.length} slots");
      for (var s in slotsFromDb) {
        log("  Slot: ${s.slot.label}, amount: ${s.amount}, status: ${s.status}");
      }

      if (slotsFromDb.isEmpty) {
        emit(state.copyWith(entries: []));
      } else {
        final total = slotsFromDb
            .where((e) => e.status == HydrationStatus.completed)
            .fold(0, (sum, e) => sum + e.amount);

        emit(state.copyWith(entries: slotsFromDb, totalDrank: total));
      }
    } catch (e) {
      log("[Cubit] Failed to load slots from DB: $e");
      emit(state.copyWith(errorMessage: "Failed to load slots from DB."));
    }
  }

  void toggleStatus(int index) {
    final updated = List<HydrationEntry>.from(state.entries);
    final entry = updated[index];

    updated[index] = entry.copyWith(
      status: entry.status == HydrationStatus.completed
          ? HydrationStatus.pending
          : HydrationStatus.completed,
    );

    final total = updated
        .where((e) => e.status == HydrationStatus.completed)
        .fold(0, (sum, e) => sum + e.amount);

    emit(state.copyWith(
        entries: updated,
        totalDrank: total,
        errorMessage: null,
        successMessage: null));
  }

  void updateDate(DateTime newDate) {
    emit(state.copyWith(
        selectedDate: newDate, errorMessage: null, successMessage: null));
  }

  void updateTimeSlot({
    required HydrationSlot slot,
    required TimeOfDay newStart,
    required TimeOfDay newEnd,
  }) async {
    final newStartMin = _timeOfDayToMinutes(newStart);
    final newEndMin = _timeOfDayToMinutes(newEnd);

    if (newStartMin == newEndMin) {
      emit(state.copyWith(
        errorMessage: "Start and end time cannot be the same.",
        successMessage: null,
      ));
      return;
    }

    final newIntervals = _toIntervals(newStartMin, newEndMin);

    for (final entry in state.entries) {
      if (entry.slot == slot) continue;

      final existingIntervals = _toIntervals(
        _timeOfDayToMinutes(entry.startTime),
        _timeOfDayToMinutes(entry.endTime),
      );

      if (_intervalsOverlapAny(newIntervals, existingIntervals)) {
        emit(state.copyWith(
          errorMessage: "Time range overlaps with ${entry.slot.label}.",
          successMessage: null,
        ));
        return;
      }
    }

    final updated = state.entries.map((entry) {
      if (entry.slot == slot) {
        return entry.copyWith(startTime: newStart, endTime: newEnd);
      }
      return entry;
    }).toList();

    emit(state.copyWith(entries: updated));

    _calculateCurrentSlotStatus();

    final updatedEntry = updated.firstWhere((e) => e.slot == slot);
    final notificationService = NotificationService();
    await notificationService.cancelReminder(slot);
    await notificationService.scheduleHydrationReminders([updatedEntry]);
    await notificationService.testNotification();
    await _dbHelper.insertOrUpdateSlot(updatedEntry);
    ble.queueHydrationSlots(updated);
  }

  Future<void> markCompletedByEntries(List<HydrationEntry> newEntries) async {
    final currentEntries = List<HydrationEntry>.from(state.entries);

    for (final incoming in newEntries) {
      final index = currentEntries.indexWhere((e) => e.slot == incoming.slot);

      if (index >= 0) {
        final updatedEntry = currentEntries[index].copyWith(
          waterDrank: incoming.waterDrank,
          status: HydrationStatus.completed,
        );

        currentEntries[index] = updatedEntry;

        await _dbHelper.insertOrUpdateSlot(updatedEntry);
      } else {
        final newEntry = incoming.copyWith(status: HydrationStatus.completed);

        currentEntries.add(newEntry);

        await _dbHelper.insertOrUpdateSlot(newEntry);
      }
    }
    final total = currentEntries
        .where((e) => e.status == HydrationStatus.completed)
        .fold(0, (sum, e) => sum + e.waterDrank);

    emit(state.copyWith(
      entries: currentEntries,
      totalDrank: total,
      errorMessage: null,
      successMessage: "${newEntries.length} slot(s) marked as completed!",
    ));

    _calculateCurrentSlotStatus();
  }

  void clearMessages() {
    emit(state.copyWith(errorMessage: null, successMessage: null));
  }

  int _timeOfDayToMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  /// Convert a possibly-wrapping range [startMin, endMin) to one or two intervals
  /// If start < end -> single interval [start,end)
  /// If start > end -> wraps midnight -> return [start,1440) and [0,end)
  List<_Interval> _toIntervals(int startMin, int endMin) {
    if (startMin < endMin) {
      return [_Interval(startMin, endMin)];
    } else {
      // wrap-around
      return [
        _Interval(startMin, 1440),
        _Interval(0, endMin),
      ];
    }
  }

  bool _intervalsOverlapAny(List<_Interval> aList, List<_Interval> bList) {
    for (final a in aList) {
      for (final b in bList) {
        if (_intervalsOverlap(a.start, a.end, b.start, b.end)) return true;
      }
    }
    return false;
  }

  bool _intervalsOverlap(int s1, int e1, int s2, int e2) {
    return s1 < e2 && e1 > s2;
  }
}

class _Interval {
  final int start;
  final int end;
  _Interval(this.start, this.end);
}
