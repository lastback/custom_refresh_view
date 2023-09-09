import 'dart:developer';

import 'package:custom_refresh_view/env.dart';
import 'package:flutter/material.dart';

mixin CustomHeaderStateMixin {
  void rebuildUi();

  /// 当前的header的状态
  HeaderState _headerState = HeaderState.idle;

  /// 当前的header的状态
  /// ***
  /// [CustomHeaderStateMixin]
  /// ***
  HeaderState get headerState => _headerState;

  /// [setter]header状态
  /// ***
  /// [CustomHeaderStateMixin]
  /// ***
  @protected
  set headerState(HeaderState s) {
    _headerState = s;
    log("headerState = $_headerState");
    rebuildUi();
  }

  ///直接设置
  // void forceSetHeaderState(HeaderState s) {
  //   _HeaderState = s;
  //   log("HeaderState = $_HeaderState");
  //   rebuildUi();
  // }

  /// 当前的footer的状态
  FooterState _footerState = FooterState.idle;

  /// 当前的footer的状态
  /// ***
  /// [CustomHeaderStateMixin]
  /// ***
  FooterState get footerState => _footerState;

  /// [setter]footer状态
  /// ***
  /// [CustomHeaderStateMixin]
  /// ***
  @protected
  set footerState(FooterState s) {
    _footerState = s;
    log("footerState = $_footerState");
    rebuildUi();
  }

  // /// 直接设置
  // void forceSetFooterState(FooterState s) {
  //   _footerState = s;
  //   log("footerState = $_footerState");
  //   rebuildUi();
  // }

  /// 顶部触发器状态路由
  @protected
  void headerStateRoute() {
    log("[headerStateRoute] HeaderState = $headerState");
    switch (headerState) {
      case HeaderState.idle:
        break;
      case HeaderState.canLoading:
        prepareRefresh();
        break;
      case HeaderState.loading:
        todoRefresh();
        break;
      case HeaderState.loaded:
        finishRefresh();
        break;
      case HeaderState.failed:
        failRefresh();
        break;
      default:
        break;
    }
  }

  /// 底部触发器状态路由
  @protected
  void footerStateRoute() {
    log("[footerStateRoute] footerState = $footerState");
    switch (footerState) {
      case FooterState.idle:
        break;
      case FooterState.canLoading:
        prepareRefresh();
        break;
      case FooterState.loading:
        todoRefresh();
        break;
      case FooterState.loaded:
        finishRefresh();
        break;
      case FooterState.failed:
        failRefresh();
        break;
      case FooterState.noMore:
        noMoreRefresh();
        break;
      default:
        break;
    }
  }

  @protected
  void prepareRefresh();

  @protected
  void todoRefresh();

  @protected
  void finishRefresh();

  @protected
  void noMoreRefresh();

  @protected
  void failRefresh();
}
