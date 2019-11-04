//
//  SubscriptionController.swift
//  sub-manager
//
//  Created by aaron yanes on 6/17/19.
//  Copyright © 2019 aaron yanes. All rights reserved.
//

import UIKit


class SubscriptionController: UITableViewController {

    @IBOutlet var myTableView: UITableView!
    var company : [String] = []
    var listOfSubscriptions: [Subs] = [Subs]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.register(UINib(nibName: "ListOfAvailableSubs", bundle: nil), forCellReuseIdentifier: "listOfSubs")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subscriptions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listOfSubs", for: indexPath) as! ListOfAvailableSubs
        
        //TODO: SORT SUBS IN ORDER
        for i in subscriptions {
            listOfSubscriptions.append(Subs(subscription: i.subscription, price: i.price))
            company.append(i.subscription)
        }
        
        cell.companyName.text = company[indexPath.row]
        return cell
    }
    
    /*
    ** allows user to add the price of chosen subscription
    */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Price") as? PriceViewController {
            vc.selectedSubscription = company[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }

}



