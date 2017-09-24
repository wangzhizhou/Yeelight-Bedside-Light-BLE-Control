//
//  BLEManager+CBPeripheralDelegate.swift
//  jokerHub
//
//  Created by JokerAtBaoFeng on 2017/9/22.
//  Copyright © 2017年 joker. All rights reserved.
//
import CoreBluetooth

extension BLEManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if let services = peripheral.services {
            
            for service in services {
                if service.uuid.uuidString == YeelightService.mcu.rawValue {
                    print(service)
                    peripheral .discoverCharacteristics(nil, for: service)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            
            for characteristic in characteristics {
                
                if characteristic.properties.contains([.write]),characteristic.uuid.uuidString == YeelightMCUCharacteristc.control.rawValue {
                    
                    print("yeelight mcu control: \(characteristic)")
                    yeelightMCUControllCharacteristic = characteristic
                    
                    print("send the auth access data to peripheral")
                    peripheral.writeValue(YeelightControllCommand.authAccess.data, for: characteristic, type: .withResponse)
                }
                
                if characteristic.properties.contains(.notify),characteristic.uuid.uuidString == YeelightMCUCharacteristc.status.rawValue {
                    print("yeelight mcu status: \(characteristic)")
                    yeelightMCUStatucCharacteristic = characteristic
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        print("update Value for: \(characteristic.uuid)")
        
        if let data = characteristic.value {
            
            if (data[0] == 0x43 && data[1] == 0x45) {
                
                
                
                print("Bright: \(data[8])")
                
                lightMode.value = data[3]
                lightBrightness.value = data[8]
                
                if (data[2] == 1) {
                    print("Power On")
                    lightPowerOn.value = true
                    
                }
                else {
                    print("Power Off")
                    lightPowerOn.value = false
                    
                }
            }
        }
    }

    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        if characteristic.uuid.uuidString == YeelightMCUCharacteristc.status.rawValue {
            
            print("updateNotificationState for: \(characteristic)")
            
            if characteristic.isNotifying,
                let control = yeelightMCUControllCharacteristic {
                peripheral.writeValue(YeelightControllCommand.status.data, for: control, type: .withResponse)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
    }
}
