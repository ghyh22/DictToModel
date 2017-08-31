//
//  DictToModel.swift
//  ModelToJSON
//
//  Created by 龚浩 on 2017/8/25.
//  Copyright © 2017年 龚浩. All rights reserved.
//

import UIKit

/// 使用GHDictToModel需要继承本类
class GHKVCModel: NSObject {
    /// 子类必须实现的构造方法
    required override init() {
        super.init()
    }
    
    /**
     1. 含有的子model类型
     2. 如果属性数组也是model型数组，需要绑定数组的元素类型且必须是GHKVCModel的子类
     3. 如果在这声明的属性类型和定义的类型不一质时，该属性将不作处理
     */
    func subModelTypes<T:GHKVCModel>()->[String:T.Type] {
        return [:]
    }
    
    /// model对应字典的映射表，当model中属性名和字典中key名不一样时设置对应关系
    func modelPropDictKeyMap()->[String:String] {
        return [:]
    }
    
    private var _forUndefinedHandle:((String)->Void)?
    func setValue(value:Any, key:String, forUndefinedHandle:@escaping (String)->Void) {
        self._forUndefinedHandle = forUndefinedHandle
        super.setValue(value, forKey: key)
    }
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        self._forUndefinedHandle?(key)
        return
    }
    override func value(forUndefinedKey key: String) -> Any? {
        return nil
    }
}
/**
 * 使用DictToModel将字典转成model的条件:
 1. model以及model中包含的子model都必须继承NSObject类，并且统一使NSObject.init()构造函数(不能有参数)进行实例化;否则不会被KVC
 2. 目前有些基本类型的可选类型(Int?,Float?,Double?,Bool?等)属性,没法通过setValue的方式给属性赋值，所以统一规定:model中数值可选类型统一使用NSNumber?,不然会丢弃掉(即不作处理);不能使用Bool?可选类型,不然会被丢弃掉.建议不使用这些类型的可选类型.
 3. 不能对常量赋值，不然会丢弃掉.
 
 * 使用的目的:
 1. 防止一些简单的赋值时因类型不统一而产生崩溃;
 2. 防止访问空值产生崩溃;
 3. 会列出model与接口不同的地方的日志,方便查错
 */
class GHDictToModel: NSObject {
    
    static func kvcModel(dict:[String:Any], model:GHKVCModel){
        let dtm = GHDictToModel(dict: dict, model: model)
        dtm.handleModel()
    }
    
    let dict:[String:Any]
    let model:GHKVCModel
    init(dict:[String:Any], model:GHKVCModel){
        self.dict = dict
        self.model = model
        super.init()
    }
    
    var dictKeys:[String]!
    var removedKeys:[String]!
    func removeDictKey(key:String) {
        if let index = self.dictKeys.index(of: key) {
            self.dictKeys.remove(at: index)
            removedKeys.append(key)
        }
    }
    func restoreKey(prop:String) {
        var key = prop
        if let tmp = self.model.modelPropDictKeyMap()[prop] {
            key = tmp
        }
        if removedKeys.index(of: key) != nil {
            self.dictKeys.append(key)
        }
    }
    
