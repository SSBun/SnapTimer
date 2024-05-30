//
//  BuyPlan.swift
//  PIP
//
//  Created by caishilin on 2024/5/30.
//

import Foundation

// MARK: - BuyPlan

struct BuyPlan: Equatable {
    let name: String
    let date: Date
}

// MARK: Codable

extension BuyPlan: Codable {}
