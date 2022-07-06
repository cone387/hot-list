



class CachedObject{
    bool exists = false;
    String key = '';
    dynamic object;
    int ttl = 30;
    DateTime createTime = DateTime.now();

    CachedObject(String key, dynamic object, {this.ttl: 1}){
        this.object = object;
        this.key = key;
        exists = this.object != null;
    }

    bool get expired{
        return DateTime.now().difference(createTime).inSeconds > ttl;
    }
    
    @override
    String toString() {
        return "Cache<key=$key, createTime=$createTime, ttl=$ttl>";
    }

}