    func handleModel() {
        self.dictKeys = dict.keys.map { (key) -> String in
            return key
        }
        self.removedKeys = []
        var mirror:Mirror? = Mirror(reflecting: model)
        while mirror != nil {
            if let list = mirror?.children {
                for item in list {
                    if let prop = item.label {
                        handlePropValue(prop: prop, value: item.value)
                    }
                }
            }
            mirror = mirror?.superclassMirror
        }
        if let index = unsettingProps.index(of: "_forUndefinedHandle") {
            unsettingProps.remove(at: index)
        }
        print("-----------------------------------------------------------------")
        print("\(type(of: model))中未处理的属性:", unsettingProps)
        print("\(type(of: model))对应的字典未处理的key:")
        for item in self.dictKeys {
            print(item, ":", self.dict[item] as Any)
        }
        print("-----------------------------------------------------------------\n")
    }
    /**
     1. 不处理属性是Int8,Int16,Int64,Float16,Float64等类型的数值型数组，目前支持UInt,Int,Float,Double,NSNumber等类型的数值型数组
    */
    func handlePropValue(prop:String, value:Any) {
        let mirror = Mirror(reflecting: value)
        if mirror.subjectType == Bool.self || mirror.subjectType == Optional<Bool>.self {
            handleBool(prop: prop, value: value as? Bool)
        }else if value as? NSNumber != nil || mirror.subjectType == NSNumber.self || mirror.subjectType == Optional<NSNumber>.self {
            handleNumber(prop: prop, value: value as? NSNumber)
        }else if mirror.subjectType == String.self || mirror.subjectType == Optional<String>.self || mirror.subjectType == NSString.self || mirror.subjectType == Optional<NSString>.self {
            handleString(prop: prop, value: value as? String)
        }else if let subType = model.subModelTypes()[prop] {
            if isOptionalArray(type: mirror.subjectType) || mirror.displayStyle == .collection {
                handleObjectArray(prop: prop, arrayType: subType)
            }else{
                handleSubModel(prop: prop, subType: subType)
            }
        }else if mirror.subjectType == Array<Int>.self || mirror.subjectType == Optional<Array<Int>>.self {
            handleIntArray(prop: prop)
        }else if mirror.subjectType == Array<UInt>.self || mirror.subjectType == Optional<Array<UInt>>.self {
            handleUIntArray(prop: prop)
        }else if mirror.subjectType == Array<Float>.self || mirror.subjectType == Optional<Array<Float>>.self {
            handleFloatArray(prop: prop)
        }else if mirror.subjectType == Array<Double>.self || mirror.subjectType == Optional<Array<Double>>.self {
            handleDoubleArray(prop: prop)
        }else if mirror.subjectType == Array<NSNumber>.self || mirror.subjectType == Optional<Array<NSNumber>>.self {
            handleNumberArray(prop: prop)
        }else if mirror.subjectType == [[String:Any]].self || mirror.subjectType == Optional<[[String:Any]]>.self {
            handleDictArray(prop: prop)
        }else if mirror.subjectType == [String:Any].self || mirror.subjectType == Optional<[String:Any]>.self {
            handleDict(prop: prop)
        }else{
            unsettingProps.append(prop)
        }
    }
    
