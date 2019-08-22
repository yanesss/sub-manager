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
        
        //configure the size of table view
        configureTableView()
        
        checkIfUserIsLoggedIn()
        
        //refresh controller
        addRefreshControl()
        
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
                self.navigationController?.popViewController(animated: true)
            }
            
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
    }

    /*
     ** provides the ability to refresh if subscription did not update
    */
    func addRefreshControl() {
        refresh.tintColor = UIColor.red
        refresh.attributedTitle = NSAttributedString(string: "Refreshing Subscriptions")
        refresh.addTarget(self, action: #selector(refreshSubscription), for: .valueChanged)
        tableView.addSubview(refresh)
    }
    
    @objc func refreshSubscription() {
        refresh.endRefreshing()
        tableView.reloadData()
        monthlyExpense()
    }
    
    // Retrieve subs from db
    func retrieveSubscriptions() {
        let user = Auth.auth().currentUser
        guard let uid = user?.uid else {
            return
        }

        let subscriptionDB = Database.database().reference().child("users").child(uid).child("email")

        //when there is a new subscription put into the database
        subscriptionDB.observe(.childAdded) { (snapshot) in
            //grab data inside snapshot
            print(snapshot)
            let snapshotValue = snapshot.value as! Dictionary<String, String>

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
    
    //TODO - Fix monthly expense

    
    
    //Calculates monthly subscription expense
    func monthlyExpense() {
        var cost = 0.00
        for price in priceOfCompany {
            let formatPrice = price.removeFormatAmount()
            cost += formatPrice
        }
        cost = cost.roundTo(places: 2)
        print(cost)
        totalCosts.text = String(cost)
    }
    
    //updates monthly expense once a row is deleted
    func updateMonthlyExpenseOnDelete() {
        var cost: Double = 0.00
        for price in priceOfCompany {
            let formatPrice = price.removeFormatAmount()
            cost += formatPrice
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
        //return listOfCompany.count
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
        
//        guard let uid = Auth.auth().currentUser?.uid else {
//            return
//        }
//
//        let sub = self.subscriptionArray[indexPath.row]
//
//        Database.database().reference().child("users").child(uid).child("email").child(sub.price).removeValue { (error, ref) in
//            if error != nil {
//                print("failed to delete")
//                return
//            }
//
//        }
        
        
        if editingStyle == .delete {
            subscriptionArray.remove(at: indexPath.row)
            priceOfCompany.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            updateMonthlyExpenseOnDelete()
            tableView.endUpdates()
        }
        
    }
    
    
    
}






