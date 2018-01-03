Pod::Spec.new do |spec|
  spec.name         = 'Kvitto'
  spec.version      = '1.0.3'
  spec.summary      = "Parse and validate iTunes App Store receipts"
  spec.homepage     = "https://github.com/Cocoanetics/Kvitto"
  spec.author       = { "Oliver Drobnik" => "oliver@cocoanetics.com" }
  spec.documentation_url = 'http://docs.cocoanetics.com/DTKeychain'
  spec.social_media_url = 'https://twitter.com/cocoanetics'
  spec.source       = { :git => "https://github.com/Cocoanetics/Kvitto.git", :tag => spec.version.to_s }
  spec.ios.deployment_target = '8.0'
  spec.license      = 'BSD'
  spec.requires_arc = true
  spec.dependency 'DTFoundation/DTASN1', '~> 1.7.13'

  spec.subspec 'Core' do |ss|
    ss.ios.deployment_target = '8.0'
    ss.source_files = 'Core/Source/*.{h,m,c,swift}'
  end
end
