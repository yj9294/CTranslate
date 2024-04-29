//
//  SVLottieView.swift
//  CTTranslation
//
//  Created by  cttranslation on 2024/3/1.
//

import UIKit
import Foundation
import Lottie

@objc
public class LottieTools: NSObject {
    @objc public class func getLottieView(with name: String, count: NSInteger) -> LottieAnimationView {
        let anView = LottieAnimationView(name: name)
        anView.contentMode = .scaleAspectFill
        if (count == -1) {
            anView.loopMode = .loop
        } else {
            anView.loopMode = .repeat(Float(count))
        }
        return anView;
    }
    
    @objc public class func play(anView: LottieAnimationView) {
        anView.play()
    }
    
    @objc public class func stop(anView: LottieAnimationView) {
        anView.stop()
    }
    
    @objc public class func pause(anView: LottieAnimationView) {
        anView.pause()
    }
    
    @objc public class func remove(anView: LottieAnimationView) {
        anView.removeFromSuperview()
    }
}

//@objc
//public enum SVLottieBackgroundBehavior:Int {
//    case sv_default = 0
//    case sv_stop = 1
//    case sv_pause = 2
//    case sv_pauseAndRestore = 3
//    case sv_forceFinish = 4
//    case sv_continuePlaying = 5
//}
//
//@objc
//open class SVLottieView: UIView {
//    //动画
//    @objc public var mAnimationView = LottieAnimationView()
//    
//    ///次数
//    @objc public var loopAnimationCount: CGFloat = 0 {
//        didSet {
//            mAnimationView.loopMode = loopAnimationCount == -1 ? .loop : .repeat(Float(loopAnimationCount))
//        }
//    }
//    
//    /// 速度
//    @objc public var speed: CGFloat = 1 {
//        didSet {
//            mAnimationView.animationSpeed = speed
//        }
//    }
//    
//    /// 程序到后台动画的行为
//    @objc public var backgroundBehavior: SVLottieBackgroundBehavior = .sv_default {
//        didSet {
//            switch backgroundBehavior {
//            case .sv_stop:
//                mAnimationView.backgroundBehavior = .stop
//            case.sv_pause:
//                mAnimationView.backgroundBehavior = .pause
//            case.sv_pauseAndRestore:
//                mAnimationView.backgroundBehavior = .pauseAndRestore
//            case.sv_continuePlaying:
//                mAnimationView.backgroundBehavior = .continuePlaying
//            case .sv_forceFinish:
//                mAnimationView.backgroundBehavior = .forceFinish
//            case .sv_default:
//                break
//            }
//        }
//    }
//    
//    public init() {
//        self.speed = 1
//        self.loopAnimationCount = 0
//        self.backgroundBehavior = .sv_default
//        super.init(frame: .zero)
//    }
//    
//    ///名称--创建动画
//    @objc public convenience init(name: String) {
//        self.init()
//        if let jsonPath = Bundle.lottieBundle.path(forResource: name, ofType: "json"),
//           let animation = LottieAnimation.filepath(jsonPath) {
//            mAnimationView.animation = animation
//            self.addSubview(mAnimationView)
//            mAnimationView.mas_makeConstraints { make in
//                make?.left.mas_equalTo()(0)
//                make?.right.mas_equalTo()(0)
//                make?.top.mas_equalTo()(0)
//                make?.bottom.mas_equalTo()(0)
//            }
//            mAnimationView.play()
//        }
//    }
//    
//    ///远层--创建动画
//    @objc public convenience init(remoteUrl:String) {
//        self.init()
//        weak var weakSelf = self
//        if let url = URL(string: remoteUrl) {
//            mAnimationView = LottieAnimationView(url:url, closure: { (error) in
//                if let _ = error {
//                    DispatchQueue.main.async {
//                        weakSelf?.remove()
//                    }
//                } else {
//                    DispatchQueue.main.async {
//                        weakSelf?.showRemoteLottieWhenSuccess()
//                    }
//                }
//            })
//        }
//    }
//    
//    ///远层动画成功
//    fileprivate func showRemoteLottieWhenSuccess() {
//        mAnimationView.contentMode = .scaleAspectFit
//        self.addSubview(mAnimationView)
//        mAnimationView.mas_makeConstraints { make in
//            make?.left.mas_equalTo()(0)
//            make?.right.mas_equalTo()(0)
//            make?.top.mas_equalTo()(0)
//            make?.bottom.mas_equalTo()(0)
//        }
//        mAnimationView.play()
//    }
//    
//    required public init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    ///播放动画
//    @objc open func play(completion:@escaping() -> ()) {
//        mAnimationView.play { (isu) in
//            if Thread.isMainThread {
//                completion()
//            } else {
//                DispatchQueue.main.async {
//                    completion()
//                }
//            }
//        }
//    }
//    
//    ///播放动画
//    @objc public func play() -> Void {
//        mAnimationView.play()
//    }
//    
//    ///暂停动画
//    @objc public func pause() -> Void {
//        mAnimationView.pause();
//    }
//    
//    ///停止动画
//    @objc public func stop() -> Void {
//        mAnimationView.stop();
//    }
//    
//    ///删除动画
//    @objc public func remove() -> Void {
//        mAnimationView.removeFromSuperview()
//        self.removeFromSuperview()
//    }
//}
//
//
//extension Bundle {
//    static var lottieBundle: Bundle{
//        return Bundle.init(path:Bundle.init(for: SVLottieView.self).path(forResource: "Lottie_Resource", ofType: "bundle")!)!
//    }
//}

