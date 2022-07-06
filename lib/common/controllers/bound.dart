// ignore_for_file: body_might_complete_normally_nullable, unnecessary_no_such_method

import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:hot_list/common/commont.dart';
import 'package:hot_list/common/controllers/base.dart';
import 'package:hot_list/common/controllers/cache.dart';
import 'package:hot_list/common/controllers/list.dart';
import 'package:hot_list/common/controllers/mixin.dart';
import 'package:hot_list/common/controllers/shared.dart';
import 'package:hot_list/common/entities/bound.dart';
import 'package:hot_list/logger.dart';

mixin BoundServerMixin<T extends IdSerializable> on RichListController<T> {
  String? scope;

  @override
  bool autoRefresh = false;
}

mixin BoundLocalMixin<T extends IdSerializable>
    on RichListController<BoundEntity<T>> {
  String? scope;

  @override
  bool autoRefresh = false;

  Future<void> addActionLog(BoundEntity<T> bound);

  @override
  BoundEntity<T> decoder(Json json) {
    return BoundEntity.fromJson(
      json,
      (entityJson) => entityDecoder(entityJson),
    );
  }

  Future<List<BoundEntity<T>>> listAddItems(
      {bool justListUnbound: false}) async {
    var bounds = await (justListUnbound ? listUnboundItems() : listItems());
    items.addAll(bounds);
    return bounds;
  }

  Future<List<BoundEntity<T>>> listUnboundItems() => listItems();

  T entityDecoder(Json json);

  // objectsToLocal(List<BoundEntity<T>> objects);
}

abstract class BoundLocalSqlController<T extends IdSerializable>
    extends SqlRichListController<BoundEntity<T>> with BoundLocalMixin<T> {
  late String actionTable = table + '_action';

  @override
  Future<bool> addActionLog(BoundEntity<T> bound) async {
    Json value = bound.toJson();
    value.remove('id');
    var id = await db.insert(actionTable, value,
        conflictAlgorithm: ConflictAlgorithm.replace);
    logger.i("$runtimeType add $bound to action<$actionTable> ${id != 0}");
    return id != 0;
  }

  @override
  List<String> get defaultWhere => [
        "type = '${runtimeType.toString()}'",
        // "create_date = '${DateTime.now().YYmmdd}'",
        if (scope != null) "scope = '$scope'" else "scope is null"
      ];

  @override
  Future<List<BoundEntity<T>>> listUnboundItems() => queryItems(
      where: defaultWhere + ["status!=${BoundStatus.success.index}"]);

  late String createCommand = """
    CREATE TABLE IF NOT EXISTS `{table}`(
      `id` INTEGER PRIMARY KEY AUTOINCREMENT,
      `server_id` int(11) DEFAULT NULL,
      `status` int(11) NOT NULL,
      `action` int(11) NOT NULL,
      `type` varchar(50) DEFAULT NULL,
      `message` varchar(200) DEFAULT NULL,
      `entity` json NOT NULL,
      `scope` varchar(50) DEFAULT NULL,
      `create_date` date NOT NULL DEFAULT CURRENT_DATE,
      unique(scope, server_id, action)
    )
    """;

  @override
  onCreated() async {
    // await db.execute('drop table if exists $table');
    await db.execute(createCommand.replaceAll('{table}', table));
    await db.execute(createCommand.replaceAll('{table}', actionTable));
  }
}

abstract class BoundLocalSharedController<T extends IdSerializable>
    extends SharedRichListController<BoundEntity<T>> with BoundLocalMixin<T> {
  late String actionKey = key + '-action';

  @override
  Future<void> onCreated() async {
    await super.onCreated();
    backend!.remove(listKey);
  }

  @override
  Future<void> addActionLog(BoundEntity<IdSerializable> bound) async {
    String? string = backend!.getString(actionKey);
    List<Json> actions = [];
    if (string != null) {
      actions = jsonDecode(string);
    }
    actions.add(bound.toJson());
    backend!.setString(actionKey, jsonEncode(actions));
    logger.i("$runtimeType add $bound to actions success");
  }

  // @override
  // objectsToLocal(List<BoundEntity<T>> objects) {
  //   backend!.setString(listKey, jsonEncode(objects));
  // }
}

