Pod::Spec.new do |s|
  s.name             = 'identity_core_dart'
  s.version          = '0.1.0'
  s.summary          = 'QuarkID holder SDK — Hardware KMS via Secure Enclave'
  s.homepage         = 'https://phinx.io'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Phinx' => 'dev@phinx.io' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency       'Flutter'
  s.platform         = :ios, '13.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version    = '5.9'
end
