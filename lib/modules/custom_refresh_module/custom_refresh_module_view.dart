import 'package:custom_refresh_view/custom_refresh_view.dart';
import 'package:custom_refresh_view/custom_refresh_viewmodel.dart';
import 'package:custom_refresh_view/env.dart';
import 'package:custom_refresh_view/modules/custom_refresh_module/custom_refresh_module_tip_view.dart';
import 'package:custom_refresh_view/modules/custom_refresh_module/custom_refresh_module_viewmodel.dart';
import 'package:custom_refresh_view/physics/position_retained_scroll_physics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stacked/stacked.dart';

abstract class CustomRefreshModuleView<VM extends CustomRefreshModuleViewModel>
    extends StackedView<VM> {
  /// `自定义刷新列表` module 基类
  /// ***
  /// [CustomRefreshModuleView]
  /// ***
  const CustomRefreshModuleView({super.key});

  /// 是否初始化就刷新
  /// ***
  /// [CustomRefreshModuleView]
  /// ***
  bool get initialRefresh => false;

  /// refreshWidgetExtent
  /// ***
  /// [CustomRefreshModuleView]
  /// ***
  double get refreshWidgetExtent;

  /// 自定义header
  /// ***
  /// [CustomRefreshModuleView]
  /// ***
  CustomRefreshHeaderConfig? customHeaderConfigBuilder(
      BuildContext context, VM viewModel) {
    return CustomRefreshHeaderConfig(
      initialRefresh: initialRefresh,
      top: 0,
      left: 0,
      right: 0,
      maxExtent: refreshWidgetExtent,
      builder: ({required HeaderState status}) {
        Widget body;
        if (status == HeaderState.idle) {
          body = const Text('');
        } else if (status == HeaderState.loading) {
          body = CupertinoActivityIndicator(
            //
            radius: 8.w,
          );
        } else if (status == HeaderState.failed) {
          body = Text("加载失败，稍后重试！", style: TextStyle(fontSize: 10.sp));
        } else if (status == HeaderState.canLoading) {
          body = Text("松手,加载更多!", style: TextStyle(fontSize: 10.sp));
        } else if (status == HeaderState.loaded) {
          body = Text("加载成功!", style: TextStyle(fontSize: 10.sp));
        } else {
          body = Text("已显示全部内容!", style: TextStyle(fontSize: 10.sp));
        }
        return Container(
          decoration: BoxDecoration(color: Theme.of(context).focusColor),
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: refreshWidgetExtent,
            child: Center(child: body),
          ),
        );
      },
      onRefresh: ({required CustomRefreshViewModel refresh}) async {
        return await viewModel.refreshData();
      },
    );
  }

  /// 自定义footer
  /// ***
  /// [CustomRefreshModuleView]
  /// ***
  CustomRefreshFooterConfig? customFooterConfigBuilder(
      BuildContext context, VM viewModel) {
    return CustomRefreshFooterConfig(
      maxExtent: refreshWidgetExtent,
      bottom: 0,
      left: 0,
      right: 0,
      builder: ({required FooterState status}) {
        Widget body;
        if (status == FooterState.idle) {
          body = const Text('');
        } else if (status == FooterState.loading) {
          body = CupertinoActivityIndicator(
            radius: 8.w,
          );
        } else if (status == FooterState.failed) {
          body = Text("加载失败，稍后重试！", style: TextStyle(fontSize: 10.sp));
        } else if (status == FooterState.canLoading) {
          body = Text("松手,加载更多!", style: TextStyle(fontSize: 10.sp));
        } else if (status == FooterState.loaded) {
          body = Text("加载成功!", style: TextStyle(fontSize: 10.sp));
        } else {
          body = Text("已显示全部内容!", style: TextStyle(fontSize: 10.sp));
        }
        return Container(
          height: refreshWidgetExtent,
          decoration: BoxDecoration(color: Theme.of(context).focusColor),
          child: Center(child: body),
        );
      },
      onLoading: ({required CustomRefreshViewModel refresh}) async {
        return await viewModel.loadData();
      },
    );
  }

  /// 自定义empty
  /// ***
  /// [CustomRefreshModuleView]
  /// ***
  CustomRefreshEmptyConfig? customEmptyConfigBuilder(
      BuildContext context, VM viewModel) {
    return CustomRefreshEmptyConfig(
      builder: ({required CustomRefreshViewModel refresh}) {
        if (viewModel.isDataEmpty) {
          return GestureDetector(
            onTap: () {
              refresh.goRefresh();
            },
            child: CustomRefreshModuleTipView(
              tips: '没有更多数据，点击刷新',
              headerState: refresh.headerState,
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  /// 自定义scroll
  /// ***
  /// [CustomRefreshModuleView]
  /// ***
  CustomRefreshScrollConfig customScrollConfigBuilder(
      BuildContext context, VM viewModel) {
    return CustomRefreshScrollConfig(
      scrollController: viewModel.scrollController,
      slivers: customSliversBuilder(context, viewModel),
      physics: PositionRetainedScrollPhysics(
        parent: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        offset: 2 * refreshWidgetExtent,
      ),
    );
  }

  /// 自定义slivers
  /// ***
  /// [CustomRefreshModuleView]
  /// ***
  List<Widget> customSliversBuilder(BuildContext context, VM viewModel);

  @override
  Widget builder(BuildContext context, VM viewModel, Widget? child) {
    return CustomRefreshView(
      config: CustomRefreshConfig(
        header: customHeaderConfigBuilder(context, viewModel),
        footer: customFooterConfigBuilder(context, viewModel),
        scrollConfig: customScrollConfigBuilder(context, viewModel),
        emptyConfig: customEmptyConfigBuilder(context, viewModel),
      ),
    );
  }
}
