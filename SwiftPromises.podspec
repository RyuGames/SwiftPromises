Pod::Spec.new do |s|
  s.name             = 'SwiftPromises'
  s.version          = '1.0.0'
  s.summary          = 'Light-weight Promise package for Swift'
  s.homepage         = 'https://github.com/Ryucoin/SwiftPromises'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'WyattMufson' => 'wyatt@ryu.games' }
  s.source           = { :git => 'https://github.com/Ryucoin/SwiftPromises.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.swift_version = '5.1'
  s.source_files = 'SwiftPromises/Classes/**/*'
end
