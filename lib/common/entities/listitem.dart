import 'package:hot_list/common/commont.dart';

abstract class ListItemCreateEntity extends Serializable {
  String? error;
  bool isValid() => true;
}
