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
    var ref: DatabaseReference!
    var uid: String?
    
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
        
        //refresh controller
        addRefreshControl()
        
        //check for user
        //getCurrentUserInfo()
        
        //observer listens for Notification from PriceViewDelegate
        NotificationCenter.default.addObserver(forName: .subscription, object: nil, queue: OperationQueue.main) { (notification) in
            let subVc = notification.object as! PriceViewController
            self.listOfCompany.append(subVc.nameOfSubscription.text!)
            self.priceOfCompany.append(subVc.priceOfSubscription.text!)
            let indexPath = IndexPath(row: self.listOfCompany.count - 1, section: 0)
            self.monthlyExpense()
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
        }
        
    }
    
    //get current user
    func getCurrentUserID() {
        let user = Auth.auth().currentUser
        if let user = user {
            uid = user.uid
        }
    }
    
    //save subscriptions to user id
    func saveSubscriptions() {
        ref = Database.database().reference()
    }
    
    //post: signs out user
    //      sends user back to welcome page
    @IBAction func signOutButton(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            // go to sign in page
            print("sign out success")
            
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
        return listOfCompany.count
    }
    
    //displays what is seen on each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! SubCells
        
        cell.companyName.text = listOfCompany[indexPath.row]
        cell.price.text = priceOfCompany[indexPath.row]
        
        return cell
    }
    
    //enable ability to edit cell rows
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //swipe to delete feature
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            listOfCompany.remove(at: indexPath.row)
            priceOfCompany.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            updateMonthlyExpenseOnDelete()
            tableView.endUpdates()
        }
        
    }
    
}






