import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrify/cubit/ble/ble_cubit.dart';
import 'package:hydrify/helpers/database_helper.dart';
import 'package:hydrify/models/bottle_data.dart';
import 'package:sqflite/sqflite.dart';
part 'bottle_data_state.dart';

class BottleDataCubit extends Cubit<BottleDataState> {
  final BleCubit _bleCubit;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late final StreamSubscription _bleSub;

  static const int pageSize = 50;

  BottleDataCubit(this._bleCubit) : super(BottleDataState.initial()) {
    _restoreLastValues();
    _bleSub = _bleCubit.stream.listen(_handleBleStateChange);
  }
  Future<void> _restoreLastValues() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableName,
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    print("🔍 Last record query result: $maps");

    if (maps.isNotEmpty) {
      final lastData = BottleData.fromMap(maps.first);
      print("✅ Restoring from last record: "
          "volume=${lastData.liquidVolume}, "
          "percent=${lastData.liquidPercent}, "
          "battery=${lastData.battery}, "
          "timestamp=${lastData.timestamp}");

      emit(state.copyWith(
        volume: lastData.liquidVolume,
        volumePercent: lastData.liquidPercent,
        battery: lastData.battery,
      ));
    } else {
      print("⚠️ No previous bottle data found in DB.");
    }
  }

  Future<void> _handleBleStateChange(BleState bleState) async {
    if (bleState.status != BleStatus.connected) {
      log("⚠️ Skipping DB insert — BLE not connected (state: ${bleState.status})");
      return;
    }

    final newVolume = bleState.volume ?? 0.0;
    final newPercent = bleState.percent ?? 0;
    final newBattery = bleState.battery ?? 0;

    final newData = BottleData(
      liquidVolume: newVolume,
      liquidPercent: newPercent,
      battery: newBattery,
      timestamp: DateTime.now(),
    );

    final db = await _dbHelper.database;
    await db.insert(
      DatabaseHelper.tableName,
      newData.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    List<BottleData> pageData = state.currentPage == 0
        ? await fetchPageInternal(0)
        : state.currentPageData;

    emit(state.copyWith(
      volume: newVolume,
      volumePercent: newPercent,
      battery: newBattery,
      currentPage: state.currentPage,
      currentPageData: pageData,
    ));
  }

  Future<List<BottleData>> fetchPage(int page) async {
    final data = await fetchPageInternal(page);
    emit(state.copyWith(
      currentPage: page,
      currentPageData: data,
    ));
    return data;
  }

  Future<List<BottleData>> fetchPageInternal(int page) async {
    final db = await _dbHelper.database;
    final offset = page * pageSize;

    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableName,
      orderBy: 'timestamp DESC',
      limit: pageSize,
      offset: offset,
    );

    return List.generate(
      maps.length,
      (i) => BottleData.fromMap(maps[i]),
    );
  }

  Future<int> getTotalRecords() async {
    final db = await _dbHelper.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${DatabaseHelper.tableName}'),
    );
    return count ?? 0;
  }

  Future<List<BottleData>> getHistoryForDateRange(
      DateTime start, DateTime end) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableName,
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'timestamp DESC',
    );

    return List.generate(
      maps.length,
      (i) => BottleData.fromMap(maps[i]),
    );
  }

  Future<void> clearOldRecords(int daysToKeep) async {
    final db = await _dbHelper.database;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

    await db.delete(
      DatabaseHelper.tableName,
      where: 'timestamp < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );

    final refreshedPage = await fetchPageInternal(state.currentPage);
    emit(state.copyWith(currentPageData: refreshedPage));
  }

  @override
  Future<void> close() {
    _bleSub.cancel();
    return super.close();
  }
}
