
import '../storage/storage.dart';
import '../storage/file.dart';
import '../logger.dart';
import 'cache_object.dart';




class Cache{

    static Map<String, CachedObject> _mapping = {};
    static CacheStorer _cacheStorer = FileCacheStorer();
    static CachedObject emptyCacheObject = CachedObject('', null);

    static init() async{
        // DB.
        await _cacheStorer.init();
        // clear();
        List<CachedObject> cachedObjects = await _cacheStorer.readAll();
        cachedObjects.forEach((element) {
           _mapping[element.key] = element; 
        });
    }

    static setCache(CachedObject obj, {persistence: true}){
        // var obj = CachedObject(k, v);
        // 加入过期时间
        // 缓存中不存或者缓存中的obj已经过期
        // persistence: 是否持久化存储到本地
        if(!_mapping.containsKey(obj.key) || _mapping[obj.key]!.expired){
            _mapping[obj.key] = obj;
            if(persistence){
                _cacheStorer.write(obj);
            }
        }
        logger.i(_mapping[obj.key]);
        
    }

    static CachedObject getCache(k){
        var obj = _mapping[k];
        return obj != null && !obj.expired? obj: emptyCacheObject;
    }

    static clear(){
        _mapping.clear();
        _cacheStorer.clear();
    }

}