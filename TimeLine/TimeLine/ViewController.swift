//
//  ViewController.swift
//  TimeLine
//
//  Created by 蒋悦斌 on 16/6/21.
//  Copyright © 2016年 jyb. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, NSFetchedResultsControllerDelegate,  DetailViewDelegate {

    //基础控件
    @IBOutlet var addBtn: UIButton!
    @IBOutlet var income: UILabel!
    @IBOutlet var outcome: UILabel!
    @IBOutlet var tableView: UITableView!
    var selectedCell: TableViewCell!
    
    //从系统的AppDelegate获得managedObjectContext数据库上下文对象
    var managedObjectContext: NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //基础控件样式
        addBtn.layer.cornerRadius = addBtn.frame.width / 2
        addBtn.layer.borderColor = UIColor.lightGrayColor().CGColor
        addBtn.layer.borderWidth = 1
        self.tableView.registerNib(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        self.navigationController?.delegate = self
        setupCome()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(delOperation), name: "delOperation", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(editOperation), name: "editOperation", object: nil)
    }
    
    ///计算总收入和总支出
    func setupCome() {
        var countA: Double = 0
        var countB: Double = 0
        if let sections = self.fetchedResultsController.sections {
            for section in sections {
                if let objects = section.objects {
                    for object in objects {
                        if let cprice = object.valueForKey("cprice") as? Double {
                            if let ctype = object.valueForKey("ctype") as? Bool {
                                if ctype {
                                    countA += cprice
                                } else {
                                    countB += cprice
                                }
                            }
                        }
                    }
                }
            }
        }
        self.income.text = String(format: "收入\n%.2lf", countA)
        self.outcome.text =  String(format: "支出\n%.2lf", countB)
    }
    
    ///跳转
    @IBAction func addItem(sender: AnyObject) {
        self.selectedCell = nil
        self.performSegueWithIdentifier("showDetail", sender: self)
    }
    
    // MARK: - Table View
    //定义section 数量
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    //定义section Header高度
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    //定义section view
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView = NSBundle.mainBundle().loadNibNamed("SectionView", owner: nil, options: nil)?.first as? SectionView
        sectionView?.topLine.hidden = section == 0//首条section，线只有下半部分
        sectionView?.time.text = self.fetchedResultsController.sections?[section].name//根据ctime进行分组
        return sectionView
    }
    
    //定义row 数量
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    ///CoreData查询
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableViewCell") as! TableViewCell
        //根据NSManagedObject格式化显示
        if let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as? NSManagedObject {
            //格式化收入或者支出的详情
            if let cname = object.valueForKey("cname") as? String {
                if let cprice = object.valueForKey("cprice") as? Double {
                    //判断是收入还是支出
                    if let ctype = object.valueForKey("ctype") as? Bool {
                        if ctype {
                            cell.income.text = cname + String(format: " %.2lf", cprice)
                            cell.outcome.text = ""
                        } else {
                            cell.income.text = ""
                            cell.outcome.text = cname + String(format: " %.2lf", cprice)
                        }
                    }
                }
            }
            //显示收入或者支出的图片
            if let cid = object.valueForKey("cid") as? Int {
                cell.priceImage.image = UIImage(named: "type_big_\(cid)")
            }
            //末条row，线只有上半部分
            if let number = self.fetchedResultsController.sections?[indexPath.section].numberOfObjects {
                if let count = self.fetchedResultsController.sections?.count {
                    cell.bottomLine.hidden = number - 1 == indexPath.row && count - 1 == indexPath.section
                }
            }
        }
        return cell
    }
    
    //选中动画
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? TableViewCell {
            if selectedCell != nil {
                selectedCell.hileOperation()
                if cell == selectedCell {
                    selectedCell = nil
                    return
                }
            }
            cell.showOperation()
            selectedCell = cell
        }
    }
    
    //删除提示
    func delOperation(){
        let alertController = UIAlertController(title: "提示", message: "您是否确定要删除所选账目", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) in
            self.selectedCell.hileOperation()
            self.valueDelete()
        }))
        alertController.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    ///跳转
    func editOperation(){
        self.selectedCell.hileOperation()
        self.performSegueWithIdentifier("editDetail", sender: self)
    }
    
    ///CoreData插入
    func valueInsert(controller: DetailViewController){
        let context = self.fetchedResultsController.managedObjectContext
        if let entityName = self.fetchedResultsController.fetchRequest.entity?.name {
            //新建NSManagedObject
            let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context)
            saveObject(newManagedObject, controller: controller)
        }
    }
    
    ///CoreData更新
    func valueUpdate(controller: DetailViewController){
        if let obj = controller.detailItem as? NSManagedObject {
            saveObject(obj, controller: controller)
        }
    }
    
    ///保存CoreData，并且刷新列表，上传到服务器
    func saveObject(managedObject: NSManagedObject, controller: DetailViewController) {
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        
        let dateNow = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        managedObject.setValue(controller.cid, forKey: "cid")
        managedObject.setValue(controller.cname, forKey: "cname")
        managedObject.setValue(controller.cprice, forKey: "cprice")
        managedObject.setValue(dateFormatter.stringFromDate(dateNow), forKey: "ctime")
        managedObject.setValue(dateNow, forKey: "timeStamp")
        managedObject.setValue(controller.cid == 0, forKey: "ctype")
        
        // Save the context.
        do {
            try managedObject.managedObjectContext?.save()
            //                try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        self.tableView.reloadData()
        setupCome()
        
        /* 上传到服务器 */
    }
    
    ///CoreData删除
    func valueDelete(){
        if let indexPath = self.tableView.indexPathForSelectedRow {
            if let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as? NSManagedObject {
                let context = self.fetchedResultsController.managedObjectContext
                context.deleteObject(object)
                
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    //print("Unresolved error \(error), \(error.userInfo)")
                    abort()
                }
            }
        }
        self.tableView.reloadData()
        setupCome()
        /* 上传到服务器 */
    }
    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? DetailViewController{
            if segue.identifier == "showDetail" {
                controller.title = "新建"
            } else if segue.identifier == "editDetail" {
                controller.title = "编辑"
                if let indexPath = self.tableView.indexPathForSelectedRow {
                    let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
                    controller.detailItem = object
                    controller.image = self.selectedCell.priceImage.image
                }
            }
            controller.delegate = self
        }
    }
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if self.selectedCell != nil {
            if operation == UINavigationControllerOperation.Pop {
                return PopControllerAnimatedTransitioning()
            } else if operation == UINavigationControllerOperation.Push {
                return nil
            }
        }
        return nil
    }

    // MARK: - Fetched results controller CoreData分组排序代码
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Event", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: "ctime", cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Move:
            tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

}
