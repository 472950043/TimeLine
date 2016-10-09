//
//  SectionViewCell.swift
//  TimeLine
//
//  Created by 蒋悦斌 on 16/6/24.
//  Copyright © 2016年 jyb. All rights reserved.
//

import UIKit

class SectionViewCell: UITableViewCell {
    
    @IBOutlet var round: UIView!
    @IBOutlet var topLine: UIView!
    @IBOutlet var bottomLine: UIView!
    @IBOutlet var time: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
