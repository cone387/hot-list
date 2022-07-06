// ignore_for_file: library_private_types_in_public_api

import 'package:hot_list/common/entities/types.dart';
import 'package:hot_list/common/logger.dart';
import 'package:get/get.dart' hide Response, MultipartFile, FormData;

class ControllerTag {
  final Map<String, Object?> map;

  ControllerTag(this.map);

  @override
  String toString() {
    return map.entries.join(',');
  }
}

mixin BaseItemMixin<T> {
  T decoder(Json json);
}

Map<Type, Map<String, ListController>> _controllerMapping = {};

class _ListControllerPool {
  bool exists(Type controllerType) {
    return _controllerMapping.containsKey(controllerType);
  }

  T add<T extends ListController>(T controller, {Object? tag}) {
    Type type = controller.runtimeType;
    Map map = _controllerMapping[type] ??= {};
    map["$type->${tag ?? ''}"] = controller;
    return controller;
  }

  T addIfNotExists<T extends ListController>(T Function() builder,
      {Object? tag}) {
    String key = "$T->${tag ?? ''}";
    if (!_controllerMapping.containsKey(T) ||
        !_controllerMapping[T]!.containsKey(key)) {
      builder();
    }
    return _controllerMapping[T]![key] as T;
  }

  T? get<T extends ListController>({Object? tag}) {
    Map? map = _controllerMapping[T];
    T? o = map?["$T->${tag ?? ''}"];
    return o;
  }
}

abstract class ListController<T> extends GetxController with BaseItemMixin<T> {
  late RxList<T> items;
  RxInt refreshTimes = 0.obs;
  late Future<List<T>?> isItemsInitialized;
  bool isLoading = false;
  bool autoRefresh;
  Object? tag;

  ListController({
    this.autoRefresh = true,
    List<T>? initItems,
  }) : super() {
    ListControllerPool.add(this, tag: tag);
    logger.d("${runtimeType.toString()} created");
    items = (initItems ?? []).obs;
    isItemsInitialized = onCreated().then((value) {
      if (initItems != null) {
        return null;
      }
      return loadInitItems().then((value) {
        if (value != null && value.isNotEmpty) {
          // 使用items.value避免更新
          // ignore: invalid_use_of_protected_member
          items.value.addAll(value);
          onItemsInitialized();
          logger.d("$runtimeType items initialized");
        }
        if (autoRefresh) {
          refreshItems();
        }
        return value;
      });
    });
  }

  Future<void> onCreated() async {}

  void setItems(List<T> objects) {
    items.clear();
    items.addAll(objects);
  }

  void onItemsInitialized() => refresh();

  Future<List<T>?> loadInitItems() async => null;

  List<T> filterItems(bool Function(T item) filter) =>
      items.where(filter).toList();

  Future<List<T>> listItems();

  Future<List<T>> refreshItems() async {
    if (isLoading) {
      logger.d("$runtimeType is loading, ignored refresh");
      return [];
    }
    isLoading = true;
    refreshTimes += 1;
    logger.d("$runtimeType refreshTimes: $refreshTimes");
    List<T> objects = [];
    try {
      objects = await listItems();
    } catch (e) {
      logger.e("error on list items: $e");
    }
    setItems(objects);
    isLoading = false;
    return objects;
  }

  int onPositionChanged(T sourceItem, T targetItem) {
    int oldIndex = items.indexOf(sourceItem);
    int newIndex = items.indexOf(targetItem);
    items.removeAt(oldIndex);
    items.insert(newIndex, sourceItem);
    return newIndex;
  }
}

// ignore: non_constant_identifier_names
_ListControllerPool ListControllerPool = _ListControllerPool();
