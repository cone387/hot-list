import 'package:hot_list/common/controllers/list.dart';
import 'package:hot_list/common/entities/types.dart';
import 'package:hot_list/common/http/requests.dart';
import 'package:hot_list/hot_list/api.dart';
import 'package:hot_list/hot_list/entities/subscribe.dart';

class DataSearchController extends HttpPagedListController<DataEntity> {
  String? q;
  DataSearchController({this.q, List<DataEntity>? initItems})
      : super(initItems: initItems, autoRefresh: false);

  void setQuery(String? q) {
    this.q = q;
  }

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
  String? q;
  SubscribeSearchController({this.q, List<Subscribe>? initItems})
      : super(initItems: initItems, autoRefresh: false);

  @override
  Subscribe decoder(Json json) {
    return Subscribe.fromJson(json);
  }

  void setQuery(String? q) {
    this.q = q;
  }

  @override
  String get listUrl => API.search;

  @override
  Json get listParams => {"fields": "sub", "q": q, ...super.listParams};
}

enum SearchType { all, data, subscribe }

class SearchController {
  final isSearching = true.obs;
  final Rx<SearchType> searchType = SearchType.all.obs;
  final String? keyword;
  final DataSearchController dataController = DataSearchController();
  final SubscribeSearchController subscribeController =
      SubscribeSearchController();

  SearchController({this.keyword});

  Future<bool> search({String? keyword}) async {
    isSearching.value = true;
    searchType.value = SearchType.all;
    String? q = keyword ?? this.keyword;
    subscribeController.items.clear();
    dataController.items.clear();
    subscribeController.setQuery(q);
    dataController.setQuery(q);
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
    subscribeController.setItems(subscribeList);
    dataController.setItems(dataList);
    isSearching.value = false;
    return false;
  }
}
