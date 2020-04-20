# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'GrantInspection' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
 	use_frameworks!
	
  # Pods for Progress
	pod 'EVReflection/Alamofire'
	pod 'UICircularProgressRing'
  pod 'IQKeyboardManagerSwift'
	pod 'GoogleMaps'
  pod 'GooglePlaces'
	pod 'NVActivityIndicatorView'
	pod 'RxSwift'
  pod 'RxCocoa'
	pod 'ImagePicker'
	pod 'Lightbox'
	pod 'Firebase/Core'
	pod 'Fabric', '~> 1.9.0'
	pod 'Crashlytics', '~> 3.12.0'
	pod "GTProgressBar"
  pod 'Toaster'
  pod 'XCGLogger'
  pod 'NotificationBannerSwift', '2.0.1'
  pod 'MarqueeLabel/Swift'
  pod 'OHHTTPStubs/Swift'
  
 
  
  target 'GrantInspectionTests' do
  
  inherit! :search_paths
  
  use_frameworks!
 
  pod 'Quick'
  pod 'Nimble'

  # includes the Default subspec, with support for NSURLSession & JSON, and the Swiftier API wrappers
  
#  post_install do |installer|
#    installer.pods_project.targets.each do |target|
#      target.build_configurations.each do |config|
#        config.build_settings['SWIFT_VERSION'] <= '4.2'
#      end
#    end
#  end
post_install do |installer|
previous_swift_version = '4.2'
current_swift_version = '5.0'
pods_written_with_previous_swift = []

if pods_written_with_previous_swift != []
  installer.pods_project.targets.each do |target|
      if pods_written_with_previous_swift.include? target.name
        target.build_configurations.each do |config|
          config.build_settings['SWIFT_VERSION'] <= previous_swift_version
        end
      else
        target.build_configurations.each do |config|
          config.build_settings['SWIFT_VERSION'] = current_swift_version
        end
      end
  end
end
end
end
end
