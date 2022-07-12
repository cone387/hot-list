import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hot_list/hot_list/controllers/setting.dart';
import 'package:hot_list/hot_list/controllers/subscribe.dart';
import 'package:hot_list/hot_list/entities/setting.dart';
import 'package:hot_list/hot_list/entities/subscribe.dart';
import 'package:hot_list/hot_list/widgets/buttons/browse.dart';
import 'package:hot_list/hot_list/widgets/buttons/setting.dart';
import 'package:hot_list/hot_list/widgets/subscribe.dart';
import 'package:hot_list/route.dart';

class SubscribeTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<UserSubscribe> subscribes;
  final TabController controller;
  const SubscribeTabBar({
    Key? key,
    required this.controller,
    required this.subscribes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: TabBar(
          controller: controller,
          isScrollable: true,
          labelPadding: EdgeInsets.zero,
          tabs: subscribes
              .map((e) => Stack(fit: StackFit.passthrough, children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Tab(
                        // padding: const EdgeInsets.only(top: 10, right: 10),
                        child: Text(e.name),
                      ),
                    ),
                    SettingsObx(
                        keys: [
                          ObservedKey.isShowNotBrowsedFlag,
                          e.subscribe.browsedTimesObsKey,
                        ],
                        builder: (keys, controller) {
                          bool isShowNotBrowsedFlag =
                              controller.getSetting(keys[0]);
                          if (!isShowNotBrowsedFlag) return Container();
                          return Positioned(
                              right: 4,
                              top: 0,
                              child: Container(
                                  width: 20,
                                  height: 20,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    controller.getSetting(keys[1]).toString(),
                                    style: const TextStyle(color: Colors.white),
                                  )));
                        }),
                  ]))
              .toList(),
          indicatorColor: Colors.red,
          unselectedLabelColor: Colors.black,
          labelColor: Colors.red,
        ),
      ),
      IconButton(
          onPressed: () {
            Get.toNamed(Routes.subscribeManage);
          },
          icon: const Icon(Icons.menu))
    ]);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
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
          SubscribeTabBar tabBar = SubscribeTabBar(
              controller: tabController, subscribes: controller.items);

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
                IconButton(
                    onPressed: () {
                      Get.toNamed(Routes.search);
                    },
                    icon: const Icon(Icons.search)),
                ToHistoryButton(),
                PopupMenuButton(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  icon: const Icon(Icons.more_horiz),
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem(
                        child: IsShowBrowsedDataButton(),
                      ),
                      const PopupMenuItem(
                        child: IsShowNotBrowsedCountButton(),
                      ),
                      const PopupMenuItem(
                        child: IsLabelLatesetDataButton(),
                      ),
                    ];
                  },
                )
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
