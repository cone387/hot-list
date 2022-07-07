// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:hot_list/common/controllers/base.dart';
import '../controllers/list.dart';

typedef ItemBuilder<T> = Widget Function(T, int, {dynamic arg});

class RichListWidget<T> extends StatefulWidget {
  final ItemBuilder<T> itemBuilder;
  final String tag;
  final dynamic argument;
  final ListController<T> controller;
  final bool keepAlive;
  final bool refreshable;
  final bool loadable;
  final bool useEmptyWidget;
  final bool reorderable;
  final bool initRefresh;
  final Axis scrollDirection;
  final ScrollController? scrollController;
  final bool Function(T)? ietmFilter;
  final bool Function(T)? itemFilter;
  final ScrollPhysics physics;
  final Function(T sourceItem, T targetItem)? onPositionChanged;
  final bool
      shrinkWrap; // 是否自动计算子组件高度，为true时AlwaysScrollableScrollPhysics失效, 可以不用在外包裹expanded，否则需要包裹或者在container里面指定height。
  final Widget? emptyWidget;
  static const Widget defultEmptyWdiget = Text("还没有数据~");

  const RichListWidget(
      {Key? key,
      required this.controller,
      required this.itemBuilder,
      this.argument,
      this.tag: '',
      this.keepAlive: true,
      this.refreshable: true,
      this.loadable: true,
      this.initRefresh: true,
      this.shrinkWrap: false,
      this.reorderable: false,
      this.useEmptyWidget: false,
      this.physics: const AlwaysScrollableScrollPhysics(),
      this.itemFilter,
      this.emptyWidget,
      this.scrollController,
      this.ietmFilter,
      this.scrollDirection: Axis.vertical,
      this.onPositionChanged})
      : super(key: key);

  @override
  State<RichListWidget<T>> createState() {
    // GetBuilder
    return _RichListState<T>();
  }
}

class _RichListState<T> extends State<RichListWidget<T>>
    with AutomaticKeepAliveClientMixin {
  // 这是真的坑， 这里controller=widget.controller 会导致后面new ListWidget时用的都是同一个controller，
  ListController<T> get controller => widget.controller;
  // RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    controller.isItemsInitialized.then((value) {
      if ((widget.initRefresh || controller.items.isEmpty) &&
          !controller.autoRefresh) {
        controller.refreshItems();
      }
    });
  }

  _onScrollNotification(ScrollNotification scrollInfo) {
    // print("pixels=>" + scrollInfo.metrics.pixels.toString());
    // print("minScrollExtent=>" + scrollInfo.metrics.minScrollExtent.toString());
    // print("maxScrollExtent=>" + scrollInfo.metrics.maxScrollExtent.toString());
    if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
      // //滑到了底部
      (controller as PagedListController).loadMoreItems();
    }
    return true;
  }

  Widget itemBuilder(T item, int index, {dynamic arg}) {
    return widget.itemBuilder(item, index, arg: arg);
    // return Row(
    //   children: [
    //     Checkbox(
    //         value: false,
    //         onChanged: (value) {
    //           print(value);
    //         }),
    //     Expanded(child: widget.itemBuilder(item, index, arg))
    //   ],
    // );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() {
      List<T> items = controller.items.value;
      if (widget.itemFilter != null) {
        items = controller.filterItems(widget.itemFilter!);
      }
      Widget child;

      if (items.length == 0 &&
          (widget.useEmptyWidget || widget.emptyWidget != null)) {
        child = Center(
          child: SingleChildScrollView(
            child: widget.useEmptyWidget
                ? RichListWidget.defultEmptyWdiget
                : widget.emptyWidget!,
          ),
        );
      } else if (widget.reorderable || widget.onPositionChanged != null) {
        child = ReorderableListView(
          shrinkWrap: true,
          children: items
              .asMap()
              .entries
              .map((e) => Container(
                  key: ValueKey(e.value),
                  child: itemBuilder(e.value, e.key, arg: widget.argument)))
              .toList(),
          onReorder: (int oldIndex, int newIndex) {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            T sourceItem = items[oldIndex];
            T targetItem = items[newIndex];
            // 防止经过filter处理过后的oldIndex无效
            // controller.moveItemByIndex(oldIndex, newIndex, entity);
            controller.onPositionChanged(sourceItem, targetItem);
            widget.onPositionChanged?.call(sourceItem, targetItem);
          },
        );
      } else {
        child = ListView.builder(
          shrinkWrap: widget.shrinkWrap,
          physics: widget.physics,
          controller: widget.scrollController,
          scrollDirection: widget.scrollDirection,
          itemBuilder: (context, index) {
            return itemBuilder(
              items[index],
              index,
            );
          },
          itemCount: items.length,
        );
      }
      if (widget.refreshable) {
        child = RefreshIndicator(
          // key: widget.refreshKey,
          notificationPredicate: (notification) {
            return notification.depth == 0;
          },
          child: child,
          onRefresh: () async {
            await controller.refreshItems();
          },
        );
      }
      if (widget.loadable &&
          controller is PagedListController &&
          (controller as PagedListController).haveMore) {
        child = NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) =>
              _onScrollNotification(scrollInfo),
          child: child,
        );
      }
      return child;
    });
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}

