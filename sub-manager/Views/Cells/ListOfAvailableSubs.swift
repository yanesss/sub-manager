//
//  ListOfAvailableSubs.swift
//  sub-manager
//
//  Created by aaron yanes on 6/18/19.
//  Copyright © 2019 aaron yanes. All rights reserved.
//

import UIKit

class ListOfAvailableSubs: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
