import 'dart:async';
import 'dart:developer';
import 'package:custom_refresh_view/env.dart';
import 'package:custom_refresh_view/mixins/scroll_mixin.dart';
import 'package:custom_refresh_view/mixins/state_mixin.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class CustomRefreshViewModel extends FutureViewModel with CustomRefreshScrollMixin, CustomHeaderStateMixin {
  final CustomRefreshConfig config;

  @override
  CustomRefreshScrollConfig get scrollConfig => config.scrollConfig;

  CustomRefreshHeaderConfig? get headerConfig => config.header;

  CustomRefreshFooterConfig? get footerConfig => config.footer;

  CustomRefreshViewModel({required this.config}) {
    scrollController.addListener(onScroll);
  }

  @override
  void dispose() async {
    super.dispose();
    scrollController.removeListener(onScroll);
  }

  @override
  Future futureToRun() async {
    initialRefresh();
  }

  /// 初始化刷新
  /// ***
  /// [CustomRefreshScrollMixin]
  /// ***
  @protected
  initialRefresh() async {
    if (headerConfig?.initialRefresh == true) {
      //等待 scrollController hasClients
      await Future.delayed(const Duration(milliseconds: 500));
      await scrollController.animateTo(
        -1 * headerConfig!.maxExtent.truncateToDouble(),
        duration: const Duration(milliseconds: 100),
        curve: Curves.ease,
      );
      preventSpringback();
      goStateRoute();
    }
  }

  /// 动态header高度
  double _dynamicHeaderHeight = 0;

  /// 动态header高度
  /// - 控制显示（刷新中）&隐藏（刷新结束）
  /// ***
  /// [CustomRefreshScrollMixin]
  /// ***
  double get dynamicHeaderHeight => _dynamicHeaderHeight.truncateToDouble();

  /// 动态footer高度
  double _dynamicFooterHeight = 0;

  /// 动态footer高度
  /// - 控制显示（加载中）&隐藏（加载结束）
  /// ***
  /// [CustomRefreshScrollMixin]
  /// ***
  double get dynamicFooterHeight => _dynamicFooterHeight.truncateToDouble();

  /// 刷新触发的滑动阈值
  /// ***
  /// [CustomRefreshScrollMixin]
  /// ***
  @protected
  double get currentRefreshThreshold => getRefreshThreshold();

  /// 获取刷新的滑动阈值
  ///
  /// - 默认为对应header&footer配置的height
  /// ***
  /// [CustomRefreshScrollMixin]
  /// ***
  @protected
  double getRefreshThreshold() {
    double threshold = 0;

    switch (currentRefreshType) {
      case EnumCustomRefreshType.header:
        threshold = headerConfig?.maxExtent ?? 0;
        break;
      case EnumCustomRefreshType.footer:
        threshold = footerConfig?.maxExtent ?? 0;
        break;
      default:
    }

    return threshold.truncateToDouble();
  }

  ///滑动回调
  onPointerDown() {}

  ///松手回调
  onPointerUp() {
    log("滑动抬手");

    goStateRoute();
  }

  onScroll() {
    if (isEmptyViewport) return;

    // 越界偏移
    double outOfRangeOffset = 0;

    if (isScrollOutOfRange) {
      // 如果滑动越界，则先确定刷新类型（方向）是上拉还是下拉
      switch (currentRefreshType) {
        case EnumCustomRefreshType.header:
          _dynamicFooterHeight = 0;
          outOfRangeOffset = _dynamicHeaderHeight = scrollOutOfRangeOffset;
          break;
        case EnumCustomRefreshType.footer:
          _dynamicHeaderHeight = 0;
          outOfRangeOffset = _dynamicFooterHeight = scrollOutOfRangeOffset;
          break;
        default:
      }
      rebuildUi();
    }

    if (currentRefreshThreshold != 0 && outOfRangeOffset >= currentRefreshThreshold) {
      ///纠正offset为阈值
      switch (currentRefreshType) {
        case EnumCustomRefreshType.header:
          if (headerState == HeaderState.idle) {
            log("滑动达到触发器的阈值. 触发器类型 = $currentRefreshType 越界偏移 = $outOfRangeOffset 越界阈值 = $currentRefreshThreshold");
            //可以激活触发器
            headerState = HeaderState.canLoading;
          }

          break;
        case EnumCustomRefreshType.footer:
          if (footerState == FooterState.idle) {
            log("滑动达到触发器的阈值. 触发器类型 = $currentRefreshType 越界偏移 = $outOfRangeOffset 越界阈值 = $currentRefreshThreshold");
            footerState = FooterState.canLoading;
          }

          break;
        default:
          break;
      }
    } else {
      //只有canLoading才可以放弃执行’刷新‘操作
      switch (currentRefreshType) {
        case EnumCustomRefreshType.header:
          if (headerState == HeaderState.canLoading) {
            log("滑动未达到触发器的阈值");
            headerState = HeaderState.idle;
          }
          break;
        case EnumCustomRefreshType.footer:
          if (footerState == FooterState.canLoading) {
            log("滑动未达到触发器的阈值");
            footerState = FooterState.idle;
          }
          break;
        default:
      }
    }
  }

  @override
  springback(bool hasMore) async {
    if (disposed) return;

    switch (currentRefreshType) {
      case EnumCustomRefreshType.header:
        {
          await Future.delayed(const Duration(milliseconds: 500));

          if (disposed) return;

          super.springback(hasMore);

          await Future.delayed(const Duration(milliseconds: 500));

          if (disposed) return;
        }
        break;
      case EnumCustomRefreshType.footer:
        {
          if (!hasMore) {
            await Future.delayed(const Duration(milliseconds: 500));
          }

          if (disposed) return;

          super.springback(hasMore);

          if (!hasMore) {
            await Future.delayed(const Duration(milliseconds: 500));
          }

          if (disposed) return;
        }
        break;
      default:
        break;
    }

    goStateRoute();
  }

  /// 状态路由
  /// ***
  /// [CustomRefreshScrollMixin]
  /// ***
  goStateRoute() {
    switch (currentRefreshType) {
      case EnumCustomRefreshType.header:
        headerStateRoute();
        break;
      case EnumCustomRefreshType.footer:
        footerStateRoute();
        break;
      default:
        break;
    }
  }

  /// `state route` 准备`刷新`
  /// - 手指滑动离开屏幕时如果状态是canloading则route到此
  /// ***
  /// [CustomRefreshScrollMixin]
  /// ***
  @override
  void prepareRefresh() async {
    log('[prepareRefresh]');

    try {
      switch (currentRefreshType) {
        case EnumCustomRefreshType.header:
          if (headerState != HeaderState.canLoading) {
            throw 'headerState != HeaderState.canLoading, = $headerState';
          }

          // scroll到漏出header即可，如果有多余的scroll offset
          scrollController.jumpTo(-currentRefreshThreshold);
          break;
        case EnumCustomRefreshType.footer:
          if (footerState != FooterState.canLoading) {
            throw 'footerState != FooterState.canLoading, = $footerState';
          }

          // scroll到漏出footer即可，如果有多余的scroll offset
          scrollController.jumpTo(maxScrollOffset + currentRefreshThreshold);
          break;
        default:
      }

      preventSpringback();

      await Future.delayed(const Duration(milliseconds: 100));

      switch (currentRefreshType) {
        case EnumCustomRefreshType.header:
          headerState = HeaderState.loading;
          break;
        case EnumCustomRefreshType.footer:
          footerState = FooterState.loading;
          break;
        default:
          break;
      }

      goStateRoute();
    } catch (e) {
      log('$e');
    }
  }

  /// `state route` 开始`刷新`
  /// - 状态是loading则route到此
  /// ***
  /// [CustomRefreshScrollMixin]
  /// ***
  @override
  void todoRefresh() async {
    if (disposed) return;

    try {
      log('[todoRefresh]');
      switch (currentRefreshType) {
        case EnumCustomRefreshType.header:
          if (headerState != HeaderState.loading) {
            throw 'headerState != headerState.loading, = $headerState';
          }

          try {
            log("顶部触发器loading");
            await headerConfig!.onRefresh(viewModel: this);
            headerState = HeaderState.loaded;
            springback(true);
          } catch (e) {
            log("顶部触发器failed");
            headerState = HeaderState.failed;
            goStateRoute();
          }

          break;
        case EnumCustomRefreshType.footer:
          if (footerState != FooterState.loading) {
            throw 'footerState != FooterState.loading, = $footerState';
          }

          try {
            log("底部触发器loading");
            footerState = FooterState.loading;
            bool hasMore = await config.footer!.onLoading(viewModel: this);
            footerState = FooterState.loaded;
            springback(hasMore);
          } catch (e) {
            log("底部触发器failed");
            footerState = FooterState.failed;
            goStateRoute();
          }
          break;
        default:
      }
    } catch (e) {
      log('$e');
    }
  }

  /// `state route` 完成`刷新`
  /// - 状态是loaded则route到此
  /// ***
  /// [CustomRefreshScrollMixin]
  /// ***
  @override
  finishRefresh() async {
    try {
      log('[finishRefresh]');
      switch (currentRefreshType) {
        case EnumCustomRefreshType.header:
          if (headerState != HeaderState.loaded) {
            throw 'headerState != HeaderState.loaded, = $headerState';
          }

          await Future.delayed(const Duration(milliseconds: 100));

          if (disposed) return;

          resetScroll();
          break;
        case EnumCustomRefreshType.footer:
          if (footerState != FooterState.loaded) {
            throw 'footerState != FooterState.loaded, = $footerState';
          }

          await Future.delayed(const Duration(milliseconds: 100));

          if (disposed) return;

          resetScroll();
          break;
        default:
      }
    } catch (e) {
      log('$e');
    }
  }

  /// `state route` `刷新`失败
  /// - 状态是failed则route到此
  /// ***
  /// [CustomRefreshScrollMixin]
  /// ***
  @override
  failRefresh() async {
    try {
      log('[failRefresh]');
      switch (currentRefreshType) {
        case EnumCustomRefreshType.header:
          if (headerState != HeaderState.failed) {
            throw 'headerState != HeaderState.failed, = $headerState';
          }

          await Future.delayed(const Duration(milliseconds: 100));

          if (disposed) return;

          springback(true);

          await Future.delayed(const Duration(milliseconds: 500));

          if (disposed) return;

          resetScroll();
          break;
        case EnumCustomRefreshType.footer:
          if (footerState != FooterState.failed) {
            throw 'footerState != FooterState.failed, = $footerState';
          }

          await Future.delayed(const Duration(milliseconds: 100));

          if (disposed) return;

          springback(true);

          await Future.delayed(const Duration(milliseconds: 500));

          if (disposed) return;

          resetScroll();
          break;
        default:
      }
    } catch (e) {
      log('$e');
    }
  }

  /// `刷新` 结束，重置状态
  /// ***
  /// [CustomRefreshScrollMixin]
  /// ***
  @protected
  resetScroll() {
    log('[resetScroll]');
    switch (currentRefreshType) {
      case EnumCustomRefreshType.header:
        if ([HeaderState.loaded, HeaderState.failed].contains(headerState)) {
          headerState = HeaderState.idle;
          _dynamicHeaderHeight = 0;
        }
        break;
      case EnumCustomRefreshType.footer:
        if ([FooterState.loaded, FooterState.failed].contains(footerState)) {
          footerState = FooterState.idle;
          _dynamicFooterHeight = 0;
        }
        break;
      default:
    }
  }
}
