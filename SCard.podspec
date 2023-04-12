Pod::Spec.new do |s|
  s.name             = 'SCard'
  s.version          = '0.1.0'
  s.summary          = 'Description of Sora Card.'

  s.description      = <<-DESC
  A description of Sora Card neet to add here
                       DESC

  s.homepage         = 'https://github.com/Soramitsu/SCard'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Soramitsu' => 'soracard@soramitsu.co.jp' }
  s.source           = { :git => 'https://github.com/sora-xor/sora-card-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'

  s.source_files = 'SCard/Classes/**/*'

  s.resources = "SCard/Assets/*.xcassets"
  s.frameworks = 'UIKit'
  s.dependency 'R.swift', '~> 6.1.0'
  s.dependency 'SnapKit'
  s.dependency 'SoraUIKit', '~> 1.0.0'
  s.dependency 'PayWingsOAuthSDK', '1.2.1'
  s.dependency 'PayWingsOnboardingKYC', '5.1.4'
  # TODO: release IdensicMobileSDK to public pods
  s.dependency 'IdensicMobileSDK' #, :http => 'https://github.com/paywings/PayWingsOnboardingKycSDK-iOS-IdensicMobile/archive/v2.0.0.tar.gz'

end
