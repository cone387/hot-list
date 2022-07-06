// ignore_for_file: unused_field

class API {
  static String login = '/api/rest/v1/user/login/';
  static String logOut = "/api/rest/v1/user/logout/";

  // 用户信息
  static String profileUpdate = "/api/rest/v1/user/profile/";
  static String profileGet = "/api/rest/v1/user/profile/";

  static String settingUpdate = '/api/rest/v1/user/s/{name}/';

  // 用户订阅增删改查
  static String subscribeList = '/api/rest/v1/user/sub/';
  static String subscribeDelete = '/api/rest/v1/user/sub/{id}/';
  static String subscribeUpdate = '/api/rest/v1/user/sub/{id}/';
  static String subscribeCreate = '/api/rest/v1/user/sub/';

  static String browseRecordList = '/api/rest/v1/user/history/';
  static String browseRecordCreate = '/api/rest/v1/user/history/';
  static String browseRecordDelete = '/api/rest/v1/user/history/{id}/';

  // 订阅数据和订阅
  static String publicSubscribeList = '/api/rest/v1/sub/';
  static String publicSubscribeDetail = '/api/rest/v1/sub/{id}/data/';

  static String search = '/api/rest/v1/sub/search/';

  static String collectionList = '/api/rest/v1/user/collection/';
  static String collectionCreate = '/api/rest/v1/user/collection/';
  static String collectionDelete = '/api/rest/v1/user/collection/{id}/';

  static String userSubPath = '/api/rest/v1/user/sub/{id}/';
  static String subDataPath = '/api/rest/v1/sub/{id}/data/';
  static String categoryPath = '/api/rest/v1/sub/cate/';
  static String categorySubPath = '/api/rest/v1/sub/cate/{id}/';
}