class StatelessListWidget<T> extends StatelessWidget {
  final ItemBuilder<T> itemBuilder;
  final tag;
  final dynamic argument;
  final ListController<T> controller;
  final bool keepAlive;
  final bool refreshable;
  final bool loadable;
  final bool useEmptyWidget;
  final bool reorderable;
  final bool initRefresh;
  final Axis scrollDirection;
  final bool Function(T)? ietmFilter;
  final bool Function(T)? itemFilter;
  final Function(T sourceItem, T targetItem)? onPositionChanged;
  final bool
      shrinkWrap; // 是否自动计算子组件高度，为true时AlwaysScrollableScrollPhysics失效, 可以不用在外包裹expanded，否则需要包裹或者在container里面指定height。
  final Widget? emptyWidget;
  static const Widget defultEmptyWdiget = Text("还没有数据~");

  const StatelessListWidget(
      {required this.controller,
      required this.itemBuilder,
      this.argument,
      this.tag: '',
      this.keepAlive: true,
      this.refreshable: true,
      this.loadable: true,
      this.initRefresh: true,
      this.shrinkWrap: false,
      this.reorderable: false,
      this.useEmptyWidget: false,
      this.itemFilter,
      this.emptyWidget,
      this.ietmFilter,
      this.scrollDirection: Axis.vertical,
      this.onPositionChanged});

  _onScrollNotification(ScrollNotification scrollInfo) {
    // print("pixels=>" + scrollInfo.metrics.pixels.toString());
    // print("minScrollExtent=>" + scrollInfo.metrics.minScrollExtent.toString());
    // print("maxScrollExtent=>" + scrollInfo.metrics.maxScrollExtent.toString());
    if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
      // //滑到了底部
      (controller as PagedListController).loadMoreItems();
    }
    return true;
  }

  Widget tileBuilder(T item, int index, arg) {
    return itemBuilder(item, index, arg: arg);
    // return Row(
    //   children: [
    //     Checkbox(
    //         value: false,
    //         onChanged: (value) {
    //           print(value);
    //         }),
    //     itemBuilder(item, index, arg)
    //   ],
    // );
  }

  @override
  Widget build(BuildContext context) {
    controller.isItemsInitialized.then((value) {
      if ((initRefresh || controller.items.isEmpty) &&
          !controller.autoRefresh) {
        controller.refreshItems();
      }
    });
    return Obx(() {
      List<T> items = controller.items.value;
      if (itemFilter != null) {
        items = controller.filterItems(itemFilter!);
      }
      Widget child;

      if (items.length == 0 && (useEmptyWidget || emptyWidget != null)) {
        child = Center(
          child: SingleChildScrollView(
            child: useEmptyWidget
                ? RichListWidget.defultEmptyWdiget
                : emptyWidget!,
          ),
        );
      } else if (reorderable || onPositionChanged != null) {
        child = ReorderableListView(
          shrinkWrap: true,
          children: items
              .asMap()
              .entries
              .map((e) => Container(
                  key: ValueKey(e.value),
                  child: tileBuilder(e.value, e.key, argument)))
              .toList(),
          onReorder: (int oldIndex, int newIndex) {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            T sourceItem = items[oldIndex];
            T targetItem = items[newIndex];
            // 防止经过filter处理过后的oldIndex无效
            // controller.moveItemByIndex(oldIndex, newIndex, entity);
            controller.onPositionChanged(sourceItem, targetItem);
            onPositionChanged?.call(sourceItem, targetItem);
          },
        );
      } else {
        child = ListView.builder(
          shrinkWrap: shrinkWrap,
          physics: AlwaysScrollableScrollPhysics(),
          // controller: _scrollController,
          scrollDirection: scrollDirection,
          itemBuilder: (context, index) {
            return tileBuilder(items[index], index, argument);
          },
          itemCount: items.length,
        );
      }
      if (refreshable) {
        child = RefreshIndicator(
          // key: widget.refreshKey,
          notificationPredicate: (notification) {
            return notification.depth == 0;
          },
          child: child,
          onRefresh: () async {
            await controller.refreshItems();
          },
        );
      }
      if (loadable &&
          controller is PagedListController &&
          (controller as PagedListController).haveMore) {
        child = NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) =>
              _onScrollNotification(scrollInfo),
          child: child,
        );
      }
      return child;
    });
  }
}

