library custom_refresh_view;

import 'package:custom_refresh_view/custom_refresh_viewmodel.dart';
import 'package:custom_refresh_view/env.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

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
  @override
  void didUpdateWidget(covariant CustomRefreshView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final CustomRefreshScrollConfig scrollConfig = widget.config.scrollConfig;
    final CustomRefreshHeaderConfig? header = widget.config.header;
    final CustomRefreshFooterConfig? footer = widget.config.footer;
    final CustomRefreshEmptyConfig? emptyConfig = widget.config.emptyConfig;

    return ViewModelBuilder.reactive(
        viewModelBuilder: () => CustomRefreshViewModel(config: widget.config),
        onViewModelReady: (CustomRefreshViewModel viewModel) async {},
        builder: (BuildContext context, CustomRefreshViewModel viewModel, Widget? child) {
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
                    ],
                  ),
                  emptyConfig != null ? emptyConfig.builder(refresh: viewModel) : const SizedBox.shrink(),
                ],
              ),
            ),
          );
        });
  }
}