mixin ServerRichListMixin<T extends IdSerializable>
    on RichListController<BoundEntity<T>> {
  bool enableLocal = true;
  bool enableServer = true;
  String? get scope;
  RichListController<T> get serverController;

  Future<bool> addActionLog(BoundEntity<T> bound) async {
    print("not implemented");
    return true;
  }

  @override
  Future<void> onCreated() async {
    logger.i(
        "$runtimeType local enabled: $enableLocal, server enabled: $enableServer");
    autoRefresh = false;
    await serverController.isItemsInitialized;
  }

  List<T> localToServers(List<BoundEntity<T>> locals) {
    return locals.map((e) => e.entity).toList();
  }

  List<BoundEntity<T>> serverToLocals(List<T> items) {
    return items
        .map<BoundEntity<T>>((e) => BoundEntity<T>(
                entity: e,
                status: BoundStatus.success,
                action: BoundAction.list,
                type: runtimeType.toString(),
                scope: scope,
                serverId: e.id)
            // 这里将item.id置为服务端本地id, 必要的
            )
        .toList();
  }

  @override
  Future<List<BoundEntity<T>>> loadInitItems() async {
    return listLocalItems();
  }

  @override
  BoundEntity<T> decoder(Json json) {
    return BoundEntity.fromJson(json, serverController.decoder);
  }

  Future<List<BoundEntity<T>>> listLocalItems({bool unboundOnly: false}) async {
    return super.listItems();
  }

  @override
  Future<List<BoundEntity<T>>> listItems() async {
    if (!enableServer) {
      // only local controller enabled;
      return await listLocalItems();
    }
    if (!enableLocal) {
      // only server controller enabled;
      return serverToLocals(await serverController.listItems());
    }
    // local and server are enabled;
    List<BoundEntity<T>> servers =
        serverToLocals(await serverController.listItems());
    List<BoundEntity<T>> locals =
        await listLocalItems(unboundOnly: page == initPage);
    onItemsAdd(servers);
    return locals + servers;
  }

  @override
  Future<List<BoundEntity<T>>> refreshItems() {
    serverController.page = 1;
    serverController.pageSize = pageSize;
    return super.refreshItems();
  }

  @override
  Future<List<BoundEntity<T>>> loadMoreItems() {
    serverController.page = page;
    serverController.pageSize = pageSize;
    return super.loadMoreItems();
  }

  @override
  Future<String?> onItemAdd(item) async {
    item.scope = scope;
    item.type = runtimeType.toString();
    if (!enableServer) {
      return await super.onItemAdd(item);
    }
    if (!enableLocal) {
      return serverController.onItemAdd(item.entity);
    }
    String? error = await super.onItemAdd(item);
    if (error == null) {
      serverController.onItemAdd(item.entity).then((value) {
        if (value != null) {
          item.status = BoundStatus.failed;
          addActionLog(item.copyWith(
              status: BoundStatus.failed,
              message: value,
              action: BoundAction.create));
        } else {
          super
              .onItemUpdate(
                  -1,
                  item,
                  item.copyWith(
                    status: BoundStatus.success,
                    serverId: item.entity.id,
                  ))
              .then((value) {
            if (value == null) {
              item.serverId = item.entity.id;
              item.status = BoundStatus.success;
            } else {
              logger.i("$runtimeType update $item to sql failed: $value");
            }
          });
        }
      });
    }
    return error;
  }

  @override
  Future<String?> onItemUpdate(int oldIndex, oldItem, newItem) async {
    newItem.action = BoundAction.update;
    if (!enableServer) {
      return await super.onItemUpdate(oldIndex, oldItem, newItem);
    }
    if (!enableLocal) {
      return serverController.onItemUpdate(
          oldIndex, oldItem.entity, newItem.entity);
    }
    String? error = await super.onItemUpdate(oldIndex, oldItem, newItem);
    if (error == null && newItem.isSynced) {
      newItem.status = BoundStatus.none;
      serverController
          .onItemUpdate(oldIndex, oldItem.entity, newItem.entity)
          .then((value) {
        if (value != null) {
          newItem.status = BoundStatus.failed;
          addActionLog(
              newItem.copyWith(status: BoundStatus.failed, message: value));
        } else {
          newItem.status = BoundStatus.success;
          super.onItemUpdate(
              oldIndex,
              oldItem,
              newItem.copyWith(
                status: BoundStatus.success,
              ));
        }
      });
    }
    return error;
  }

  @override
  Future<String?> onItemRemove(item) async {
    if (!enableLocal) {
      return await super.onItemRemove(item);
    }
    if (!enableServer) {
      return serverController.onItemRemove(item.entity);
    }
    String? error = await super.onItemRemove(item);
    if (error == null && item.isSynced) {
      serverController.onItemRemove(item.entity).then((value) {
        if (value != null) {
          item.status = BoundStatus.failed;
          item.action = BoundAction.delete;
          addActionLog(item.copyWith(
              status: BoundStatus.failed,
              message: value,
              action: BoundAction.delete));
        }
      });
    }
    return error;
  }
}

