//
//  JokerAlertManager.swift
//  jokerHub
//
//  Created by JokerAtBaoFeng on 2017/6/1.
//  Copyright © 2017年 joker. All rights reserved.
//

import UIKit

class JokerAlertManager {
    
    static let shareInstance = JokerAlertManager()
    
    func showAlertWith(title: String? = "Oops 😏", message: String?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(action)
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        
    }
    
}
