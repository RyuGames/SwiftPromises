Pod::Spec.new do |s|
  s.name             = 'SwiftPromises'
  s.version          = '2.0.0'
  s.summary          = 'Light-weight Promise package for Swift'
  s.homepage         = 'https://github.com/RyuGames/SwiftPromises'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'WyattMufson' => 'wyatt@ryu.games' }
  s.source           = { :git => 'https://github.com/RyuGames/SwiftPromises.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.swift_version = '5.3'
  s.source_files = 'SwiftPromises/Classes/**/*'

  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end
