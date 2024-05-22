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
    
    @objc var isDismissFullAd = false
    
    @UserDefault(key: "show.choose.vc")
    var needChooseVC: Bool?
    @objc var getNeedChooseVC: Bool {
        return needChooseVC ?? true
    }
    @objc func updateNeedChooseVC() {
        needChooseVC = false   
    }
    
    @UserDefault(key: "text.translate.guide")
    var needTextGuide: Bool?
    @objc var getNeedTextGuide: Bool {
        defer {
            needTextGuide = false
        }
        return needTextGuide ?? true
    }
    
    @UserDefault(key: "voice.translate.guide")
    var needVoiceGuide: Bool?
    @objc var getNeedVoiceGuide: Bool {
        defer {
            needVoiceGuide = false
        }
        return needVoiceGuide ?? true
    }
    
    @UserDefault(key: "text.camera.guide")
    var needCameraGuide: Bool?
    @objc var getNeedCameraGuide: Bool {
        defer {
            needCameraGuide = false
        }
        return needCameraGuide ?? true
    }
}
