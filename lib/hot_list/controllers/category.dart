import 'package:hot_list/common/controllers/list.dart';
import 'package:hot_list/common/controllers/mixin.dart';
import 'package:hot_list/common/entities/types.dart';
import 'package:hot_list/common/http/requests.dart';
import 'package:hot_list/hot_list/api.dart';
import 'package:hot_list/hot_list/entities/subscribe.dart';
import 'package:hot_list/hot_list/requests.dart';

class CategoryListController
    extends HttpCacheableListController<CategoryEntity> {
  static const String tabId = 'subscribe-categorys';

  CategoryListController._();
  static final CategoryListController _instance = CategoryListController._();

  factory CategoryListController() {
    return _instance;
  }

  @override
  onItemsInitialized() {
    // update不指定id就是refresh, refresh跟update不一样
    update([tabId]);
  }

  doUpdate() {
    update([tabId]);
  }

  @override
  Future<List<CategoryEntity>> listItems() async {
    var o = await super.listItems();
    update();
    return o;
  }

  @override
  CategoryEntity decoder(Json json) {
    return CategoryEntity.fromJson(json);
  }

  @override
  String get key => 'subscribe-category';

  @override
  String get listUrl => API.categoryPath;

  @override
  BaseRequests get requests => UserRequests;
}

class CategoryDetailController extends HttpPagedListController<Subscribe>
    with CacheableListMixin {
  final CategoryEntity category;
  CategoryDetailController.of(this.category);

  static final Map<CategoryEntity, CategoryDetailController> _mapping = {};
  factory CategoryDetailController(CategoryEntity category) {
    CategoryDetailController? instance = _mapping[category];
    if (instance == null) {
      _mapping[category] = CategoryDetailController.of(category);
    }
    return _mapping[category]!;
  }

  @override
  onItemsInitialized() {
    update();
  }

  @override
  List decodeResponse(Response response) {
    return response.getJson()['results']['subs'];
  }

  @override
  Subscribe decoder(Json json) {
    return Subscribe.fromJson(json);
  }

  @override
  String get key => 'subscribe-of-category<${category.id}>';

  @override
  String get listUrl =>
      API.categorySubPath.replaceAll('{id}', category.id.toString());

  @override
  BaseRequests get requests => UserRequests;
}
