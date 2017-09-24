//
//  BLEManager+CBPeripheralManagerDelegate.swift
//  jokerHub
//
//  Created by JokerAtBaoFeng on 2017/9/22.
//  Copyright © 2017年 joker. All rights reserved.
//

import CoreBluetooth

extension BLEManager: CBPeripheralManagerDelegate {
    //    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
    //        if let centrals = dict[CBPeripheralManagerOptionRestoreIdentifierKey] {
    //            print(centrals)
    //        }
    //    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        guard peripheral.state == .poweredOn else {
            print("BLE Peripheral Manager is PoweredOff!")
            return
        }
        
        //can use cmd `uuidgen` to generate UUID for custom service and characteristic
        let characteristicUUID = CBUUID(string: "180D")
        let characteristic = CBMutableCharacteristic(type: characteristicUUID, properties: .read, value: nil, permissions: .readable)
        
        let serviceUUID = CBUUID()
        let service = CBMutableService(type: serviceUUID, primary: true)
        service.characteristics = [characteristic]
        
        peripheral.add(service)
        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
        
        peripheral.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [service.uuid]])
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        
        if request.characteristic.uuid.isEqual(CBUUID()){
            
            let c = CBMutableCharacteristic(type: CBUUID(), properties: [.read,.write], value: Data(), permissions: [.readable,.writeable])
            
            if(request.offset > (c.value?.count)!){
                peripheral.respond(to: request, withResult: .invalidOffset)
            }
            
            request.value = Data()
            peripheral.respond(to: request, withResult: .success)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        
        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("central subscribed characteristic \(characteristic)")
        
        let c = CBMutableCharacteristic(type: CBUUID(), properties: .read, value: Data(), permissions: .readable)
        peripheral.updateValue(Data(), for: c, onSubscribedCentrals: nil)
    }
}
