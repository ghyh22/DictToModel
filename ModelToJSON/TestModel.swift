//
//  TestModel.swift
//  ModelToJSON
//
//  Created by 龚浩 on 2017/8/24.
//  Copyright © 2017年 龚浩. All rights reserved.
//

import UIKit

class BaseModel: GHKVCModel {
    var id = 0
    var name = "John"
}

class TestModel: BaseModel {
    //(constNum, nilInt, optionalInt, optionalFloat, optionalDouble, otherObjectToNumber, constStr, otherToStr, constBool, optionalBool, otherStrToBool, otherObjectToBool)
    //数值类型
    let constNum:NSNumber = 3
    var varInt = 0
    var varFloat:Float = 1.0
    var varDouble:Double = 2.0
    var nilInt:Int?
    var optionalInt:Int? = 0
    var optionalFloat:Float? = 1.0
    var optionalDouble:Double? = 2.0
    var optionalNum:NSNumber?
    var strToInt = 0
    var strToFloat = 2.0
    var strToDouble = 3.0
    var strToNumber:NSNumber = 4.0
    var otherObjectToNumber:NSNumber = 5
    var trueToNumber = 3
    var falseToNumber = 3
    var floatToInt = 3
    var intToFloat:Float = 4.0
    
    //字符串型
    let constStr = "gggg"
    var varStr = "hhhh"
    var optionalStr:String?
    var numberToStr:String?
    var falseToStr:String?
    var trueToStr:String?
    var otherToStr:String?
    var nsString:NSString?
    
    //布尔型
    let constBool = true
    var varBool = false
    var optionalBool:Bool?
    var numberToBool = false
    var zeroToBool = true
    var trueStrToBool = false
    var falseStrToBool = true
    var otherStrToBool = true
    var otherObjectToBool = true
    //数组型
    let constArray = [1, 2, 3]
    var varIntArray = [1, 2, 3, 4]
    var optionalIntArray:[Int]?
    var optionalNumberArray:[NSNumber]?
    var optionalFloatArray:[Float]?
    var optionalDoubleArray:[Double]?
    var intToDoubleArray:[Double]?
    var optionalUIntArray:[UInt]?
    var optionalInt8Array:[Int8]?
    var optionalStringArray:[String]?
    var optionalBoolArray:[Bool]?
    var optionalAnyArray:[Any]?
    var otherObjectArray:[StringModel]?
    var dictArray:[[String:Any]]?
    var dict:[String:Any]?
    var subModel:BoolModel?
    var stringModel:StringModel?
    
    var otherKeyName = 4
    
    override func subModelTypes<T>() -> [String : T.Type] where T : GHKVCModel {
        return ["otherObjectArray":StringModel.self, "subModel":BoolModel.self, "stringModel":BoolModel.self] as! [String : T.Type]
    }
    
    override func modelPropDictKeyMap() -> [String : String] {
        return ["otherKeyName":"other_key_name"]
    }
}

class NumberModel: BaseModel {
    //数值类型
    let constNum:NSNumber = 3
    var varInt = 0
    var varFloat:Float = 1.0
    var varDouble:Double = 2.0
    var nilInt:Int?
    var optionalInt:Int? = 0
    var optionalFloat:Float? = 1.0
    var optionalDouble:Double? = 2.0
    var optionalNum:NSNumber?
    var strToInt = 0
    var strToFloat = 2.0
    var strToDouble = 3.0
    var strToNumber:NSNumber = 4.0
    var otherObjectToNumber:NSNumber = 5
    var trueToNumber = 3
    var falseToNumber = 3
    var floatToInt = 3
    var intToFloat:Float = 4.0
}
class StringModel:BaseModel{
    //字符串型
    let constStr = "gggg"
    var varStr = "hhhh"
    var optionalStr:String?
    var numberToStr:String?
    var falseToStr:String?
    var trueToStr:String?
    var otherToStr:String?
    var nsString:NSString?
}

class BoolModel:BaseModel{
    //布尔型
    let constBool = true
    var varBool = false
    var optionalBool:Bool?
    var numberToBool = false
    var zeroToBool = true
    var trueStrToBool = false
    var falseStrToBool = true
    var otherStrToBool = true
    var otherObjectToBool = true
}

class ArrayModel: BaseModel {
    let constArray = [1, 2, 3]
    var varIntArray = [1, 2, 3, 4]
    var optionalIntArray:[Int]?
    var optionalNumberArray:[NSNumber]?
    var optionalFloatArray:[Float]?
    var optionalDoubleArray:[Double]?
    var intToDoubleArray:[Double]?
    var optionalUIntArray:[UInt]?
    var optionalInt8Array:[Int8]?
    var otherObjectArray:[StringModel]?
    var dictArray:[[String:Any]]?
    var dict:[String:Any]?
    var subModel:BoolModel?
    var stringModel:StringModel?
    
    override func subModelTypes<T>() -> [String : T.Type] where T : GHKVCModel {
        return ["otherObjectArray":StringModel.self, "subModel":BoolModel.self, "stringModel":BoolModel.self] as! [String : T.Type]
    }
}
