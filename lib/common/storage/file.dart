
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../logger.dart';
import './storer.dart';
import '../caches/cache.dart';
import '../caches/cache_object.dart';


class FileCacheStorer extends CacheStorer{
    late Directory tempPath;
    late Directory fileCachePath;
    

    init() async{
        tempPath = await getTemporaryDirectory();
        fileCachePath = Directory('${tempPath.path}/fileCaches/');
        if(!fileCachePath.existsSync()){
            fileCachePath.createSync(recursive: true);
        }
    }

    @override
    Future<CachedObject> read(String path) async{
        File file = File(path);
        try{
            String content = await file.readAsString();
            return CachedObject(path.split('/').last, jsonDecode(content));
        }catch(e){
            logger.e(e);
            return Cache.emptyCacheObject;
        }
        
    }

    @override
    Future<List<CachedObject>> readAll() async{
        Stream<FileSystemEntity> fileList = fileCachePath.list();
        List<CachedObject> objects = [];
        await for(FileSystemEntity entity in fileList){
            if(entity is File){
                objects.add(await read(entity.path));
            }
        }
        return objects;
    }

    @override
    Future write(CachedObject obj) {
        String? content;
        try{
            content = jsonEncode(obj.object);
        }catch(e){
            logger.e(e);
        }
        if(content != null){
            File file = new File('${fileCachePath.path}${obj.key}');
            if(!file.existsSync()) {
                file.createSync();
            }
            logger.i("write cache to ${file.path}");
            return file.writeAsString(content);
        }
        return Future.value(null);
    }

    @override
    clear() async{
        Stream<FileSystemEntity> fileList = fileCachePath.list();
        await for(FileSystemEntity entity in fileList){
            entity.delete();
        }
    }


}


// 
// 
// 1. 新疆财经大学
// 2. 内蒙古农大 内内蒙古财经
// 3. 浙江大学城市学院


// 安徽工程
// 安徽理工
// 安徽农业大学


// 4. 南京信息工程大学滨江学院
// 