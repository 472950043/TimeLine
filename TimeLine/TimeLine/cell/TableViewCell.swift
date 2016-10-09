//
//  TableViewCell.swift
//  TimeLine
//
//  Created by 蒋悦斌 on 16/6/22.
//  Copyright © 2016年 jyb. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet var income: UILabel!
    @IBOutlet var outcome: UILabel!
    @IBOutlet var priceImage: UIImageView!
    @IBOutlet var topLine: UIView!
    @IBOutlet var bottomLine: UIView!
    @IBOutlet var del: UIButton!
    @IBOutlet var edit: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        income.text = ""
        outcome.text = ""
        del.hidden = true
        edit.hidden = true
    }
    
    func showOperation(){
        income.hidden = true
        outcome.hidden = true
        del.hidden = false
        edit.hidden = false
        UIView.animateWithDuration(0.5, animations: {
            self.del.center.x = self.frame.width / 4
            self.edit.center.x = self.frame.width / 4 * 3
        }) { (Bool) in
        }
    }
    
    func hileOperation(){
        UIView.animateWithDuration(0.5, animations: {
            self.del.center.x = self.frame.width / 2
            self.edit.center.x = self.frame.width / 2
        }) { (Bool) in
            self.income.hidden = false
            self.outcome.hidden = false
            self.del.hidden = true
            self.edit.hidden = true
        }
    }

    @IBAction func delClick(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("delOperation", object: nil)
    }
    
    @IBAction func editClick(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("editOperation", object: nil)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
