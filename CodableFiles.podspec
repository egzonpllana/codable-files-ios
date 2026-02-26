Pod::Spec.new do |s|
  s.name             = 'CodableFiles'
  s.version          = '2.0.0'
  s.summary          = 'Save and load Codable objects from DocumentDirectory on iOS Devices.'
  s.homepage         = 'https://github.com/egzonpllana/CodableFiles'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author           = { 'Egzon Pllana' => 'docpllana@gmail.com' }
  s.source           = { :git => 'https://github.com/egzonpllana/CodableFiles.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.5'
  s.source_files = 'Sources/CodableFiles/**/*'
  # Exclude simulator builds.
  #s.pod_target_xcconfig = {
    #'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  #}
  #s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end