mixin BoundSqlMixin<T extends IdSerializable>
    on SqlRichListController<BoundEntity<T>>, ServerRichListMixin<T> {
  late String actionTable = table + '_action';

  @override
  Future<bool> addActionLog(BoundEntity<IdSerializable> bound) async {
    Json value = bound.toJson();
    value.remove('id');
    var id = await db.insert(actionTable, value,
        conflictAlgorithm: ConflictAlgorithm.replace);
    logger.i("$runtimeType add $bound to action<$actionTable> ${id != 0}");
    return id != 0;
  }

  @override
  List<String> get defaultWhere => [
        "type = '${runtimeType.toString()}'",
        // "create_date = '${DateTime.now().YYmmdd}'",
        if (scope != null) "scope = '$scope'" else "scope is null"
      ];

  @override
  Future<List<BoundEntity<T>>> listLocalItems({bool unboundOnly: false}) async {
    if (!enableLocal) {
      return [];
    }
    if (unboundOnly) {
      return queryItems(
          where: defaultWhere + ["status!=${BoundStatus.success.index}"]);
    }
    return super.listLocalItems();
  }

  late String createCommand = """
    CREATE TABLE IF NOT EXISTS `{table}`(
      `id` INTEGER PRIMARY KEY AUTOINCREMENT,
      `server_id` int(11) DEFAULT NULL,
      `status` int(11) NOT NULL,
      `action` int(11) NOT NULL,
      `type` varchar(50) DEFAULT NULL,
      `message` varchar(200) DEFAULT NULL,
      `entity` json NOT NULL,
      `scope` varchar(50) DEFAULT NULL,
      `create_date` date NOT NULL DEFAULT CURRENT_DATE,
      unique(scope, server_id, action)
    )
    """;

  @override
  onCreated() async {
    if (enableLocal) {
      // await db.execute('drop table if exists $table');
      await db.execute(createCommand.replaceAll('{table}', table));
      await db.execute(createCommand.replaceAll('{table}', actionTable));
    } else {
      logger.w("$runtimeType local disabled, ignored create table");
    }
  }

  @override
  Future<String?> onItemsAdd(List<BoundEntity<T>> objects) async {
    if (objects.isEmpty) return null;
    var batch = db.batch();
    objects.forEach((e) async {
      // 注意， 一定不养带上id，否则会出现重复插入的问题
      batch.insert(table, e.toJson(exclude: ['id']),
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
    batch.commit(continueOnError: true).then((commitItems) {
      logger.d("write ${commitItems.length} $T items to Table<$table> success");
      objects.asMap().forEach((key, value) {
        value.id = commitItems[key] as int;
      });
      assert(objects.length == commitItems.length,
          "${objects.length} fetched but ${commitItems.length} committed");
      return null;
    });
  }
}

mixin LocalRichListMixin<T extends IdSerializable> on RichListController<T> {
  bool enableLocal = true;
  bool enableServer = true;
  String? get _scope => localController.scope;
  BoundLocalMixin<T> get localController;

  @override
  Future<void> onCreated() async {
    logger.i("local enabled: $enableLocal, server enabled: $enableServer");
    localController.autoRefresh = false;
    await localController.isItemsInitialized;
  }

  List<T> boundsToItems(List<BoundEntity<T>> bounds) {
    return bounds.map((e) => e.entity).toList();
  }

  List<BoundEntity<T>> itemsToBounds(List<T> items) {
    return items
        .map<BoundEntity<T>>((e) => BoundEntity<T>(
                entity: e,
                status: BoundStatus.success,
                action: BoundAction.list,
                type: localController.runtimeType.toString(),
                scope: _scope,
                serverId: e.id)
            // 这里将item.id置为服务端本地id, 必要的
            )
        .toList();
  }

  BoundEntity<T> findLocalBound(T item) {
    return localController.items.firstWhere((e) =>
        (e.entity == item) || (e.serverId == item.id || e.id == item.id));
  }

  @override
  Future<List<T>> loadInitItems() async {
    return boundsToItems(await localController.listItems());
  }

  @override
  Future<List<T>> listItems() async {
    if (!enableLocal) {
      // only server controller enabled;
      return await super.listItems();
    }
    if (!enableServer) {
      // only local controller enabled;
      return boundsToItems(
          await localController.listAddItems(justListUnbound: false));
    }
    // local and server are enabled;
    List<T> locals = [];
    if (page == initPage) {
      locals = boundsToItems(
          await localController.listAddItems(justListUnbound: true));
    }
    if (enableServer) {
      List<T> servers = await super.listItems();
      localController.addItems(itemsToBounds(servers));
      locals += servers;
    }
    return locals;
  }

  @override
  Future<List<T>> refreshItems() {
    localController.page = 1;
    localController.pageSize = pageSize;
    return super.refreshItems();
  }

  @override
  Future<List<T>> loadMoreItems() {
    localController.page = page;
    localController.pageSize = pageSize;
    return super.loadMoreItems();
  }

  @override
  Future<String?> onItemAdd(item) async {
    if (!enableLocal) {
      return await super.onItemAdd(item);
    }
    BoundEntity<T> bound = BoundEntity(
      entity: item,
      scope: _scope,
      type: localController.runtimeType.toString(),
      action: BoundAction.create,
      status: BoundStatus.none,
    );
    String? error = await localController.addItem(bound);
    if (enableServer) {
      super.onItemAdd(item).then((value) {
        if (value != null) {
          localController.addActionLog(bound.copyWith(
              status: BoundStatus.failed,
              message: value,
              action: BoundAction.create));
        } else {
          localController.updateItem(
              bound, bound.copyWith(status: BoundStatus.success));
        }
      });
    }
    return error;
  }

  @override
  Future<String?> onItemUpdate(int oldIndex, oldItem, newItem) async {
    if (!enableLocal) {
      return await super.onItemUpdate(oldIndex, oldItem, newItem);
    }
    BoundEntity<T> oldBound = findLocalBound(oldItem);
    BoundEntity<T> newBound = oldBound.copyWith(entity: newItem);
    String? error = await localController.updateItem(oldBound, newBound);
    if (enableServer && oldBound.status == BoundStatus.success) {
      super.onItemUpdate(oldIndex, oldItem, newItem).then((value) =>
          value != null
              ? localController.addActionLog(newBound.copyWith(
                  status: BoundStatus.failed,
                  message: value,
                  action: BoundAction.update))
              : null);
    }
    return error;
  }

  @override
  Future<String?> onItemRemove(item) async {
    if (!enableLocal) {
      return await super.onItemRemove(item);
    }
    BoundEntity<T> local = findLocalBound(item);
    String? error = await localController.removeItem(local);
    if (enableServer && local.status == BoundStatus.success) {
      super.onItemRemove(item).then((value) => value != null
          ? localController.addActionLog(local.copyWith(
              status: BoundStatus.failed,
              message: value,
              action: BoundAction.delete))
          : null);
    }
    return error;
  }
}

abstract class HttpSqlListController<T extends IdSerializable>
    extends HttpRichListController<T> with LocalRichListMixin<T> {
  @override
  BoundLocalSqlController<T> get localController;
}
