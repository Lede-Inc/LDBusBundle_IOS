# Uncomment this line to define a global platform for your project
#
#执行命令可以监控执行过程
#pod install --verbose --no-repo-update

#设置一个静态库的最低支持的系统版本，ios默认是4.3
platform :ios, '5.0'
#设置隐藏pod library的所有警告
inhibit_all_warnings!

#设置包含所有引用工程的workspace
#默认取podfile所在目录的工程名
workspace 'WLDBusBundle'

#设置包含target的xcode project，用于被pod library链接
#默认取当前podfile所在目录的project
xcodeproj 'LDBusBundle'


target :LDBusBundle do
    #三方库
    pod 'objective-zip', '~> 0.8.3'
    pod 'ZipArchive', '~> 1.3.0'

    #设置pod target需要link的工程target
    #默认链接当前工程中的第一个target
    link_with 'LDBusBundle'
end
