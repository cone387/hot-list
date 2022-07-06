import 'dart:convert';
import 'package:dio/dio.dart' show MultipartFile;
import 'package:hot_list/common/entities/types.dart';
import 'package:hot_list/common/utils/media.dart';

bool isSameListValue(List source, List target) {
  bool isSame = source.length == target.length;
  if (isSame) {
    for (var element in source.asMap().entries) {
      var sourceValue = element.value;
      var targetValue = target[element.key];
      if (sourceValue is Map) {
        sourceValue as Json;
        isSame = getUpdatedJson(sourceValue, targetValue).isEmpty;
      } else if (sourceValue is List) {
        isSame = isSameListValue(sourceValue, targetValue);
      } else {
        isSame = sourceValue == targetValue;
      }
      if (!isSame) {
        break;
      }
    }
  }
  return isSame;
}

Json getUpdatedJson(Json source, Json target, {Json? extra}) {
  Json updated = {};
  source.forEach((key, value) {
    var targetValue = target[key];
    if (value is Map) {
      value as Json;
      if (jsonEncode(value) != jsonEncode(targetValue)) {
        updated[key] = targetValue;
      }
    } else if (value is List && targetValue is List) {
      if (!isSameListValue(value, targetValue)) updated[key] = targetValue;
    } else if (target.containsKey(key) && target[key] != value) {
      updated[key] = target[key];
    }
  });
  if (updated.isNotEmpty && extra != null) {
    updated.addAll(extra);
  }
  return updated;
}

Json updateJson(Json sourceJson, Json targetJson) {
  sourceJson.forEach((key, value) {
    var targetValue = targetJson[key];
    if (value is Map) {
      value as Json;
      // Json result = getUpdatedJson(value, targetValue);
      if (jsonEncode(value) != jsonEncode(targetValue)) {
        sourceJson[key] = targetValue;
      }
    } else if (value is List && targetValue is List) {
      if (!isSameListValue(value, targetValue)) sourceJson[key] = targetValue;
    } else if (targetJson.containsKey(key) && targetValue != value) {
      sourceJson[key] = targetValue;
    }
  });
  return sourceJson;
}

Json getFormJson(Json json) {
  json.forEach((key, value) {
    if (value is Map) {
      json[key] = jsonEncode(value);
    } else if (value is List) {
      if (value.isNotEmpty && !(value[0] is MultipartFile)) {
        json[key] = jsonEncode(value);
      }
    }
  });
  return json;
}

List<String> getJsonMedias(json,
    {List<String> keys = const ['image', 'video'], List<String>? medias}) {
  List<String> uris = medias ?? [];
  if (json is Map) {
    json.forEach((key, value) {
      if (value is Map || value is List) {
        getJsonMedias(value, keys: keys, medias: uris);
      } else if (keys.contains(key) && isLocalMedia(value)) {
        uris.add(value);
      }
    });
  } else if (json is List) {
    json.forEach((element) {
      if (element is Map || element is List) {
        getJsonMedias(element, keys: keys, medias: uris);
      }
    });
  }
  return uris;
}

List<String> getDeltaMedias(
  List<dynamic> delta, {
  List<String> keys = const ['image', 'video'],
  List<String>? medias,
}) {
  return getJsonMedias(delta, keys: keys, medias: medias);
}

bool isFormData(Json json) {
  for (var item in json.values) {
    if (item is MultipartFile) {
      return true;
    } else if (item is List) {
      if (item.isNotEmpty && item[0] is MultipartFile) {
        return true;
      }
    }
  }
  return false;
}
