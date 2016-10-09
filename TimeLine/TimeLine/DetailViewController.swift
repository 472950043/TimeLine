//
//  DetailViewController.swift
//  Notes
//
//  Created by 蒋悦斌 on 16/6/15.
//  Copyright © 2016年 jyb. All rights reserved.
//

import UIKit

///操作协议
protocol DetailViewDelegate: NSObjectProtocol{
    ///CoreData插入
    func valueInsert(controller: DetailViewController)
    ///CoreData更新
    func valueUpdate(controller: DetailViewController)
}

class DetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    ///协议配置
    var delegate: DetailViewDelegate?
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var priceView: UIView!
    @IBOutlet weak var priceImage: UIImageView!
    var image: UIImage!
    @IBOutlet weak var priceName: UILabel!
    @IBOutlet weak var priceCount: UIButton!
    @IBOutlet weak var calculateView: UIView!
    @IBOutlet var lineHeight: NSLayoutConstraint!
    @IBOutlet var calculateBottom: NSLayoutConstraint!
    @IBOutlet var collectionBottom: NSLayoutConstraint!
    
    ///初始化数据
    var cid = 0//账目id
    var cname = "工资"//账目抬头名称
    var number = ""//账目临时数额
    var cprice: Double = 0//账目总额
    var modify = false
    
    //账目名称列表
    var items = ["工资", "一般", "就餐", "零食", "充值", "购物", "娱乐", "住房", "日杂", "鞋帽", "护肤", "丽人", "转账", "腐败",
                 "运动", "医疗", "学习", "香烟", "酒水", "数码", "家庭", "宠物", "服装", "日用品", "宝贝", "信用卡", "投资", "工资"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        lineHeight.constant = 0.5
        setupButton(calculateView)
        self.automaticallyAdjustsScrollViewInsets = false
        collectionView.registerNib(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SnapshotViewAnimationStop), name: "SnapshotViewAnimationStop", object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    ///递归简单实现边框分割效果
    func setupButton(superViews: UIView){
        for view in superViews.subviews {
            if let button = view as? UIButton {
                button.layer.borderColor = UIColor.whiteColor().CGColor
                button.layer.borderWidth = 0.25
            } else if view.subviews.count > 0 {
                setupButton(view)
            }
        }
    }
    
    ///小键盘点击事件
    @IBAction func btnClick(sender: UIButton) {
        if let title = sender.titleLabel?.text {
            if modify && title != "+" {
                cprice = 0
                modify = false
            }
            switch title {
            case "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", ".":
                if number.characters.count == 1 && number.characters.first == "0" && title != "." {
                    //去除前面的0
                    deleteCharacter()
                }
                number += title
                let str = number.componentsSeparatedByString(".")
                if str.count == 1 {
                    if number.characters.count > 7 {
                        //只允许7位数
                        deleteCharacter()
                    }
                } else if str.count > 1 {
                    if str.last?.characters.count > 2 {
                        //只允许小数点后两位
                        deleteCharacter()
                    }
                } else if str.count > 2 {
                    //只允许一个小数点
                    deleteCharacter()
                }
                refreshPriceCount()
            case "+":
                calculation()
            case "del":
                deleteCharacter()
                refreshPriceCount()
            case "C":
                number = ""
                cprice = 0
                refreshPriceCount()
            default:
                calculation()
                saveValue()
            }
        }
    }
    
    ///删除一个字符
    func deleteCharacter() {
        if number.characters.count > 1 {
            number = number.substringToIndex(number.endIndex.advancedBy(-1))
        } else {
            number = ""
        }
    }
    
    ///计算结果
    func calculation() {
        if let num = Double(number) {
            cprice += num
            number = String(format: "%.2lf", cprice)
            refreshPriceCount()
        }
        number = ""
    }
    
    ///刷新显示价格
    func refreshPriceCount(){
        if let num = Double(number) {
            priceCount.setTitle(String(format: "¥ %.2lf", num), forState: UIControlState.Normal)
        } else {
            priceCount.setTitle( "¥ 0.00", forState: UIControlState.Normal)
        }
    }
    
    ///保存结果
    func saveValue() {
        if title == "新建" {
            //CoreData插入
            delegate?.valueInsert(self)
        } else if title == "编辑" {
            //CoreData更新
            delegate?.valueUpdate(self)
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    ///编辑属性
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    ///配置编辑属性
    func configureView() {
        // Update the user interface for the detail item.
        if let cid = self.detailItem?.valueForKey("cid") as? Int {
            if let cname = self.detailItem?.valueForKey("cname") as? String {
                self.setupType(cid, name: cname)
            }
        }
        if let cprice = self.detailItem?.valueForKey("cprice") as? Double {
            if let pri = self.priceCount {
                self.cprice = cprice
                modify = true
                pri.setTitle(String(format: "¥ %.2lf", cprice), forState: UIControlState.Normal)
            }
        }
    }
    
    ///保存选中的账目，并显示
    func setupType(id: Int, name: String){
        cid = id
        cname = name
        if let img = self.priceImage {
            img.image = UIImage(named: "type_big_\(cid)")
        }
        if let label = self.priceName {
            label.text = cname
        }
    }
    
    // MARK: - UICollectionViewDataSource
    //定义展示的UICollectionViewCell的个数
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    //每个UICollectionView展示的内容
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as! CollectionViewCell
        cell.name.text = items[indexPath.row]
        cell.logo.image = UIImage(named: "type_big_\(indexPath.row)")
        return cell
    }
    
    //定义展示的Section的个数
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int{
        return 1
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    //定义每个UICollectionView 的大小
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = UIScreen.mainScreen().bounds.size.width / 4
        return CGSizeMake(width, width)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(20, 0, 0, 0)
    }
    
    // MARK: - UICollectionViewDelegate
    //UICollectionView被选中时调用的方法
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        cid = indexPath.row
        cname = items[indexPath.row]
        let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionViewCell
        animateAdd(selectedCell)
    }

    func animateAdd(selectedCell: CollectionViewCell) {
        //使用关键帧动画，移动路径为预定的贝塞尔曲线路径
        let fromPoint = self.view.convertPoint(selectedCell.logo.center, fromView: selectedCell)
        let toPoint = self.view.convertPoint(priceImage.center, fromView: priceView)
        let controlPoint = CGPointMake(fromPoint.x - 20, fromPoint.y - 100)
        let path = UIBezierPath()
        path.moveToPoint(fromPoint)
        path.addQuadCurveToPoint(toPoint, controlPoint: controlPoint)
        
        let positionAnimation = CAKeyframeAnimation(keyPath: "position")
        positionAnimation.path = path.CGPath
        
        let transformAnimation = CABasicAnimation(keyPath: "transform")
        transformAnimation.fromValue = NSValue(CATransform3D: CATransform3DIdentity)
        transformAnimation.toValue = NSValue(CATransform3D: CATransform3DMakeScale(priceImage.frame.width / selectedCell.logo.frame.width, priceImage.frame.height / selectedCell.logo.frame.height, 1))

        let delegate = SnapshotViewDelegate()
        delegate.cid = cid
        delegate.cname = cname
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [positionAnimation, transformAnimation]
        animationGroup.duration = 1
        animationGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        animationGroup.delegate = delegate
        animationGroup.removedOnCompletion = false
        
        
        if let snapshotView = selectedCell.logo.snapshotViewAfterScreenUpdates(false) {
            snapshotView.frame = selectedCell.logo.bounds
            snapshotView.center = fromPoint
            delegate.snapshotView = snapshotView
            
            self.view.layer.addSublayer(snapshotView.layer)
            snapshotView.layer.addAnimation(animationGroup, forKey: nil)
        }
    }
    
    func SnapshotViewAnimationStop(notification: NSNotification) {
        if let cid = notification.userInfo?["cid"] as? Int {
            if let cname = notification.userInfo?["cname"] as? String {
                setupType(cid, name: cname)
            }
        }
    }
    
    var offsetY: CGFloat = 0//记录上次的拖拽位置

    // MARK: - UIScrollViewDelegate
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        //记录上次的拖拽位置
        offsetY = scrollView.contentOffset.y
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView){
        calculateFinalAnimation()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            calculateFinalAnimation()
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        calculateFinalAnimation()
    }
    
    //执行动画，判断计算器是显示还是隐藏
    func calculateFinalAnimation() {
        if offsetY > collectionView.contentOffset.y {
            showCalculate("")
        } else {
            UIView.animateWithDuration(0.5, animations: {
                self.priceView.frame.origin.y = self.collectionView.bounds.height
                self.calculateView.frame.origin.y = self.priceView.frame.origin.y + self.priceView.frame.height
            }) { (Bool) in
                self.calculateBottom.constant = -self.calculateView.frame.height
            }
        }
    }
    
    @IBAction func showCalculate(sender: AnyObject) {
        UIView.animateWithDuration(0.5, animations: {
            self.priceView.frame.origin.y = self.collectionView.bounds.height - self.calculateView.frame.height
            self.calculateView.frame.origin.y = self.priceView.frame.origin.y + self.priceView.frame.height
        }) { (Bool) in
            self.calculateBottom.constant = 0
        }
    }
    
}

