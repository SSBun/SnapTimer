//
//  ListLayoutConfig.swift
//  PIP
//
//  Created by caishilin on 2024/5/28.
//

import UIKit

// MARK: - ListLayout

struct ListLayout {
    var sections: [Section] { _sections.filter({ $0.isHidden == false })}
    private(set) var _sections: [Section]
    
    init(@ArrayBuilder<Section> _ builder: () -> [Section]) {
        _sections = builder()
    }
    
    func indexPaths(of flags: String...) -> [(IndexPath, ListItem)] {
        var result: [(IndexPath, ListItem)] = []
        for (sectionIndex, section) in _sections.enumerated() {
            if let flag = section.flag, flags.contains(flag) {
                result.append((IndexPath(row: 0, section: sectionIndex), section))
            }
            for (cellIndex, cell) in section._cells.enumerated() {
                if let flag = cell.flag, flags.contains(flag) {
                    result.append((IndexPath(row: cellIndex, section: sectionIndex), cell))
                }
            }
        }
        return result
    }
//    
//    func visibleIndexPaths(of flags: String...) -> [(IndexPath, ListItem)] {
//        for (sectionIndex, section) in sections.enumerated() {
//            if section.flag == flag {
//                return (IndexPath(row: 0, section: sectionIndex), section)
//            }
//            for (cellIndex, cell) in section.cells.enumerated() {
//                if cell.flag == flag {
//                    return (IndexPath(row: cellIndex, section: sectionIndex), cell)
//                }
//            }
//        }
//        return nil
//    }
}

class ListItem {
    var isHidden = false
    private(set) var flag: String?
    
    @discardableResult
    func flag(_ flag: String) -> Self {
        self.flag = flag
        return self
    }
    
    @discardableResult
    func visible(_ isVisible: Bool) -> Self {
        isHidden = !isVisible
        return self
    }
}

// MARK: - Section

class Section: ListItem {
    var header: SectionBanner?
    var headerHeight: CGFloat = UITableView.automaticDimension
    var footer: SectionBanner?
    var footerHeight: CGFloat = UITableView.automaticDimension
    var cells: [Cell] { _cells.filter({ $0.isHidden == false })}
    private(set) var _cells: [Cell]
    
    init(@ArrayBuilder<Cell> _ builder: () -> [Cell]) {
        _cells = builder()
    }
    
    @discardableResult
    func header(_ header: SectionBanner? = nil, height: CGFloat = UITableView.automaticDimension) -> Self {
        self.header = header
        self.headerHeight = height
        return self
    }
    
    @discardableResult
    func footer(_ footer: SectionBanner? = nil, height: CGFloat = UITableView.automaticDimension) -> Self {
        self.footer = footer
        self.footerHeight = height
        return self
    }
}

// MARK: - Cell

class Cell: ListItem {
    enum Kind {
        case unique(_ content: UIView)
        case reusable(_ cellType: (UITableViewCell & DataRenderedCell).Type)
        case accessory(_ config: UIContentConfiguration, accessory: UIView? = nil)
    }
    
    var kind: Kind
    var height: CGFloat
    var isLoadingAccessoryViewInContent = false
    var data: Any?
    var selectHandler: ((IndexPath) -> Void)?
    var contentConfiguration: UIContentConfiguration?
    
    init(_ kind: Kind, height: CGFloat = UITableView.automaticDimension) {
        self.kind = kind
        self.height = height
    }
    
    @discardableResult
    func loadAccessoryViewInContent(_ isInContent: Bool = true) -> Self {
        guard case .accessory = kind else { return self }
        isLoadingAccessoryViewInContent = isInContent
        return self
    }
    
    @discardableResult
    func data(_ data: Any) -> Self {
        self.data = data
        return self
    }
    
    @discardableResult
    func onSelect(_ handler: @escaping (IndexPath) -> Void) -> Self {
        selectHandler = handler
        return self
    }
    
    @discardableResult
    func contentConfiguration(_ config: UIContentConfiguration) -> Self {
        contentConfiguration = config
        return self
    }
}

// MARK: - SectionBanner

enum SectionBanner {
    case text(String)
    case view(UIView)
}
