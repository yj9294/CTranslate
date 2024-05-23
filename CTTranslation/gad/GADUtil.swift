//
//  GADUtil.swift
//  XXTranslate
//
//  Created by  sunlang on 2024/4/25.
//

import Foundation
import Combine
import FBSDKCoreKit
import GoogleMobileAds

public class GADUtil: NSObject {
    @objc public static let shared = GADUtil()
    public var rootVC: UIViewController? = nil
    override init() {
        super.init()
        /// 广告配置是否是当天的
        if limit == nil || limit?.date.isToday != true {
            limit = .init()
        }
    }
    
    public var bannerView: GADBannerView? = nil
    
    // 本地记录 配置
    @UserDefault(key: "config")
    private var config: GADConfig?
    func updateConfig(_ config: GADConfig?) {
        self.config = config
    }
    
     public var getConfig: GADConfig {
         config ?? .init(positionConfig: [], sceneConfig: [], isUserGo: false, showGuide: false, reportPrice: -1.0, recommand: [])
    }
    
    // 是否配置了引导
    @objc public var isGuideConfig: Bool {
        getConfig.showGuide
    }
    
    // 获取recommand
    @objc public var recommandArray: [String] {
        config?.recommand ?? []
    }
    
    // 本地记录 限制次数
    @UserDefault(key: "limit")
    fileprivate var limit: GADLimit?
    
    /// 是否超限
    public func isGADLimited(_ scene: GADScene) -> Bool {
        if limit?.date.isToday == true {
            if let li = limit?.scenes.filter({ $0.scene == scene }).first, let con = config?.sceneConfig.filter({$0.scene == scene.title}).first {
                if li.showTimes >= con.showTimes || li.clickTimes >= con.clickTimes {
                    return true
                }
            }
        }
        return false
    }
        
    /// 广告位加载模型
    let ads:[GADLoadModel] = GADPosition.allCases.map { p in
        GADLoadModel(position: p, p: .none)
    }
    
    // 场景打点
    @objc func logScene(_ scene: GADScene) {
        CTStatisticAnalysis.saveEvent("gag_chungjung", params: ["place": scene.title])
    }
    
    @UserDefault(key: "paid.price")
    private var price: Double?
    var getPrice: Double {
        price ?? 0.0
    }
    // 价值回传
    @objc func addPrice(price: Double, currency: String) {
        if getPrice == 0 {
            self.price = price
        } else {
            self.price = price + getPrice
        }
        let configPrice = config?.reportPrice ?? -1
        if getPrice > (configPrice / 1000.0) {
            AppEvents.shared.logEvent(.initializeSDK, parameters: [AppEvents.ParameterName(rawValue: "match_user"): 1])
        }
    }
}

extension GADUtil {
    
    // 如果使用 async 请求广告 则这个值可能会是错误的。
    @objc public func isLoaded(_ position: GADPosition) -> Bool {
        return self.ads.filter {
            $0.position.rawValue == position.rawValue
        }.first?.isLoadCompletion == true
    }
    
    @objc public func isDidLoaded(_ position: GADPosition) -> Bool {
        return (self.ads.filter {
            $0.position.rawValue == position.rawValue
        }.first?.loadedArray.count ?? 0) > 0
    }
    
//    /// 请求远程配置
//    /// debug is true will load the local json file name "GADConfig.json", or "GADConfig_debug.json".
//    public func requestConfig(_ isDebug: Bool = true) {
//        // 获取本地配置
//        if config == nil {
//            let path = Bundle.main.path(forResource: isDebug ? "GADConfig_debug" : "GADConfig", ofType: "json")
//            let url = URL(fileURLWithPath: path!)
//            do {
//                let data = try Data(contentsOf: url)
//                config = try JSONDecoder().decode(GADConfig.self, from: data)
//                NSLog("[Config] Read local ad config success.")
//            } catch let error {
//                NSLog("[Config] Read local ad config fail.\(error.localizedDescription)")
//            }
//        }
//    }
    
    /// 限制
    fileprivate func add(_ status: GADLimit.GADSceneLimit.Status, scene: GADScene, position: GADPosition) {
        if isGADLimited(scene) {
            NSLog("[AD] (\(position.title)) (\(scene.title)) 用戶超过限制。")
            return
        }
        let ret = limit?.add(scene, type: status) ?? 0
        let con = config?.sceneConfig.filter({ $0.scene == scene.title }).first
        NSLog("[AD] (\(position.title)) (\(scene.title)) [LIMIT] \(status == .show ? "正在展示" : "正在点击"): \(ret) total: (\(con?.clickTimes ?? 0),\(con?.showTimes ?? 0))")
    }
    
