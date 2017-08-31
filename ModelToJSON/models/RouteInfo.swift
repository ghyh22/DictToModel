//
//  RouteInfo.swift
//  ComponentDemo
//
//  Created by 龚浩 on 2017/8/11.
//  Copyright © 2017年 龚浩. All rights reserved.
//

import UIKit

class RouteInfo: NSObject {
    var name = ""
    var url = ""
    var cdnId = ""
    var videoId = ""
    var updateTime = ""
    var clearList:[ClearInfo] = []
    
    init(data:[String:Any], name:String) {
        self.name = name
        if let url = data["url"] as? String {
            self.url = url
        }
        if let cdnId = data["cdn_id"] as? String{
            self.cdnId = cdnId
        }
        if let vid = data["video_id"] as? String {
            self.cdnId = vid
        }
        if let updateTime = data["updatetime"] as? String{
            self.updateTime = updateTime
        }
        if let list = data["detail"] as? [[String:String]] {
            for tmp in list{
                let clear = ClearInfo(data: tmp, url: self.url)
                clearList.append(clear)
            }
        }
    }
    
    override var description: String{
        return "线路信息:name=\(name), url=\(url), cdnId=\(cdnId), videoId=\(videoId),updateTime=\(updateTime),clearList=\(clearList)\n"
    }
}
