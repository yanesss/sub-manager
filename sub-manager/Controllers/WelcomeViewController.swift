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

class WelcomeViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var signInSelector: UISegmentedControl!
    @IBOutlet weak var signInLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    
    var isSignIn: Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gradientNavBar()
        
        //sign in button rounder
        signInButton.layer.cornerRadius = 10
        signInButton.clipsToBounds = true
        
        //navigationController?.navigationBar.barTintColor = UIColor.white
        
        //observe state of login
        let listener = Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil {
                print("user not logged in")
            } else {
                self.performSegue(withIdentifier: "HomePage", sender: self)
            }
        }        
        Auth.auth().removeStateDidChangeListener(listener)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        passwordTextField.delegate = self
        passwordTextField.returnKeyType = .done
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
                    let userInfoReference = ref.child("user-info").child(uid)
                    let userInfo = ["userid": uid, "email":encodeEmail]
                    userInfoReference.updateChildValues(userInfo, withCompletionBlock: {(err, ref) in
                        if err != nil {
                            return
                        }
                    })
                        //login to homepage
                        self.performSegue(withIdentifier: "HomePage", sender: self)
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
    
    //return button on keyboard clears keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        passwordTextField.resignFirstResponder()
        return true
    }
    
    //gradient navbar
    func gradientNavBar() {
        guard
                   let navigationController = navigationController,
                   let flareGradientImage = CAGradientLayer.primaryGradient(on: navigationController.navigationBar)
                   else {
                       print("Error creating gradient color!")
                       return
                   }

               navigationController.navigationBar.barTintColor = UIColor(patternImage: flareGradientImage)
    }
    
    // alert message when user types in invalid credentials
    // erase text fields of invalid credentials
    func errorAlert() {
        if isSignIn {
            let alert = UIAlertController(title: "Error", message: "Incorrect password or email", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: nil))
            present(alert, animated: true)
//            emailTextField.text = ""
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

/**
 ** used to create gradient bar
 */
extension CAGradientLayer {
    
    class func primaryGradient(on view: UIView) -> UIImage? {
        let gradient = CAGradientLayer()
        let flareRed = UIColor(displayP3Red: 241.0/255.0, green: 39.0/255.0, blue: 17.0/255.0, alpha: 1.0)
        let flareOrange = UIColor(displayP3Red: 245.0/255.0, green: 175.0/255.0, blue: 25.0/255.0, alpha: 1.0)
        var bounds = view.bounds
        bounds.size.height += UIApplication.shared.statusBarFrame.size.height
        gradient.frame = bounds
        gradient.colors = [flareRed.cgColor, flareOrange.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        return gradient.createGradientImage(on: view)
    }
    
    private func createGradientImage(on view: UIView) -> UIImage? {
        var gradientImage: UIImage?
        UIGraphicsBeginImageContext(view.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            render(in: context)
            gradientImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        }
        UIGraphicsEndImageContext()
        return gradientImage
    }
}
