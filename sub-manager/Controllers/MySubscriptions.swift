//
//  mySubscriptions.swift
//  sub-manager
//
//  Created by aaron yanes on 6/10/19.
//  Copyright © 2019 aaron yanes. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class MySubscriptions: UIViewController {
    
    @IBOutlet weak var expenses: UILabel!
    @IBOutlet weak var totalCosts: UILabel!
    @IBOutlet weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    var listOfCompany = [String]()
    var priceOfCompany = [String]()
    let refresh = UIRefreshControl()
    var subscriptionArray: [Subs] = [Subs]()
    var ref: DatabaseReference!
    var refHandle: DatabaseHandle!
    var KEY: String?
    @IBOutlet weak var signOutButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //used to access table view
        tableView.delegate = self
        tableView.dataSource = self
        
        //only shows cells if they contain data
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        //allow access to custom cells
        tableView.register(UINib(nibName: "CustomSubCells", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        
        checkIfUserIsLoggedIn()
        
        retrieveSubscriptions()
    }
    
    
    //post: signs out user
    //      sends user back to welcome page
    @IBAction func signOutButton(_ sender: Any) {
        handleSignOut()
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleSignOut), with: nil, afterDelay: 0)
        }
    }
    
    @objc func handleSignOut() {
        let firebaseAuth = Auth.auth()
        
        do {
            try firebaseAuth.signOut()
            // go to sign in page
            print("sign out success")
            
            dismiss(animated: true) {
                self.navigationController?.popToRootViewController(animated: true)
            }
           
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
    }
    
    // Retrieve subs from db
    func retrieveSubscriptions() {
        let user = Auth.auth().currentUser
        guard let uid = user?.uid else {
            return
        }
        guard let email = user?.email else {
            return
        }

        let subscriptionDB = Database.database().reference().child("users").child(uid)
        
        //when there is a new subscription put into the database
        subscriptionDB.observe(.childAdded) { (snapshot) in
            //grab data inside snapshot
            let snapshotValue = snapshot.value as! Dictionary<String, String>
            self.KEY = snapshot.key
            
            let sub = snapshotValue["Subscription"]
            let price = snapshotValue["Price"]
            
            self.priceOfCompany.append(price!)
            let subInfo = Subs(subscription: sub!, price: price!)
            self.subscriptionArray.append(subInfo)
            self.configureTableView()
            self.monthlyExpense()
            self.tableView.reloadData()
        }

    }
    
    //Calculates monthly subscription expense
    func monthlyExpense() {
        var cost = 0.00
        for price in priceOfCompany {
            cost += Double(price)!
        }
        cost = cost.roundTo(places: 2)
        totalCosts.text = String(cost)
    }
    
    //custom constraints for tables cells
    func configureTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120.0
    }
    
    //allows segue to unwind back to view controller (MySubscriptions)
    @IBAction func unwindToMySubscriptions(_ sender: UIStoryboardSegue) {}
    
}

extension MySubscriptions: UITableViewDelegate, UITableViewDataSource {
    //displays the number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subscriptionArray.count
    }
    
    //displays what is seen on each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! SubCells
        
        cell.companyName.text = subscriptionArray[indexPath.row].subscription
        cell.price.text = subscriptionArray[indexPath.row].price
        
        return cell
    }
    
    //enable ability to edit cell rows
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //TODO: Delete subscription from database
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let ref = Database.database().reference().child("users")
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let sub = self.subscriptionArray[indexPath.row]
       
        //capture childAutoId value
        ref.child(uid).observe(.value) { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key // autoid keys list
                
                ref.child(uid).child(key).observe(.value) { (snapshot) in
                    for child in snapshot.children {
                        let snap = child as! DataSnapshot
                        let value = snap.value as! String
                        
                        if value == sub.subscription {
                            print(ref.child(uid).child(key).child(sub.subscription))
                            ref.child(uid).child(key).removeValue { (err, ref) in
                                if err != nil {
                                    print(err?.localizedDescription)
                                    return
                                }
                            }
                        }
                    }
                }
            }
        }
        
    
        if editingStyle == .delete {
            subscriptionArray.remove(at: indexPath.row)
            priceOfCompany.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            monthlyExpense()
            tableView.endUpdates()
        }
        
    }
    
}