class SingleListWidget<T> extends StatefulWidget {
  final List<T> items;
  final ItemBuilder<T> itemBuilder;
  final tag;
  final dynamic argument;
  final bool keepAlive;
  final bool refreshable;
  final bool useEmptyWidget;
  final bool reorderable;
  final Function(int index, T entity)? onPositionChanged;
  final ScrollPhysics physics;
  final bool
      shrinkWrap; // 是否自动计算子组件高度，为true时AlwaysScrollableScrollPhysics失效, 可以不用在外包裹expanded，否则需要包裹或者在container里面指定height。
  final Widget? emptyWidget;
  static const Widget defultEmptyWdiget = Center(
    child: Text("还没有数据~"),
  );
  // final GlobalKey<RefreshIndicatorState> refreshKey =
  //     GlobalKey<RefreshIndicatorState>();

  SingleListWidget(
      {required this.items,
      required this.itemBuilder,
      this.argument,
      this.tag: '',
      this.keepAlive: true,
      this.refreshable: true,
      this.shrinkWrap: false,
      this.reorderable: false,
      this.useEmptyWidget: false,
      this.physics: const AlwaysScrollableScrollPhysics(),
      this.emptyWidget,
      this.onPositionChanged});

  @override
  _SingleListState createState() {
    // GetBuilder
    return _SingleListState<T>();
  }
}

class _SingleListState<T> extends State<SingleListWidget<T>>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget child;
    if (widget.items.length == 0 &&
        (widget.useEmptyWidget || widget.emptyWidget != null)) {
      return widget.useEmptyWidget
          ? SingleListWidget.defultEmptyWdiget
          : widget.emptyWidget!;
    }
    if (widget.reorderable || widget.onPositionChanged != null) {
      child = ReorderableListView(
        shrinkWrap: true,
        children: widget.items
            .asMap()
            .entries
            .map((e) => Container(
                key: ValueKey(e.value),
                child:
                    widget.itemBuilder(e.value, e.key, arg: widget.argument)))
            .toList(),
        onReorder: (int oldIndex, int newIndex) {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          // T entity = widget.items[oldIndex];
          T entity = widget.items.removeAt(oldIndex);
          widget.items.insert(newIndex, entity);
          widget.onPositionChanged?.call(newIndex, entity);
          setState(() {});
        },
      );
    } else {
      child = ListView.builder(
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics,
        // controller: _scrollController,
        itemBuilder: (context, index) {
          return widget.itemBuilder(widget.items[index], index,
              arg: widget.argument);
        },
        itemCount: widget.items.length,
      );
    }

    return child;
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}