    fileprivate var unsettingProps:[String] = []
    func forUndefinedKey(key:String) {
        unsettingProps.append(key)
        restoreKey(prop: key)
    }
    /**
     处理数值型属性：
     0. 如果属性为数值可选类型且不是(NSNumber?)时直接丢弃
     1. 字典和model对应的key和属性同为数值型时，直接赋值;
     2. 字典中key为字符串型时,如果能将字符串转为数值时，将转换的结果赋值给model属性;
     3. 字典中key为布尔型时，true对应为数值1,false对应为0
     4. 其它情况下不改变model属性的值
    */
    func handleNumber(prop:String, value:NSNumber?) {
        var key = prop
        if let tmp = model.modelPropDictKeyMap()[prop] {
            key = tmp
        }
        let dictValue = dict[key]
        if let num = dictValue as? NSNumber {
            self.removeDictKey(key: key)
            model.setValue(value: num, key: prop, forUndefinedHandle: forUndefinedKey(key:))
        }else if let num = (dictValue as? NSString)?.doubleValue {
            self.removeDictKey(key: key)
            model.setValue(value: num, key: prop, forUndefinedHandle: forUndefinedKey(key:))
        }else{
            unsettingProps.append(prop)
        }
    }
    /**
     处理字符串属性:
     1. 字典和model对应的key和属性同为字符串型时，直接赋值;
     2. 字典中key为Bool类型时，true转为字符串"true",false转为字符串"false"
     3. 字典中key为Number类型时，将数值转为字符串赋值
     4. 其它情况下不改变model属性的值
    */
    func handleString(prop:String, value:String?) {
        var key = prop
        if let tmp = model.modelPropDictKeyMap()[prop] {
            key = tmp
        }
        let dictValue = dict[key]
        if let str = dictValue as? String {
            self.removeDictKey(key: key)
            model.setValue(value: str, key: prop, forUndefinedHandle: forUndefinedKey(key:))
        }else if let b = dictValue as? Bool {
            self.removeDictKey(key: key)
            model.setValue(value: "\(b)", key: prop, forUndefinedHandle: forUndefinedKey(key:))
        }else if let number = dictValue as? NSNumber {
            self.removeDictKey(key: key)
            model.setValue(value: "\(number)", key: prop, forUndefinedHandle: forUndefinedKey(key:))
        }else{
            unsettingProps.append(prop)
        }
    }
    private var trueStrList = ["true", "True", "TRUE"]
    private var falseStrList = ["false", "False", "FALSE"]
    /**
     处理Bool属性:
     1. 属性是(Bool?)型会直接丢弃,不处理
     2. 字典和model对应的key和属性同为Bool型时，直接赋值;
     3. 字典中key值是数值类型时，将数值转化为Bool型，0是false,其它值为true
     4. 字典中key值是字符串类型时，判断字符串如果在trueStrList中时为true,如果在falseStrList中时为false,其它情况丢弃;(trueStrList和falseStrList可根据自己的需要进行修改)
     5. 其它情况下不改变model属性的值
    */
    func handleBool(prop:String, value:Bool?) {
        var key = prop
        if let tmp = model.modelPropDictKeyMap()[prop] {
            key = tmp
        }
        let dictValue = dict[key]
        if let b = dictValue as? Bool {
            self.removeDictKey(key: key)
            model.setValue(value: b, key: prop, forUndefinedHandle: forUndefinedKey(key:))
        }else if let number = dictValue as? NSNumber {
            self.removeDictKey(key: key)
            model.setValue(value: number.boolValue, key: prop, forUndefinedHandle: forUndefinedKey(key:))
        }else if let str = dictValue as? String {
            if trueStrList.index(of: str) != nil {
                self.removeDictKey(key: key)
                model.setValue(value: true, key: prop, forUndefinedHandle: forUndefinedKey(key:))
            }else if falseStrList.index(of: str) != nil {
                self.removeDictKey(key: key)
                model.setValue(value: false, key: prop, forUndefinedHandle: forUndefinedKey(key:))
            }else{
                unsettingProps.append(prop)
            }
        }else{
            unsettingProps.append(prop)
        }
    }
    /**
     处理Int型数组属性:
     1. 字典对应的key值也只能是数值型数组，否则被丢弃
     2. 浮点型数值会转化成整型
    */
    func handleIntArray(prop:String) {
        var key = prop
        if let tmp = model.modelPropDictKeyMap()[prop] {
            key = tmp
        }
        let dictValue = dict[key]
        if let keyValue = dictValue as? [NSNumber] {
            if keyValue.count > 0 {
                var intArr = [Int]()
                for item in keyValue {
                    intArr.append(Int(item))
                }
                self.removeDictKey(key: key)
                model.setValue(value: intArr, key: prop, forUndefinedHandle: forUndefinedKey(key:))
                return
            }
        }
        unsettingProps.append(prop)
    }
    /**
     处理UInt型数组属性:
     1. 字典对应的key值也只能是数值型数组，否则被丢弃
     2. 浮点型数值会转化成UInt整型
    */
    func handleUIntArray(prop:String) {
        var key = prop
        if let tmp = model.modelPropDictKeyMap()[prop] {
            key = tmp
        }
        let dictValue = dict[key]
        if let keyValue = dictValue as? [NSNumber] {
            if keyValue.count > 0 {
                var uintArr = [UInt]()
                for item in keyValue {
                    uintArr.append(UInt(item))
                }
                self.removeDictKey(key: key)
                model.setValue(value: uintArr, key: prop, forUndefinedHandle: forUndefinedKey(key:))
                return
            }
        }
        unsettingProps.append(prop)
    }
    /**
     处理float型数组属性:
     字典对应的key值也只能是数值型数组，否则被丢弃
    */
    func handleFloatArray(prop:String) {
        var key = prop
        if let tmp = model.modelPropDictKeyMap()[prop] {
            key = tmp
        }
        let dictValue = dict[key]
        if let keyValue = dictValue as? [NSNumber] {
            if keyValue.count > 0 {
                var floatArr = [Float]()
                for item in keyValue {
                    floatArr.append(Float(item))
                }
                self.removeDictKey(key: key)
                model.setValue(value: floatArr, key: prop, forUndefinedHandle: forUndefinedKey(key:))
                return
            }
        }
        unsettingProps.append(prop)
    }
    /**
     处理double型数组属性:
     字典对应的key值也只能是数值型数组，否则被丢弃
    */
    func handleDoubleArray(prop:String) {
        var key = prop
        if let tmp = model.modelPropDictKeyMap()[prop] {
            key = tmp
        }
        let dictValue = dict[key]
        if let keyValue = dictValue as? [NSNumber]{
            if keyValue.count > 0 {
                var doubleArr = [Double]()
                for item in keyValue {
                    doubleArr.append(Double(item))
                }
                self.removeDictKey(key: key)
                model.setValue(value: doubleArr, key: prop, forUndefinedHandle: forUndefinedKey(key:))
                return
            }
        }
        unsettingProps.append(prop)
    }
    /**
     处理NSNumber型数组属性:
     字典对应的key值也只能是数值型数组，否则被丢弃
     */
    func handleNumberArray(prop:String) {
        var key = prop
        if let tmp = model.modelPropDictKeyMap()[prop] {
            key = tmp
        }
        let dictValue = dict[key]
        if let keyValue = dictValue as? [NSNumber] {
            self.removeDictKey(key: key)
            model.setValue(value: keyValue, key: prop, forUndefinedHandle: forUndefinedKey(key:))
        }else{
            unsettingProps.append(prop)
        }
    }
    /**
     如果属性是字典型数组，并且key也是字典型数组，直接赋值
    */
    func handleDictArray(prop:String) {
        var key = prop
        if let tmp = model.modelPropDictKeyMap()[prop] {
            key = tmp
        }
        let dictValue = dict[key]
        if let keyValue = dictValue as? [[String:Any]] {
            self.removeDictKey(key: key)
            model.setValue(value: keyValue, key: prop, forUndefinedHandle: forUndefinedKey(key:))
        }else{
            unsettingProps.append(prop)
        }
    }
    /**
     处理对象类型Array属性:
     对象类型必须是GHKVCModel的子类
    */
    func handleObjectArray<T:GHKVCModel>(prop:String, arrayType:T.Type) {
        var key = prop
        if let tmp = model.modelPropDictKeyMap()[prop] {
            key = tmp
        }
        let dictValue = dict[key]
        if let keyValue = dictValue as? [[String:Any]] {
            if keyValue.count > 0 {
                var modelArray = [T]()
                for item in keyValue {
                    let tmpModel = arrayType.init()
                    let dtm = GHDictToModel(dict: item, model: tmpModel)
                    dtm.handleModel()
                    modelArray.append(tmpModel)
                }
                self.removeDictKey(key: key)
                model.setValue(value: modelArray, key: prop, forUndefinedHandle: forUndefinedKey(key:))
                return
            }
        }
        unsettingProps.append(prop)
    }
    /**
     统一只处理[String:Any]型字典,其它类型字典直接丢弃
    */
    func handleDict(prop:String) {
        var key = prop
        if let tmp = model.modelPropDictKeyMap()[prop] {
            key = tmp
        }
        let dictValue = dict[key]
        if let keyValue = dictValue as? [String:Any] {
            self.removeDictKey(key: key)
            model.setValue(value: keyValue, key: prop, forUndefinedHandle: forUndefinedKey(key:))
            return
        }
        unsettingProps.append(prop)
    }
    /**
     处理子model属性，对应的key值必须是[String:Any]类型，否则丢弃
    */
    func handleSubModel<T:GHKVCModel>(prop:String, subType:T.Type) {
        var key = prop
        if let tmp = model.modelPropDictKeyMap()[prop] {
            key = tmp
        }
        let dictValue = dict[key]
        if let keyValue = dictValue as? [String:Any] {
            let tmpModel = subType.init()
            GHDictToModel.kvcModel(dict: keyValue, model: tmpModel)
            self.removeDictKey(key: key)
            model.setValue(value: tmpModel, key: prop, forUndefinedHandle: forUndefinedKey(key:))
            return
        }
        unsettingProps.append(prop)
    }
    
    /// 判断类型是否为可选数组类型
    ///
    /// - Parameter type:
    /// - Returns:
    func isOptionalArray(type:Any.Type) -> Bool {
        let typeStr = "\(type)"
        return typeStr.contains("Optional<Array<")
    }
}
