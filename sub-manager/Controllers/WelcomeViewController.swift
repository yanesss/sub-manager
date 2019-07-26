//
//  WelcomeViewController.swift
//  sub-manager
//
//  Created by aaron yanes on 7/23/19.
//  Copyright © 2019 aaron yanes. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var signInSelector: UISegmentedControl!
    @IBOutlet weak var signInLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    var isSignIn: Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func signInSelectorChanged(_ sender: UISegmentedControl) {
        //when user changes selector
        //bool flips
        isSignIn = !isSignIn
        
        //check bool
        if isSignIn {
            signInLabel.text = "Sign In"
            signInButton.setTitle("Sign In", for: .normal)
        } else {
            signInLabel.text = "Register"
            signInButton.setTitle("Register", for: .normal)
        }
        
    }
    

    @IBAction func signInButtonTapped(_ sender: UIButton) {
        //check email and password validation
        if let email = emailTextField.text, let password = passwordTextField.text {
            //check if signed in or register is selected
            if isSignIn {
                //sign in user w/ firebase
                Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                    if let user = user {
                        // go to my subscriptions page
                        self.performSegue(withIdentifier: "HomePage", sender: self)
                    } else {
                        print(error)
                    }
                    
                }
            } else {
                //create new user in firebase
                Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                    if let user = user {
                        //user found: go to my subs
                        self.performSegue(withIdentifier: "HomePage", sender: self)
                    } else {
                        //error
                        
                    }
                }
            }
            
        }
        
       
    }
    
    //dismiss keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    
}
