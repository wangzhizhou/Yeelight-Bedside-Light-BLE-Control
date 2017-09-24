//
//  YeelightViewController
//  jokerHub
//
//  Created by JokerAtBaoFeng on 2017/9/22.
//  Copyright © 2017年 joker. All rights reserved.
//

import UIKit
import CoreBluetooth
import RxSwift

class YeelightViewController: UIViewController {
    
    let bag = DisposeBag()
    
    let bleManager = BLEManager()
    
    @IBOutlet weak var lightModeSeg: UISegmentedControl!
    @IBAction func lightMode(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print("daylight mode")
            self.sendBLELightCommand(.daylight)
        case 1:
            print("ambilight mode")
            JokerAlertManager.shareInstance.showAlertWith(message: "流光命令没有破解出来，有知道的联系我")
            self.sendBLELightCommand(.transition)
        case 2:
            print("color mode")
             self.sendBLELightCommand(.color((R: 0xFF, G: 0, B: 0)))
        default:
            print("Out of bound!")
        }
    }
    
    @IBOutlet weak var lightSwitch: UISwitch!
    
    @IBAction func switchLight(_ sender: UISwitch) {
        
        if sender.isOn {
            self.sendBLELightCommand(.powerOn)
        }
        else {
            self.sendBLELightCommand(.powerOff)
        }
    }
    
    @IBOutlet weak var brightness: UISlider!
    
    @IBAction func setBrightnessAction(_ sender: UISlider) {
        
        
        self.sendBLELightCommand(.bright(UInt8(100 * sender.value)))
    }
    
    
    private func sendBLELightCommand(_ command: YeelightControllCommand)
    {
        if let yeelightBedside = bleManager.discoveredPeripheral,
            let mcuControl = bleManager.yeelightMCUControllCharacteristic {
            yeelightBedside.writeValue(command.data, for: mcuControl, type: .withResponse)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hiddenLightControl()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        bleManager.lightPowerOn
            .asObservable()
            .subscribe(onNext: {
                [weak self] (powerOn) in
                
                if self?.lightSwitch.isOn != powerOn {
                    self?.lightSwitch.isOn = powerOn
                }
            })
            .addDisposableTo(bag)
        
        bleManager.lightBrightness
            .asObservable()
            .subscribe {
                [weak self] (event) in
                
                guard let brightness = event.element else {
                    print("invalid bright event")
                    return
                }
                self?.brightness.value = Float(brightness) / 100.0
                
            }
            .addDisposableTo(bag)
        
        bleManager.isConnected
            .subscribe(
                onNext: {
                    (peripheral) in
                    self.showLightControl()
                    self.title = peripheral.name
            },
                onError: {
                    (error) in
                    JokerAlertManager.shareInstance.showAlertWith(message: error.localizedDescription)
            })
            .addDisposableTo(bag)
        
        bleManager.lightMode.asObservable()
            .distinctUntilChanged()
            .subscribe {[weak self] (event) in
                guard let mode = event.element else {
                    return
                }
                
                print("light mode: \(mode)")
                
                switch mode {
                case 2:
                    self?.lightModeSeg.selectedSegmentIndex = 0
                case 3:
                    self?.lightModeSeg.selectedSegmentIndex = 1
                case 1:
                    self?.lightModeSeg.selectedSegmentIndex = 2
                default:
                    print("unknown light mode")
                }
        }
        .addDisposableTo(bag)
        
        bleManager.managerAvailable.asObservable()
            .subscribe { [weak self] (event) in
                
                guard let managerAvailable = event.element else {
                    return
                }
                if managerAvailable {
                    self? .beginConnect()
                }
        }
        .addDisposableTo(bag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.cancelConnect()
    }
    
    @IBAction func scanPeripheral() {
        self.beginConnect()
    }
    private func beginConnect() {
        self.hiddenLightControl()
        bleManager.scan(peripheral: .yeelightBedside)
    }
    
    @IBAction func disconnect(_ sender: Any) {
        self.cancelConnect()
    }
    
    private func cancelConnect() {
        if let connectedPeripheral = bleManager.connectedPeripheral,
            let instance = bleManager.instance as? CBCentralManager {
            instance.cancelPeripheralConnection(connectedPeripheral)
        }
    }
    
    private func hiddenLightControl() {
        self.lightSwitch.isHidden = true
        self.brightness.isHidden = true
        self.lightModeSeg.isHidden = true
    }
    
    private func showLightControl() {
        self.lightSwitch.isHidden = false
        self.brightness.isHidden = false
        self.lightModeSeg.isHidden = false
    }
}
