//
//  BaseNavigationController.swift
//  PIP
//
//  Created by caishilin on 2024/5/28.
//

import UIKit

final class BaseNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.prefersLargeTitles = true
//        navigationBar.tintColor = self.navigationBar.window?.tintColor
        navigationBar.tintColor = .systemGreen
    }
}
