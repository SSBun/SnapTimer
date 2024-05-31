//
//  StaticTableView.swift
//  PIP
//
//  Created by caishilin on 2024/5/29.
//

import UIKit

extension UIContentConfiguration where Self == UIListContentConfiguration {
    static func list(_ config: UIListContentConfiguration, then: ((inout UIListContentConfiguration) -> Void)? = nil) -> Self {
        var config = config
        then?(&config)
        return config
    }
}

protocol DataRenderedCell {
    func update(data: Any?)
}

protocol StaticTableViewDelegate: AnyObject {
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath,
        cell: UITableViewCell,
        cellConfig: Cell
    )
}

class StaticTableView: UITableView {
    weak var staticDelegate: StaticTableViewDelegate?
    
    var listLayout: ListLayout = .init {} {
        didSet { reloadData() }
    }
    
    func updateCellVisibility(hidden: Bool, at indexPaths: [IndexPath]) {
        if indexPaths.isEmpty { return }
        
        var resultIndexPaths: [IndexPath] = []
        for indexPath in indexPaths {
            // Checks array overflow
            guard indexPath.section < listLayout._sections.count,
                  indexPath.row < listLayout._sections[indexPath.section]._cells.count
            else {
                logger.error("Index out of bounds")
                continue
            }
            
            let cell = listLayout._sections[indexPath.section]._cells[indexPath.row]
            guard cell.isHidden != hidden else { continue }
            cell.isHidden = hidden
            resultIndexPaths.append(indexPath)
        }
        if hidden {
            deleteRows(at: resultIndexPaths, with: .automatic)
        } else {
            insertRows(at: resultIndexPaths, with: .automatic)
        }
    }
    
    func updateCells(at indexPaths: [IndexPath]) {
        reloadRows(at: indexPaths, with: .automatic)
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        delegate = self
        dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension StaticTableView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        listLayout.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        listLayout.sections[section].cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellConfig = listLayout.sections[indexPath.section].cells[indexPath.row]
        let resultCell: UITableViewCell
        switch cellConfig.kind {
        case let .reusable(type):
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: type)) ?? type.init(style: .default, reuseIdentifier: String(describing: type))
            (cell as? DataRenderedCell)?.update(data: cellConfig.data)
            resultCell = cell
        case let .unique(contentView):
            let cell = UITableViewCell(style: .default, reuseIdentifier: "unique")
            cell.contentView.addSubview(contentView)
            contentView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            resultCell = cell
        case let .accessory(config, accessory: accessoryView):
            let cell = UITableViewCell(style: .default, reuseIdentifier: "accessory")
            cell.contentConfiguration = cellConfig.contentConfiguration ?? config
            if let accessoryView {
                cell.accessoryView = accessoryView
            }
            resultCell = cell
        }
        resultCell.selectionStyle = .none
        staticDelegate?.tableView(tableView, cellForRowAt: indexPath, cell: resultCell, cellConfig: cellConfig)
        return resultCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellConfig = listLayout.sections[indexPath.section].cells[indexPath.row]
        cellConfig.selectHandler?(indexPath)
    }
}

// MARK: UITableViewDelegate

extension StaticTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellConfig = listLayout.sections[indexPath.section].cells[indexPath.row]
        return cellConfig.height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = listLayout.sections[section].header
        switch header {
        case let .text(text):
            let headerView = UITableViewHeaderFooterView()
            var config = UIListContentConfiguration.prominentInsetGroupedHeader()
            config.text = text
            headerView.contentConfiguration = config
            return headerView
        case let .view(headerView):
            return headerView
        case .none:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = listLayout.sections[section].footer
        switch footer {
        case let .text(text):
            let footerView = UITableViewHeaderFooterView()
            var config = UIListContentConfiguration.groupedFooter()
            config.text = text
            footerView.contentConfiguration = config
            return footerView
        case let .view(footerView):
            return footerView
        case .none:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section = listLayout.sections[section]
        return section.headerHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let section = listLayout.sections[section]
        return section.footerHeight
    }
}
