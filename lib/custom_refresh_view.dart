library custom_refresh_view;

import 'package:custom_refresh_view/custom_refresh_viewmodel.dart';
import 'package:custom_refresh_view/env.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

///自定义idle widget配置
///
///idle widget是一个满视窗的组件，可以支持点击来激活refresh操作
// class CustomIdleWidgetConfig {
//   ///空时显示的组件，可以点击刷新
//   final Widget Function({required CustomRefreshViewModel refresh}) widgetBuilder;

//   ///是否允许点击刷新操作
//   final bool refreshEnabled;

//   CustomIdleWidgetConfig({required this.widgetBuilder, this.refreshEnabled = true});
// }

class CustomRefreshView extends StatefulWidget {
  final CustomRefreshConfig config;

  const CustomRefreshView({
    super.key,
    required this.config,
  });

  @override
  CustomRefreshViewState createState() => CustomRefreshViewState();
}

class CustomRefreshViewState extends State<CustomRefreshView> {
  double _fixedHeight = 0;

  // ScrollController get scrollController => dynamicLocator<ScrollControllerShared>(
  //       () => ScrollControllerShared(),
  //       instanceName: widget.uniqueKey.toString(),
  //     ).scrollController;

  @override
  void didUpdateWidget(covariant CustomRefreshView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if (oldWidget.slivers != widget.slivers) {
    //   // afterBuild(oldWidget);
    // }
  }

  ///https://stackoverflow.com/questions/57484677/how-to-keep-the-scrollposition-while-inserting-items-at-the-front
  ///
  ///shrinkWrap = true时，viewport初始值才是0，false时直接就是expanded值，所以没必要走下面的代码
  ///
  ///当sliver发生改变时(从空数据到有数据)，需要scrollController停住offset，不然refresh还没执行结束就springback了
  // afterBuild(covariant CustomRefreshView oldWidget) async {
  //   await Future.delayed(Duration.zero);

  //   if (!widget.shrinkWrap || _fixedHeight == 0 || !scrollController.hasClients) return;
  //   await Future.delayed(Duration.zero);
  //   double v = widget.reverse ? 1 : -1;

  //   ///为什么时viewportDimension不是_fixedHeight，比如聊天界面，记录很多，上翻到顶了后_fixedHeight是0了
  //   // scrollController.jumpTo(v * scrollController.position.viewportDimension);
  // }

  // afterBuild2(CustomRefreshViewModel viewModel) async {
  //   await Future.delayed(Duration.zero);

  //   if (widget.shrinkWrap && viewModel.scroller.hasClients) {
  //     double h = viewModel.headerConfig?.height ?? 0;
  //     h = viewModel.viewportDimension <= h ? h : 0;
  //     if (_fixedHeight != h) {
  //       setState(() {
  //         _fixedHeight = h;
  //         print("_fixedHeight = $_fixedHeight, ${viewModel.viewportDimension}");
  //       });
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final CustomRefreshScrollConfig scrollConfig = widget.config.scrollConfig;
    final CustomRefreshHeaderConfig? header = widget.config.header;
    final CustomRefreshFooterConfig? footer = widget.config.footer;

    return ViewModelBuilder.reactive(
        viewModelBuilder: () => CustomRefreshViewModel(config: widget.config),
        onViewModelReady: (CustomRefreshViewModel viewModel) async {},
        builder: (BuildContext context, CustomRefreshViewModel viewModel, Widget? child) {
          ///第一次build时,hasClients = false
          // afterBuild2(viewModel);
          // if (widget.shrinkWrap && viewModel.scroller.hasClients) {
          //   final double h = viewModel.headerConfig?.height ?? 0;
          //   _fixedHeight = viewModel.viewportDimension <= h ? h : 0;
          //   print("_fixedHeight = $_fixedHeight, ${viewModel.viewportDimension}");
          // }

          return Align(
            // 此处为关键代码, reverse时，slivers数量不够，也能顶上去
            alignment: Alignment.topCenter,
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (e) {
                viewModel.onPointerDown();
              },
              onPointerUp: (e) {
                viewModel.onPointerUp();
              },
              onPointerCancel: (e) {
                viewModel.onPointerUp();
              },
              child: Stack(
                children: [
                  header != null
                      ? Positioned(
                          top: header.top,
                          left: header.left,
                          right: header.right,
                          bottom: header.bottom,
                          child: Container(
                            height: viewModel.dynamicHeaderHeight,
                            decoration: BoxDecoration(border: kDebugMode ? Border.all() : null),
                            child: header.builder(
                              status: viewModel.headerState,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                  footer != null
                      ? Positioned(
                          top: widget.config.footer?.top,
                          left: widget.config.footer?.left,
                          right: widget.config.footer?.right,
                          bottom: widget.config.footer?.bottom,
                          child: Container(
                            height: viewModel.dynamicFooterHeight,
                            decoration: BoxDecoration(border: kDebugMode ? Border.all() : null),
                            child: widget.config.footer!.builder(
                              status: viewModel.footerState,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                  CustomScrollView(
                    controller: scrollConfig.scrollController,
                    reverse: scrollConfig.reverse,
                    shrinkWrap: scrollConfig.shrinkWrap,
                    physics: scrollConfig.physics ??
                        const RangeMaintainingScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                    scrollDirection: scrollConfig.scrollDirection,
                    semanticChildCount: scrollConfig.semanticChildCount,
                    primary: scrollConfig.primary,
                    dragStartBehavior: scrollConfig.dragStartBehavior,
                    cacheExtent: scrollConfig.cacheExtent,
                    slivers: [
                      ...scrollConfig.slivers,
                      SliverToBoxAdapter(
                        child: Container(
                          height: _fixedHeight,
                          decoration: BoxDecoration(border: kDebugMode ? Border.all() : null),
                        ),
                      ),
                    ],
                  ),
                  // widget.idleWidgetConfig != null ? widget.idleWidgetConfig!.widgetBuilder(refresh: viewModel) : const SizedBox.shrink(),
                ],
              ),
            ),
          );
        });
  }
}
