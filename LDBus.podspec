#
# Be sure to run `pod lib lint LDCPGameIssues.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = "LDBus"
    s.version          = "0.0.1"
    s.summary          = "基于Bundle架构的总线组件"
    s.description      = "基于Bundle架构的总线组件, 包括URL导航的UI总线，服务总线，消息总线"
    s.license          = {:type => 'MIT', :file => 'LICENSE'}
    s.homepage         = 'https://git.ms.netease.com/commonlibraryios/LDBusBundle_IOS'
    s.author           = { "huipang" => "huipang@corp.netease.com" }
    s.source           = { :git => "https://git.ms.netease.com/commonlibraryios/LDBusBundle_IOS.git", :tag => "0.0.1" }

    s.platform              = :ios, '5.0'
    s.ios.deployment_target = '5.0'
    s.ios.public_header_files = 'LDBus/LDMBusContext.h', 'LDBus/LDMContainer.h', 'LDBus/LDUIBus/LDMUIBusConnector.h', 'LDBus/LDUIBus/NavigatorCore/LDMNavigator.h', 'LDBus/LDUIBus/NavigatorCore/TTBaseNavigator.h', 'LDBus/LDUIBus/NavigatorCore/URL\ Action/TTURLAction.h','LDBus/LDUIBus/NavigatorUI/TTWebController.h', 'LDBus/LDMessageBus/LDMMessageReceiver.h'
    s.subspec 'arc' do |sa|
        sa.ios.source_files = 'LDBus/*.{h,m}', 'LDBus/LDBusConfig', 'LDBus/LDServiceBus', 'LDBus/LDMessageBus', 'LDBus/LDUIBus/*.{h,m}'
        sa.requires_arc = true
        sa.dependency 'LDBus/non-arc'
    end

    s.subspec 'non-arc' do |sn|
        sn.source_files = 'LDBus/LDUIBus/NavigatorCore/**/*.{h,m}', 'LDBus/LDUIBus/NavigatorUI/**/*.{h,m}'
        sn.requires_arc = false
        sn.dependency 'LDBus/arc'
    end
end
