//
//  RemoteUtil.swift
//  XXTranslate
//
//  Created by  sunlang on 2024/4/28.
//

import Foundation
import FirebaseCore
import FirebaseRemoteConfig

class RemoteUtil: NSObject {
    @objc static let shared = RemoteUtil()
    private lazy var remoteConfig = {
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        return remoteConfig
    }()
    private var gadConfig: GADConfig?
    
    override init() {
        super.init()
        FirebaseApp.configure()
    }
    
    @objc func requestGADConfig() {
        remoteConfig.fetch { status, error in
            if status == .success {
                self.remoteConfig.activate { (changed, error) in
                    // Remote Config数据已准备好，可以使用了
                    let configData = self.remoteConfig.configValue(forKey: "adConfig").stringValue ?? ""
                    NSLog("[Config] key: adConfig value:\(configData)")
                    // 执行Base64解码
                    if let decodedData = Data(base64Encoded: configData) {
                        // 执行JSON解析
                        do {
                            let jsonObject = try JSONSerialization.jsonObject(with: decodedData, options: [])
                            // 如果你选择使用SwiftyJSON，则替换下面这行
                            // let json = JSON(jsonObject)
                            
                            // 将JSON转换为你的自定义struct类型对象
                            if let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: []) {
                                let decoder = JSONDecoder()
                                let adConfig = try decoder.decode(GADConfig.self, from: jsonData)
                                GADUtil.share.updateConfig(adConfig)
                            }
                        } catch {
                            NSLog("[Config] Error parsing JSON: \(error.localizedDescription)")
                        }
                    }
                }
            } else {
                NSLog("[Config] Error fetching Remote Config: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        if GADUtil.share.getConfig.isDefaul() {
            let path = Bundle.main.path(forResource: AppManager.shared.isDebug ? "GADConfig_debug" : "GADConfig", ofType: "json")
            let url = URL(fileURLWithPath: path!)
            do {
                let data = try Data(contentsOf: url)
                GADUtil.share.updateConfig(try JSONDecoder().decode(GADConfig.self, from: data))
                NSLog("[Config] Read local ad config success.")
            } catch let error {
                NSLog("[Config] Read local ad config fail.\(error.localizedDescription)")
            }
        }
    }
}
