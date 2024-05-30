//
//  MainTabViewController.swift
//  PIP
//
//  Created by caishilin on 2024/5/28.
//

import UIKit

final class MainTabViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupChildren()
    }
    
    private func setupChildren() {
        let homeVC = HomeViewController()
        let settingVC = SettingViewController()
        viewControllers = [homeVC, settingVC]
        append(childVC: homeVC, title: .local("Time"), icon: .symbol(.stopwatch), tag: 0)
        append(childVC: settingVC, title: .local("Buy Plan"), icon: .symbol(.calendar), tag: 1)
    }
    
    private func append(childVC: UIViewController, title: String, icon: UIImage, tag: Int) {
        let nav = BaseNavigationController(rootViewController: childVC)
        nav.tabBarItem = UITabBarItem(title: title, image: icon, tag: tag)
        viewControllers?.append(nav)
    }
}

#Preview {
    MainTabViewController()
}
