#
# Be sure to run `pod lib lint DBrowser.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DBrowser'
  s.version          = '0.0.3'
  s.summary          = 'Database browser for debugging iOS application.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  A small project reading sqlite file and displaying it in an easy way to debug while developing features relating to database.
                       DESC

  s.homepage         = 'https://github.com/hieupham9809/DBrowser'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'harley.pham' => 'hieupham9809@gmail.com' }
  s.source           = { :git => 'https://github.com/hieupham9809/DBrowser.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '14.0'
  s.swift_versions = '5.0'

  s.source_files = 'DBrowser/**/*.swift'
  
  # s.resource_bundles = {
  #   'DBrowser' => ['DBrowser/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