    /// 加载
    @available(*, renamed: "load()")
     @objc public func load(_ position: GADPosition, p: GADScene, completion: ((Bool)->Void)? = nil) {
        let ads = ads.filter{
            $0.position.rawValue == position.rawValue
        }
        let ad = ads.first
        if let scene = config?.sceneConfig.filter({$0.scene == p.title}).first, scene.userGo {
            if config?.isUserGo == false {
                NSLog("[ad] (\(position.title)) ((\(p.title)) ad must be user go. but now is false")
                ad?.isLoadCompletion = true
                completion?(false)
                return
            }
        }
        if isGADLimited(p) {
            NSLog("[AD] (\(position.title)) ((\(p.title)) load limit")
            ad?.isLoadCompletion = true
            completion?(false)
            return
        }
        ad?.p = p
        ad?.beginAddWaterFall(callback: { isSuccess in
            if position == .native {
                self.show(position, p: p) { ad in
                    let newAD = ad
                    newAD?.p = p
                    NotificationCenter.default.post(name: .nativeUpdate, object: ad)
                }
            }
            if position == .banner {
                self.show(position, p: p) { ad in
                    let newAD = ad
                    newAD?.p = p
                    NotificationCenter.default.post(name: .bannerUpdate, object: ad)
                }
            }
            completion?(isSuccess)
        })
    }
    
    /// 展示
    @available(*, renamed: "show()")
    @objc public func show(_ position: GADPosition, p: GADScene , from vc: UIViewController? = nil , completion: ((GADBaseModel?)->Void)? = nil) {
        if let scene = config?.sceneConfig.filter({$0.scene == p.title}).first, scene.userGo {
            if config?.isUserGo == false {
                NSLog("[ad] (\(position.title)) ((\(p.title)) ad must be user go. but now is \(scene.userGo)")
                completion?(nil)
                return
            }
        }
        // 超限需要清空广告
        if isGADLimited(p) {
            completion?(nil)
            return
        }
        let loadAD = ads.filter {
            $0.position.rawValue == position.rawValue
        }.first
        if position == .open || position == .interstital {
            /// 有廣告
            if let ad = loadAD?.loadedArray.first as? GADFullScreenModel, !isGADLimited(p) {
                if let ad = ad as? GADInterstitialModel {
                    ad.ad?.paidEventHandler = {  [weak ad] adValue in
                        ad?.network = ad?.ad?.responseInfo.loadedAdNetworkResponseInfo?.adNetworkClassName ?? ""
                        ad?.price = Double(truncating: adValue.value)
                        ad?.currency = adValue.currencyCode
                        ad?.precisionType = adValue.precision.type
                        NotificationCenter.default.post(name: .adPaid, object: ad)
                    }
                } else if let ad = ad as? GADOpenModel {
                    ad.ad?.paidEventHandler = {  [weak ad] adValue in
                        ad?.network = ad?.ad?.responseInfo.loadedAdNetworkResponseInfo?.adNetworkClassName ?? ""
                        ad?.price = Double(truncating: adValue.value)
                        ad?.currency = adValue.currencyCode
                        ad?.precisionType = adValue.precision.type
                        NotificationCenter.default.post(name: .adPaid, object: ad)
                    }
                }
                ad.impressionHandler = { [weak self, loadAD, ad] in
                    loadAD?.impressionDate = Date()
                    self?.add(.show, scene: p, position: position)
                    self?.display(position, model: ad)
                    self?.load(position, p: p)
                    NotificationCenter.default.post(name: .adImpression, object: ad)
                }
                ad.clickHandler = { [weak self, ad] in
                    self?.add(.click, scene: p, position: position)
                    NotificationCenter.default.post(name: .adClick, object: ad)
                }
                ad.closeHandler = { [weak self] in
                    self?.disappear(position)
                    completion?(nil)
                }
                NotificationCenter.default.post(name: .adPresent, object: ad)
                if position == .open {
                    ad.present(from: vc)
                    return
                }
                UIView.ct_tipForeplay {
                    ad.present(from: vc)
                }
            } else {
                completion?(nil)
            }
        } else if position == .native || position == .banner {
            if let ad = loadAD?.loadedArray.first as? GADBaseModel, !isGADLimited(p) {
                /// 预加载回来数据 当时已经有显示数据了
                if loadAD?.isDisplay == true {
                    NSLog("[ad] (\(position.title)) ((\(p.title)) 广告正在展示, 当前缓存数量:\(loadAD?.loadedArray.count ?? 0), 当前正在加载数量:\(loadAD?.loadingArray.count ?? 0)")
                    return
                }
                if let ad = ad as? GADNativeModel {
                    ad.nativeAd?.unregisterAdView()
                    ad.nativeAd?.delegate = ad
                    ad.nativeAd?.paidEventHandler = {  [weak ad] adValue in
                        ad?.network = ad?.nativeAd?.responseInfo.loadedAdNetworkResponseInfo?.adNetworkClassName ?? ""
                        ad?.price = Double(truncating: adValue.value)
                        ad?.currency = adValue.currencyCode
                        ad?.precisionType = adValue.precision.type
                        NotificationCenter.default.post(name: .adPaid, object: ad)
                    }
                } else if let ad = ad as? GADBannerModel {
                    ad.bannerView?.paidEventHandler = { [weak ad] adValue in
                        ad?.network = ad?.bannerView?.responseInfo?.loadedAdNetworkResponseInfo?.adNetworkClassName ?? ""
                        ad?.price = Double(truncating: adValue.value)
                        ad?.currency = adValue.currencyCode
                        ad?.precisionType = adValue.precision.type
                        NotificationCenter.default.post(name: .adPaid, object: ad)
                    }
                }
                
                ad.impressionHandler = { [weak loadAD, ad]  in
                    loadAD?.impressionDate = Date()
                    self.add(.show, scene: p, position: position)
                    self.display(position, model: ad)
                    self.load(position, p: p)
                    NotificationCenter.default.post(name: .adImpression, object: ad)
                }
                ad.clickHandler = { [weak ad] in
                    self.add(.click, scene: p, position: position)
                    NotificationCenter.default.post(name: .adClick, object: ad)
                }
                completion?(ad)
            } else {
                /// 预加载回来数据 当时已经有显示数据了 并且没超过限制
                if loadAD?.isDisplay == true, !isGADLimited(p) {
                    return
                }
                NSLog("[ad] (\(position.title)) ((\(p.title)) 当前无可用广告实例")
                completion?(nil)
            }
        }
    }
    
