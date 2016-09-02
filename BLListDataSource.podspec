#
# Be sure to run `pod lib lint BLListDataSource.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "BLListDataSource"
  s.version          = "0.9.10"
  s.summary          = "BLListDataSource is a simple and powerfull method of fetching and maintainig list data from internet."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
  Simple and powerfull method of fetching and maintainig list data from internet. It can be used with BLListViewController and BLParseFetch (or another BLFetch object).
                       DESC

  s.homepage         = "https://github.com/batkov/BLListDataSource"
  s.license          = 'MIT'
  s.author           = { "Hariton Batkov" => "batkov@i.ua" }
  s.source           = { :git => "https://github.com/batkov/BLListDataSource.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/batkov111'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
end
