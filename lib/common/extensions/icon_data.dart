

import 'package:flutter/material.dart';

extension IconDataEx on IconData{
    static IconData fromJson(json){
        return IconData(json['codePoint'], fontFamily: json['fontFamily'], fontPackage: json['fontPackage']);
        
    }

    Map<String, dynamic> toJson(){
        return {
            "codePoint": codePoint,
            "fontFamily": fontFamily,
            "fontPackage": fontPackage
        };
    }

}
