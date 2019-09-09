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
        
        //observe state of login
        let listener = Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil {
//                self.performSegue(withIdentifier: "loginPage", sender: nil)
                print("user not logged in")
            }
        }        
        Auth.auth().removeStateDidChangeListener(listener)
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
            emailTextField.text = ""
            passwordTextField.text = ""
            
        } else {
            signInLabel.text = "Register"
            signInButton.setTitle("Register", for: .normal)
            emailTextField.text = ""
            passwordTextField.text = ""
        }
        
    }
    
    /*
     ** pre: sign in to current account
     **      or register new account
     ** post: takes user to subscription page
     */
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            //replace . with , in email for firebase
            let encodeEmail = email.replacingOccurrences(of: ".", with: ",")
            print(encodeEmail)
            
            //check if signed in or register is selected
            if isSignIn == true {
                Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                    if error != nil {
                        print(error?.localizedDescription)
                        self.errorAlert()
                        return
                    }
                    self.performSegue(withIdentifier: "HomePage", sender: self)
                }
            }
            
            //create new user in firebase
            if isSignIn == false {
                Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                    if error != nil {
                        if let errorCode = AuthErrorCode(rawValue: error!._code) {
                            switch errorCode {
                            case .weakPassword:
                                print("Please provide a strong password")
                                let alert = UIAlertController(title: "Weak Password", message: "Password must contain at least 6 characters.", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: nil))
                                self.present(alert, animated: true)
                            default:
                                print("There is an error")
                                self.errorAlert()
                            }
                        }
                        return
                    }
                    
                    guard let uid = user?.user.uid else {
                        return
                    }
                    
                    let ref = Database.database().reference(fromURL: "https://sub-manager-79124.firebaseio.com/")
                    let userReference = ref.child("users").child(uid)
                    let values = ["email": encodeEmail]
                    userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                        if err != nil {
                            print(err?.localizedDescription)
                            return
                        }
                        //login to homepage
                        self.performSegue(withIdentifier: "HomePage", sender: self)
                    })
                }   
            }
            //clears password after user signs in
            passwordTextField.text = ""
            
        }
        
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
            emailTextField.text = ""
            passwordTextField.text = ""
        } else {
            let alert = UIAlertController(title: "Error", message: "Must be valid email address and password with a minimum of 6 characters", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: nil))
            present(alert, animated: true)
            emailTextField.text = ""
            passwordTextField.text = ""
        }
    }
    
}
