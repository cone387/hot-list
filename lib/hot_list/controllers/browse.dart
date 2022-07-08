import 'package:hot_list/common/controllers/list.dart';
import 'package:hot_list/common/controllers/mixin.dart';
import 'package:hot_list/common/http/requests.dart';
import 'package:hot_list/common/entities/types.dart';
import 'package:hot_list/hot_list/api.dart';
import 'package:hot_list/hot_list/entities/subscribe.dart';
import 'package:hot_list/hot_list/requests.dart';

class BrowseCollectionController
    extends HttpListCreateRemoveController<Collection> with CacheableListMixin {
  BrowseCollectionController._();
  static final BrowseCollectionController _instace =
      BrowseCollectionController._();
  factory BrowseCollectionController() => _instace;

  @override
  Collection decoder(Json json) => Collection.fromJson(json);

  @override
  BaseRequests get requests => UserRequests;

  @override
  String get listUrl => API.collectionList;

  @override
  String get postUrl => API.collectionCreate;

  @override
  String get removeUrl => API.collectionDelete;

  @override
  String get key => "browse-collection-cache";

  bool contains(Collection record) {
    return items.contains(record);
  }

  @override
  Future<String?> addItem(Collection item) {
    item.data.isCollected = true;
    return super.addItem(item);
  }

  @override
  Future<String?> removeItem(Collection item) {
    item.data.isCollected = false;
    return super.removeItem(item);
  }
}

class BrowseHistoryController
    extends HttpListCreateRemoveController<BrowseRecord>
    with CacheableListMixin {
  BrowseHistoryController._();
  static final BrowseHistoryController _instace = BrowseHistoryController._();
  factory BrowseHistoryController() => _instace;

  @override
  BrowseRecord decoder(Json json) {
    return BrowseRecord.fromJson(json);
  }

  @override
  String get listUrl => API.browseRecordList;

  @override
  String get postUrl => API.browseRecordCreate;

  @override
  String get removeUrl => API.browseRecordCreate;

  @override
  BaseRequests get requests => UserRequests;

  @override
  String get key => "browse-history-cache";

  bool contains(BrowseRecord record) {
    return items.contains(record);
  }

  @override
  Future<String?> addItem(BrowseRecord item) {
    item.data.isBrowsed = true;
    return super.addItem(item);
  }

  @override
  Future<String?> removeItem(BrowseRecord item) {
    item.data.isBrowsed = false;
    return super.removeItem(item);
  }
}
