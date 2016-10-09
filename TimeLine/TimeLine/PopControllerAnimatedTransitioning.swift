//
//  PopControllerAnimatedTransitioning.swift
//  TimeLine
//
//  Created by 蒋悦斌 on 16/6/24.
//  Copyright © 2016年 jyb. All rights reserved.
//

import UIKit

class PopControllerAnimatedTransitioning: NSObject, CAAnimationDelegate, UIViewControllerAnimatedTransitioning {
    
    var transitionContext: UIViewControllerContextTransitioning!
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        //获取动画的源控制器和目标控制器
        if let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as? DetailViewController {
            if let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as? ViewController{
                let container = transitionContext.containerView()
                
                //设置目标控制器的位置
                toVC.view.frame = transitionContext.finalFrameForViewController(toVC)
                //添加到container中,注意顺序不能错了
                container.insertSubview(toVC.view, belowSubview: fromVC.view)
                //执行动画
                self.transitionContext = transitionContext
                
                showAnimation(fromVC.view)
            }
        }
    }
    
    enum AnimationType: UInt32 {
        case Fade = 1,//淡入淡出
        Push,//推挤
        Reveal,//揭开
        MoveIn,//覆盖
        Cube,//立方体
        SuckEffect,//吮吸
        OglFlip,//翻转
        RippleEffect,//波纹
        PageCurl,//翻页
        PageUnCurl,//反翻页
        CameraIrisHollowOpen,//开镜头
        CameraIrisHollowClose,//关镜头
        CurlDown,//下翻页
        CurlUp,//上翻页
        FlipFromLeft,//左翻转
        FlipFromRight//右翻转
    }

    func showAnimation(view: UIView){
        if let animationType = AnimationType(rawValue: arc4random() % 16){
            switch(animationType){
            case .Fade:
                self.transitionWithType(kCATransitionFade, forView: view)
            case .Push:
                self.transitionWithType(kCATransitionPush, forView: view)
            case .Reveal:
                self.transitionWithType(kCATransitionReveal, forView: view)
            case .MoveIn:
                self.transitionWithType(kCATransitionMoveIn, forView: view)
            case .Cube:
                self.transitionWithType("cube", forView: view)
            case .SuckEffect:
                self.transitionWithType("suckEffect", forView: view)
            case .OglFlip:
                self.transitionWithType("oglFlip", forView: view)
            case .RippleEffect:
                self.transitionWithType("rippleEffect", forView: view)
            case .PageCurl:
                self.transitionWithType("pageCurl", forView: view)
            case .PageUnCurl:
                self.transitionWithType("pageUnCurl", forView: view)
            case .CameraIrisHollowOpen:
                self.transitionWithType("cameraIrisHollowOpen", forView: view)
            case .CameraIrisHollowClose:
                self.transitionWithType("cameraIrisHollowClose", forView: view)
            case .CurlDown:
                self.animationWithView(view, withAnimationTransition: UIViewAnimationTransition.CurlDown)
            case .CurlUp:
                self.animationWithView(view, withAnimationTransition: UIViewAnimationTransition.CurlUp)
            case .FlipFromLeft:
                self.animationWithView(view, withAnimationTransition: UIViewAnimationTransition.FlipFromLeft)
            case .FlipFromRight:
                self.animationWithView(view, withAnimationTransition: UIViewAnimationTransition.FlipFromRight)
            }
        }
    }
    
    // MARK: CATransition动画实现
    func transitionWithType(type: String, forView view: UIView) {
        //创建CATransition对象
        let animation = CATransition()
        //设置运动时间
        animation.duration = transitionDuration(transitionContext)
        //设置运动type
        animation.type = type
        //设置子类
        let random = arc4random() % 4
        if random == 0 {
            animation.subtype = kCATransitionFromLeft
        } else if random == 1 {
            animation.subtype = kCATransitionFromBottom
        } else if random == 2 {
            animation.subtype = kCATransitionFromRight
        } else if random == 3 {
            animation.subtype = kCATransitionFromTop
        } else {
            animation.subtype = kCATransitionFromLeft
        }
        //设置运动速度
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.delegate = self
        view.layer.addAnimation(animation, forKey: "animation")
    }
    
    func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        //一定要记得动画完成后执行此方法，让系统管理 navigation
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
    }
    
    // MARK: UIView实现动画
    func animationWithView(view: UIView, withAnimationTransition transition: UIViewAnimationTransition) {
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            UIView.setAnimationTransition(transition, forView: view, cache: true)
        }) { (finish: Bool) -> Void in
            //一定要记得动画完成后执行此方法，让系统管理 navigation
            self.transitionContext.completeTransition(!self.transitionContext.transitionWasCancelled())
        }
    }
}
