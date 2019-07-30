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
        //when user changes selector bool flips
        isSignIn = !isSignIn
        
        //check bool
        if isSignIn {
            signInLabel.text = "Sign In"
            signInButton.setTitle("Sign In", for: .normal)
//            emailTextField.text = ""
//            passwordTextField.text = ""
            
        } else {
            signInLabel.text = "Register"
            signInButton.setTitle("Register", for: .normal)
//            emailTextField.text = ""
//            passwordTextField.text = ""
        }
        
    }
    
    /*
     ** pre: sign in to current account
     **      or register new account
     ** post: takes user to subscription page
     */
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        //check email and password validation
        if let email = emailTextField.text, let password = passwordTextField.text {
            //check if signed in or register is selected
            if isSignIn {
                //sign in user w/ firebase
                Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                    if let user = user {
                        self.getUserInfo()
                        self.performSegue(withIdentifier: "HomePage", sender: self)
                        
                    } else {
                        self.errorAlert()
                    }
                    
                }
            } else {
                //create new user in firebase
                Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                    if let user = user {
                        //user found: go to my subscriptions page
                        self.performSegue(withIdentifier: "HomePage", sender: self)
                        
                    } else {
                        self.errorAlert()
                    }
                }
            }
            
        }
        
    }
    
    private func navigateToMainInterface() {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let mainNavigationVC = mainStoryBoard.instantiateViewController(withIdentifier: "MySubscriptions") as? MySubscriptions else {
            return
        }
        present(mainNavigationVC, animated: true, completion: nil)
    }
    
    //dismiss keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    // alert message when user types in invalid credentials
    // erase text fields of invalid credentials
    func errorAlert() {
        if isSignIn {
            let alert = UIAlertController(title: "Error", message: "Incorrect password or email", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: nil))
            present(alert, animated: true)
//            emailTextField.text = ""
//            passwordTextField.text = ""
        } else {
            let alert = UIAlertController(title: "Error", message: "Must be valid email address and password with a minimum of 6 characters", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: nil))
            present(alert, animated: true)
//            emailTextField.text = ""
//            passwordTextField.text = ""
        }
    }
    
}
