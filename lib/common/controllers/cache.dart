import 'package:sqflite/sqlite_api.dart';
import 'package:hot_list/common/controllers/base.dart';
import 'package:hot_list/common/controllers/list.dart';
import 'package:hot_list/common/controllers/mixin.dart';
import 'package:hot_list/common/entities/identifiable.dart';
import 'package:hot_list/common/entities/serializable.dart';
import 'package:hot_list/common/entities/types.dart';
import 'package:hot_list/common/logger.dart';
import 'package:hot_list/common/storage/db.dart';

// class SqlListController extends ListController{

// }

mixin SqlItemMixin<T extends Serializable> on BaseItemMixin<T> {
  String get table;

  Database get db => SqliteDB.db;
}

// // 添加item到服务端
mixin SqlListMixin<T extends Serializable>
    on ListController<T>, SqlItemMixin<T> {
  String orderBy = 'id desc';

  List<String> get defaultWhere;

  String getListQuery(List<String> where) {
    assert(where.isNotEmpty, "where cant be null");
    return "select * from $table where ${where.join(' and ')} order by $orderBy";
  }

  Future<List<T>> queryItems({required List<String> where}) async {
    String query = getListQuery(where);
    var objects = await db.rawQuery(query);
    logger.d("query ${objects.length} items using query: $query");
    return objects.map((e) => decoder(e)).toList();
  }

  @override
  Future<List<T>> listItems() async {
    return queryItems(where: defaultWhere);
  }
}

// 添加item到服务端
mixin SqlPagedListMixin<T extends Serializable>
    on SqlListMixin<T>, PagedListMixin<T> {
  @override
  String getListQuery(List<String> where) {
    String query = super.getListQuery(where);
    int p = page - initPage;
    return query + " limit ${p * pageSize}, ${(p + 1) * pageSize}";
  }
}

// 添加item到服务端
mixin SqlItemAddMixin<T extends IdSerializable>
    on SqlPagedListMixin<T>, ItemAddMixin<T> {
  Future<String?> onItemAdd(T item) async {
    Json value = item.toJson();
    value.remove('id');
    var id = await db.insert(table, value,
        conflictAlgorithm: ConflictAlgorithm.replace);
    if (id != 0) {
      item.id = id;
    }
    logger.d("$runtimeType add $item to sql: $id");
    return id > 0 ? null : "$runtimeType failed on add $item to sql";
  }
}

// 删除远程Item
mixin SqlItemRemoveMixin<T extends IdSerializable>
    on SqlItemMixin<T>, ItemRemoveMixin<T> {
  Future<String?> onItemRemove(T item) async {
    var num = await db.delete(table, where: 'id=${item.id}');
    logger.d("$runtimeType delete $item in sql: $num");
    return num > 0 ? null : "$runtimeType failed on delete $item in sql";
  }
}

mixin SqlItemUpdateMixin<T extends IdSerializable>
    on SqlItemMixin<T>, ItemUpdateMixin<T> {
  @override
  Future<String?> onItemUpdate(int oldIndex, T oldItem, T newItem) async {
    Json value = newItem.toJson();
    value.remove('id');
    var num = await db.update(table, value, where: "id=${oldItem.id}");
    logger.d("$runtimeType update $newItem in sql: $num");
    return num > 0 ? null : "$runtimeType failed on update $newItem";
  }
}

// base http controller
abstract class SqlController<T extends Serializable> extends ListController<T>
    with SqlItemMixin<T> {}

// list http controller
abstract class SqlListController<T extends Serializable>
    extends SqlController<T> with SqlListMixin<T> {}

//
abstract class _SqlPagedListController<T extends Serializable>
    extends SqlListController<T> with PagedListMixin<T> {}

abstract class SqlPagedListController<T extends Serializable>
    extends _SqlPagedListController<T> with SqlPagedListMixin<T> {}

abstract class _SqlListCreateController<T extends Serializable>
    extends SqlPagedListController<T> with ItemAddMixin<T> {}

abstract class SqlListCreateController<T extends IdSerializable>
    extends _SqlListCreateController<T> with SqlItemAddMixin<T> {}

abstract class _SqlListCreateRemoveController<T extends IdSerializable>
    extends SqlPagedListController<T> with ItemAddMixin<T>, ItemRemoveMixin {}

abstract class SqlListCreateRemoveController<T extends IdSerializable>
    extends _SqlListCreateRemoveController<T>
    with SqlItemAddMixin<T>, SqlItemRemoveMixin<T> {}

// 这里with HttpItemAddMixin<T>, HttpItemRemoveMixin<T>, HttpItemUpdateMixin<T> 会报错：The class doesn't have a concrete implementation of the super-invoked member 'onItemUpdate'.
// 不知道是不是with有个数限制
abstract class SqlRichListController<T extends IdSerializable>
    extends RichListController<T>
    with
        PagedListMixin<T>,
        ItemAddMixin<T>,
        ItemRemoveMixin<T>,
        ItemUpdateMixin<T>,
        SqlItemMixin<T>,
        SqlListMixin<T>,
        SqlPagedListMixin<T>,
        SqlItemAddMixin<T>,
        SqlItemRemoveMixin<T>,
        SqlItemUpdateMixin<T> {}
