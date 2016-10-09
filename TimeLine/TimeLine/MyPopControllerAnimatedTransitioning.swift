//
//  MyPopControllerAnimatedTransitioning.swift
//  TimeLine
//
//  Created by 蒋悦斌 on 16/6/23.
//  Copyright © 2016年 jyb. All rights reserved.
//

import UIKit

class MyPopControllerAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        //1.获取动画的源控制器和目标控制器
        if let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as? DetailViewController {
            if let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as? ViewController{
                if let container = transitionContext.containerView() {
                    //2.创建一个 Cell 中 imageView 的截图，并把 imageView 隐藏，造成使用户以为移动的就是 imageView 的假象
                    let snapshotView = fromVC.priceImage.snapshotViewAfterScreenUpdates(false)
                    snapshotView.frame = container.convertRect(fromVC.priceImage.frame, fromView: fromVC.view)
                    snapshotView.frame.origin.y += fromVC.priceView.frame.origin.y
                    
                    //3.设置目标控制器的位置，默认透明度设为1，在后面的动画中慢慢隐藏变为0
                    toVC.view.frame = transitionContext.finalFrameForViewController(toVC)
                    toVC.selectedCell.priceImage.hidden = true
                    
                    //4.都添加到 container 中。注意顺序不能错了
                    container.insertSubview(toVC.view, belowSubview: fromVC.view)
                    container.addSubview(snapshotView)
                    
                    UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                        snapshotView.frame = container.convertRect(toVC.selectedCell.priceImage.frame, fromView: toVC.selectedCell)
                        fromVC.view.alpha = 0
                    }) { (finish: Bool) -> Void in
                        toVC.selectedCell.priceImage.hidden = false
                        snapshotView.removeFromSuperview()
                        fromVC.priceImage.hidden = false
                        
                        //一定要记得动画完成后执行此方法，让系统管理 navigation
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                    }
                }
            }
        }
    }
}
