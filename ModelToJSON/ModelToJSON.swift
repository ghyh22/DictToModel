//
//  ModelToJSON.swift
//  ModelToJSON
//
//  Created by 龚浩 on 2017/8/24.
//  Copyright © 2017年 龚浩. All rights reserved.
//

import UIKit

class GHModelToJSON: NSObject {
    
    /// model转JSON
    ///
    /// - Parameters:
    ///   - model:
    ///   - surpportGHKVC: 是否支持GHKVCModel中的属性名称映射表(modelPropDictKeyMap),默认false不支持
    /// - Returns:
    static func handle(model:NSObject, surpportGHKVC:Bool = false)->String{
        let mtj = GHModelToJSON(model: model, surpportGHKVC: surpportGHKVC)
        return mtj.json
    }
    
    let model:NSObject
    var surpportGHKVC:Bool = false
    var json:String = ""
    init(model:NSObject, surpportGHKVC:Bool = false) {
        self.model = model
        self.surpportGHKVC = surpportGHKVC
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
                            var key = prop
                            if self.surpportGHKVC {
                                if let kvcModel = model as? GHKVCModel {
                                    if let tmp = kvcModel.modelPropDictKeyMap()[prop] {
                                        key = tmp
                                    }
                                }
                            }
                            dict[key] = value
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
    func toJSON(surpportGHKVC:Bool = false) -> String {
        return GHModelToJSON.handle(model: self, surpportGHKVC: surpportGHKVC)
    }
}
