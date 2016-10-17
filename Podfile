
use_frameworks!

def utils
	pod 'BuildaUtils', '~> 0.4'
end

def tests
	pod 'DVR', :git => 'https://github.com/Sajjon/DVR.git'
	pod 'Nimble', '~> 5.0'
end

target 'XcodeServerSDK' do
	utils
end

target 'XcodeServerSDKTests' do
	utils
	tests
end
