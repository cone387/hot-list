import 'package:hot_list/common/commont.dart';
import 'package:hot_list/common/controllers/base.dart';
import 'package:hot_list/common/controllers/bound.dart';
import 'package:hot_list/common/controllers/list.dart';
import 'package:hot_list/common/controllers/mixin.dart';
import 'package:hot_list/common/entities/bound.dart';

mixin LocalListMixin<T extends IdSerializable> on ListController<T> {
  bool enableLocal = true;
  bool enableServer = true;
  String? scope;

  ListController<BoundEntity<T>> get localController;

  List<BoundEntity<T>> objectsToLocal(List<T> objects);

  List<T> boundsToItems(List<BoundEntity<T>> bounds) {
    return bounds.map((e) => e.entity).toList();
  }

  BoundEntity<T> findLocalBound(T item) {
    return localController.items.firstWhere((e) => e.entity == item);
  }

  Future<List<T>> listUnboundItems();

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
      return boundsToItems(await localController.listItems());
    }
    // local and server are enabled;
    List<T> locals = await listUnboundItems();
    if (enableServer) {
      List<T> servers = await super.listItems();
      objectsToLocal(servers);
      locals += servers;
    }
    return locals;
  }
}

mixin LocalPagedListMixin<T extends IdSerializable>
    on PagedListController<T>, LocalListMixin<T> {
  PagedListController<BoundEntity<T>> get localController;

  @override
  Future<List<T>> listUnboundItems() async {
    if (page != initPage) {
      return [];
    }
    return boundsToItems(await localController.listItems());
  }

  @override
  Future<List<T>> refreshItems() {
    localController.page = page;
    localController.pageSize = pageSize;
    return super.refreshItems();
  }

  @override
  Future<List<T>> loadMoreItems() {
    localController.page = page;
    localController.pageSize = pageSize;
    return super.loadMoreItems();
  }
}

mixin LocalListAddMixin<T extends IdSerializable> on ListCreateController<T>
    implements LocalListMixin<T> {
  ListCreateController<BoundEntity<T>> get localController;

  @override
  Future<String?> onItemAdd(item) async {
    if (!enableLocal) {
      return await super.onItemAdd(item);
    }
    String? error = await localController.addItem(BoundEntity(
      entity: item,
      scope: scope,
      action: BoundAction.create,
      status: BoundStatus.none,
    ));
    if (enableServer) {
      super.onItemAdd(item).then((value) => null);
    }
    return error;
  }
}

mixin LocalListRemoveMixin<T extends IdSerializable>
    on ListCreateRemoveController<T> implements LocalListMixin<T> {
  ListCreateRemoveController<BoundEntity<T>> get localController;

  @override
  Future<String?> onItemRemove(item) async {
    if (!enableLocal) {
      return await super.onItemRemove(item);
    }
    BoundEntity<T> local = findLocalBound(item);
    String? error = await localController.removeItem(local);
    if (enableServer) {
      super.onItemRemove(item).then((value) => null);
    }
    return error;
  }
}

mixin LocalListUpdateMixin<T extends IdSerializable>
    on RichListController<T>, LocalListMixin<T> {
  RichListController<BoundEntity<T>> get localController;
  @override
  Future<String?> onItemUpdate(int oldIndex, oldItem, newItem) async {
    if (!enableLocal) {
      return await super.onItemUpdate(oldIndex, oldItem, newItem);
    }
    BoundEntity<T> oldBound = findLocalBound(oldItem);
    BoundEntity<T> newBound = oldBound.copyWith(entity: newItem);
    String? error = await localController.updateItem(oldBound, newBound);
    if (enableServer) {
      super.onItemUpdate(oldIndex, oldItem, newItem).then((value) => null);
    }
    return error;
  }
}

mixin LocalRichListMixin<T extends IdSerializable> on RichListController<T> {
  bool enableLocal = true;
  bool enableServer = true;
  String? scope;
  BoundLocalMixin<T> get localController;

  List<BoundEntity<T>> objectsToLocal(List<T> objects);

  List<T> boundsToItems(List<BoundEntity<T>> bounds) {
    return bounds.map((e) => e.entity).toList();
  }

  BoundEntity<T> findLocalBound(T item) {
    return localController.items.firstWhere((e) => e.entity == item);
  }

  Future<List<T>> listUnboundItems();

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
      return boundsToItems(await localController.listItems());
    }
    // local and server are enabled;
    List<T> locals = await listUnboundItems();
    if (enableServer) {
      List<T> servers = await super.listItems();
      objectsToLocal(servers);
      locals += servers;
    }
    return locals;
  }

  @override
  Future<List<T>> refreshItems() {
    localController.page = page;
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
    String? error = await localController.addItem(BoundEntity(
      entity: item,
      scope: scope,
      action: BoundAction.create,
      status: BoundStatus.none,
    ));
    if (enableServer) {
      super.onItemAdd(item).then((value) => null);
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
    if (enableServer) {
      super.onItemUpdate(oldIndex, oldItem, newItem).then((value) => null);
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
    if (enableServer) {
      super.onItemRemove(item).then((value) => null);
    }
    return error;
  }
}
