//
//  BLEManager.swift
//  jokerHub
//
//  Created by JokerAtBaoFeng on 2017/9/19.
//  Copyright © 2017年 joker. All rights reserved.
//

import Foundation
import CoreBluetooth
import RxSwift

enum BLEPeripheral: String {
    case unknown
    case yeelightBedside = "XMCTD_"
}

enum YeelightService: String {
    case mcu = "8E2F0CBD-1A66-4B53-ACE6-B494E25F87BD"
}

enum YeelightMCUCharacteristc: String {
    case control = "AA7D3F34-2D4F-41E0-807F-52FBF8CF7443"
    case status = "8F65073D-9F57-4AAA-AFEA-397D19D5BBEB"
}

enum YeelightControllCommand {
    case status
    case powerOn,powerOff
    case authAccess
    case bright(UInt8)
    case color((R: UInt8,G: UInt8,B: UInt8))
    case daylight
    case transition
    
//    case ambilightConfig((UInt8,UInt8,UInt8,UInt8,UInt8,UInt8))
//    case ambilight
    
    var data: Data {
        
        var cmdData = Data(count:18)
        
        switch self {
        case .status:
            cmdData[0] = 0x43
            cmdData[1] = 0x44
        case .powerOn:
            cmdData[0] = 0x43
            cmdData[1] = 0x40
            cmdData[2] = 0x01
        case .powerOff:
            cmdData[0] = 0x43
            cmdData[1] = 0x40
            cmdData[2] = 0x02
        case .authAccess:
            cmdData[0] = 0x43
            cmdData[1] = 0x67
            cmdData[2] = 0xDE
            cmdData[3] = 0xAD
            cmdData[4] = 0xBE
            cmdData[5] = 0xBF
        case .bright(let brightness):
            cmdData[0] = 0x43
            cmdData[1] = 0x42
            cmdData[2] = brightness
        case .color(let color):
            cmdData[0] = 0x43
            cmdData[1] = 0x41
            cmdData[2] = color.R
            cmdData[3] = color.G
            cmdData[4] = color.B
            cmdData[5] = 0xFF
            cmdData[6] = 0x65
        case .daylight:
            cmdData[0] = 0x43
            cmdData[1] = 0x4A
            cmdData[2] = 0x01
            cmdData[3] = 0x01
            cmdData[4] = 0x01
        case .transition:
            cmdData[0] = 0x43
            cmdData[1] = 0x7F
            cmdData[2] = 0x03
            
//流光命令还没有成功
//        case .ambilight:
//            cmdData[0] = 0x43
//            cmdData[1] = 0x4A
//            cmdData[2] = 0x01
//            cmdData[3] = 0x03
//            cmdData[4] = 0x02
//            cmdData[9] = 0x30
//            cmdData[11] = 0x24
            
        }
        
        return cmdData
    }
}

class BLEManager: NSObject {

    enum BLERole {
        case central
        case peripheral
    }
    
    private let role: BLERole
    private var centralManger: CBCentralManager?
    private var peripheralManager: CBPeripheralManager?
    
    var instance: CBManager? {
        switch role {
        case .central:
            return centralManger
        case .peripheral:
            return peripheralManager
        }
    }
    var connectedPeripheral: CBPeripheral?
    var targetPeripheral: BLEPeripheral
    var discoveredPeripheral: CBPeripheral?
    
    var yeelightMCUControllCharacteristic: CBCharacteristic?
    var yeelightMCUStatucCharacteristic: CBCharacteristic?
    
    let managerAvailable = Variable<Bool>(false)
    let lightPowerOn = Variable<Bool>(false)
    let lightBrightness = Variable<UInt8>(0)
    let lightMode = Variable<UInt8>(0)
    
    let isConnected = PublishSubject<CBPeripheral>()
    
    init(role: BLERole = .central) {
        self.role = role
        targetPeripheral = .unknown
        super.init()
        
        switch role {
            
        case .central:
            
            self.centralManger = CBCentralManager(delegate: self, queue: nil, options: nil)
            
        case .peripheral:
            
            self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        }
    }
    
    func scan(peripheral: BLEPeripheral) {
        
        guard let manager = self.centralManger, manager.state == .poweredOn  else {
            return
        }
        
        targetPeripheral = peripheral
        
        
        if let mcuControlService = self.yeelightMCUControllCharacteristic,
           let mcuStatusService = self.yeelightMCUStatucCharacteristic {
            
            let peripherals = manager.retrieveConnectedPeripherals(withServices: [mcuControlService.uuid, mcuStatusService.uuid])
            
            peripherals.forEach({ [weak self] (peripheral) in
                if let _ = peripheral.name?.hasPrefix(BLEPeripheral.yeelightBedside.rawValue) {
                    self?.discoveredPeripheral = peripheral
                    manager.connect(peripheral, options: nil)
                    return
                }
            })
        }
        
        if let discoveredPeripheral = self.discoveredPeripheral {
            
           let peripherals = manager.retrievePeripherals(withIdentifiers: [discoveredPeripheral.identifier])
            
            peripherals.forEach({[weak self](peripheral) in
                if let _ = peripheral.name?.hasPrefix(BLEPeripheral.yeelightBedside.rawValue) {
                    self?.discoveredPeripheral = peripheral
                    manager.connect(peripheral, options: nil)
                    return
                }
            })
        }
                
        manager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    
}
