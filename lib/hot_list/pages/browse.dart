// ignore_for_file: library_private_types_in_public_api

import 'package:hot_list/common/commont.dart';
import 'package:hot_list/hot_list/controllers/browse.dart';
import 'package:hot_list/hot_list/entities/subscribe.dart';
import 'package:hot_list/hot_list/widgets/buttons/browse.dart';
import 'package:flutter/material.dart';
import 'package:hot_list/hot_list/widgets/browse.dart';

class BrowseDetailPage extends StatefulWidget {
  final BrowseRecord _record;

  const BrowseDetailPage(this._record, {Key? key}) : super(key: key);

  @override
  _BrowseDetailState createState() {
    return _BrowseDetailState();
  }
}

class _BrowseDetailState extends State<BrowseDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget._record.data.title),
          actions: [
            CollectionButton(record: widget._record),
            OpenInBrowseButton(widget._record.data),
            DataShareButton(context)
          ],
        ),
        body: BrowseWidget(
          record: widget._record,
        )
        // floatingActionButton: FloatingActionButton(onPressed: (){}, child: Text("hello")),
        );
  }
}

class BrowseCollectionPage extends StatelessWidget {
  const BrowseCollectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("收藏"),
      ),
      body: RichListWidget<BrowseRecord>(
        controller: BrowseCollectionController(),
        itemBuilder: (item, index) => RecordTile(
          data: item.data,
          index: index,
        ),
      ),
    );
  }
}

class BrowseHistoryPage extends StatelessWidget {
  const BrowseHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("浏览记录"),
      ),
      body: RichListWidget<BrowseRecord>(
        controller: BrowseHistoryController(),
        itemBuilder: (item, index) => RecordTile(
          data: item.data,
          index: index,
        ),
      ),
    );
  }
}
