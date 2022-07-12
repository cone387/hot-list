import 'package:hot_list/common/commont.dart';
import 'package:hot_list/common/utils/url.dart';
import 'package:hot_list/global.dart';
import 'package:hot_list/hot_list/controllers/browse.dart';
import 'package:hot_list/hot_list/controllers/subscribe.dart';
import 'package:hot_list/hot_list/entities/setting.dart';

class CategoryEntity extends IdSerializable {
  late String name;
  List<Subscribe> subList = [];

  // CategoryEntity({this.id, this.name, this.subList}): super();

  CategoryEntity.fromJson(Json json) {
    id = json['id'];
    name = json['name'];
    List subs = json['subs'];
    subList = subs.map<Subscribe>((e) => Subscribe.fromJson(e)).toList();
  }

  @override
  toJson() {
    return {
      'id': id,
      'name': name,
      'subs': subList,
    };
  }

  @override
  String toString() {
    return "Category(id=$id, name=$name)";
  }
}

class DataEntity extends IdSerializable {
  late String title;
  late String url;
  late int subscribeId = 0;
  int pos = 0;
  String? tag;
  String? image;
  Subscribe subscribe;
  late DateTime createTime;
  late DateTime updateTime;

  bool _isBrowsed = false;
  bool _isCollected = false;
  final Map<String, Function()> _notifyListeners = {};

  DataEntity.fromJson(Json json, this.subscribe) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
    tag = json['tag'];
    image = json['image'];
    subscribeId = json['subscribe_id'] ?? 0;
    pos = json['crawl_pos'];
    _isBrowsed = json['is_browsed'] ?? false;
    _isCollected = json['is_collected'] ?? false;
    createTime = DateTime.parse(json['create_time']);
    updateTime = DateTime.parse(json['update_time']);
  }

  @override
  toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'tag': tag,
      'image': image,
      'subscribe_id': subscribeId,
      'crawl_pos': pos,
      'is_browsed': _isBrowsed,
      'iscoverted': _isCollected,
      'create_time': createTime.YYmmddHHMMSS,
      'update_time': updateTime.YYmmddHHMMSS
    };
  }

  @override
  String toString() {
    return "Data(title=$title, tag=$tag)";
  }

  bool get isBrowsed {
    if (!_isBrowsed) {
      _isBrowsed = BrowseHistoryController().contains(BrowseRecord(data: this));
    }
    return _isBrowsed;
  }

  listenChange(name, Function() listener) {
    _notifyListeners[name] ??= listener;
  }

  set isBrowsed(bool value) {
    if (value != _isBrowsed) {
      _isBrowsed = value;
      _notifyListeners['isBrowsed']?.call();
    }
  }

  bool get isCollected {
    if (!_isCollected) {
      _isCollected =
          BrowseCollectionController().contains(BrowseRecord(data: this));
    }
    return _isCollected;
  }

  set isCollected(bool value) {
    if (value != _isCollected) {
      _isCollected = value;
      _notifyListeners['isCollected']?.call();
    }
  }

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    return (identical(this, other)) ||
        (other is DataEntity &&
            other.id == id &&
            subscribe.id == other.subscribe.id);
  }
}

class WebSite extends Serializable {
  String? category;
  late String image;
  late String url;
  late String name;
  late int id;

  WebSite.fromJson(Map<String, dynamic> data) {
    category = data['category'];
    image = data['image'];
    url = data['url'];
    name = data['name'];
    id = data['id'];
  }

  @override
  Json toJson() {
    return {
      'category': category,
      'image': image,
      'name': name,
      'url': url,
      'id': id,
    };
  }

  @override
  String toString() {
    return "WebSite(name=$name, category=$category)";
  }
}

class Subscribe extends IdSerializable {
  late String name;
  String? image;
  late WebSite site;
  List<DataEntity> dataList = [];
  
  late SettingKey browsedTimesObsKey = SettingKey('subscribe<$id>browsed-times-changed', value: 0);

  Subscribe();

  String get imageUrl => urlJoin(Global.cdnBaseUrl, (image ?? site.image));

  Subscribe.fromJson(Map<String, dynamic> data) {
    id = data['id'];
    name = data['name'];
    image = data['image'];
    if (data['site'] != null) {
      site = WebSite.fromJson(data['site']);
    }
  }

  @override
  Json toJson() {
    return {
      "name": name,
      "image": image,
      "site": site.toJson(),
      'id': id,
    };
  }

  @override
  String toString() {
    return "Subscribe(id=$id, site=$site, name=$name)";
  }
}

class UserSubscribe extends IdSerializable {
  double position = 0;
  String? _name;
  late Subscribe subscribe;

  String get name => _name ?? subscribe.name;

  UserSubscribe({required this.subscribe});

  UserSubscribe.fromJson(Json json) {
    id = json['id'];
    _name = json['name'];
    position = double.parse(json['position'].toString());
    subscribe = Subscribe.fromJson(json['subscribe']);
  }

  @override
  Json toJson() {
    return {
      'id': id,
      'subscribe': subscribe.toJson(),
      'custom_name': _name,
      'position': position,
      'subscribe_id': subscribe.id,
    };
  }

  @override
  String toString() {
    return "UserSubscribe(id=$id, subscribe=$subscribe, position=$position)";
  }

  UserSubscribe copyWith({
    String? name,
    double? position,
  }) {
    var o = UserSubscribe(subscribe: subscribe);
    o.id = id;
    o._name = name ?? _name;
    o.position = position ?? this.position;
    return o;
  }
}

class BrowseRecord extends IdSerializable {
  late Subscribe subscribe;
  late DataEntity data;
  late String title;
  DateTime browseTime = DateTime.now();

  BrowseRecord({required this.data})
      : subscribe = data.subscribe,
        title = data.title;

  BrowseRecord.fromJson(json) {
    subscribe = Subscribe.fromJson(json['subscribe']);
    data = DataEntity.fromJson(json['data'], subscribe);
    browseTime = DateTime.parse(json['create_time']);
    title = json['title'];
    id = json['id'];
  }

  @override
  toJson() {
    return {
      "create_time": browseTime.YYmmddHHMMSS,
      "subscribe": subscribe.toJson(),
      'title': title,
      "data": data.toJson(),
      "id": id
    };
  }

  @override
  String toString() {
    return "BrowseRecord(subscibe=$subscribe, data=$data)";
  }

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    return (identical(this, other)) ||
        (other is BrowseRecord && other.data == data);
  }
}

typedef Collection = BrowseRecord;
