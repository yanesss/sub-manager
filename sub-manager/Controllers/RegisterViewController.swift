//
//  RegisterViewController.swift
//  sub-manager
//
//  Created by aaron yanes on 7/23/19.
//  Copyright © 2019 aaron yanes. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func registerPressed(_ sender: Any) {
        //set up new firebase user
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            
            if error != nil {
                print("register failed")
            } else {
                //self. --> used when inside a closure (Keyword: "in")
                self.performSegue(withIdentifier: "RegisterMySubscription", sender: self)
            }
            
        }
        
    }
    
}
