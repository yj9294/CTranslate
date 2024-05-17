platform :ios, '13.0'
use_frameworks!
use_modular_headers!
target 'CTTranslation' do
  pod 'FirebaseAnalytics'
  pod 'FirebaseCrashlytics'
  pod 'FirebaseRemoteConfig'
  pod 'Google-Mobile-Ads-SDK'

  #pod 'GoogleMobileAdsMediationFacebook'
  #pod 'GoogleMobileAdsMediationPangle'
  #pod 'GoogleMobileAdsMediationUnity'
  #pod 'GoogleMobileAdsMediationAppLovin'
  #pod 'GoogleMobileAdsMediationMintegral'
  #pod 'GoogleMobileAdsMediationVungle'
  
  pod 'GoogleMLKit/Translate'
  #拉丁文
  pod 'GoogleMLKit/TextRecognition'
  #中文
  pod 'GoogleMLKit/TextRecognitionChinese'
  #日文
  pod 'GoogleMLKit/TextRecognitionJapanese'
  #韩文
  pod 'GoogleMLKit/TextRecognitionKorean'
  #梵文
  pod 'GoogleMLKit/TextRecognitionDevanagari'
  
  pod 'YYText'
  pod 'Masonry'
  pod 'AFNetworking'
  pod 'MBProgressHUD'
  pod 'IQKeyboardManager'
  pod 'lottie-ios'
  pod "FBSDKCoreKit"
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "13.0"
    end
  end
end

