//
//  BLEManager+CBCentralManagerDelegate.swift
//  jokerHub
//
//  Created by JokerAtBaoFeng on 2017/9/22.
//  Copyright © 2017年 joker. All rights reserved.
//

import CoreBluetooth

extension BLEManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
        case .unknown:
            print("unknown")
        case .unsupported:
            print("unsupport")
            JokerAlertManager.shareInstance.showAlertWith(message: "BLE unsupport")
        case .unauthorized:
            print("unauthorized")
            JokerAlertManager.shareInstance.showAlertWith(message: "BLE unauthorized")
        case .resetting:
            print("resetting")
            JokerAlertManager.shareInstance.showAlertWith(message: "BLE resetting")
        case .poweredOn:
            print("poweredOn")
            managerAvailable.value = true
        case .poweredOff:
            print("poweredOff")
            managerAvailable.value = false
            JokerAlertManager.shareInstance.showAlertWith(message: "BLE powered Off")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("Discovered Peripheral: \(peripheral)")

        if let name = peripheral.name, name.hasPrefix(targetPeripheral.rawValue) {
            discoveredPeripheral = peripheral
            central.stopScan()
            central.connect(peripheral, options: nil)
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        print("Connected Peripheral: \(peripheral)")
        peripheral.delegate = self
        isConnected.onNext(peripheral)
        connectedPeripheral = peripheral
        peripheral.discoverServices(nil)

    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
        if let error = error {
            print("FailToConnect: \(error.localizedDescription)")
            isConnected.onError(error)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    
        if let error = error {
            print(error.localizedDescription)
            isConnected.onError(error)
        }
    
        JokerAlertManager.shareInstance.showAlertWith(message: "\(peripheral.name ?? "peripheral") has disconnected!")
    }
}
