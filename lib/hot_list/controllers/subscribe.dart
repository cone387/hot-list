import 'package:hot_list/common/controllers/list.dart';
import 'package:hot_list/common/controllers/mixin.dart';
import 'package:hot_list/common/entities/types.dart';
import 'package:hot_list/common/http/requests.dart';
import 'package:hot_list/hot_list/api.dart';
import 'package:hot_list/hot_list/controllers/setting.dart';
import 'package:hot_list/hot_list/controllers/user.dart';
import 'package:hot_list/hot_list/entities/setting.dart';
import 'package:hot_list/hot_list/entities/subscribe.dart';
import 'package:hot_list/hot_list/requests.dart';

class UserSubscribeControler extends HttpRichListController<UserSubscribe>
    with CacheableListMixin<UserSubscribe> {
  UserSubscribeControler._({List<UserSubscribe>? initItems})
      : super(initItems: initItems);
  bool isInitialized = false;

  static String tabId = "user-subscribes";

  static UserSubscribeControler? _instance;
  factory UserSubscribeControler() {
    _instance ??= UserSubscribeControler._(initItems: GlobalUser.subscribes);
    return _instance!;
  }

  @override
  onItemsInitialized() {
    doUpdate();
  }

  doUpdate() {
    update();
  }

  @override
  Future<String?> addItem(UserSubscribe item) async {
    var error = await super.addItem(item);
    if (error == null) {
      doUpdate();
    }
    return error;
  }

  @override
  Future<String?> removeItem(UserSubscribe item) async {
    var error = await super.removeItem(item);
    if (error == null) {
      doUpdate();
    }
    return error;
  }

  @override
  void update([List<Object>? ids, bool condition = true]) {
    super.update([tabId], condition);
  }

  // 是否订阅
  bool exists(Subscribe subscribe) {
    return querySubscribe(subscribe) != null;
  }

  UserSubscribe? querySubscribe(Subscribe subscribe) {
    for (var element in UserSubscribeControler().items) {
      if (element.subscribe.id == subscribe.id) {
        return element;
      }
    }
    return null;
  }

  sort() {
    items.sort((a, b) => a.position.compareTo(b.position));
  }

  @override
  UserSubscribe decoder(Json json) {
    return UserSubscribe.fromJson(json);
  }

  @override
  String get key => '/subscribe/user';

  @override
  String get listUrl => API.subscribeList;

  @override
  BaseRequests get requests => UserRequests;

  @override
  String get postUrl => API.subscribeCreate;

  @override
  String get removeUrl => API.subscribeDelete;

  @override
  String get updateUrl => API.subscribeUpdate;
}

class DataSubscribeController extends HttpCacheableListController<DataEntity> {
  final Subscribe subscribe;
  DataSubscribeController.of(this.subscribe);

  // 不能使用Map<Subscribe, DataSubscribeController>, 因为从缓存加载过来会的Subscribe跟内存中的不一样
  static final Map<int, DataSubscribeController> _mapping = {};
  factory DataSubscribeController(Subscribe subscribe) {
    DataSubscribeController? instance = _mapping[subscribe.id];
    if (instance == null) {
      _mapping[subscribe.id] = DataSubscribeController.of(subscribe);
    }
    return _mapping[subscribe.id]!;
  }

  sort() {
    items.sort((a, b) => a.pos.compareTo(b.pos));
  }

  bool isNewItem(DataEntity data) {
    return !cachedItems.contains(data);
  }

  bool isItemBrowsed(DataEntity data) {
    if (data.isBrowsed) {
      return true;
    }
    DataEntity? oldItem =
        cachedItems.firstWhereOrNull((element) => data == element);
    if (oldItem != null) {
      return oldItem.isBrowsed;
    }
    return false;
  }

  @override
  void setItems(List<DataEntity> objects) {
    super.setItems(objects);
    SettingController.updateSetting(subscribe.browsedTimesObsKey, notBrowsedCount);
  }

  int get notBrowsedCount {
    return items.where((element) => !isItemBrowsed(element)).length;
  }

  setItemBrowsed(DataEntity data) {
    SettingController.updateSetting(subscribe.browsedTimesObsKey, notBrowsedCount);
    toCahce(items);
  }

  @override
  onItemsInitialized() {
    // sort();
    update();
  }

  @override
  DataEntity decoder(Json json) {
    return DataEntity.fromJson(json, subscribe);
  }

  @override
  List decodeResponse(Response response) {
    return response.getJson()['data'];
  }

  @override
  String get key => 'subscribe[${subscribe.name}]-data';

  @override
  String get listUrl =>
      API.publicSubscribeDetail.replaceAll("{id}", subscribe.id.toString());

  @override
  BaseRequests get requests => UserRequests;
}
