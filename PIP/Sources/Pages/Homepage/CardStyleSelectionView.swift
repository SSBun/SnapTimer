//
//  CardStyleSelectionView.swift
//  PIP
//
//  Created by caishilin on 2024/5/28.
//

import UIKit
import Combine

class CardStyleSelectionView: NiblessView {
    let segmentView = UISegmentedControl(items: CardStyle.allCases.map(\.description))
    
    init(size: CGSize) {
        super.init(frame: .init(origin: .zero, size: size))
        
        setupUI()
    }
    
    private func setupUI() {
        addSubview(segmentView)
        segmentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(31)
            $0.center.equalToSuperview()
        }
        segmentView.addTarget(self, action: #selector(itemDidSelected), for: .valueChanged)
        
        segmentView.selectedSegmentIndex = appState.selectedCardStyle.rawValue
        
        appState.$selectedCardStyle
            .distinctUntilChanged()
            .map(\.rawValue)
            .bind { [weak self] in
                guard let self else { return }
                self.segmentView.selectedSegmentIndex = $0
            }
            .disposed(by: disposeBag)
    }
    
    @objc private func itemDidSelected() {
        let selectedIndex = segmentView.selectedSegmentIndex
        appState.selectedCardStyle = .init(rawValue: selectedIndex)!
    }
}

#Preview {
    CardStyleSelectionView(size: .init(width: 200, height: 40))
}
