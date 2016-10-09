//
//  SectionView.swift
//  TimeLine
//
//  Created by 蒋悦斌 on 16/6/22.
//  Copyright © 2016年 jyb. All rights reserved.
//

import UIKit

class SectionView: UIView {

    @IBOutlet var round: UIView!
    @IBOutlet var topLine: UIView!
    @IBOutlet var bottomLine: UIView!
    @IBOutlet var time: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        round.layer.cornerRadius = round.frame.width / 2
        time.text = ""
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
