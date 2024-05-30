//
//  AddCalendarViewController.swift
//  PIP
//
//  Created by caishilin on 2024/5/29.
//

import UIKit
import RxSwift
import RxCocoa

class AddCalendarViewController: BaseViewController {
    let listView = StaticTableView(frame: .zero, style: .insetGrouped)
    
    var listLayout: ListLayout = .init {}
    
    private lazy var doneItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(clickAdd))
    
    @State
    private var isFormValid = false
    
    @State
    private var eventName: String = ""
    @State
    private var eventDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = .local("Add Plan")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(clickCancel))
        navigationItem.rightBarButtonItem = doneItem
        $isFormValid.bind(to: doneItem.rx.isEnabled).disposed(by: disposeBag)
        
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        Observable.combineLatest($eventName, $eventDate)
            .map { !$0.0.isEmpty && $0.1 != nil }
            .distinctUntilChanged()
            .bind(to: $isFormValid)
            .disposed(by: disposeBag)
        
        listView.listLayout = .init {
            Section {
                Cell(.accessory(.list(.cell(), then: {
                    $0.text = "Event"
                    $0.textProperties.color = .secondaryLabel
                }), accessory: UITextField().then({
                    $0.frame = .init(x: 0, y: 0, width: 200, height: 30)
                    $0.rx.text.orEmpty.bind(to: $eventName).disposed(by: disposeBag)
                    $0.textAlignment = .right
                })))
                .loadAccessoryViewInContent()
                Cell(.accessory(.list(.cell(), then: {
                    $0.text = "Date"
                    $0.textProperties.color = .secondaryLabel
                }), accessory: UIDatePicker().then({
                    $0.datePickerMode = .dateAndTime
                    $0.preferredDatePickerStyle = .compact
                    $0.rx.date.bind(to: $eventDate).disposed(by: disposeBag)
                })))
            }
        }
        
    }
    
    @objc private func clickCancel() {
        dismiss(animated: true)
    }
    
    @objc private func clickAdd() {
        appState.plans.insert(BuyPlan(name: eventName, date: eventDate!), at: 0)
        dismiss(animated: true)
    }
}

#Preview {
    let nav = BaseNavigationController(rootViewController: AddCalendarViewController())
    nav.navigationBar.prefersLargeTitles = false
    return nav
}