    /// 清除缓存 针对loadedArray数组
    public func clean(_ position: GADPosition) {
        let loadAD = ads.filter{
            $0.position.rawValue == position.rawValue
        }.first
        loadAD?.clean()
        
        if position == .native {
            NotificationCenter.default.post(name: .nativeUpdate, object: nil)
        }
        if position == .banner {
            NotificationCenter.default.post(name: .bannerUpdate, object: nil)
        }
    }
    
    /// 关闭正在显示的广告（原生，插屏）针对displayArray
    @objc public func disappear(_ position: GADPosition) {
        ads.filter{
            $0.position.rawValue == position.rawValue
        }.first?.closeDisplay()
        
        if position == .native {
            NotificationCenter.default.post(name: .nativeUpdate, object: nil)
        }
        if position == .banner {
            NotificationCenter.default.post(name: .bannerUpdate, object: nil)
        }
    }
    
    /// 展示
    fileprivate func display(_ position: GADPosition, model: GADBaseModel) {
        ads.filter {
            $0.position.rawValue == position.rawValue
        }.first?.display(model)
    }
}

public struct GADConfig: Codable {
    var positionConfig: [GADPostionModel]
    var sceneConfig: [GADSceneModel]
    var isUserGo: Bool
    var showGuide: Bool
    var reportPrice: Double
    var recommand: [String]
    
    func isDefaul() -> Bool {
        reportPrice < 0
    }
}

public struct GADPostionModel: Codable {
    public var pid: String
    public var cached: Int
    public var position: GADPosition
}

public struct GADSceneModel: Codable {
    public var scene: String
    public var userGo: Bool
    public var showTimes: Int
    public var clickTimes: Int
}

public class GADBaseModel: NSObject, Identifiable {
    public let id = UUID().uuidString
    /// 廣告加載完成時間
    var loadedDate: Date?
    
    /// 點擊回調
    var clickHandler: (() -> Void)?
    /// 展示回調
    var impressionHandler: (() -> Void)?
    /// 加載完成回調
    var loadedHandler: ((_ result: Bool, _ error: String) -> Void)?
    
    /// 當前廣告model
    public var model: GADPostionModel?
    /// 廣告位置
    @objc public var position: GADPosition
    
    @objc public var p: GADScene
    // 收入
    @objc public var price: Double = 0.0
    // 收入货币
    @objc public var currency: String = "USD"
    // 广告网络
    public var network: String = ""
    // precision type form adValue
    public var precisionType: String = ""
    
    init(model: GADPostionModel?, position: GADPosition, p: GADScene) {
        self.model = model
        self.position = position
        self.p = p
        super.init()
    }
    
