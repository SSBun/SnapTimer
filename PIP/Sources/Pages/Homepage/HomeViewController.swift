//
//  HomeViewController.swift
//  PIP
//
//  Created by caishilin on 2024/5/28.
//

import AVFAudio
import RxCocoa
import RxSwift
import UIKit
import SwiftRichString

// MARK: - PreviewAreaView

class PreviewAreaView: NiblessView {
    let areaView = UIView()
    let cardView = PIPCard()
    
    init() {
        super.init(frame: .zero)
        
        setupUI()
    }
    
    private func setupUI() {
        addSubview(areaView)
        areaView.backgroundColor = .clear
        areaView.addSubview(cardView)
        areaView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        }
        cardView.layer.cornerRadius = 10
        cardView.clipsToBounds = true
    }
    
    func update(watchDial: UIView & WatchDial & PIPContentView) {
        let size = areaView.bounds.size
        let resultW: CGFloat
        let resultH: CGFloat
        if watchDial.aspectRatio > size.width / size.height {
            resultW = size.width
            resultH = resultW / watchDial.aspectRatio
        } else {
            resultH = size.height
            resultW = resultH * watchDial.aspectRatio
        }
        cardView.snp.remakeConstraints {
            $0.width.equalTo(resultW)
            $0.height.equalTo(resultH)
            $0.center.equalToSuperview()
        }
        cardView.updateLayout(width: Int(resultW), height: Int(resultH), color: watchDial.fillColor)
        cardView.update(content: watchDial)
    }
}

// MARK: - HomeViewController

final class HomeViewController: BaseViewController {
    private let listView = StaticTableView(frame: .zero, style: .insetGrouped)
    
    private let previewAreaView = PreviewAreaView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        navigationItem.title = .local("Time")
        
        setupUI()
        
