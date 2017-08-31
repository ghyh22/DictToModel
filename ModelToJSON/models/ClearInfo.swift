//
//  ClearInfo.swift
//  ComponentDemo
//
//  Created by 龚浩 on 2017/8/11.
//  Copyright © 2017年 龚浩. All rights reserved.
//

import UIKit

/// 清晰度信息
class ClearInfo: NSObject {
    /// 清晰度名称
    var name = ""
    /// 域网址
    var url = ""
    /// 流连接
    var stream = ""
    /// 连接参数
    var keyName = ""
    var keyValue = ""
    
    /// 生成视频播放连接
    var path:String{
        return "\(url)\(stream)?\(keyName)=\(keyValue)"
    }
    
    init(data:[String:String], url:String) {
        self.url = url
        if let name = data["name"]{
            self.name = name
        }
        if let stream = data["stream"]{
            self.stream = stream
        }
        if let keyName = data["key_name"]{
            self.keyName = keyName
        }
        if let keyValue = data["key_value"]{
            self.keyValue = keyValue
        }
    }
    
    override var description: String{
        return "清晰度信息name=\(name), url=\(url), stream=\(stream), keyName=\(keyName), keyValue=\(keyValue), path=\(path)\n"
    }
}
