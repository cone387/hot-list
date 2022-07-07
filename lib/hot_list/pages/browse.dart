// ignore_for_file: library_private_types_in_public_api

import 'package:hot_list/common/commont.dart';
import 'package:hot_list/hot_list/controllers/browse.dart';
import 'package:hot_list/hot_list/entities/subscribe.dart';
import 'package:hot_list/hot_list/widgets/buttons/browse.dart';
// ignore: unused_import
import 'package:hot_list/hot_list/widgets/mobile_browse.dart'
    if (dart.library.html) 'package:hot_list/hot_list/widgets/web_browse.dart';

import 'package:flutter/material.dart';

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

Widget recordBuilder(BrowseRecord record, int index, {dynamic arg}) {
  return ListTile(
      // isThreeLine: true,
      // subtitle: history[index].sub,
      minLeadingWidth: 0,
      leading: Text(
        (index + 1).toString(),
        style: const TextStyle(color: Colors.red),
      ),
      title: Align(
          alignment: Alignment.centerLeft, child: Text(record.data.title)),
      trailing: Text(record.browseTime.smartFormat),
      onTap: () {
        goToDetail(record: record);
      });
}

class BrowseCollectionPage extends StatelessWidget {
  const BrowseCollectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Browse Collection"),
      ),
      body: RichListWidget<BrowseRecord>(
        controller: BrowseCollectionController(),
        itemBuilder: recordBuilder,
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
        itemBuilder: recordBuilder,
      ),
    );
  }
}
