import 'package:hot_list/common/controllers/list.dart';
import 'package:hot_list/common/entities/types.dart';
import 'package:hot_list/common/http/requests.dart';
import 'package:hot_list/hot_list/api.dart';
import 'package:hot_list/hot_list/entities/subscribe.dart';

class DataSearchController extends HttpPagedListController<DataEntity> {
  final String? q;
  DataSearchController({required this.q, List<DataEntity>? initItems})
      : super(initItems: initItems);

  @override
  DataEntity decoder(Json json) {
    return DataEntity.fromJson(json, Subscribe.fromJson(json['subscribe']));
  }

  @override
  String get listUrl => API.search;

  @override
  Json get listParams => {"fields": "data", "q": q, ...super.listParams};
}

class SubscribeSearchController extends HttpPagedListController<Subscribe> {
  final String? q;
  SubscribeSearchController({required this.q, List<Subscribe>? initItems})
      : super(initItems: initItems);

  @override
  Subscribe decoder(Json json) {
    return Subscribe.fromJson(json);
  }

  @override
  String get listUrl => API.search;

  @override
  Json get listParams => {"fields": "sub", "q": q, ...super.listParams};
}

class SearchController {
  final isSearching = true.obs;
  final String? keyword;
  DataSearchController? dataController;
  SubscribeSearchController? subscribeController;

  SearchController({this.keyword});

  Future<bool> search({String? keyword}) async {
    String? q = keyword ?? this.keyword;
    var response = await Requests.get(API.search, params: {
      'q': q,
    });
    List<Subscribe> subscribeList = [];
    List<DataEntity> dataList = [];
    if (response.statusCode == 200) {
      final json = response.getJson();
      final data = json['data']['results'];
      final subs = json['sub']['results'];
      for (var element in subs) {
        subscribeList.add(Subscribe.fromJson(element));
      }
      for (var element in data) {
        dataList.add(DataEntity.fromJson(
            element, Subscribe.fromJson(element['subscribe'])));
      }
    }
    subscribeController =
        SubscribeSearchController(q: q, initItems: subscribeList);
    dataController = DataSearchController(q: q, initItems: dataList);
    isSearching.value = false;
    return false;
  }
}
