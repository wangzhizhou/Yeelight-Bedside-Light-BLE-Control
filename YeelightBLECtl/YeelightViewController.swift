//
//  YeelightViewController
//  jokerHub
//
//  Created by JokerAtBaoFeng on 2017/9/22.
//  Copyright © 2017年 joker. All rights reserved.
//

import UIKit
import RxSwift
import OrzBLE

class YeelightViewController: UIViewController {
    
    let bag = DisposeBag()
    
    let light = XMCTD01YL.shared
    
    @IBOutlet weak var lightModeSeg: UISegmentedControl!
    @IBAction func lightMode(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            light.dayLight()
        case 1:
            light.ambiLight()
        case 2:
            light.colorLight((R: 0x00, G: 0xFF, B: 0x00, brightness: 100))
        default:
            break
        }
    }
    
    @IBOutlet weak var lightSwitch: UISwitch!
    
    @IBAction func switchLight(_ sender: UISwitch) {
        
        if sender.isOn {
            light.powerOn()
        }
        else {
            light.powerOff()
        }
    }
    
    @IBOutlet weak var brightness: UISlider!
    @IBAction func setBrightnessAction(_ sender: UISlider) {
        light.brightLight(UInt8(100 * sender.value))
    }
    @IBAction func disconnect(_ sender: UIBarButtonItem) {
        light.disconnect()
    }
    @IBAction func reconnect(_ sender: UIBarButtonItem) {
        light.connect()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hiddenLightControl()
        
        light.connectedDevice.subscribe(onNext: { [weak self](peripheral) in
            self?.title = peripheral.name
        }).disposed(by: bag)
        
        light.power.subscribe(onNext: { [weak self] (isPowerOn) in
            self?.lightSwitch.isOn = isPowerOn
            self?.showLightControl()
        }).disposed(by: bag)
        
        
        light.bright.subscribe(onNext: { [weak self] (bright) in
            self?.brightness.value = Float(bright) / 100.0
        }).disposed(by: bag)
        
        light.error.subscribe(onNext: { (error) in
            JokerAlertManager.shareInstance.showAlertWith(message: error.localizedDescription)
        }).disposed(by: bag)
        
        light.lightMode.subscribe(onNext: { [weak self](mode) in
            switch mode {
            case 2:
                self?.lightModeSeg.selectedSegmentIndex = 0
            case 3:
                self?.lightModeSeg.selectedSegmentIndex = 1
            case 1:
                self?.lightModeSeg.selectedSegmentIndex = 2
            default:
                break;
            }
        }).disposed(by: bag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.hiddenLightControl()
        light.connect()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
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
    
    deinit {
        print("Yeelight deinit")
    }
}
