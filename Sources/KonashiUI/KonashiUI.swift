//
//  KonashiUI.swift
//  konashi-ios-sdk2
//
//  Created by Akira Matsuda on 2021/08/10.
//

import Combine
import JGProgressHUD
import Konashi
import Promises
import UIKit

public final class KonashiUI {
    public static let shared = KonashiUI()
    public static let defaultRSSIThreshold: NSNumber = -80

    fileprivate var hudCancellable = Set<AnyCancellable>()
    private var cancellable = Set<AnyCancellable>()
    fileprivate var discoveredPeripherals = Set<KonashiPeripheral>()
    var rssiThreshold: NSNumber = defaultRSSIThreshold

    init() {
        CentralManager.shared.didDiscoverSubject.sink { [weak self] peripheral in
            guard let weakSelf = self, let peripheral = peripheral as? KonashiPeripheral else {
                return
            }
            if weakSelf.rssiThreshold.decimalValue <= peripheral.currentRSSI.decimalValue {
                weakSelf.discoveredPeripherals.insert(peripheral)
            }
        }.store(in: &cancellable)
        CentralManager.shared.$isScanning.sink { scanning in
            guard let window = UIApplication.shared.windows.first else {
                return
            }
            if scanning {
                let hud = JGProgressHUD()
                hud.textLabel.text = "Scanning"
                hud.show(in: window)
            }
            else {
                JGProgressHUD.allProgressHUDs(in: window).forEach { hud in
                    hud.dismiss()
                }
            }
        }.store(in: &cancellable)
        CentralManager.shared.$isConnecting.sink { connecting in
            guard let window = UIApplication.shared.windows.first else {
                return
            }
            if connecting {
                let hud = JGProgressHUD()
                hud.textLabel.text = "Connecting"
                hud.show(in: window)
            }
            else {
                JGProgressHUD.allProgressHUDs(in: window).forEach { hud in
                    hud.dismiss()
                }
            }
        }.store(in: &cancellable)
        CentralManager.shared.didDisconnectSubject.sink { _ in
            KonashiUI.shared.discoveredPeripherals.removeAll()
            KonashiUI.shared.hudCancellable.removeAll()
            guard let window = UIApplication.shared.windows.first else {
                return
            }
            JGProgressHUD.allProgressHUDs(in: window).forEach { hud in
                hud.dismiss()
            }
        }.store(in: &cancellable)
    }
}

extension UIViewController: AlertPresentable {
    var presentingViewController: UIViewController {
        return self
    }

    public func presentCandidatePeripheral(name: String, timeoutDuration: TimeInterval = 3, rssiThreshold: NSNumber = KonashiUI.defaultRSSIThreshold) {
        KonashiUI.shared.rssiThreshold = rssiThreshold
        CentralManager.shared.find(name: name).timeout(timeoutDuration).then { [weak self] peripheral in
            guard let weakSelf = self else {
                return
            }
            var name: String {
                guard let name = peripheral.name else {
                    return ""
                }
                return name
            }
            let alertController = UIAlertController(
                title: NSLocalizedString("このKoshianと接続しますか？", comment: ""),
                message: name,
                preferredStyle: .alert
            )
            alertController.addAction(
                UIAlertAction(
                    title: NSLocalizedString("接続", comment: ""),
                    style: .default,
                    handler: { _ in
                        peripheral.connect().then { [weak self] peripheral in
                            guard let weakSelf = self else {
                                return
                            }
                            weakSelf.presentConnectedAlertController(name: peripheral.name)
                        }.catch { error in
                            guard let weakSelf = self else {
                                return
                            }
                            weakSelf.presentAlertViewController(
                                AlertContext(
                                    title: NSLocalizedString("接続できませんでした", comment: ""),
                                    detail: error.localizedDescription
                                )
                            )
                        }
                    }
                )
            )
            alertController.addAction(
                UIAlertAction(
                    title: NSLocalizedString("キャンセル", comment: ""),
                    style: .cancel,
                    handler: nil
                )
            )
            weakSelf.present(alertController, animated: true, completion: nil)
        }.catch { [weak self] _ in
            CentralManager.shared.stopScan()
            guard let weakSelf = self else {
                return
            }
            let alertController = UIAlertController(
                title: NSLocalizedString("次の名前のKoshianが見つかりませんでした", comment: ""),
                message: name,
                preferredStyle: .alert
            )
            alertController.addAction(
                UIAlertAction(
                    title: NSLocalizedString("OK", comment: ""),
                    style: .cancel,
                    handler: nil
                )
            )
            weakSelf.present(alertController, animated: true, completion: nil)
        }
    }

    public func presentKoshianListViewController(
        scanDuration: TimeInterval = 3,
        rssiThreshold: NSNumber = KonashiUI.defaultRSSIThreshold
    ) -> Promise<any Peripheral> {
        let promise = Promise<any Peripheral>.pending()
        KonashiUI.shared.rssiThreshold = rssiThreshold
        CentralManager.shared.scan().delay(scanDuration).then(CentralManager.shared.stopScan).then { [weak self] _ in
            guard let weakSelf = self else {
                return
            }
            if KonashiUI.shared.discoveredPeripherals.isEmpty {
                let alertController = UIAlertController(
                    title: nil,
                    message: NSLocalizedString("接続可能なKoshianを発見できませんでした", comment: ""),
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
                weakSelf.present(alertController, animated: true, completion: nil)
                return
            }

            let alertController = UIAlertController(
                title: NSLocalizedString("接続するKoshianを選択してください", comment: ""),
                message: nil,
                preferredStyle: .actionSheet
            )
            for peripheral in KonashiUI.shared.discoveredPeripherals {
                alertController.addAction(
                    UIAlertAction(
                        title: peripheral.name,
                        style: .default,
                        handler: { _ in
                            KonashiUI.shared.hudCancellable.removeAll()
                            peripheral.isReady.sink { ready in
                                guard let window = UIApplication.shared.windows.first else {
                                    return
                                }
                                if ready == false {
                                    let hud = JGProgressHUD()
                                    hud.textLabel.text = "Preparing..."
                                    hud.show(in: window)
                                }
                                else {
                                    JGProgressHUD.allProgressHUDs(in: window).forEach { hud in
                                        hud.dismiss()
                                    }
                                }
                            }.store(in: &KonashiUI.shared.hudCancellable)
                            peripheral.connect().then { [weak self] peripheral in
                                guard let weakSelf = self else {
                                    return
                                }
                                promise.fulfill(peripheral)
                                weakSelf.presentConnectedAlertController(name: peripheral.name)
                            }.catch { error in
                                guard let weakSelf = self else {
                                    return
                                }
                                weakSelf.presentAlertViewController(
                                    AlertContext(
                                        title: NSLocalizedString("接続できませんでした", comment: ""),
                                        detail: error.localizedDescription
                                    )
                                )
                            }
                        }
                    )
                )
            }
            alertController.addAction(
                UIAlertAction(
                    title: NSLocalizedString("キャンセル", comment: ""),
                    style: .cancel,
                    handler: nil
                )
            )
            weakSelf.present(alertController, animated: true, completion: nil)
        }
        return promise
    }

    private func presentConnectedAlertController(name: String?) {
        let alertController = UIAlertController(
            title: NSLocalizedString("次のKoshianに接続しました", comment: ""),
            message: name,
            preferredStyle: .alert
        )
        alertController.addAction(
            UIAlertAction(
                title: NSLocalizedString("OK", comment: ""),
                style: .cancel,
                handler: nil
            )
        )
        present(alertController, animated: true, completion: nil)
    }
}
