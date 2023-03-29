#
# Be sure to run `pod lib lint KonashiUI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'KonashiUI'
    s.version          = '0.0.1'
    s.summary          = 'A support library for konashi-ios-sdk2'
    s.swift_versions   = '5.4'
  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  
    s.description      = <<-DESC
    A support library that provides interfaces to connect konashi.
                         DESC
  
    s.homepage         = 'https://github.com/YUKAI/konashi-ios-ui'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
    s.author           = { 'YUKAI Engineering.Inc' => 'contact@ux-xu.com' }
    s.source           = { :git => 'https://github.com/YUKAI/konashi-ios-ui.git', :tag => s.version.to_s }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  
    s.ios.deployment_target = '13.0'
  
    s.source_files = 'Sources/**/**.swift'
    
    # s.resource_bundles = {
    #   'KonashiUI' => ['KonashiUI/Assets/*.png']
    # }
  
    # s.public_header_files = 'Pod/Classes/**/*.h'
    s.frameworks = 'UIKit'
    s.dependency 'Konashi', '>= 0.0.1'
    s.dependency 'PromisesSwift', '>= 2.0.0'
    s.dependency 'JGProgressHUD', '>= 2.0.0'
  end
