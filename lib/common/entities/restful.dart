

import 'types.dart';



abstract class RestfulEntity<T>{
    late int id;

    T fromJson(Json json);

}


