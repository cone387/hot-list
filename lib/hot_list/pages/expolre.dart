import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hot_list/hot_list/controllers/category.dart';
import 'package:hot_list/hot_list/pages/subscribe.dart';
import 'package:hot_list/hot_list/widgets/category.dart';
import 'package:hot_list/hot_list/widgets/search.dart';
import 'package:hot_list/hot_list/widgets/subscribe.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() {
    return _ExploreState();
  }
}

class _ExploreState extends State<ExplorePage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    CategoryListController()
        .isItemsInitialized
        .then((value) => CategoryListController().refreshItems());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget body = GetBuilder<CategoryListController>(
        init: CategoryListController(),
        global: false,
        id: CategoryListController.tabId,
        builder: (controller) {
          TabController tabController =
              TabController(vsync: this, length: controller.items.length);

          TabBar tabBar = TabBar(
            controller: tabController,
            tabs: controller.items.map((e) => Tab(text: e.name)).toList(),
            indicatorColor: Colors.red,
            unselectedLabelColor: Colors.black,
            labelColor: Colors.red,
          );

          Widget tabView = TabBarView(
              controller: tabController,
              children: controller.items
                  .map((e) => CategoryDetailWidget(category: e))
                  .toList());
          return Scaffold(
            appBar: AppBar(
              title: const Text("发现"),
              actions: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.search))
              ],
              bottom: tabBar,
            ),
            body: tabView,
          );
          // return NestedScrollView(
          //     headerSliverBuilder: (context, innerBoxIsScrolled) {
          //       return [
          //         SliverAppBar(
          //           automaticallyImplyLeading: false,
          //           floating: false,
          //           backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
          //           pinned: false,
          //           flexibleSpace: FlexibleSpaceBar(
          //               centerTitle: true,
          //               title: AppBarSearch(
          //                 onTap: () {
          //                   // Get.toNamed(Routes.search
          //                   // );
          //                 },
          //                 // actions: [addSuggestSubBtn(context)],
          //               )),
          //         ),
          //         SliverPersistentHeader(
          //           delegate: SliverDelegate(
          //             tabBar,
          //             color: const Color.fromRGBO(250, 250, 250, 1),
          //           ),
          //           pinned: true,
          //         ),
          //       ];
          //     },
          //     body: tabView);
        });

    return body;
  }
}
