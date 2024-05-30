//
//  SettingViewController.swift
//  PIP
//
//  Created by caishilin on 2024/5/28.
//

import SwiftDate
import UIKit
import Combine

// MARK: - SettingViewController

final class SettingViewController: BaseViewController {
    let listView = UITableView(frame: .zero, style: .insetGrouped)
    
    private lazy var calendarPlusBtn = UIBarButtonItem(
        image: .symbol(.calendar_badge_plus),
        style: .plain,
        target: self,
        action: #selector(clickCalendarBtn)
    )
    private lazy var editBtn = UIBarButtonItem(
        title: .local("Edit"),
        style: .plain,
        target: self,
        action: #selector(clickEditBtn)
    )
    
    private var cancellables: Set<AnyCancellable> = []
    private let refreshTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = .local("Buy Plan")
        
        setupUI()
        
        refreshTimer.sink { [weak self] _ in
            self?.refreshListViewIfNeeded()
        }.store(in: &cancellables)
    }
    
    private func refreshListViewIfNeeded() {
        if Date().second == 0 {
            listView.reloadData()
        }
    }
    
    private func setupUI() {
        navigationItem.rightBarButtonItem = calendarPlusBtn
        navigationItem.leftBarButtonItem = editBtn
        
        view.addSubview(listView)
        listView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        listView.delegate = self
        listView.dataSource = self
        
        appState.$plans
            .distinctUntilChanged()
            .asyncBind(onNext: { [weak self] _ in
                self?.listView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func clickCalendarBtn() {
        let nav = BaseNavigationController(rootViewController: AddCalendarViewController())
        nav.navigationBar.prefersLargeTitles = false
        present(nav, animated: true)
    }
    
    @objc private func clickEditBtn() {
        let edit = !listView.isEditing
        listView.setEditing(edit, animated: true)
        editBtn.title = edit ? .local("Done") : .local("Edit")
    }
}

// MARK: UITableViewDataSource

extension SettingViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        appState.plans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let plan = appState.plans[indexPath.row]
        cell.textLabel?.text = plan.name
        cell.detailTextLabel?.text = plan.date.formatted(.dateTime)
        
        if plan.date.isInPast {
            cell.accessoryView = UIImageView(image: .symbol(.clock_badge_xmark))
            cell.accessoryView?.tintColor = .systemRed
        } else if plan.date.compareCloseTo(.now, precision: 10.minutes.timeInterval) {
            cell.accessoryView = UIImageView(image: .symbol(.alarm_waves_left_and_right))
            cell.accessoryView?.tintColor = .systemYellow
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        appState.plans.remove(at: indexPath.row)
    }
}

// MARK: UITableViewDelegate

extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

#Preview {
    BaseNavigationController(rootViewController: SettingViewController())
}
