Pod::Spec.new do |s|
  s.name             = 'SwiftPromises'
  s.version          = '0.1.0'
  s.summary          = 'Light-weight Promise package for Swift'
  s.homepage         = 'https://github.com/Ryucoin/SwiftPromises'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'WyattMufson' => 'wyatt@ryu.games' }
  s.source           = { :git => 'https://github.com/Ryucoin/SwiftPromises.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/_ryugames'

  s.ios.deployment_target = '12.0'
  s.swift_version = '5'
  s.source_files = 'SwiftPromises/Classes/**/*'
end
