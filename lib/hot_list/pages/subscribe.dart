import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hot_list/hot_list/controllers/subscribe.dart';
import 'package:hot_list/hot_list/entities/subscribe.dart';
import 'package:hot_list/hot_list/widgets/buttons/browse.dart';
import 'package:hot_list/hot_list/widgets/search.dart';
import 'package:hot_list/hot_list/widgets/subscribe.dart';
import 'package:hot_list/logger.dart';
import 'package:hot_list/route.dart';

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight > minHeight ? maxHeight : minHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  final Widget widget;
  final Color color;

  const SliverDelegate(this.widget, {required this.color});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: color,
      child: widget,
    );
  }

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return false;
  }

  @override
  double get maxExtent => 40; //widget.preferredSize.height;

  @override
  double get minExtent => 40; //widget.preferredSize.height;
}

class SubscribePage extends StatefulWidget {
  const SubscribePage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _SbscribeState();
  }
}

class _SbscribeState extends State<SubscribePage>
    with TickerProviderStateMixin {
  UserSubscribe? current;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserSubscribeControler>(
      init: UserSubscribeControler(),
      id: UserSubscribeControler.tabId,
      global: false,
      builder: (controller) {
        int index = current == null ? 0 : controller.items.indexOf(current);
        if (index == -1) index = 0;
        TabController tabController = TabController(
            initialIndex: index, length: controller.items.length, vsync: this);
        tabController.addListener(() {
          current = controller.items[tabController.index];
        });
        Widget tabBar = Expanded(
            child: TabBar(
          controller: tabController,
          isScrollable: true,
          tabs: controller.items.map((e) => Tab(text: e.name)).toList(),
          indicatorColor: Colors.red,
          unselectedLabelColor: Colors.black,
          labelColor: Colors.red,
        ));

        Widget tabView = TabBarView(
            controller: tabController,
            children: controller.items
                .map((e) => SubscriibeDetailWidget(subscribe: e.subscribe))
                .toList());
        return Scaffold(
          appBar: AppBar(
            title: const Text("今日热榜"),
            bottom: AppBarSearch(
                onTap: () {
                  Get.toNamed(Routes.search);
                  // actions: [goToHistoryBtn(context)],
                },
                actions: [ToHistoryButton()]),
          ),
          body: Column(
            children: [
              SizedBox(
                height: kToolbarHeight,
                child: Row(
                  children: [tabBar, SubscribeManageButton()],
                ),
              ),
              Expanded(child: tabView)
            ],
          ),
        );

        //   return SafeArea(
        //     child: Scaffold(
        //       body: NestedScrollView(
        //           // floatHeaderSlivers: true,
        //           headerSliverBuilder: (context, bool) {
        //             return [
        //               SliverAppBar(
        //                 // expandedHeight: 100.0,
        //                 automaticallyImplyLeading: false,
        //                 floating: false,
        //                 // snap: true,
        //                 backgroundColor: Color.fromRGBO(250, 250, 250, 1),
        //                 // backgroundColor: Colors.red,
        //                 pinned: false,
        //                 title: Text("今日热榜"),
        //                 bottom: AppBarSearch(
        //                     onTap: () {
        //                       // Get.toNamed(Routes.search);},
        //                       //   actions: [goToHistoryBtn(context)],
        //                     },
        //                     actions: [ToHistoryButton()]),
        //               ),

        //               // SliverPersistentHeader的刷新机制貌似是独立的
        //               SliverPersistentHeader(
        //                 delegate: new SliverDelegate(
        //                   Row(
        //                     // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                     children: [
        //                       tabBar,
        //                       IconButton(
        //                           icon: Icon(Icons.menu_sharp),
        //                           onPressed: () {
        //                             Get.toNamed(HotNewsRoutes.subscribeManage)
        //                                 ?.then((value) {
        //                               controller.update();
        //                             });
        //                           })
        //                     ],
        //                   ),
        //                   color: Color.fromRGBO(250, 250, 250, 1),
        //                 ),
        //                 pinned: true,
        //               ),
        //             ];
        //           },
        //           body: tabView),
        //     ),
        //   );
      },
    );
  }
}
