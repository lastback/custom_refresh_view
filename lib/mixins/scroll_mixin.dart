import 'dart:developer';

import 'package:custom_refresh_view/env.dart';
import 'package:flutter/material.dart';

/// Scroll mixin
/// ***
/// [CustomRefreshScrollMixin]
/// ***
mixin CustomRefreshScrollMixin {
  void rebuildUi();

  CustomRefreshScrollConfig get scrollConfig;

  /// ScrollController
  /// ***
  /// [CustomRefreshScrollMixin]
  /// ***
  ScrollController get scrollController => scrollConfig.scrollController;

  /// 滑动是否反向
  /// ***
  /// [CustomRefreshScrollMixin]
  /// ***
  // bool get scrollerReverse => scrollConfig.reverse;

  /// `ScrollController` 是否挂接了client
  /// ***
  /// [CustomRefreshScrollMixin]
  /// ***
  bool get scrollHasClients => scrollController.hasClients;

  /// `ScrollController` 滑动offset
  /// ***
  /// [CustomRefreshScrollMixin]
  /// ***
  double get scrollerOffset => scrollController.offset;

  /// `ScrollPosition`
  /// ***
  /// [CustomRefreshScrollMixin]
  /// ***
  ScrollPosition get scrollPosition => scrollController.position;

  /// 滑动视窗维度
  /// ***
  /// [CustomRefreshScrollMixin]
  /// ***
  double get viewportDimension => scrollHasClients ? scrollPosition.viewportDimension : 0;

  /// 滑动视窗是否是空
  /// - `ScrollController` 暂时没有挂接到client
  /// - 无内容
  /// ***
  /// [CustomRefreshScrollMixin]
  /// ***
  bool get isEmptyViewport => viewportDimension == 0;

  /// 滑动是否越界滑动视窗区域
  /// ***
  /// [CustomRefreshScrollMixin]
  /// ***
  bool get isScrollOutOfRange => scrollHasClients ? scrollPosition.outOfRange : false;

  /// 滑动越界超出滑动视窗区域的偏移量
  /// - viewportDimension - extentInside
  /// ***
  /// [CustomRefreshScrollMixin]
  /// ***
  double get scrollOutOfRangeOffset => scrollHasClients ? (scrollPosition.viewportDimension - scrollPosition.extentInside).truncateToDouble() : 0;

  /// 滑动内容的总范围，eg：高度
  /// ***
  /// [CustomRefreshScrollMixin]
  /// ***
  double get extentTotal => scrollController.position.extentTotal;

  /// 滑动内容在视窗绝对顶部的偏移量
  /// - reverse后顶部还是顶部
  /// ***
  /// [CustomRefreshScrollMixin]
  /// ***
  double get extentBefore => scrollController.position.extentBefore;

  /// 滑动内容在视窗绝对底部的偏移量
  /// - reverse后底部还是底部
  /// ***
  /// [CustomRefreshScrollMixin]
  /// ***
  double get extentAfter => scrollController.position.extentAfter;

  /// 滑动内容在视窗内的范围
  /// ***
  /// [CustomRefreshScrollMixin]
  /// ***
  double get extentInside => scrollController.position.extentInside;

  /// 最大滑动距离
  /// ***
  /// [CustomRefreshScrollMixin]
  /// ***
  double get maxScrollOffset => scrollHasClients ? scrollPosition.maxScrollExtent : 0;

  /// 最小滑动距离
  /// ***
  /// [CustomRefreshScrollMixin]
  /// ***
  double get minScrollOffset => scrollHasClients ? scrollPosition.minScrollExtent : 0;

  /// 当前滑动越界后刷新的类型
  /// - 刷新&加载
  /// ***
  /// [CustomRefreshScrollMixin]
  /// ***
  EnumCustomRefreshType get currentRefreshType => getCurrentRefreshType();

  /// 阻止滑动越界后回弹
  /// ***
  /// [CustomRefreshScrollMixin]
  /// ***
  @protected
  void preventSpringback() {
    if (scrollHasClients) {
      log('滑动越界，阻止回弹。');
      scrollPosition.beginActivity(IdleScrollActivity(scrollPosition as ScrollActivityDelegate));
    }
  }

  /// 滑动越界后回弹
  /// ***
  /// [CustomRefreshScrollMixin]
  /// ***
  void springback(bool hasMore) {
    if (scrollHasClients) {
      if (hasMore && extentTotal > viewportDimension) {
        // 如果有更多数据，则直接向加载的方向快速加载滑动而不是直接回弹
        switch (currentRefreshType) {
          case EnumCustomRefreshType.header:
            log('不回弹，快速加载滑动');
            // head不需要加载更多数据，直接回弹
            // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
            scrollPosition.activity?.delegate.goBallistic(0);
            break;
          case EnumCustomRefreshType.footer:
            log('不回弹，快速加载滑动');
            // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
            scrollPosition.activity?.delegate.goBallistic(1000);
            break;
          default:
            log('直接回弹归位1');
            // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
            scrollPosition.activity?.delegate.goBallistic(0);
            break;
        }
      } else {
        log('直接回弹归位2');
        // 直接回弹
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        scrollPosition.activity?.delegate.goBallistic(0);
      }
    }
  }

  /// 获取当前的刷新类型
  /// - 刷新&加载
  /// ***
  /// [CustomRefreshScrollMixin]
  /// ***
  @protected
  EnumCustomRefreshType getCurrentRefreshType() {
    EnumCustomRefreshType type = EnumCustomRefreshType.none;

    if (scrollerOffset < 0) {
      //header漏出来
      type = EnumCustomRefreshType.header;
    } else if (scrollerOffset > 0) {
      //foot漏出来
      type = EnumCustomRefreshType.footer;
    }

    log('当前刷新类型 = $type');

    //没有offset就不触发
    return type;
  }
}
