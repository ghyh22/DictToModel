//
//  ViewController.swift
//  ModelToJSON
//
//  Created by 龚浩 on 2017/8/24.
//  Copyright © 2017年 龚浩. All rights reserved.
//
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let dict:[String:Any] = ["name":"GH", "id":1, "constNum":30, "varInt":10, "varFloat":10.0, "varDouble":20.0, "nilInt":10, "optionalInt":10, "optionalFloat":10.0, "optionalDouble":20.0, "optionalNum":33,"strToInt":"20.3", "strToFloat":"30.33", "strToDouble":"55.55", "strToNumber":"66.09", "otherObjectToNumber":["33"], "trueToNumber":true, "falseToNumber":false, "floatToInt":55.66, "intToFloat":44,
            "constStr":"ooo", "varStr":"ooo", "optionalStr":"ooo","numberToStr":33.44, "falseToStr":false, "trueToStr":true, "otherToStr":["number":44],"nsString":"NSString",
            "constBool":false, "varBool":true, "optionalBool":true, "numberToBool":4.4, "zeroToBool":0, "trueStrToBool":"true","falseStrToBool":"false", "otherStrToBool": "123","otherObjectToBool":["gii"],
            "constArray":[11, 22, 33], "varIntArray":[11, 22], "optionalIntArray":[11, 22, 33], "optionalNumberArray":[11.3, 11], "optionalFloatArray": [11.2, 11.2], "optionalDoubleArray":[33.3, 34],"intToDoubleArray":[11, 11, 22], "optionalUIntArray":[-11,22,33], "optionalInt8Array":[33.3, 44.4],"optionalStringArray":["", "eeee", "nnnn", "xxxx"],"optionalAnyArray":[",,,", 1, [1,"2",3], ["f":4], true, true, false, false],"optionalBoolArray":[false, false, true],
            "otherObjectArray":[["constStr":"ooo", "varStr":"ooo", "optionalStr":"ooo","numberToStr":33.44, "falseToStr":false, "trueToStr":true, "otherToStr":["number":44], "nsString":"NSString",], ["constStr":"ooo", "varStr":"ooo", "optionalStr":"ooo","numberToStr":33.44, "falseToStr":false, "trueToStr":true, "otherToStr":["number":44], "nsString":"NSString",]],
            "dictArray":[["name":"aaa", "id:":3], ["name":"bbb", "age":30]],
            "dict":["name":"gggg", "id": 123, "ie": false],
            "subModel":["constBool":false, "varBool":true, "optionalBool":true, "numberToBool":4.4, "zeroToBool":0, "trueStrToBool":"true","falseStrToBool":"false", "otherStrToBool": "123","otherObjectToBool":["gii"]],
            "other_key_name": "400.0",
            "anyInt":33, "anyString":"any string", "anyBool":true, "anyDict":["key":123, "fff":false], "anyModel":["123"]
        ]
        let kvcModel = TestModel()
//        GHDictToModel.kvcModel(dict: dict, model: kvcModel)
        kvcModel.dictToModel(dict: dict)
        print(kvcModel.toJSON())
        
//        testArrayModel()
//        let model = ArrayModel()
    }

    func testModelToJSON() {
//        let model = TestModel(data: ["name":"GH", "age":30])
//        let model:[String:Any] = ["name":"GH", "age":30]
        let model:[Any] = [1, ["name":"GH", "age":30], "GH", false]
        do{
           let json = try JSONSerialization.data(withJSONObject: model, options: .prettyPrinted)
            print(String(data: json, encoding: .utf8)!)
        }catch{
            print("生成json失败!")
        }
    }
    
    func numberKVCTest() {
        let numDict = ["constNum":30, "varInt":10, "varFloat":10.0, "varDouble":20.0, "nilInt":10, "optionalInt":10, "optionalFloat":10.0, "optionalDouble":20.0, "optionalNum":33, "strToInt":"20.3", "strToFloat":"30.33", "strToDouble":"55.55", "strToNumber":"66.09", "otherObjectToNumber":["33"], "trueToNumber":true, "falseToNumber":false, "floatToInt":55.66, "intToFloat":44] as [String : Any]
        let kvcModel = NumberModel()
        GHDictToModel.kvcModel(dict: numDict, model: kvcModel)
        print(kvcModel.toJSON())
    }
    
    func strKVCTest() {
        let strDict:[String:Any] = ["constStr":"ooo", "varStr":"ooo", "optionalStr":"ooo","numberToStr":33.44, "falseToStr":false, "trueToStr":true, "otherToStr":["number":44], "nsString":"NSString",]
        let kvcModel = StringModel()
        GHDictToModel.kvcModel(dict: strDict, model: kvcModel)
        print(kvcModel.toJSON())
    }
    
    func boolKVCTest() {
        let boolDict:[String:Any] = ["constBool":false, "varBool":true, "optionalBool":true, "numberToBool":4.4, "zeroToBool":0, "trueStrToBool":"true","falseStrToBool":"false", "otherStrToBool": "123","otherObjectToBool":["gii"]]
        let kvcModel = BoolModel()
        let dtm = GHDictToModel(dict: boolDict, model: kvcModel)
        dtm.handleModel()
        print(kvcModel.toJSON())
    }
    
    func testArrayModel() {
        let arrayDict = ["constArray":[11, 22, 33], "varIntArray":[11, 22], "optionalIntArray":[11, 22, 33], "optionalNumberArray":[11.3, 11], "optionalFloatArray": [11.2, 11.2], "optionalDoubleArray":[33.3, 34],"intToDoubleArray":[11, 11, 22], "optionalUIntArray":[-11,22,33], "optionalInt8Array":[33.3, 44.4],
            "otherObjectArray":[["constStr":"ooo", "varStr":"ooo", "optionalStr":"ooo","numberToStr":33.44, "falseToStr":false, "trueToStr":true, "otherToStr":["number":44], "nsString":"NSString",], ["constStr":"ooo", "varStr":"ooo", "optionalStr":"ooo","numberToStr":33.44, "falseToStr":false, "trueToStr":true, "otherToStr":["number":44], "nsString":"NSString",]],
            "dictArray":[["name":"aaa", "id:":3], ["name":"bbb", "age":30]],
            "dict":["name":"gggg", "id": 123, "ie": false],
            "subModel":["constBool":false, "varBool":true, "optionalBool":true, "numberToBool":4.4, "zeroToBool":0, "trueStrToBool":"true","falseStrToBool":"false", "otherStrToBool": "123","otherObjectToBool":["gii"]]] as [String : Any]
        let kvcModel = ArrayModel()
        let dtm = GHDictToModel(dict: arrayDict, model: kvcModel)
        dtm.handleModel()
        print(kvcModel.toJSON())
    }
}

