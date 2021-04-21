Pod::Spec.new do |spec|
  spec.name         = 'Kvitto'
  spec.version      = '1.0.6'
  spec.summary      = "Parse and validate iTunes App Store receipts"
  spec.homepage     = "https://github.com/Cocoanetics/Kvitto"
  spec.author       = { "Oliver Drobnik" => "oliver@cocoanetics.com" }
  spec.documentation_url = 'https://docs.cocoanetics.com/Kvitto'
  spec.social_media_url = 'https://twitter.com/cocoanetics'
  spec.source       = { :git => "https://github.com/Cocoanetics/Kvitto.git", :tag => spec.version.to_s }
  spec.ios.deployment_target = '9.0'
  spec.osx.deployment_target = '10.11'
  spec.license      = 'BSD'
  spec.requires_arc = true
  spec.dependency 'DTFoundation/DTASN1', '~> 1.7.17'
  spec.swift_version = '5.0'

  spec.subspec 'Core' do |ss|
    ss.ios.deployment_target = '9.0'
    ss.osx.deployment_target = '10.11'
    ss.source_files = 'Core/Source/*.{h,m,c,swift}'
  end
end
