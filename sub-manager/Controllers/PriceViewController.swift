//
//  PriceViewController.swift
//  sub-manager
//
//  Created by aaron yanes on 7/2/19.
//  Copyright © 2019 aaron yanes. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class PriceViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameOfSubscription: UILabel!
    @IBOutlet weak var priceOfSubscription: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet var tableView: UIView!
    var selectedSubscription: String?
    var subscriptionToLoad: String = ""
    var amount: Int = 0
    var ref: DatabaseReference!
    //var key: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        priceOfSubscription.delegate = self
        priceOfSubscription.placeholder = updateAmount()
        
        
        if let subscriptionToLoad = selectedSubscription {
            nameOfSubscription.text = subscriptionToLoad
        }
        
    }
    
    //Notifies observer when button is pressed
    @IBAction func buttonPressed(_ sender: Any) {
        NotificationCenter.default.post(name: .subscription, object: self) //self is passing in the entire view controller
        sendSubscriptionToDb()
        view.endEditing(true)
        
    }
    
    func sendSubscriptionToDb() {
//        let user = Auth.auth().currentUser?.uid
//
//        let subscriptionDB = Database.database().reference().child(user!)
//
//        let subscriptionDictionary = ["Name": selectedSubscription]

//        subscriptionDB.child("Subscription").setValue(subscriptionDictionary) {
//            (error, ref) in
//            if error != nil {
//                print("error sending data")
//            } else {
//                print("subscription saved")
//            }
       // }
        
        
        ref = Database.database().reference()
        let user = Auth.auth().currentUser
        
        guard let uid = user?.uid else {
            return
        }
        
        //sets first subscription selected
//        self.ref.child("users").child(uid).setValue(["Subscription": selectedSubscription])

        //update and add new subscriptions
        let key = ref.child("user").child("Subscription").childByAutoId().key
        let post = ["subscription": selectedSubscription]
        let childUpdates = ["/users/\(key)": post]
        ref.updateChildValues(childUpdates)
        
        //TODO: NEST DATA
        
        //THIS WORKS
//
//        let subscriptionDB = ref.child("/Users/\(uid)")
//
//        let subscriptionDictionary = ["Subscription": selectedSubscription]
//
//        subscriptionDB.childByAutoId().setValue(subscriptionDictionary) {
//            (error, ref) in
//            if error != nil {
//                print("error")
//            } else {
//                print("success")
//            }
//        }
        
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

    //allows user input to print numbers from right to left
    func updateAmount() -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        let price = Double(amount / 100) + Double(amount % 100) / 100 //if user enter 5 -> 0 + 5 % 100 = 0.05
        return formatter.string(from: NSNumber(value: price))
    }

}



