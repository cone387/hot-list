import 'package:hot_list/common/commont.dart';
export 'package:dio/src/form_data.dart';

abstract class FormEntity<T extends Identifiable> {
  T? entity;
  String? error;
  // Json updatedData = {};
  Json createdData = {};

  FormEntity({this.entity}) {
    if (entity != null) {
      loadEntity(entity!);
    }
  }

  loadEntity(T entity);

  bool get isCreateForm {
    return entity == null;
  }

  dynamic get createData;
  dynamic get editData;

  int get id => entity != null ? entity!.id : throw UnsupportedError;

  bool isValid() => true;
  bool haveUpdate() => true;
}

abstract class BaseItemForm<T extends IdSerializable> extends FormEntity<T> {
  BaseItemForm({T? entity}) : super(entity: entity);
}
