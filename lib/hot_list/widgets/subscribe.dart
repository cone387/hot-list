import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hot_list/common/utils/url.dart';
import 'package:hot_list/common/widgets/image.dart';
import 'package:hot_list/common/widgets/list.dart';
import 'package:hot_list/global.dart';
import 'package:hot_list/hot_list/controllers/browse.dart';
import 'package:hot_list/hot_list/controllers/subscribe.dart';
import 'package:hot_list/hot_list/entities/subscribe.dart';
import 'package:hot_list/hot_list/widgets/buttons/subscribe.dart';
import 'package:hot_list/route.dart';
// ignore: unused_import
import 'package:hot_list/hot_list/widgets/mobile_browse.dart'
    if (dart.library.html) 'package:hot_list/hot_list/widgets/web_browse.dart';

class SubscribeTile extends StatelessWidget {
  final Subscribe subscribe;
  const SubscribeTile({required this.subscribe, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: buildRectWidget(
          radius: 10, child: buildImageWidget(subscribe.imageUrl)),
      title: Text(subscribe.name),
      trailing: SubscribeButton(subscribe),
      isThreeLine: true,
      subtitle: Text(subscribe.site.name),
      onTap: () {
        Get.toNamed(Routes.subscribeDetail, arguments: subscribe);
      },
    );
  }
}

Widget subscribeDetailBuilder(DataEntity data, int index, dynamic argument) {
  Widget title;
  Widget trailing = Container(
    width: 10,
  );
  if (data.image != null) {
    title = Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // 顶部对齐
        children: [
          Expanded(
              flex: 2,
              child: Column(
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        data.title,
                        style: TextStyle(fontSize: 15),
                      )),
                  Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        data.tag!,
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                      )),
                ],
              )),
          const Padding(padding: EdgeInsets.all(5)),
          Expanded(
            flex: 1,
            child: data.image == null
                ? const Text("")
                : buildRectWidget(
                    radius: 5,
                    child: buildImageWidget(
                      urlJoin(Global.cdnBaseUrl, data.image!),
                      fit: BoxFit.cover,
                    )),
          )
        ],
      ),
    );
  } else {
    title = Align(
        alignment: Alignment.centerLeft,
        child: Text(
          data.title,
          style: const TextStyle(fontSize: 15),
        ));
    trailing = Text(data.tag!);
  }
  return ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
    onTap: () {
      var record = BrowseRecord(subscribe: argument, data: data);
      BrowseHistoryController().addItem(record);
      goToDetail(record: record);
    },
    // dense: true,
    title: title,
    leading: Text("${index + 1}",
        style: const TextStyle(fontSize: 15, color: Colors.red)),
    trailing: trailing,
    minLeadingWidth: 0,
  );
}

class SubscriibeDetailWidget extends StatelessWidget {
  final Subscribe subscribe;
  final bool subscribable;
  final bool scaffoldable;

  const SubscriibeDetailWidget(
      {Key? key,
      required this.subscribe,
      this.subscribable = false,
      this.scaffoldable = false})
      : super(key: key);

  @override
  Widget build(context) {
    Widget child = RichListWidget<DataEntity>(
      controller: DataSubscribeController(subscribe),
      itemBuilder: subscribeDetailBuilder,
      argument: subscribe,
    );
    if (subscribable || scaffoldable) {
      child = Scaffold(
        appBar: AppBar(
          title: Text("${subscribe.site.name}·${subscribe.name}"),
        ),
        body: child,
        floatingActionButton: subscribable
            ? SubscribeButton<FloatingActionButton>(subscribe)
            : null,
      );
    }
    return child;
  }
}

class SubscribeManageWidget extends StatelessWidget {
  late final UserSubscribeControler controller = UserSubscribeControler();

  SubscribeManageWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("订阅管理"),
        ),
        body: Obx(() {
          int i = 0;
          return ReorderableListView(
            onReorder: _onReorder,
            children: controller.items.map((e) {
              i += 1;
              return ListTile(
                key: ObjectKey(e),
                leading: Text("$i"),
                title: Text(e.name),
                trailing: SubscribeButton(e.subscribe),
              );
            }).toList(),
          );
        }));
  }

  _onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    var sourceItem = controller.items[oldIndex];
    var targetItem = controller.items[newIndex];
    controller.onPositionChanged(sourceItem, targetItem);
    controller.updateItem(
        sourceItem,
        sourceItem.copyWith(
          position: 10,
        ));
  }
}