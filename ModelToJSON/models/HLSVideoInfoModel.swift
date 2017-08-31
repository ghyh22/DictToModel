//
//  HLSVideoInfoModel.swift
//  ComponentDemo
//
//  Created by 龚浩 on 2017/8/11.
//  Copyright © 2017年 龚浩. All rights reserved.
//

import UIKit

/// HLS流视频信息
class HLSVideoInfoModel: NSObject {
    var routeList:[RouteInfo] = []
    var defaultRoute = 0
    
    init(data:[String:Any]) {
        if let list = data["cdn_hls"] as? [[String:Any]] {
            for (n,tmp) in list.enumerated() {
                let name = tmp["name"] as? String ?? ""
                let dr = tmp["default"] as? Int ?? 0
                if dr == 1 {
                    defaultRoute = n
                }
                if let key = tmp["hls"] as? String {
                    if let hlsData = data[key] as? [String:Any] {
                        let route = RouteInfo(data: hlsData, name: name)
                        routeList.append(route)
                    }
                }
            }
        }
    }
    
    override var description: String{
        return "HLS流视频信息defaultRoute=\(defaultRoute),rounteList=\(routeList)\n"
    }
}
