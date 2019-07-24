//
//  SubscriptionDelegate.swift
//  sub-manager
//
//  Created by aaron yanes on 7/4/19.
//  Copyright © 2019 aaron yanes. All rights reserved.
//

import Foundation

protocol SubscriptionDelegate: class {
    func nameReceived(name: String)
    func priceReceived(price: String)
}
