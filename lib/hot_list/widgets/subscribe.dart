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
  const SubscribeTile({required this.subscribe, int? index, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: key,
      leading: buildRectWidget(
          radius: 10, child: buildImageWidget(subscribe.imageUrl)),
      title: Text(subscribe.name),
      trailing: SubscribeButton(subscribe),
      // isThreeLine: true,
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(subscribe.site.name),
      ),
      onTap: () {
        Get.toNamed(Routes.subscribeDetail, arguments: subscribe);
      },
    );
  }
}

class DataTile extends StatefulWidget {
  final DataEntity data;
  final int index;
  final DataSubscribeController controller;
  const DataTile({Key? key, required this.data, 
    required this.controller,
    required this.index})
      : super(key: key);

  @override
  State<DataTile> createState() => _DataTileState();
}

class _DataTileState extends State<DataTile> {
  @override
  void initState() {
    super.initState();
    widget.data.listenChange('isBrowsed', () => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    DataEntity data = widget.data;
    int index = widget.index;
    Widget? subTitle;
    Widget tralling;
    Widget title = Text(
      data.title,
      style: TextStyle(color: widget.controller.isItemBrowsed(data) ? Colors.grey : Colors.black));
    Widget leading = Column(
      mainAxisAlignment: data.image != null
          ? MainAxisAlignment.start
          : MainAxisAlignment.center,
      children: [
        Text(
          (index + 1).toString(),
          textAlign: TextAlign.end,
        ),
      ],
    );
    if (data.image != null) {
      tralling = buildRectWidget(
          radius: 5,
          child: buildImageWidget(
            urlJoin(Global.cdnBaseUrl, data.image!),
            fit: BoxFit.cover,
          ));
      if (data.tag != null) {
        subTitle = Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(data.tag!),
        );
      }
    } else {
      tralling = Text(
        data.tag ?? "",
      );
    }
    return ListTile(
      leading: leading,
      title: title,
      subtitle: subTitle,
      trailing: tralling,
      minLeadingWidth: 0,
      // minVerticalPadding: 5,
      // horizontalTitleGap: 10,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      onTap: () {
        var record = BrowseRecord(data: data);
        BrowseHistoryController().addItem(record);
        widget.controller.setItemBrowsed(data);
        goToDetail(record: record);
      },
    );
  }
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
      itemBuilder: (data, index, {arg}) {
        return DataTile(data: data, index: index, controller: DataSubscribeController(subscribe),);
      },
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
              return SubscribeTile(
                subscribe: e.subscribe,
                key: ObjectKey(e),
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
    controller.doUpdate();
  }
}
