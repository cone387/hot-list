


import '../caches/cache_object.dart';


abstract class CacheStorer{

    init(){}

    Future<CachedObject> read(String key);
    Future<List<CachedObject>> readAll();

    Future write(CachedObject obj);
    
    clear();
}