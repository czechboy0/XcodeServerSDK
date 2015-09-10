Pod::Spec.new do |s|

  s.name         = "XcodeServerSDK"
  s.version      = "0.2.1"
  s.summary      = "Access Xcode Server API with native Swift objects."

  s.homepage     = "https://github.com/czechboy0/XcodeServerSDK"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Honza Dvorsky" => "honzadvorsky.com" }
  s.social_media_url   = "http://twitter.com/czechboy0"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "2.0"
  
  s.source       = { :git => "https://github.com/czechboy0/XcodeServerSDK.git", :tag => "v#{s.version}" }

  subspec "Core" do |sp|
    sp.source_files  = "XcodeServerSDK/**/*.{swift}"
    sp.dependency "BuildaUtils", "0.0.11"
  end

  subspec "ReactiveCocoa" do |sp|
    sp.dependency "XcodeServerSDK/Core"
    # sp.dependency "ReactiveCocoa", "~> SWIFT 2 WHENEVER ITS READY"
    sp.source_files = "XcodeServerSDK-ReactiveCocoa/**/*.{swift}"
  end

end