    @objc func getSceneName() -> String {
        return p.title
    }
}

extension GADBaseModel {
    
    @available(*, renamed: "loadAd()")
    @objc public func loadAd( completion: @escaping ((_ result: Bool, _ error: String) -> Void)) {
    }
    
    @available(*, renamed: "present()")
    @objc public func present(from vc: UIViewController? = nil) {
    }
}

struct GADLimit: Codable {
    var scenes: [GADSceneLimit] = GADScene.allCases.filter({ $0 != .none}).map { scene in
        GADSceneLimit(showTimes: 0, clickTimes: 0, scene: scene)
    }
    var date: Date = Date()
    
    mutating func add(_ scene: GADScene, type: GADSceneLimit.Status) -> Int {
        var ret = 0
        scenes = scenes.map({ limit in
            if limit.scene == scene {
                var newLimit = limit
                if type == .click {
                    newLimit.clickTimes += 1
                    ret = newLimit.clickTimes
                } else {
                    newLimit.showTimes += 1
                    ret = newLimit.showTimes
                }
                return newLimit
            }
            return limit
        })
        return ret
    }
    
    struct GADSceneLimit: Codable {
        var showTimes: Int
        var clickTimes: Int
        var scene: GADScene
        
        enum Status {
            case show, click
        }
    }
}

//public enum GADPosition: CaseIterable, Equatable {
//    case native
//    case interstitial
//    case open
//}

// 自定义广告位置枚举协议
@objc public enum GADPosition: Int, CaseIterable, Codable {
    case open, native, interstital, banner
    public var title: String {
        switch self {
        case .open:
            return "open"
        case .native:
            return "native"
        case .interstital:
            return "interstital"
        case .banner:
            return "banner"
        }
    }
}

@objc public enum GADScene: Int, CaseIterable, Codable {
    case  none, launOpen, selectLanNative, selectLanInter, homeEnterInter, backHomeInter, userfulInter, resultInter, recommendInter, translateBanner, translateNative, settingsNative, usefulNative
    public var title: String {
        switch self {
        case .none:
            return "none"
        case .launOpen:
            return "launOpen"
        case .selectLanNative:
            return "selectLanNative"
        case .selectLanInter:
            return "selectLanInter"
        case .homeEnterInter:
            return "homeEnterInter"
        case .backHomeInter:
            return "backHomeInter"
        case .userfulInter:
            return "userfulInter"
        case .resultInter:
            return "resultInter"
        case .recommendInter:
            return "recommendInter"
        case .translateBanner:
            return "translateBanner"
        case .translateNative:
            return "translateNative"
        case .settingsNative:
            return "settingsNative"
        case .usefulNative:
            return "usefulNative"
        }
    }
}

class GADLoadModel: NSObject {
    /// 當前廣告位置類型
    var position: GADPosition
    /// 當前廣告场景類型
    var p: GADScene
    /// 是否正在加載中
    var isPreloadingAD: Bool {
        return loadingArray.count > 0
    }
    // 是否已有加载成功的数据
    var isPreloadedAD: Bool {
        return loadedArray.count > 0
    }
    // 是否需要预加载
    var isNeedPreloaded: Bool {
        // 当前加载成功数量小于配置的档期广告位置需要缓存个数
        let con = GADUtil.shared.getConfig.positionConfig.filter({$0.position == position}).first?.cached ?? 2
        if loadedArray.count + loadingArray.count < con {
            return true
        }
        return false
    }
    // 当前广告位置有缓存
     var isLoadedCached: Bool {
        let con = GADUtil.shared.getConfig.positionConfig.filter({$0.position == position}).first?.cached ?? 2
        return loadedArray.count >= con
    }
    // 是否加载完成 不管成功还是失败
    var isLoadCompletion: Bool = false
    /// 正在加載術組
    var loadingArray: [GADBaseModel] = []
    /// 加載完成
    var loadedArray: [GADBaseModel] = []
    /// 展示
    var displayArray: [GADBaseModel] = []
        
    var isDisplay: Bool {
        return displayArray.count > 0
    }
    
    /// 该广告位显示广告時間 每次显示更新时间
    var impressionDate = Date(timeIntervalSinceNow: -100)
    
        
    init(position: GADPosition, p: GADScene) {
        self.position = position
        self.p = p
        super.init()
    }
}