        appState.$showMilliseconds
            .asyncBind(onNext: { [weak self] in
                if let (indexPath, _) = self?.listView.listLayout.indexPath(of: "MillisecondsColor") {
                    self?.listView.updateCellVisibility(hidden: !$0, at: indexPath)
                }
                if let (indexPath, _) = self?.listView.listLayout.indexPath(of: "TwoDigitalMilliseconds") {
                    self?.listView.updateCellVisibility(hidden: !$0, at: indexPath)
                }
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(appState.$timeColor, appState.$timeBackgroundColor, appState.$timeMillisecondColor)
            .skip(1)
            .asyncBind(onNext: { _ in
                appState.useDynamicColor = false
            })
            .disposed(by: disposeBag)
        
        appState.$timerRemindOffset
            .bind(onNext: { [weak self] offset in
                guard let self else { return }
                if let (_, cell) = self.listView.listLayout.visibleIndexPath(of: "TimeOffset") {
                    (cell as? Cell)?.contentConfiguration = .list(.cell()) {
                        $0.attributedText = .local("Time offset") + ": \(offset) ms".set(style: Style {
                            $0.font = UIFont.systemFont(ofSize: 17)
                            $0.color = UIColor.systemGreen
                        })
                    }
                    self.listView.reloadData()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setupUI() {
        view.addSubview(listView)
        listView.contentInset = .init(top: 20, left: 0, bottom: 0, right: 0)
        listView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        listView.listLayout = ListLayout {
            Section {
                Cell(.unique(previewAreaView), height: 130)
            }
            .header(.text(.local("Preview")))
            .footer(height: 10)
            
            Section {
                Cell(.accessory(.list(.cell()) { $0.text = .local("Show in PIP")}, accessory: UISwitch().then({ switchBtn in
                    appState.$previewInPIP.bind { [weak switchBtn] in
                        switchBtn?.setOn($0, animated: true)
                    }.disposed(by: disposeBag)
                    switchBtn.rx.isOn
                        .skip(1)
                        .bind { [weak self] in
                            self?.previewAreaView.cardView.toggle(inPIP: $0)
                        }
                        .disposed(by: disposeBag)
                })))
                Cell(.accessory(.list(.cell()) { $0.text = .local("Auto PIP")}, accessory: UISwitch().then({ switchBtn in
                    appState.$autoPIP
                        .distinctUntilChanged()
                        .bind { [weak switchBtn] in
                            switchBtn?.setOn($0, animated: true)
                        }.disposed(by: disposeBag)
                    switchBtn.rx.isOn
                        .skip(1)
                        .bind {
                            appState.autoPIP = $0
                        }
                        .disposed(by: disposeBag)
                })))
            }
            .header(height: 0)
            
            Section {
                Cell(.accessory(.list(.cell()) { $0.text = .local("Size")}, accessory: CardStyleSelectionView(size: CGSize(width: 180, height: 30))))
                // Whether displaying milliseconds
                Cell(.accessory(.list(.cell()) { $0.text = .local("Show milliseconds")}, accessory: UISwitch().then({ switchBtn in
                    appState.$showMilliseconds
                        .distinctUntilChanged()
                        .bind { [weak switchBtn] in
                            switchBtn?.setOn($0, animated: true)
                        }.disposed(by: disposeBag)
                    switchBtn.rx.isOn
                        .skip(1)
                        .bind {
                            appState.showMilliseconds = $0
                        }
                        .disposed(by: disposeBag)
                })))
                // Whether to showTwoDigitalMilliseconds
                Cell(.accessory(.list(.cell()) { $0.text = .local("Two-digital Milliseconds")}, accessory: UISwitch().then({ switchBtn in
                    appState.$showTwoDigitalMilliseconds
                        .distinctUntilChanged()
                        .bind { [weak switchBtn] in
                            switchBtn?.setOn($0, animated: true)
                        }.disposed(by: disposeBag)
                    switchBtn.rx.isOn
                        .skip(1)
                        .bind {
                            appState.showTwoDigitalMilliseconds = $0
                        }
                        .disposed(by: disposeBag)
                })))
                .flag("TwoDigitalMilliseconds")
                .visible(appState.showMilliseconds)
            }
            .header(.text(.local("Styles")))
            
            Section {
                // Use dynamic colors
                Cell(.accessory(.list(.cell()) { $0.text = .local("Use dynamic color")}, accessory: UISwitch().then({ switchBtn in
                    appState.$useDynamicColor
                        .distinctUntilChanged()
                        .bind { [weak switchBtn] in
                            switchBtn?.setOn($0, animated: true)
                        }.disposed(by: disposeBag)
                    switchBtn.rx.isOn
                        .skip(1)
                        .bind {
                            appState.useDynamicColor = $0
                        }
                        .disposed(by: disposeBag)
                })))
                // Select seconds color
                Cell(.accessory(.list(.cell()) { $0.text = .local("Seconds color")}, accessory: UIColorWell(frame: CGRect(x: 0, y: 0, width: 30, height: 30)).then({ colorWell in
                    colorWell.selectedColor = UIColor(hexString: appState.timeColor)
                    colorWell.rx.controlEvent(.valueChanged)
                        .compactMap({ [weak colorWell] in colorWell?.selectedColor?.hexString })
                        .distinctUntilChanged()
                        .asyncBind(onNext: {
                            appState.timeColor = $0
                        })
                        .disposed(by: disposeBag)
                })))
                // Select background color
                Cell(.accessory(.list(.cell()) { $0.text = .local("Background color")}, accessory: UIColorWell(frame: CGRect(x: 0, y: 0, width: 30, height: 30)).then({ colorWell in
                    colorWell.selectedColor = UIColor(hexString: appState.timeBackgroundColor)
                    colorWell.rx.controlEvent(.valueChanged)
                        .compactMap({ [weak colorWell] in colorWell?.selectedColor?.hexString })
                        .distinctUntilChanged()
                        .asyncBind(onNext: {
                            appState.timeBackgroundColor = $0
                        })
                        .disposed(by: disposeBag)
                })))
                // Select milliseconds color
                Cell(.accessory(.list(.cell()) { $0.text = .local("Milliseconds color")}, accessory: UIColorWell(frame: CGRect(x: 0, y: 0, width: 30, height: 30)).then({ colorWell in
                    colorWell.selectedColor = UIColor(hexString: appState.timeMillisecondColor)
                    colorWell.rx.controlEvent(.valueChanged)
                        .compactMap({ [weak colorWell] in colorWell?.selectedColor?.hexString })
                        .distinctUntilChanged()
                        .asyncBind(onNext: {
                            appState.timeMillisecondColor = $0
                        })
                        .disposed(by: disposeBag)
                })))
                .flag("MillisecondsColor")
                .visible(appState.showMilliseconds)
            }
            .header(height: 0)
            
            Section {
                // Whether to show timer reminder
                Cell(.accessory(.list(.cell()) { $0.text = .local("Show timer reminder")}, accessory: UISwitch().then({ switchBtn in
                    appState.$showTimerReminder
                        .distinctUntilChanged()
                        .bind { [weak switchBtn] in
                            switchBtn?.setOn($0, animated: true)
                        }.disposed(by: disposeBag)
                    switchBtn.rx.isOn
                        .skip(1)
                        .bind {
                            appState.showTimerReminder = $0
                        }
                        .disposed(by: disposeBag)
                })))
                // Timer reminder offset stepper
                Cell(.accessory(.list(.cell()), accessory: UIStepper().then({ stepper in
                    stepper.frame = .init(origin: .zero, size: .init(width: 150, height: 30))
                    stepper.minimumValue = 0
                    stepper.maximumValue = 500
                    stepper.stepValue = 50
                    stepper.value = Double(appState.timerRemindOffset)
                    stepper.rx.value
                        .distinctUntilChanged()
                        .bind {
                            appState.timerRemindOffset = Int($0)
                        }
                        .disposed(by: disposeBag)
                })))
                .flag("TimeOffset")
            }
            .header(.text(.local("Remind")))
            .footer(.text("抢购时，考虑到网络请求需要时间，提前100-300毫秒点击购买，秒杀的成功率更高!"))
        }
        
        DispatchQueue.main.async {
            appState.$selectedCardStyle
                .bind { [weak self] in
                    self?.previewAreaView.update(watchDial: NormalClockDial(aspectRatio: $0.scale))
                }
                .disposed(by: self.disposeBag)
        }
    }
}


#Preview {
    BaseNavigationController(rootViewController: HomeViewController())
}
