#
# Be sure to run `pod lib lint KFObjCKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KFObjCKit'
  s.version          = '0.1.0'
  s.summary          = 'KFObjCKit.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  KFObjCKit.
                       DESC

  s.homepage         = 'https://github.com/K6F/KFObjCKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'K6F' => 'fan.khiyuan@gmail.com' }
  s.source           = { :git => 'https://github.com/K6F/KFObjCKit.git', :tag => s.version.to_s }
  s.requires_arc          = true
  s.ios.deployment_target = '9.0'
  
  s.default_subspec = 'All'
  s.subspec 'All' do |ss|
    ss.ios.dependency 'KFObjCKit/Core'
    ss.ios.dependency 'KFObjCKit/Security'
  end

  s.subspec 'Core' do |ss|
    ss.platform = :ios
    ss.source_files = 'BBDDvK_ObjC/Macros/*.{h,m}'
  end
  
  s.subspec 'Security' do |ss|
    ss.platform = :ios
    ss.source_files = 'BBDDvK_ObjC/Security/*.{h,m}'
    ss.ios.dependency 'BBDDvK_ObjC/Core'
    ss.ios.frameworks = 'Security','SystemConfiguration'
    s.dependency 'fishhook'
  end
  
end