extension GADLoadModel {
    @available (*, renamed: "beginAddWaterFall()")
    func beginAddWaterFall(callback: ((_ isSuccess: Bool) -> Void)? = nil) {
        isLoadCompletion = false
        NSLog("[AD] (\(position.title)) ((\(p.title)) 开始预加载 --------------------")
        if isNeedPreloaded {
            NSLog("[AD] (\(position.title)) ((\(p.title)) 当前缓存数量:\(loadedArray.count), 当前正在加载数量:\(loadingArray.count)")
            if GADUtil.shared.isLoaded(.banner), position == .banner {
                NSLog("[AD] (\(position.title)) ((\(p.title)) 已经有可取缓存。可进行展示")
                callback?(true)
            }
            if GADUtil.shared.isLoaded(.native), position == .native {
                NSLog("[AD] (\(position.title)) ((\(p.title)) 已经有可取缓存。可进行展示")
                callback?(true)
            }
            
            let array: [GADPostionModel] = GADUtil.shared.getConfig.positionConfig.filter({$0.position == position})
            if !array.isEmpty {
                NSLog("[AD] (\(position.title)) ((\(p.title)) 开始加载")
                prepareLoadAd(array: array) { [weak self] isSuccess in
                    guard let self = self else {return}
                    self.isLoadCompletion = true
                    if isSuccess {
                        NSLog("[AD] (\(self.position.title)) (\(self.p.title)) 加载成功, 当前缓存数量:\(loadedArray.count), 当前正在加载数量:\(loadingArray.count)")
                    } else {
                        NSLog("[AD] (\(self.position.title)) (\(self.p.title)) 加载失败, 当前缓存数量:\(loadedArray.count), 当前正在加载数量:\(loadingArray.count)")
                    }
                    callback?(isSuccess)
                }
            } else {
                NSLog("[AD] (\(position.title)) ((\(p.title)) no configer.")
            }
        } else if isLoadedCached {
            isLoadCompletion = true
            NSLog("[AD] (\(position.title)) ((\(p.title)) 当前缓存数量:\(loadedArray.count), 当前正在加载数量:\(loadingArray.count) 不需要预加载。")
            callback?(true)
        } else {
            isLoadCompletion = true
            NSLog("[AD] (\(position.title)) ((\(p.title)) 当前缓存数量:\(loadedArray.count) 当前正在加载数量:\(loadingArray.count), 不需要预加载。")
            callback?(false)
        }
    }
    
    func prepareLoadAd(array: [GADPostionModel], at index: Int = 0, callback: ((_ isSuccess: Bool) -> Void)?) {
        if  index >= array.count {
            NSLog("[AD] (\(position.title)) ((\(p.title)) prepare Load Ad Failed, no more avaliable config.")
            callback?(false)
            return
        }
        if GADUtil.shared.isGADLimited(p) {
            NSLog("[AD] (\(position.title)) ((\(p.title)) 当前超限。")
            callback?(false)
            return
        }
        if !isNeedPreloaded {
            NSLog("[AD] (\(position.title)) ((\(p.title)) 当前不需要预加载")
            callback?(false)
            return
        }
        
        var ad: GADBaseModel? = nil
        switch position {
        case .open:
            ad = GADOpenModel(model: array[index], position: position, p: p)
        case .native:
            ad = GADNativeModel(model: array[index], position: position, p: p)
        case .interstital:
            ad = GADInterstitialModel(model: array[index], position: position, p: p)
        case .banner:
            ad = GADBannerModel(model: array[index], position: position, p: p)
        }
        guard let ad = ad  else {
            NSLog("[AD] (\(position.title)) posion error.")
            callback?(false)
            return
        }
        ad.position = position
        ad.loadAd { [weak ad] isSuccess, error in
            guard let ad = ad else { return }
            /// 刪除loading 中的ad
            self.loadingArray = self.loadingArray.filter({ loadingAd in
                return ad.id != loadingAd.id
            })
            
            /// 成功
            if isSuccess {
                self.loadedArray.append(ad)
                callback?(true)
                return
            }
            
            NSLog("[AD] (\(self.position.title)) (\(self.p.title)) Load Ad Failed: try reload at index: \(index + 1).")
            self.prepareLoadAd(array: array, at: index + 1, callback: callback)
        }
        loadingArray.append(ad)
    }
    
    fileprivate func display(_ model: GADBaseModel) {
        self.displayArray.append(model)
        self.loadedArray = self.loadedArray.filter({$0.id != model.id })
    }
    
    fileprivate func closeDisplay() {
        self.displayArray = []
//        if position == .banner {
//            self.displayArray.forEach { m in
//                if let bannerModel = m as? GADBannerModel {
//                    bannerModel.bannerView?.removeFromSuperview()
//                }
//            }
//        }
    }
    
    fileprivate func clean() {
        self.displayArray = []
        self.loadedArray = []
        self.loadingArray = []
    }
}

