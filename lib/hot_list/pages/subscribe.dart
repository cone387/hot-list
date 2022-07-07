import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hot_list/common/widgets/image.dart';
import 'package:hot_list/hot_list/api.dart';
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
    Widget body = GetBuilder<UserSubscribeControler>(
        init: UserSubscribeControler(),
        id: UserSubscribeControler.tabId,
        global: false,
        builder: (controller) {
          int index = current == null ? 0 : controller.items.indexOf(current);
          if (index == -1) index = 0;
          TabController tabController = TabController(
              initialIndex: index,
              length: controller.items.length,
              vsync: this);
          tabController.addListener(() {
            current = controller.items[tabController.index];
          });
          TabBar tabBar = TabBar(
            controller: tabController,
            isScrollable: true,
            labelPadding: EdgeInsets.zero,
            tabs: controller.items
                .map((e) => Stack(fit: StackFit.passthrough, children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Tab(
                          // padding: const EdgeInsets.only(top: 10, right: 10),
                          child: Text(e.name),
                        ),
                      ),
                      Positioned(
                          right: 4,
                          top: 0,
                          child: Container(
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              "19",
                              style: TextStyle(color: Colors.black),
                            ),
                          ))
                    ]))
                .toList(),
            indicatorColor: Colors.red,
            unselectedLabelColor: Colors.black,
            labelColor: Colors.red,
          );

          Widget tabView = TabBarView(
              controller: tabController,
              children: controller.items
                  .map((e) => SubscriibeDetailWidget(subscribe: e.subscribe))
                  .toList());

          return Scaffold(
            appBar: AppBar(
              title: const Text("订阅"),
              centerTitle: true,
              actions: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
                ToHistoryButton(),
              ],
              bottom: tabBar,
            ),
            body: tabView,
          );
          //   return  NestedScrollView(
          //       // floatHeaderSlivers: true,
          //       headerSliverBuilder: (context, a) {
          //         return [
          //           SliverAppBar(
          //             automaticallyImplyLeading: false,
          //             floating: false,
          //             backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
          //             pinned: false,
          //             flexibleSpace: FlexibleSpaceBar(
          //                 centerTitle: true,
          //                 title: AppBarSearch(
          //                   onTap: () {
          //                     Get.toNamed(Routes.search);
          //                   },
          //                   actions: [ToHistoryButton()],
          //                 )),
          //           ),
          //           SliverPersistentHeader(
          //             delegate: SliverDelegate(
          //               Row(
          //                 // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                 children: [
          //                   tabBar,
          //                   IconButton(
          //                       icon: const Icon(Icons.menu_sharp),
          //                       onPressed: () {
          //                         Get.toNamed(Routes.subscribeManage)
          //                             ?.then((value) {
          //                           controller.update();
          //                         });
          //                       })
          //                 ],
          //               ),
          //               color: const Color.fromRGBO(250, 250, 250, 1),
          //             ),
          //             pinned: true,
          //           ),
          //         ];
          //       },
          //       body: tabView);

          // });
        });
    return body;
  }
}
