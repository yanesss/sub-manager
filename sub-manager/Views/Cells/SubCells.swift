//
//  File.swift
//  sub-manager
//
//  Created by aaron yanes on 6/11/19.
//  Copyright © 2019 aaron yanes. All rights reserved.
//

import UIKit

class SubCells: UITableViewCell {

    @IBOutlet weak var cellBackground: UIView!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var price: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

