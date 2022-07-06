import 'package:hot_list/common/commont.dart';
import 'package:hot_list/common/controllers/base.dart';
import 'package:hot_list/common/controllers/mixin.dart';
export 'package:get/get.dart' hide Response, MultipartFile, FormData;

abstract class PagedListController<T> extends ListController<T>
    with PagedListMixin<T> {
  PagedListController({bool autoRefresh = true, List<T>? initItems})
      : super(autoRefresh: true, initItems: initItems);
}

abstract class ListCreateController<T> extends PagedListController<T>
    with ItemAddMixin<T> {
  ListCreateController({bool autoRefresh = true, List<T>? initItems})
      : super(autoRefresh: true, initItems: initItems);
}

abstract class ListCreateRemoveController<T> extends ListCreateController<T>
    with ItemRemoveMixin<T> {
  ListCreateRemoveController({bool autoRefresh = true, List<T>? initItems})
      : super(autoRefresh: true, initItems: initItems);
}

abstract class RichListController<T> extends ListCreateRemoveController<T>
    with ItemUpdateMixin<T> {
  RichListController({bool autoRefresh = true, List<T>? initItems})
      : super(autoRefresh: true, initItems: initItems);
}

// list http controller
abstract class HttpListController<T> extends ListController<T>
    with HttpItemMixin<T>, HttpListMixin<T> {}

abstract class HttpPagedListController<T extends Serializable>
    extends PagedListController<T>
    with HttpItemMixin<T>, HttpListMixin<T>, HttpPagedListMixin<T> {}

abstract class HttpListCreateController<T extends IdSerializable>
    extends HttpPagedListController<T>
    with ItemAddMixin<T>, HttpItemAddMixin<T> {}

abstract class HttpListCreateRemoveController<T extends IdSerializable>
    extends HttpListCreateController<T>
    with ItemRemoveMixin<T>, HttpItemRemoveMixin<T> {}

// 这里with HttpItemAddMixin<T>, HttpItemRemoveMixin<T>, HttpItemUpdateMixin<T> 会报错：The class doesn't have a concrete implementation of the super-invoked member 'onItemUpdate'.
// 不知道是不是with有个数限制
abstract class HttpRichListController<T extends IdSerializable>
    extends RichListController<T>
    with
        HttpItemMixin<T>,
        HttpListMixin<T>,
        HttpPagedListMixin<T>,
        HttpItemAddMixin<T>,
        HttpItemRemoveMixin<T>,
        HttpItemUpdateMixin<T> {
  HttpRichListController({bool autoRefresh = true, List<T>? initItems})
      : super(autoRefresh: true, initItems: initItems);
}

abstract class HttpCacheableListController<T extends Serializable>
    extends HttpListController<T> with CacheableListMixin<T> {}

class _HttpRichListController<T extends IdSerializable>
    extends HttpRichListController<T>
    with HttpItemAddMixin<T>, HttpItemRemoveMixin<T>, HttpItemUpdateMixin<T> {
  _HttpRichListController(
      {required this.listUrl,
      required this.updateUrl,
      required this.postUrl,
      required this.removeUrl,
      required this.entityDecoder});

  T Function(Json json) entityDecoder;

  @override
  T decoder(Json json) => entityDecoder(json);

  @override
  String listUrl;

  @override
  String updateUrl;

  @override
  String postUrl;

  @override
  String removeUrl;
}

HttpRichListController<T>
    createHttpRichListController<T extends IdSerializable>(
        {required String listUrl,
        required String updateUrl,
        required String postUrl,
        required String removeUrl,
        required T Function(Json json) entityDecoder}) {
  return _HttpRichListController<T>(
      listUrl: listUrl,
      updateUrl: updateUrl,
      postUrl: postUrl,
      removeUrl: removeUrl,
      entityDecoder: entityDecoder);
}
