#
# Be sure to run `pod lib lint DoodleKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DoodleKit'
  s.version          = '1.0.1'
  s.summary          = 'A drop in view controller for doodling.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A view controller for handling drawing and a text label overlay.
                       DESC

  s.homepage         = 'https://github.com/popwarsweet/DoodleKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'popwarsweet' => 'popwarsweet@gmail.com' }
  s.source           = { :git => 'https://github.com/popwarsweet/DoodleKit.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/KyleZaragoza'

  s.ios.deployment_target = '12.0'

  s.source_files = 'DoodleKit/Classes/**/*'
  
  # s.resource_bundles = {
  #   'DoodleKit' => ['DoodleKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
