//
//  AppManager.swift
//  CTTranslation
//
//  Created by 阳剑 on 2024/5/17.
//

import UIKit

public class AppManager: NSObject {
    @objc public static let shared = AppManager()
    
    @objc var window: UIWindow? = nil
    
    @objc let bannerVC: UIViewController = .init()
    
    @objc var isDebug: Bool = true
    
}