extension Date {
    func isExpired(with time: Double) -> Bool {
        Date().timeIntervalSince1970 - self.timeIntervalSince1970 > time
    }
    
    var isToday: Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyy-MM-dd HH:mm"
        let date1 = dateFormatter.string(from: self).components(separatedBy: " ")
        let date2 = dateFormatter.string(from: Date()).components(separatedBy: " ")
        return date1.first == date2.first
    }
}

class GADFullScreenModel: GADBaseModel {
    /// 關閉回調
    var closeHandler: (() -> Void)?
    var autoCloseHandler: (()->Void)?
    /// 異常回調 點擊了兩次
    var clickTwiceHandler: (() -> Void)?
    
    /// 是否點擊過，用於拉黑用戶
    var isClicked: Bool = false
        
    deinit {
        NSLog("[Memory] (\(position.title)) \(self) 💧💧💧.")
    }
}

class GADInterstitialModel: GADFullScreenModel {
    /// 插屏廣告
    var ad: GADInterstitialAd?
}

extension GADInterstitialModel: GADFullScreenContentDelegate {
    public override func loadAd(completion: ((_ result: Bool, _ error: String) -> Void)?) {
        loadedHandler = completion
        loadedDate = nil
        GADInterstitialAd.load(withAdUnitID: model?.pid ?? "", request: GADRequest()) { [weak self] ad, error in
            guard let self = self else { return }
            if let error = error {
                NSLog("[AD] (\(self.position.title)) load ad FAILED for id \(self.model?.pid ?? "invalid id"), err = \(error.localizedDescription)")
                self.loadedHandler?(false, error.localizedDescription)
                return
            }
            NSLog("[AD] (\(self.position.title)) load ad SUCCESSFUL for id \(self.model?.pid ?? "invalid id") ✅✅✅✅")
            self.ad = ad
            self.network = self.ad?.responseInfo.loadedAdNetworkResponseInfo?.adNetworkClassName ?? ""
            self.ad?.fullScreenContentDelegate = self
            self.loadedDate = Date()
            self.loadedHandler?(true, "")
        }
    }
    
    override func present(from vc: UIViewController? = nil) {
        Task.detached { @MainActor in
            if let vc = vc {
                self.ad?.present(fromRootViewController: vc)
            } else if let keyWindow = (UIApplication.shared.connectedScenes.filter({$0 is UIWindowScene}).first as? UIWindowScene)?.windows.first, let rootVC = keyWindow.rootViewController {
                if let pc = rootVC.presentedViewController {
                    self.ad?.present(fromRootViewController: pc)
                } else {
                    self.ad?.present(fromRootViewController: rootVC)
                }
            }
        }
    }
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        loadedDate = Date()
        impressionHandler?()
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        NSLog("[AD] (\(self.position)) didFailToPresentFullScreenContentWithError ad FAILED for id \(self.model?.pid ?? "invalid id"), err:\(error.localizedDescription)")
        closeHandler?()
    }
    
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        if AppManager.shared.isDismissFullAd {
            AppManager.shared.isDismissFullAd.toggle()
            return
        }
        closeHandler?()
    }
    
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        clickHandler?()
    }
}

class GADOpenModel: GADFullScreenModel {
    /// 插屏廣告
    var ad: GADAppOpenAd?
}

extension GADOpenModel: GADFullScreenContentDelegate {
    override func loadAd(completion: ((_ result: Bool, _ error: String) -> Void)?) {
        loadedHandler = completion
        loadedDate = nil
        GADAppOpenAd.load(withAdUnitID: model?.pid ?? "", request: GADRequest()) { [weak self] ad, error in
            guard let self = self else { return }
            if let error = error {
                NSLog("[AD] (\(self.position.title)) load ad FAILED for id \(self.model?.pid ?? "invalid id")")
                self.loadedHandler?(false, error.localizedDescription)
                return
            }
            self.ad = ad
            self.network = self.ad?.responseInfo.loadedAdNetworkResponseInfo?.adNetworkClassName ?? ""
            NSLog("[AD] (\(self.position.title)) load ad SUCCESSFUL for id \(self.model?.pid ?? "invalid id") ✅✅✅✅")
            self.ad?.fullScreenContentDelegate = self
            self.loadedDate = Date()
            self.loadedHandler?(true, "")
        }
    }
    
