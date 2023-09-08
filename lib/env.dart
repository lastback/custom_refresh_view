import 'package:custom_refresh_view/custom_refresh_viewmodel.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// `自定义刷新控件` 刷新状态枚举
/// ***
/// [CustomRefreshView]
/// ***
enum HeaderState {
  /// Initial state, which can be triggered loading more by gesture pull up
  idle,

  canLoading,

  /// indicator is loading more data
  loading,

  loaded,

  /// indicator load failed,Initial state, which can be click retry,If you need to pull up trigger load more,you should set enableLoadingWhenFailed = true in RefreshConfiguration
  failed
}

/// `自定义刷新控件` 加载状态枚举
/// ***
/// [CustomRefreshView]
/// ***
enum FooterState {
  /// Initial state, which can be triggered loading more by gesture pull up
  idle,

  canLoading,

  /// indicator is loading more data
  loading,

  loaded,

  /// indicator is no more data to loading,this state doesn't allow to load more whatever
  noMore,

  /// indicator load failed,Initial state, which can be click retry,If you need to pull up trigger load more,you should set enableLoadingWhenFailed = true in RefreshConfiguration
  failed
}

/// `自定义刷新控件` 加载刷新触发器类型枚举
/// ***
/// [CustomRefreshView]
/// ***
enum EnumCustomRefreshType {
  /// 无
  none,

  /// 刷新触发器
  header,

  /// 加载触发器
  footer,
}

class CustomRefreshConfig {
  CustomRefreshHeaderConfig? header;

  CustomRefreshFooterConfig? footer;

  CustomRefreshScrollConfig scrollConfig;

  /// `自定义刷新控件` 基础配置 view
  /// ***
  /// [CustomRefreshView]
  /// ***
  CustomRefreshConfig({
    required this.scrollConfig,
    this.header,
    this.footer,
  });
}

class CustomRefreshScrollConfig {
  final ScrollController scrollController;

  final double? cacheExtent;
  final bool? primary;
  final Axis scrollDirection;
  final int? semanticChildCount;
  final bool reverse;
  final bool shrinkWrap;
  final DragStartBehavior dragStartBehavior;
  final ScrollPhysics? physics;
  final List<Widget> slivers;

  ///
  /// `自定义刷新控件` CustomScrollView配置 view
  /// ***
  /// [CustomRefreshView]
  /// ***
  const CustomRefreshScrollConfig({
    required this.scrollController,
    this.dragStartBehavior = DragStartBehavior.start,
    this.primary,
    this.cacheExtent,
    this.semanticChildCount,
    this.reverse = false,
    this.shrinkWrap = false,
    this.physics,
    this.scrollDirection = Axis.vertical,
    this.slivers = const <Widget>[],
  });
}

class CustomRefreshHeaderConfig {
  double? left;
  double? right;
  double? top;
  double? bottom;

  /// 组件激活的滑动阈值
  /// ***
  /// [CustomRefreshView]
  /// ***
  double maxExtent;

  /// 是否初始化激活组件
  /// ***
  /// [CustomRefreshView]
  /// ***
  bool initialRefresh = false;

  /// `刷新` 组件
  /// ***
  /// [CustomRefreshView]
  /// ***
  Widget Function({required HeaderState status}) builder;

  /// `刷新` api
  /// ***
  /// [CustomRefreshView]
  /// ***
  Future<void> Function({required CustomRefreshViewModel viewModel}) onRefresh;

  ///
  /// `自定义刷新控件` 刷新配置 view
  /// ***
  /// [CustomRefreshView]
  /// ***
  CustomRefreshHeaderConfig({
    required this.builder,
    required this.onRefresh,
    required this.maxExtent,
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.initialRefresh = false,
  });
}

class CustomRefreshFooterConfig {
  double? left;
  double? right;
  double? top;
  double? bottom;

  /// 组件激活的滑动阈值
  /// ***
  /// [CustomRefreshView]
  /// ***
  double maxExtent;

  /// `加载` 组件
  /// ***
  /// [CustomRefreshView]
  /// ***
  Widget Function({required FooterState status}) builder;

  /// `加载` api
  /// ***
  /// [CustomRefreshView]
  /// ***
  ///
  /// 返回值
  /// - `bool` 是否有更多的数据
  Future<bool> Function({required CustomRefreshViewModel viewModel}) onLoading;

  ///
  /// `自定义刷新控件` 加载配置 view
  /// ***
  /// [CustomRefreshView]
  /// ***
  CustomRefreshFooterConfig({
    required this.builder,
    required this.maxExtent,
    required this.onLoading,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });
}
