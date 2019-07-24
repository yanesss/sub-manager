//
//  PriceViewController.swift
//  sub-manager
//
//  Created by aaron yanes on 7/2/19.
//  Copyright © 2019 aaron yanes. All rights reserved.
//

import UIKit

class PriceViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameOfSubscription: UILabel!
    @IBOutlet weak var priceOfSubscription: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet var tableView: UIView!
    var selectedSubscription: String?
    var subscriptionToLoad: String = ""
    var amount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        priceOfSubscription.delegate = self
        priceOfSubscription.placeholder = updateAmount()
        
        
        if let subscriptionToLoad = selectedSubscription {
            nameOfSubscription.text = subscriptionToLoad
        }
        
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        NotificationCenter.default.post(name: .subscription, object: self) //self is passing in the entire view controller
        view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let digit = Int(string) {
            amount = amount * 10 + digit
            priceOfSubscription.text = updateAmount()
        }

        if string == "" {
            amount = amount / 10
            priceOfSubscription.text = updateAmount()
        }

        return false
    }

    func updateAmount() -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        let price = Double(amount / 100) + Double(amount % 100) / 100 //if user enter 5 -> 0 + 5 % 100 = 0.05
        return formatter.string(from: NSNumber(value: price))
    }

}



