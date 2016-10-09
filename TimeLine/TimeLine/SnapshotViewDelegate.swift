//
//  SnapshotViewDelegate.swift
//  TimeLine
//
//  Created by 蒋悦斌 on 16/6/24.
//  Copyright © 2016年 jyb. All rights reserved.
//

import UIKit

class SnapshotViewDelegate: NSObject, CAAnimationDelegate {
    
    var cid = 0//账目id
    var cname = "工资"//账目抬头名称
    var snapshotView: UIView?
    
    func animationDidStart(anim: CAAnimation) {
    }
    
    func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        snapshotView?.hidden = true
        NSNotificationCenter.defaultCenter().postNotificationName("SnapshotViewAnimationStop", object: self, userInfo: ["cid" : cid, "cname" : cname])
    }
}
