import 'package:flutter/material.dart';
import 'package:hot_list/common/commont.dart';
import 'package:hot_list/common/controllers/list.dart';
import 'package:hot_list/hot_list/controllers/search.dart';
import 'package:hot_list/hot_list/entities/subscribe.dart';
import 'package:hot_list/hot_list/pages/browse.dart';
import 'package:hot_list/hot_list/widgets/browse.dart';
import 'package:hot_list/hot_list/widgets/search.dart';
import 'package:hot_list/hot_list/widgets/subscribe.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final controller = SearchController();

  Widget allSearchResult() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('$index'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarSearch(
        autoFocus: true,
        onSearch: (keyword) {
          controller.search(keyword: keyword);
        },
      ),
      body: Obx(() {
        List<Widget> children = [];
        if (controller.isSearching.value) {
          children =
              List.generate(3, (index) => const Center(child: Text('搜索中')));
        } else {
          children = [
            allSearchResult(),
            RichListWidget<DataEntity>(
              controller: controller.dataController!,
              itemBuilder: (
                data,
                index,
              ) {
                return RecordTile(data: data, index: index);
              },
              separatedBuilder: (data, index) {
                return const Divider(
                    indent: 70, height: 1.0, color: Colors.grey);
              },
            ),
            RichListWidget<Subscribe>(
              controller: controller.subscribeController!,
              itemBuilder: (subscribe, index, {arg}) {
                return SubscribeTile(subscribe: subscribe, index: index);
              },
            ),
          ];
        }
        return DefaultTabController(
          initialIndex: 0,
          length: 3,
          child: Column(children: [
            const TabBar(
                indicatorColor: Colors.red,
                unselectedLabelColor: Colors.black,
                labelColor: Colors.red,
                tabs: [
                  Tab(text: '全部'),
                  Tab(text: '数据'),
                  Tab(text: '订阅'),
                ]),
            Expanded(child: TabBarView(children: children))
          ]),
        );
      }),
    );
  }
}
