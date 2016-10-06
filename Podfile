
use_frameworks!

def utils
	pod 'BuildaUtils', :git => 'https://github.com/Sajjon/BuildaUtils.git'
end

def tests
	pod 'DVR', :git => 'https://github.com/czechboy0/DVR.git', :tag => 'v0.0.5-czechboy0'
	pod 'Nimble', '~> 5.0'
end

target 'XcodeServerSDK' do
	utils
end

target 'XcodeServerSDKTests' do
	utils
	tests
end
