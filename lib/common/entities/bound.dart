import 'dart:convert';
import 'package:hot_list/common/commont.dart';

enum BoundStatus {
  success,
  failed,
  none,
}

enum BoundAction { list, create, update, delete }

class BoundEntity<T extends IdSerializable> extends IdSerializable {
  late T entity;
  int? serverId;
  String? message;
  DateTime? createDate;
  String? type;
  String? scope;
  // String? _fp;
  // String get fp => _fp ??= DateTime.now().millisecondsSinceEpoch.toString();
  BoundStatus _status = BoundStatus.none;
  BoundAction action = BoundAction.create;

  void Function(BoundStatus status)? onStatusChanged;

  BoundEntity({
    BoundStatus status: BoundStatus.none,
    int? serverId,
    this.action: BoundAction.create,
    this.message,
    this.type,
    this.createDate,
    this.scope,
    this.onStatusChanged,
    required this.entity,
  }) : _status = status;
  // serverId = (serverId ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000)) {
  // if (entity.id == 0) entity.id = this.serverId;
  // id = this.serverId;
  // }

  BoundEntity.fromJson(Json json, T Function(Json json) decoder) {
    id = json['id'];
    serverId = json['server_id'];
    message = json['message'];
    type = json['type'];
    createDate =
        DateTime.tryParse(json['create_date'] ?? DateTime.now().YYmmdd);
    _status = BoundStatus.values[json['status']];
    action = BoundAction.values[json['action']];
    // 不会直接使用服务端id，所以将本地id赋给entity
    entity = decoder(jsonDecode(json['entity']));
    entity.id = id;
  }

  toJson({List<String> exclude: const []}) {
    var json = {
      'id': id,
      'server_id': serverId,
      'message': message,
      'type': type,
      'scope': scope,
      'status': _status.index,
      'action': action.index,
      'entity': jsonEncode(entity.toJson()),
      'create_date': createDate?.YYmmdd ?? DateTime.now().YYmmdd
    };
    exclude.forEach((element) {
      json.remove(element);
    });
    return json;
  }

  BoundEntity<T> copyWith({
    T? entity,
    BoundStatus? status,
    int? serverId,
    BoundAction? action,
    String? message,
    String? type,
    DateTime? createDate,
    String? scope,
  }) {
    var o = BoundEntity(
      entity: entity ?? this.entity,
      status: status ?? this.status,
      serverId: serverId ?? this.serverId,
      action: action ?? this.action,
      message: message ?? this.message,
      type: type ?? this.type,
      scope: scope ?? this.scope,
      createDate: createDate ?? this.createDate,
    );
    o.id = id;
    return o;
  }

  BoundStatus get status => _status;

  set status(BoundStatus value) {
    if (value != _status) {
      _status = value;
      onStatusChanged?.call(value);
    }
  }

  @override
  String toString() {
    return "Bound(scope=$scope, type=$type, action=$action, status=$status, entity=$entity)";
  }

  bool get isSaved {
    return id > 0 || entity.id > 0;
  }

  bool get isSynced => status == BoundStatus.success;
}
