#
# Be sure to run `pod lib lint KonashiUI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'konashi-ios-ui'
    s.module_name      = 'KonashiUI'
    s.version          = '1.0.0'
    s.summary          = 'A support library for konashi-ios-sdk2'
    s.swift_versions   = '5.7'
    s.description      = <<-DESC
      A support library that provides interfaces to connect konashi.
    DESC
  
    s.homepage         = 'https://github.com/YUKAI/konashi-ios-ui'
    s.license          = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
    s.author           = { 'YUKAI Engineering.Inc' => 'contact@ux-xu.com' }
    s.source           = { :git => 'https://github.com/YUKAI/konashi-ios-ui.git', :tag => s.version.to_s }

    s.ios.deployment_target = '13.0'
    s.static_framework = true
    s.source_files = 'Sources/**/**.swift'

    s.frameworks = 'UIKit'
    s.dependency 'konashi-ios-sdk2', '>= 1.0.0'
    s.dependency 'PromisesSwift', '>= 2.1.0'
    s.dependency 'JGProgressHUD', '>= 2.0.0'
  end