    override func present(from vc: UIViewController? = nil) {
        Task.detached { @MainActor in
            if let vc = vc {
                self.ad?.present(fromRootViewController: vc)
            } else if let keyWindow = (UIApplication.shared.connectedScenes.filter({$0 is UIWindowScene}).first as? UIWindowScene)?.windows.first, let rootVC = keyWindow.rootViewController {
                if let pc = rootVC.presentedViewController {
                    self.ad?.present(fromRootViewController: pc)
                } else {
                    self.ad?.present(fromRootViewController: rootVC)
                }
            }
        }
    }
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        loadedDate = Date()
        impressionHandler?()
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        NSLog("[AD] (\(self.position)) didFailToPresentFullScreenContentWithError ad FAILED for id \(self.model?.pid ?? "invalid id")")
        closeHandler?()
    }
    
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        if AppManager.shared.isDismissFullAd {
            AppManager.shared.isDismissFullAd.toggle();
        }
        closeHandler?()
    }
    
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        clickHandler?()
    }
}

public class GADNativeModel: GADBaseModel {
    /// 廣告加載器
    var loader: GADAdLoader?
    /// 原生廣告
    @objc public var nativeAd: GADNativeAd?
    
    deinit {
        NSLog("[Memory] (\(position.title)) \(self) 💧💧💧.")
    }
}

extension GADNativeModel {
    
    public override func loadAd(completion: ((_ result: Bool, _ error: String) -> Void)?) {
        loadedDate = nil
        loadedHandler = completion
        loader = GADAdLoader(adUnitID: model?.pid ?? "", rootViewController: nil, adTypes: [.native], options: nil)
        loader?.delegate = self
        loader?.load(GADRequest())
    }
    
    public func unregisterAdView() {
        nativeAd?.unregisterAdView()
    }
}

extension GADNativeModel: GADAdLoaderDelegate {
    public func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        NSLog("[AD] (\(position.title)) load ad FAILED for id \(model?.pid ?? "invalid id") error:\(error.localizedDescription)")
        loadedHandler?(false, error.localizedDescription)
    }
}

extension GADNativeModel: GADNativeAdLoaderDelegate {
    public func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        NSLog("[AD] (\(position.title)) load ad SUCCESSFUL for id \(model?.pid ?? "invalid id") ✅✅✅✅")
        self.nativeAd = nativeAd
        self.network = self.nativeAd?.responseInfo.loadedAdNetworkResponseInfo?.adNetworkClassName ?? ""
        loadedDate = Date()
        loadedHandler?(true, "")
    }
}

extension GADNativeModel: GADNativeAdDelegate {
    public func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
        clickHandler?()
    }
    
    public func nativeAdDidRecordImpression(_ nativeAd: GADNativeAd) {
        impressionHandler?()
    }
    
    public func nativeAdWillPresentScreen(_ nativeAd: GADNativeAd) {
    }
}

class GADBannerModel: GADBaseModel {
    /// 原生廣告
    @objc public var bannerView: GADBannerView?
    
    private var isReceiveAD: Bool = false
    
    deinit {
        NSLog("[Memory] (\(position.title)) \(self) 💧💧💧.")
    }
}

extension GADBannerModel {
    
    public override func loadAd(completion: ((_ result: Bool, _ error: String) -> Void)?) {
        loadedDate = nil
        loadedHandler = completion
        let adaptiveSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width - 20)
        if let bannerView = GADUtil.shared.bannerView {
            self.bannerView = bannerView
        } else {
            bannerView = GADBannerView(adSize: adaptiveSize)
            bannerView?.backgroundColor = .white
            bannerView?.layer.masksToBounds = true
            bannerView?.rootViewController = AppManager.shared.window?.rootViewController
        }
        bannerView?.adUnitID = model?.pid
        bannerView?.delegate = self
        bannerView?.adSizeDelegate = self
        
        AppManager.shared.window?.addSubview(bannerView!)
        bannerView?.frame = CGRect(x: 10, y: -90, width: UIScreen.main.bounds.width - 20, height: 90)

        let request = GADRequest()

       // Create an extra parameter that aligns the bottom of the expanded ad to
       // the bottom of the bannerView.
        let extras = GADExtras()
        extras.additionalParameters = ["collapsible" : "top"]
        request.register(extras)
        bannerView?.load(request)
    }
}

extension GADBannerModel: GADBannerViewDelegate, GADAdSizeDelegate {
    func adView(_ bannerView: GADBannerView, willChangeAdSizeTo size: GADAdSize) {
        
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        NSLog("[AD] (\(position.title)) load ad SUCCESSFUL for id \(model?.pid ?? "invalid id") ✅✅✅✅")
        self.bannerView = bannerView
        self.network = bannerView.responseInfo?.loadedAdNetworkResponseInfo?.adNetworkClassName ?? ""
        loadedDate = Date()
        loadedHandler?(true, "")
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        NSLog("[AD] (\(position.title)) load ad FAILED for id \(model?.pid ?? "invalid id") error:\(error.localizedDescription)")
        loadedHandler?(false, error.localizedDescription)
    }

    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        if bannerView.superview == nil {
            return
        }
        impressionHandler?()
    }
    
    func bannerViewDidRecordClick(_ bannerView: GADBannerView) {
        clickHandler?()
    }

    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
    }

    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
    }

    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
    }
}


