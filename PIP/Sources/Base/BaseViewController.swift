//
//  BaseViewController.swift
//  PIP
//
//  Created by caishilin on 2024/5/29.
//

import UIKit
import RxSwift

class BaseViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    var prefersShowCustomNavigationBar: Bool = false {
        didSet {
            updateCustomNavigationBar()
        }
    }
    var prefersTransparentCustomNavigationBar: Bool = false {
        didSet {
            updateCustomNavigationBar()
        }
    }
    lazy var customNavigationItem = UINavigationItem()
    lazy var customNavigationBar = {
        let bar = UINavigationBar()
        bar.items = [customNavigationItem]
        return bar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
    }
    
    private func updateCustomNavigationBar() {
        guard prefersShowCustomNavigationBar else {
            return
        }
        
        if customNavigationBar.superview == nil {
            view.addSubview(customNavigationBar)
            customNavigationBar.snp.makeConstraints {
                $0.leading.top.trailing.equalToSuperview()
            }
        }
        
        if prefersTransparentCustomNavigationBar {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithTransparentBackground()
            customNavigationBar.standardAppearance = navBarAppearance
        }
    }
}
