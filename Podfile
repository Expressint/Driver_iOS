# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'Book A Ride-Driver' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Book A Ride-Driver
  

#pod 'TTSegmentedControl', '~>0.3'
pod 'SideMenuController' #,'0.2.4'
pod 'IQKeyboardManagerSwift' #, '5.0.7'
pod 'GooglePlaces' #,'3.0.3'
#pod 'GooglePlacePicker' #, '3.0.3'
pod 'GoogleMaps'
pod 'Alamofire' , '4.6.0'
pod 'NVActivityIndicatorView' ,'4.1.1'
pod 'SDWebImage' #, '4.3.0'
#pod 'M13Checkbox' #, '3.2.2'
pod 'Socket.IO-Client-Swift'#, '15.1.0'
pod 'SRCountdownTimer' #,'1.1.0'
#pod 'ACProgressHUD-Swift' #,'1.3.0'
pod 'CreditCardForm' #, '0.1.7'
#pod 'CardIO'
pod 'FormTextField' #, '2.0.0'
pod 'FloatRatingView' #, '3.0'
pod 'Firebase/Core'
pod 'Firebase/Messaging'
pod 'Firebase/Crashlytics'
pod 'MarqueeLabel/Swift' #, '3.1.4'
pod 'DropDown' #, '2.3.1'
pod 'IQDropDownTextField' #,'2.0.0'
pod 'ACFloatingTextfield-Swift' #, '1.7'
#pod 'GoogleAnalytics' #, '3.17.0'
pod 'CountryPickerView'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
      config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = "YES"
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      config.build_settings["ONLY_ACTIVE_ARCH"] = "YES"
    end
  end
end
