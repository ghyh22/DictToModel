//
//  ModelToJSON.swift
//  ModelToJSON
//
//  Created by 龚浩 on 2017/8/24.
//  Copyright © 2017年 龚浩. All rights reserved.
//

import UIKit

class GHModelToJSON: NSObject {
    
    static func handle(model:NSObject)->String{
        let mtj = GHModelToJSON(model: model)
        return mtj.json
    }
    
    let model:NSObject
    var json:String = ""
    init(model:NSObject) {
        self.model = model
        super.init()
        let dict = handleModel(model: model)
        do{
            let json = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            if let str = String(data: json, encoding: .utf8){
                self.json = str
            }
        }catch{
            print("JSON化失败")
        }
    }
    
    func handleModel(model:NSObject) -> [String:Any] {
        var dict = [String:Any]()
        var mirror:Mirror? = Mirror(reflecting: model)
        while mirror != nil {
            if let list = mirror?.children {
                for item in list {
                    if let prop = item.label {
                        if let value = handleValue(value: item.value) {
                            dict[prop] = value
                        }
                    }
                }
            }
            mirror = mirror?.superclassMirror
        }
        return dict
    }
    func handleValue(value:Any) -> Any? {
        if let number = value as? NSNumber {
            return number
        }else if let str = value as? String {
            return str
        }else if let b = value as? Bool {
            return b
        }else if let arr = value as? [Any] {
            return handleArray(arr: arr)
        }else if let dict = value as? [String:Any] {
            return handleDict(dict: dict)
        }else if let other = value as? NSObject {
            return handleModel(model: other)
        }
        return nil
    }
    func handleArray(arr:[Any]) -> [Any] {
        var jsonArr = [Any]()
        for item in arr {
            if let tmp = handleValue(value: item) {
                jsonArr.append(tmp)
            }
        }
        return jsonArr
    }
    func handleDict(dict:[String:Any]) -> [String:Any] {
        var jsonDict = [String:Any]()
        for (key, value) in dict {
            if let tmp = handleValue(value: value) {
                jsonDict[key] = tmp
            }
        }
        return jsonDict
    }
}

/// NSObject 扩展输出json串
extension NSObject{
    func toJSON() -> String {
        return GHModelToJSON.handle(model: self)
    }
}
