import 'package:hot_list/common/commont.dart';

abstract class Identifiable implements Comparable {
  late int id = 0;

  @override
  int compareTo(other) {
    if (other is Identifiable) {
      return id.compareTo(other.id);
    }
    throw UnimplementedError("unknown type ${other.runtimeType}");
  }
}

abstract class BaseItem extends Identifiable {}

abstract class IdSerializable extends Identifiable implements Serializable {}

abstract class BaseCacheableItem extends BaseItem implements Serializable {
  BaseCacheableItem();

  // Json toJson() => rawData;

  late Json rawData;

  BaseCacheableItem.fromJson(Json json) {
    rawData = json;
  }
}
