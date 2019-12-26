#
# Be sure to run `pod lib lint NYPublicTest.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NYPublicTest'
  s.version          = '0.1.0'
  s.summary          = 'NYPublicTest'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/zhubug/NYPublicTest'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zhunanyang' => 'zhunanyang@aliyun.com' }
  s.source           = { :git => 'https://github.com/zhubug/NYPublicTest.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  if ENV['IS_SOURCE']
  s.source_files = 'NYPublicTest/Classes/**/*{,h,.m}'

  else
    s.source_files = 'NYPublicTest/Classes/**/*.h'
    
    s.vendored_framework = 'NYPublicTest-0.1.0/ios/NYPublicTest.framework'
    s.vendored_framework = 'NYPublicTest/ATAuthSDK.framework'

  end
  s.resource_bundles = {
     'NYPublicTest' => ['NYPublicTest/Assets/*']
   }

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.dependency 'WechatOpenSDK', '1.8.4'
  s.dependency 'MJExtension'
  s.dependency 'UMCShare/Social/ReducedWeChat'
  s.dependency 'UMCSecurityPlugins'
  s.dependency 'UMCAnalytics'
  s.dependency 'UMCCommon'
  s.dependency 'AFNetworking'
  
end
