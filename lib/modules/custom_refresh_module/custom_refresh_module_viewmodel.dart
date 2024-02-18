import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

abstract class CustomRefreshModuleViewModel extends FutureViewModel {
  /// `自定义刷新列表` module viewmodel
  /// ***
  /// [CustomRefreshModuleViewModel]
  /// ***
  CustomRefreshModuleViewModel() : super();

  /// ScrollController
  /// ***
  /// [CustomRefreshModuleViewModel]
  /// ***
  ScrollController get scrollController;

  /// 数据是否为空
  /// ***
  /// [CustomRefreshModuleViewModel]
  /// ***
  bool get isDataEmpty;

  /// `数据` 数量
  /// ***
  /// [CustomRefreshModuleViewModel]
  /// ***
  int get dataCount;

  /// 刷新数据
  /// ***
  /// [CustomRefreshModuleViewModel]
  /// ***
  Future<bool> refreshData();

  /// 加载数据
  /// ***
  /// [CustomRefreshModuleViewModel]
  /// ***
  /// 返回值
  /// - `Future<bool>` 是否有更多数据
  Future<bool> loadData();
}
