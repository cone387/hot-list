import 'package:hot_list/common/commont.dart';
import 'package:hot_list/common/utils/url.dart';
import 'package:hot_list/global.dart';
import 'package:hot_list/hot_list/controllers/subscribe.dart';

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
  late int subId = 0;
  late int pos = 0;
  String? tag;
  String? image;

  DataEntity.fromJson(Json data) {
    title = data['title'];
    url = data['url'];
    tag = data['tag'];
    image = data['image'];
    subId = data['subscribe'];
    pos = data['crawl_pos'];
  }

  @override
  toJson() {
    return {
      'title': title,
      'url': url,
      'tag': tag,
      'image': image,
      'id': id,
      'subscribe': subId,
      'crawl_pos': pos,
    };
  }

  @override
  String toString() {
    return "Data(title=$title, tag=$tag)";
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

  Subscribe();

  // String get name => customName ?? subName;
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
  }){
    var o = UserSubscribe(subscribe: subscribe); 
    o.id = id;
    o._name = name?? _name;
    o.position = position?? this.position;
    return o;
  }
}

class BrowseRecord extends IdSerializable {
  late Subscribe subscribe;
  late DataEntity data;
  late String title;
  DateTime browseTime = DateTime.now();

  BrowseRecord({required this.subscribe, required this.data})
      : title = "[${subscribe.name}]${data.title}";

  BrowseRecord.fromJson(json) {
    subscribe = Subscribe.fromJson(json['subscribe']);
    data = DataEntity.fromJson(json['data']);
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
}

typedef Collection = BrowseRecord;
