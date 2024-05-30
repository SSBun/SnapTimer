//
//  NiblessView.swift
//  PIP
//
//  Created by caishilin on 2024/5/28.
//

import UIKit
import RxSwift

class NiblessView: UIView {
    let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable, message: "Loading this view from a nib is unsupported.")
    required init?(coder: NSCoder) {
        fatalError("Loading this view from a nib is unsupported.")
    }
}