extension UserDefaults {
    public func setModel<T: Encodable> (_ object: T?, forKey key: String) {
        let encoder =  JSONEncoder()
        guard let object = object else {
            self.removeObject(forKey: key)
            return
        }
        guard let encoded = try? encoder.encode(object) else {
            return
        }
        
        self.setValue(encoded, forKey: key)
    }
    
    public func model<T: Decodable> (_ type: T.Type, forKey key: String) -> T? {
        guard let data = self.data(forKey: key) else {
            return nil
        }
        let decoder = JSONDecoder()
        guard let object = try? decoder.decode(type, from: data) else {
            print("Could'n find key")
            return nil
        }
        
        return object
    }
}

@propertyWrapper
struct UserDefault<T: Codable> {
    let key: String
    var value: T?
    
    init(key: String) {
        self.key = key
        self.value = UserDefaults.standard.model(T.self, forKey: key)
    }
    
    var wrappedValue: T? {
        set {
            value = newValue
            UserDefaults.standard.setModel(newValue, forKey: key)
        }
        get {
            value
        }
    }
    
}

class  RequestIP {
    
    struct IPResponse: Codable {
        var ip: String?
        var city: String?
        var country: String?
    }
    
    enum State: String {
        case load, impression
    }

    func requestIP(_ state: State, completion: ((String)->Void)? = nil) {
        let token = SubscriptionToken()
        NSLog("[IP] 开始请求, state: \(state.rawValue)")
        URLSession.shared.dataTaskPublisher(for: URL(string: "https://ipinfo.io/json")!).map({
            $0.data
        }).eraseToAnyPublisher().decode(type: IPResponse.self, decoder: JSONDecoder()).sink { complete in
            if case .failure(let error) = complete {
                NSLog("[IP] err:\(error)")
                DispatchQueue.main.async {
                    completion?("192.168.0.1")
                }
            }
            token.unseal()
        } receiveValue: { response in
            NSLog("[IP] 当前国家:\(response.country ?? ""), state: \(state.rawValue)")
            let ip = response.ip ?? "192.168.0.1"
            if state == .load {
                UserDefaults.standard.setModel(ip, forKey: .loadIP)
            } else {
                UserDefaults.standard.setModel(ip, forKey: .impressionIP)
            }
            DispatchQueue.main.async {
                completion?(ip)
            }
        }.seal(in: token)
    }
}

extension GADUtil {
    public func dismiss() {
        if let view = (UIApplication.shared.connectedScenes.filter({$0 is UIWindowScene}).first as? UIWindowScene)?.windows.first, let vc = view.rootViewController {
            if let presentedVC = vc.presentedViewController {
                if let persentedPresentedVC = presentedVC.presentedViewController {
                    persentedPresentedVC.dismiss(animated: true) {
                        presentedVC.dismiss(animated: true) {
                        }
                    }
                    return
                }
                presentedVC.dismiss(animated: true) {
                }
            }
        }
    }
}

public class SubscriptionToken {
    var cancelable: AnyCancellable?
    func unseal() { cancelable = nil }
}

extension AnyCancellable {
    /// 需要 出现 unseal 方法释放 cancelable
    func seal(in token: SubscriptionToken) {
        token.cancelable = self
    }
}

extension GADAdValuePrecision {
    var type: String {
        switch self {
        case .unknown:
            return "unknown"
        case .estimated:
            return "estimated"
        case .publisherProvided:
            return "publisherProvided"
        case .precise:
            return "precise"
        @unknown default:
            return ""
        }
    }
}



extension Notification.Name {
    public static let nativeUpdate = Notification.Name(rawValue: "homeNativeUpdate")
    public static let bannerUpdate = Notification.Name(rawValue: "banner.ad")
    public static let adPaid = Notification.Name(rawValue: "ad.paid")
    public static let adImpression = Notification.Name(rawValue: "ad.impression")
    public static let adPresent = Notification.Name(rawValue: "ad.present")
    public static let adClick = Notification.Name(rawValue: "ad.click")
}

extension String {
    static let adConfig = "adConfig"
    static let adLimited = "adLimited"
    static let loadIP = "loadIP"
    static let impressionIP = "impressionIP"
}
